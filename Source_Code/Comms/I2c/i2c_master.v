//   ==================================================================
//   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
//   ------------------------------------------------------------------
//   Copyright (c) 2014 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED 
//   ------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement. 
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
//   --------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02 
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
//   --------------------------------------------------------------------
`timescale 1 ns / 1 ps

module i2c_master #(
	parameter [6:0] SLAVE_ADDR = 7'h1A,	// IMX258
	parameter [7:0]	HIGH_CYCLE = 8'd35,	// 400 kHz operation by ~27 MHz clock
	parameter [7:0]	LOW_CYCLE  = 8'd35	// 400 kHz operation by ~27 MHz clock
) (
`ifdef DEBUG
	output [2:0]	debug_state,
`endif
	input			rst_n_i,
	input			sys_clk_i,	// assuming ~27 MHz for 37ns glitch filtering
	input			scl_in,
	output			scl_oe_o,
	input			sda_in,
	output			sda_oe_o,
	input			start_req_i,
	input			stop_req_i,
	input			m2s_ack_rdy,
	input			m2s_ack,
	input			m2s_data_rdy_i,
	input [7:0]		m2s_data_i,
	output			scl_stretch_o,
	output			ack_ok_o,
	output			ack_ng_o,
	output			s2m_ack_only_en,
	output			s2m_ack_en,
	output			s2m_ack,
	output			s2m_data_en,
	output [7:0]	s2m_data
);

/**********************************************************************************
* Internal Signals
**********************************************************************************/
reg			r_scl_in, r_scl_in_1d, r_scl_in_2d, r_scl_filtered, r_scl_filtered_d;
reg			r_sda_in, r_sda_in_1d, r_sda_in_2d, r_sda_filtered;
reg [7:0] 	r_high_cnt;
reg [7:0] 	r_low_cnt;
reg			r_read_trans;
reg [9:0]	r_state;
reg			r_sr_en;
reg [3:0]	r_cnt;
reg			r_s2m_data_en;
reg [7:0]	r_m2s_data;
reg [7:0]	r_s2m_data;
reg		    r_s2m_ack_only_en;
reg		    r_s2m_ack_en;
reg		    r_s2m_ack;
reg		    r_stretch_en;
reg		    r_scl_oe, r_sda_oe;
wire		w_high_end = (r_high_cnt == HIGH_CYCLE);
wire		w_low_end = (r_low_cnt == LOW_CYCLE);

reg			r_s2m_ack_ok;
reg			r_s2m_ack_ng  ;
wire 		w_scl_rising = r_scl_filtered & (~r_scl_filtered_d);
wire 		w_scl_falling = ~r_scl_filtered & r_scl_filtered_d;

///// SCL control /////
wire	w_scl_off = (r_state == IDLE); 

`ifdef DEBUG
	assign debug_state = {w_high_end, w_low_end, r_state[2]};
