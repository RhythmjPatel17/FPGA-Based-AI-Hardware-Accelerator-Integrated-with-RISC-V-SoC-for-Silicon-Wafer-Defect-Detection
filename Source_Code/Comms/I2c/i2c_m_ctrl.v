
`timescale 1 ns / 1 ps

///// Only supports I2C write transaction /////

module i2c_m_ctrl  (
	input			rst_n_i,
	input			sys_clk_i,		// assuming 27 MHz for 37ns glitch filtering
	input			scl_stretch_i,	// SCL stertch state indicator
	input			ack_ok_i,		// ACK indicator
	input			ack_ng_i,		// NACK indicator
	input			sensor_go_i,	// ready to Start Sensor
	output			start_req_o,	// I2C Start request
	output			data_rdy_o,		// Write Data send request
	output			stop_req_o,		// I2C Stop request
	output [7:0]	wdata_o,		// I2C Write Data
	output			rdy_to_go_o,	// sensor config done except for Start
	output			done_o,			// I2C transaction done flag
	output			ack_err_o		// I2C ACK Error (NACK) flag
);

reg [7:0]	r_state;
reg [3:0]	r_byte_cnt;
reg [9:0]	r_trans_cnt;
reg		    r_start_req;
reg		    r_stop_req;
reg		    r_data_rdy;
//reg [7:0]	r_wdata;
reg [7:0]	r_stop_cnt;
reg [7:0]	r_gap_cnt;
reg		    r_rdy_to_go;
reg		    r_done;
reg		    r_ack_err;

assign start_req_o = r_start_req;
assign stop_req_o  = r_stop_req;
assign data_rdy_o  = r_data_rdy;
assign rdy_to_go_o = r_rdy_to_go;
assign done_o      = r_done;
assign ack_err_o   = r_ack_err;

localparam IDLE     = 8'b00000000;
localparam START    = 8'b00000001;
localparam WAIT_ACK = 8'b00000010;
localparam SEND_RDY = 8'b00000100;
localparam PRE_STOP = 8'b00001000;
localparam STOP     = 8'b00010000;
localparam WAIT_NXT = 8'b00100000;
localparam DONE     = 8'b01000000;
localparam ERROR    = 8'b10000000;


always @(posedge sys_clk_i or negedge rst_n_i) begin
	if (~rst_n_i) begin
		r_start_req <= 0;
		r_data_rdy <= 0;
		r_stop_req <= 0;
		r_byte_cnt <= 0;
		r_trans_cnt <= 0;
		r_stop_cnt <= 0;
		r_gap_cnt <= 0;
		r_rdy_to_go <= 0;
		r_done <= 0;
		r_ack_err <= 0;
		r_state <= IDLE;
	end
	else begin
		case (r_state)
			IDLE : begin
				r_start_req <= 1;
				r_data_rdy <= 0;
				r_stop_req <= 0;
				r_byte_cnt <= 0;
				r_trans_cnt <= 0;
				r_stop_cnt <= 0;
				r_gap_cnt <= 0;
				r_rdy_to_go <= 0;
				r_done <= 0;
				r_ack_err <= 0;
				r_state <= START;
			end
			START : begin
				r_start_req <= 0;
				r_data_rdy <= 0;
				r_stop_req <= 0;
				r_byte_cnt <= 0;
				r_stop_cnt <= 0;
				r_gap_cnt <= 0;
				r_state <= WAIT_ACK;
			end
			WAIT_ACK : begin
				r_start_req <= 0;
				r_data_rdy <= 0;
				r_stop_req <= 0;
				if (ack_ok_i) begin
					if (r_byte_cnt != BYTE_COUNT) begin
						r_byte_cnt <= r_byte_cnt + 1;
						r_state <= SEND_RDY;
					end
					else begin
						r_byte_cnt <= 0;
						r_trans_cnt <= r_trans_cnt + 1;
						r_state <= PRE_STOP;
					end
				end
				else if (ack_ng_i) begin
					r_ack_err <= 1;
					r_state <= ERROR;
				end
				else begin
					r_state <= WAIT_ACK;
				end
			end
			SEND_RDY : begin
				if (scl_stretch_i) begin
					r_data_rdy <= 1;
					r_state <= WAIT_ACK;
				end
				else begin
					r_data_rdy <= 0;
					r_state <= SEND_RDY;
				end
			end
			PRE_STOP : begin
				if (scl_stretch_i) begin
					r_state <= STOP;
				end
				else begin
					r_state <= PRE_STOP;
				end
			end
			STOP : begin
				if (r_stop_cnt == STOP_COUNT) begin
					r_stop_req <= 1;
					r_stop_cnt <= 0;
					r_state <= WAIT_NXT;
				end
				else begin
					r_stop_req <= 0;
					r_stop_cnt <= r_stop_cnt + 1;
					r_state <= STOP;
				end
			end
			WAIT_NXT : begin
				r_stop_req <= 0;
				if (r_trans_cnt == NUM_OF_TRANS) begin
					r_done <= 1;
					r_state <= DONE;
				end
				else if (r_gap_cnt != GAP_COUNT) begin
					r_gap_cnt <= r_gap_cnt + 1;
					r_state <= WAIT_NXT;
				end
				else begin
					if (r_trans_cnt != (NUM_OF_TRANS-1)) begin
						r_rdy_to_go <= 0;
						r_start_req <= 1;
						r_state <= START;
					end
					else begin	// wait for all sensor configurations before start
						if (sensor_go_i) begin
							r_rdy_to_go <= 0;
							r_start_req <= 1;
							r_state <= START;
						end
						else begin
							r_rdy_to_go <= 1;
							r_start_req <= 0;
							r_state <= WAIT_NXT;
						end
					end
				end
			end
			DONE : begin
				r_state <= DONE;
			end
			ERROR : begin
				r_state <= ERROR;
			end
			default : begin
				r_start_req <= 0;
				r_data_rdy <= 0;
				r_stop_req <= 0;
				r_byte_cnt <= 0;
				r_trans_cnt <= 0;
				r_stop_cnt <= 0;
				r_gap_cnt <= 0;
				r_rdy_to_go <= 0;
				r_done <= 0;
				r_ack_err <= 0;
				r_state <= IDLE;
			end
		endcase
	end
end

rom_hm_0360_cam_out rom_hm_0360_cam_out_inst
(
	.rst_i			(~rst_n_i),
	.rd_en_i		(rst_n_i),
	.rd_clk_i		(sys_clk_i),
	.rd_clk_en_i	(rst_n_i),
	.rd_addr_i		({r_trans_cnt[8:0], r_byte_cnt[1:0]}),
	.rd_data_o		(wdata_o)
);

endmodule


