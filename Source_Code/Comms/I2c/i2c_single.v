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

///// Only supports I2C write transaction /////

module i2c_single # (
	parameter [6:0]		SLAVE_ADDR   =  7'h1A ,	// I2C Slave Address
	parameter [9:0]		NUM_OF_TRANS = 10'd80 ,	// number of write transactions,
	parameter [7:0]		HIGH_CYCLE   =  8'd35 ,	// 400 kHZ operation
	parameter [7:0]		LOW_CYCLE    =  8'd35 ,	// 400 kHZ operation
	parameter [7:0]		GAP_COUNT    =  8'd200	// GAP time between two transactions in sys_clk_i cycles
) (
	input			rst_n_i,
	input			sys_clk_i,  
	input			scl_i,
	output			scl_o,
	input			sda_i,
	output			sda_o,
	output			done_o,	    // ch0 I2C transaction done
	output			ack_err_o   // ch2 I2C ACK Error (NACK) flag
);

wire		scl_in, sda_in;
wire		scl_oe, sda_oe;
wire		ack_ok, ack_ng, scl_stretch, rdy_to_go;
wire        start_req, stop_req, data_rdy;
wire [7:0]	wdata;

assign scl_o    = scl_oe ? 1'b0 : 1'b1; //1'bz;
assign sda_o    = sda_oe ? 1'b0 : 1'b1; //1'bz;
assign scl_in   = scl_i;
assign sda_in   = sda_i;

i2c_m_ctrl #(
	.BYTE_COUNT		(3),
	.NUM_OF_TRANS	(NUM_OF_TRANS),
	.GAP_COUNT		(GAP_COUNT)
) i2c_m_ctrl2 (
	.rst_n_i		(rst_n_i),
	.sys_clk_i		(sys_clk_i),
	.scl_stretch_i  (scl_stretch),
	.ack_ok_i		(ack_ok),
	.ack_ng_i		(ack_ng),
	.sensor_go_i    (rdy_to_go),
	.start_req_o    (start_req),
	.stop_req_o		(stop_req),
	.data_rdy_o		(data_rdy),
	.wdata_o		(wdata),
	.rdy_to_go_o    (rdy_to_go),
	.done_o			(done_o),
	.ack_err_o		(ack_err_o)
);	

i2c_master #(
	.SLAVE_ADDR		(SLAVE_ADDR),
	.HIGH_CYCLE		(HIGH_CYCLE),
	.LOW_CYCLE		(LOW_CYCLE)
) i2c_m2 (
	.rst_n_i		(rst_n_i),
	.sys_clk_i		(sys_clk_i),
	.scl_in			(scl_in),
	.scl_oe_o		(scl_oe),
	.sda_in			(sda_in),
	.sda_oe_o		(sda_oe),
	.start_req_i	(start_req),
	.stop_req_i		(stop_req),
	.m2s_ack_rdy    (1'b0),
	.m2s_ack		(1'b0),
	.m2s_data_rdy_i (data_rdy),
	.m2s_data_i		(wdata),
	.scl_stretch_o  (scl_stretch),
	.ack_ok_o		(ack_ok),
	.ack_ng_o		(ack_ng),
	.s2m_ack_only_en(),
	.s2m_ack_en		(),
	.s2m_ack		(),
	.s2m_data_en	(),
	.s2m_data		()
);

endmodule