`endif

assign scl_oe_o = r_scl_oe;
assign sda_oe_o = r_sda_oe;
assign ack_ok_o = r_s2m_ack_ok;
assign ack_ng_o = r_s2m_ack_ng;

assign s2m_ack_only_en = r_s2m_ack_only_en;
assign s2m_ack_en = r_s2m_ack_en;
assign s2m_ack = r_s2m_ack;
assign s2m_data_en = r_s2m_data_en;
assign s2m_data = r_s2m_data;

// Main Slave FSM States
parameter	IDLE		  = 10'b0000000000;
parameter	START		  = 10'b0000000001;
parameter	STOP		  = 10'b0000000010;
parameter	SEND_I2C_ADDR = 10'b0000000100;
parameter	SCL_STRETCH   = 10'b0000001000;
parameter	S2M_ACK_CHK	  = 10'b0000010000;
parameter	S2M_ACK_OK	  = 10'b0000100000;
parameter	ACK_ERR		  = 10'b0001000000;
parameter	M2S_DATA	  = 10'b0010000000;
parameter	S2M_DATA	  = 10'b0100000000;
parameter	M2S_ACK		  = 10'b1000000000;

assign scl_stretch_o = (r_state == SCL_STRETCH); 

/// Glitch Filtering ///
always @(posedge sys_clk_i or negedge rst_n_i) begin
	if (~rst_n_i) begin
		r_scl_in <= 1;
		r_scl_in_1d <= 1;
		r_scl_in_2d <= 1;
		r_scl_filtered <= 1;
		r_scl_filtered_d <= 1;
		r_sda_in <= 1;
		r_sda_in_1d <= 1;
		r_sda_in_2d <= 1;
		r_sda_filtered <= 1;
	end
	else begin
		r_scl_in <= scl_in;
		r_scl_in_1d <= r_scl_in;
		r_scl_in_2d <= r_scl_in_1d;
		r_sda_in <= sda_in;
		r_sda_in_1d <= r_sda_in;
		r_sda_in_2d <= r_sda_in_1d;
		if ((r_scl_filtered ~^ r_scl_in_1d) & (r_scl_filtered ^ r_scl_in_2d))
			r_scl_filtered <= r_scl_filtered;
		else
			r_scl_filtered <= r_scl_in_2d;
			r_scl_filtered_d <= r_scl_filtered;
		if ((r_sda_filtered ~^ r_sda_in_1d) & (r_sda_filtered ^ r_sda_in_2d))
			r_sda_filtered <= r_sda_filtered;
		else
			r_sda_filtered <= r_sda_in_2d;
	end
end

always @(posedge sys_clk_i or negedge rst_n_i) begin
	if (~rst_n_i) begin
		r_high_cnt <= 0;
	end
	else if (~r_scl_filtered | w_scl_off) begin
		r_high_cnt <= 0;
	end
	else if (r_scl_filtered & (~w_high_end)) begin
		r_high_cnt <= r_high_cnt + 1;
	end
//	else begin
//		r_high_cnt <= r_high_cnt;
//	end
end

always @(posedge sys_clk_i or negedge rst_n_i) begin
	if (~rst_n_i) begin
		r_low_cnt <= 0;
	end
	else if (r_scl_filtered | w_scl_off | r_stretch_en) begin
		r_low_cnt <= 0;
	end
	else if (~r_scl_filtered & (~w_low_end)) begin
		r_low_cnt <= r_low_cnt + 1;
	end
//	else begin
//		r_low_cnt <= r_low_cnt;
//	end
end

always @(posedge sys_clk_i or negedge rst_n_i) begin
	if (~rst_n_i) begin
		r_scl_oe <= 0;
	end
	else if ((r_state == START) | (r_state == STOP) | (r_state == IDLE)) begin
		r_scl_oe <= 0;
	end
	else if (w_high_end | r_stretch_en) begin
		r_scl_oe <= 1;
	end
	else if (w_low_end) begin
		r_scl_oe <= 0;
	end
//	else begin
//		r_scl_oe <= r_scl_oe;
//	end
end
////////////////////////////////////////////////////////////////

always @(posedge sys_clk_i or negedge rst_n_i) begin
	if (~rst_n_i) begin
		r_m2s_data <= 0;
	end
	else if (start_req_i) begin
		r_m2s_data <= {SLAVE_ADDR, 1'b0};	// write only
	end
	else if (m2s_data_rdy_i) begin
		r_m2s_data <= m2s_data_i;
	end
	else if (((r_state == SEND_I2C_ADDR) | (r_state == M2S_DATA)) 
			& w_scl_falling & (r_cnt != 8)) begin
		r_m2s_data <= {r_m2s_data[6:0], 1'b1};
	end
//	else begin
//		r_m2s_data <= r_m2s_data;
//	end
end

always @(posedge sys_clk_i or negedge rst_n_i) begin
	if (~rst_n_i) begin
		r_read_trans <= 0;
	end
	else if (start_req_i) begin
//		r_read_trans <= m2s_data_i[0];
		r_read_trans <= 0;	// write only in this application
	end
end


always @(posedge sys_clk_i or negedge rst_n_i) begin
	if (~rst_n_i) begin
		r_sr_en <= 0;
		r_cnt <= 0;
		r_sda_oe <= 0;
		r_stretch_en <= 0;
//		r_m2s_data <= 0;
		r_state <= IDLE;
	end
	else begin
		case (r_state)
			IDLE : begin
				r_sr_en <= 0;
				r_cnt<= #1 0;
				r_sda_oe <= 0;
				r_stretch_en <= 0;
				if (start_req_i) begin
					r_state <= #1 START;
				end
//				else begin
//					r_state <= #1 IDLE;
//				end
			end
			START : begin
				r_cnt<= #1 0;
				r_stretch_en <= 0;
				if ((r_sr_en & (r_high_cnt == HIGH_CYCLE/2)) | (~r_sr_en)) begin
					r_sda_oe <= 1;		// SDA = 0 for Start
//					r_sr_en <= r_sr_en;
				end
				if (w_high_end) begin
					r_state <= #1 SEND_I2C_ADDR;
					r_sr_en <= 0;
				end
				else begin
//					r_sda_oe <= 0;
//					r_state <= #1 START;
				end
			end
			STOP : begin
				r_sr_en <= 0;
				r_cnt<= #1 0;
				r_stretch_en <= 0;
				if (w_high_end) begin
					r_sda_oe <= 0;		// SDA = 1 for Stop
					r_state <= #1 IDLE;
				end
				else begin
					r_sda_oe <= 1;
//					r_state <= STOP;
				end
			end
			SEND_I2C_ADDR : begin
				r_sr_en <= 0;
				if (w_scl_falling) begin
					if (r_cnt != 8) begin
						r_cnt<= #1 r_cnt + 1;
						r_sda_oe <= ~r_m2s_data[7];
						r_state <= #1 SEND_I2C_ADDR;
					end
					else begin
//						r_cnt<= r_cnt;
						r_sda_oe <= 0;
						r_stretch_en <= 0;
						r_state <= #1 S2M_ACK_CHK;
					end
				end
//				else begin
//					r_cnt<= r_cnt;
//					r_sda_oe <= 0;
//					r_state <= #1 SEND_I2C_ADDR;
//				end
			end

			SCL_STRETCH : begin
				r_sr_en <= 0;
				r_cnt <= #1 0;
				if (stop_req_i) begin
					r_stretch_en <= 0;
					r_sda_oe <= 1;
					r_sr_en <= 0;
					r_state <= STOP;
				end
				if (start_req_i) begin	// Repeated Start
					r_stretch_en <= 0;
					r_sr_en <= 1;
					r_sda_oe <= 0;
					r_state <= START;
				end
				else if (~r_read_trans & m2s_data_rdy_i) begin
					r_stretch_en <= 0;
					r_sda_oe <= ~m2s_data_i[7];
					r_sr_en <= 0;
					r_state <= M2S_DATA;
				end
				else if (r_read_trans & m2s_ack_rdy) begin
					r_stretch_en <= 0;
					r_sda_oe <= ~m2s_ack;
					r_sr_en <= 0;
					r_state <= M2S_ACK;
				end
				else begin
					r_stretch_en <= 1;
					r_sr_en <= 0;
//					r_sda_oe <= r_sda_oe;
//					r_state <= SCL_STRETCH;
				end
			end
			S2M_ACK_CHK : begin
				r_sr_en <= 0;
				r_cnt <=  0;
				r_stretch_en <= 0;
				r_sda_oe <= 0;
				if (w_scl_rising) begin	// ACK latched by Master
					if (~r_sda_filtered) begin	// ACK OK
						r_state <= S2M_ACK_OK;
					end
					else begin	// NACK --- Error!!!
						r_state <= ACK_ERR;
					end
//					else begin
				end	
				else if (~r_read_trans & w_scl_falling) begin
						r_state <= SCL_STRETCH;
//					end
				end
//				else begin
//					r_state <= S2M_ACK;
//				end
			end
			S2M_ACK_OK : begin
				r_sr_en <= 0;
				r_cnt <=  0;
				r_stretch_en <= 0;
				r_sda_oe <= 0;
				if (r_read_trans & w_scl_rising) begin
					r_sda_oe <= 0;
					r_state <= S2M_DATA;
				end
				else if (~r_read_trans & w_scl_falling) begin
						r_sda_oe <= 1;
//						r_state <= M2S_DATA;
						r_state <= SCL_STRETCH;
//					end
				end
//				else begin
//					r_state <= S2M_ACK;
//				end
			end
			M2S_DATA : begin
				r_sr_en <= 0;
				if (~w_scl_falling & (r_cnt == 0)) begin
					r_sda_oe <= ~r_m2s_data[7];
				end
				else if (w_scl_falling) begin
					if (r_cnt != 7) begin
						r_cnt<= #1 r_cnt + 1;
						r_stretch_en <= 0;
						r_sda_oe <= ~r_m2s_data[6];
						r_state <= #1 M2S_DATA;
					end
					else begin
//						r_cnt<= r_cnt;
						r_sda_oe <= 0;
						r_state <= #1 S2M_ACK_CHK;
					end
				end
//				else begin
//					r_cnt<= r_cnt;
//					r_sda_oe <= 0;
//					r_state <= #1 M2S_DATA;
//				end
			end

			S2M_DATA : begin
				r_sr_en <= 0;
				r_sda_oe <= 0;
				if (w_scl_rising & (r_cnt != 8)) begin
					r_cnt <= #1 r_cnt + 1;
					r_stretch_en <= 0;
					r_state <= #1 S2M_DATA;
				end
				else if (w_scl_falling & (r_cnt == 8)) begin
					r_cnt <= #1 0;
					r_stretch_en <= 1;
					r_state <= #1 SCL_STRETCH;
				end
//				else begin
//					r_cnt <= #1 r_cnt;
//					r_state <= #1 S2M_DATA;
//				end
			end

			M2S_ACK : begin
				r_sr_en <= 0;
				r_cnt <= #1 0;
				r_stretch_en <= 0;
//				r_sda_oe <= r_sda_oe;
				if (w_scl_rising & (~r_sda_oe)) begin	// NACK --- read end
					r_state <= STOP;
				end
				else if (w_scl_falling & r_sda_oe) begin	// ACK --- read one more data
					r_state <= S2M_DATA;
				end
//				else begin
//					r_state <= M2S_ACK;
//				end
			end

			default : begin
				r_sr_en <= 0;
				r_cnt <= 0;
				r_stretch_en <= 0;
				r_sda_oe <= 0;
				r_state <= IDLE;
			end
		endcase
	end 
end 
                
always @(posedge sys_clk_i or negedge rst_n_i) begin
	if (~rst_n_i) begin
		r_s2m_ack_ok <= 0;
		r_s2m_ack_ng <= 0;
	end
	else if ((r_state == S2M_ACK_CHK) & w_scl_rising) begin
		r_s2m_ack_ok <= ~r_sda_filtered;
		r_s2m_ack_ng <= r_sda_filtered;
	end
	else begin
		r_s2m_ack_ok <= 0;
		r_s2m_ack_ng <= 0;
	end
end

always @(posedge sys_clk_i or negedge rst_n_i) begin
	if (~rst_n_i) begin
		r_s2m_ack <= 0;
		r_s2m_ack_only_en <= 0;
		r_s2m_ack_en <= 0;
	end
	else if ((r_state == S2M_ACK_CHK) & w_scl_rising) begin
		r_s2m_ack <= r_sda_filtered;
		r_s2m_ack_only_en <= ~r_read_trans;
		r_s2m_ack_en <= r_read_trans;
	end
	else begin
//		r_s2m_ack <= r_s2m_ack;
		r_s2m_ack_only_en <= 0;
		r_s2m_ack_en <= 0;
	end
end

always @(posedge sys_clk_i or negedge rst_n_i) begin
	if (~rst_n_i) begin
		r_s2m_data <= 0;
		r_s2m_data_en <= 0;
	end
	else if ((r_state == S2M_DATA) & w_scl_rising) begin
		r_s2m_data <= {r_s2m_data[6:0], r_sda_filtered};
		r_s2m_data_en <= (r_cnt == 7);
	end
	else begin
//		r_s2m_data <= r_s2m_data;
		r_s2m_data_en <= 0;
	end
end


endmodule
