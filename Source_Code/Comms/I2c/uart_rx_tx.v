`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Ignitarium
// Engineer: shahan.a@ignitarium.com
// 
// Create Date: 31.07.2019 12:19:15
// Design Name: UART Reciever and Transmitter
// Module Name: uart_rx_tx
// Project Name: uhnder_io_char
// Target Devices: VC707
// Tool Versions: vivado 2018.2
// Description: 
//      This is the communication interface between the host PC and 
//      FPGA. FPGA register space is accessed through this interface.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module uart_rx_tx # (parameter CLOCKS_PER_BIT=417)(
    input               sys_clk,
  
    //================Transmitter============
    input               i_tx_dvalid,
    input       [7:0]   i_tx_data,
	output reg          o_tx_status,
    output reg          o_tx_serdata,
	//================reciever============
	input               i_rx_serdata,
    output reg          o_rx_dvalid,
    output reg  [7:0]   o_rx_data
    );	 

    localparam TX_IDLE      = 3'b000;
    localparam TX_START_BIT = 3'b001;
    localparam TX_DATA_BITS = 3'b010;
    localparam TX_STOP_BIT  = 3'b011;



     reg [15:0]           tx_count_clk;
     reg [3:0]           tx_bit_index; //8 bits total
     reg [2:0]           tx_state;
     reg [7:0]           tx_data;




    // Transmitter State machine
    always @ (posedge sys_clk) begin
        case (tx_state)
            TX_IDLE: begin
                tx_bit_index    <= 0;
                o_tx_serdata    <= 1;
                tx_count_clk    <= 0;
				 o_tx_status    <= 0;
                if (i_tx_dvalid == 1) begin
                    o_tx_serdata    <= 0;
					 o_tx_status     <= 1;
                    tx_state        <= TX_START_BIT;
                end else begin
                    tx_state        <= TX_IDLE;
                end
            end 
            TX_START_BIT: begin
                if (tx_count_clk < CLOCKS_PER_BIT-1) begin
                    tx_data         <= i_tx_data;
                    tx_state        <= TX_START_BIT;
                    tx_count_clk    <= tx_count_clk + 1;
                end else begin
                    o_tx_serdata    <= tx_data[tx_bit_index];
                    tx_bit_index    <= tx_bit_index + 1;
                    tx_state        <= TX_DATA_BITS;
                    tx_count_clk    <= 0;
                end
            end
            TX_DATA_BITS: begin
                if (tx_bit_index <= 7) begin
                    
                    if (tx_count_clk < CLOCKS_PER_BIT-1) begin
                        tx_count_clk    <= tx_count_clk + 1;
                    end else begin
                        o_tx_serdata    <= tx_data[tx_bit_index] ;
                        tx_count_clk    <= 0;
                        tx_bit_index       <= tx_bit_index + 1;
                    end
                    tx_state        <= TX_DATA_BITS;
                end else begin
                    if (tx_count_clk < CLOCKS_PER_BIT-1) begin
                        tx_count_clk    <= tx_count_clk + 1;
                    end else begin
                        o_tx_serdata    <= 1;       // Stop bit is 1
                        tx_count_clk    <= 0;
                        // tx_bit_index    <= tx_bit_index + 1;
                        tx_state        <= TX_STOP_BIT;
                    end
                end
            end
            //--------------------------STOPBIT GENERATWS ONLY ONE
            TX_STOP_BIT: begin
                if (tx_count_clk < (CLOCKS_PER_BIT-1)) begin
                    o_tx_serdata   <= 1;
                    tx_state       <= TX_STOP_BIT;
                    tx_count_clk   <= tx_count_clk + 1;
                end else begin
                  
                    tx_state       <= TX_IDLE;
                end
            end
 
            default: begin
                tx_state       <= TX_IDLE;
                tx_bit_index    <= 0;
                o_tx_serdata    <= 1;
				o_tx_status     <= 0;
                tx_count_clk    <= 0;
            end
        endcase
    end						  
	
	
//================================= reciever state machine=========================	
     reg [15:0]           rx_count_clk;
     reg [3:0]           rx_bit_index; //8 bits total
     reg [2:0]           rx_state;
     reg [7:0]           rx_data;
     
	localparam RX_IDLE      = 3'b000;
    localparam RX_START_BIT = 3'b001;
    localparam RX_DATA_BITS = 3'b010;
    localparam RX_STOP_BIT  = 3'b011;


    always @ (posedge sys_clk) begin
            case (rx_state)
                RX_IDLE: begin		   
                    o_rx_dvalid         <= 0;
                    rx_bit_index        <= 0;
    
                    rx_count_clk        <= 0;
                  
                    if (i_rx_serdata == 0) begin
                        rx_state       <= RX_START_BIT;
                    end else begin
                        rx_state       <= RX_IDLE;
                    end
                end
                RX_START_BIT: begin
                    if (rx_count_clk < (CLOCKS_PER_BIT-2)) begin
                        rx_count_clk       <= rx_count_clk + 1;
                        rx_state           <= RX_START_BIT;
                    end else begin
                        if (i_rx_serdata == 0) begin
                            rx_count_clk   <= 0;
                            rx_state       <= RX_DATA_BITS;
                        end else begin
                            rx_state       <= RX_IDLE;
                        end
                    end
                end
                RX_DATA_BITS: begin	 
					if (rx_bit_index <= 7) begin
	                    if (rx_count_clk < CLOCKS_PER_BIT-2) begin
	                        rx_count_clk       <= rx_count_clk + 1;
	                    end else begin
	                        o_rx_data [rx_bit_index]   <= i_rx_serdata;
	                        rx_count_clk       <= 0; 
							rx_bit_index    <= rx_bit_index + 1;
					    end
						rx_state        <= RX_DATA_BITS;
				    end
				   else begin
					    if (rx_count_clk < CLOCKS_PER_BIT-2) begin
                            rx_bit_index    <= rx_bit_index; 
							rx_count_clk       <= rx_count_clk + 1;
                        end else begin
                            rx_bit_index    <= 0;
                            rx_state        <= RX_STOP_BIT;
                        end
			     end
			  end 
                 
                //--------------------STOPBIT CHECKS ONLY FOR ONE
                RX_STOP_BIT: begin
                    if (rx_count_clk < CLOCKS_PER_BIT-2) begin
                            rx_state        <= RX_STOP_BIT;
                            rx_count_clk    <= rx_count_clk + 1;
                    end else begin
                           rx_count_clk        <= 0;
                           rx_state        <= RX_IDLE;
                           o_rx_dvalid     <= 1;
                       
                    end
                end
         
                default:  begin
                    rx_state            <= RX_IDLE;
                    o_rx_dvalid         <= 0;
                    rx_bit_index        <= 0;
					rx_count_clk        <= 0;
                  
                end
            endcase
  
    end	
	
	
endmodule