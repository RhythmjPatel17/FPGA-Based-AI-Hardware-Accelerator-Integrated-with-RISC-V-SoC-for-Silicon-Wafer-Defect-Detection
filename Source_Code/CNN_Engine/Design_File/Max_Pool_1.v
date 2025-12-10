
module maxpool2d_2x2_stride2_16_batches_112_112_32ch (
    input wire clk, 
    input wire resetn, 
    input wire start, 
    input wire [31:0] read_addr, 
    output wire [3:0] read_data, 
    // ===== Conv2D interface ports =====
    output reg done, 
    output reg conv2d_start, 
    output reg [31:0] conv2d_read_addr, 
    input wire [3:0] conv2d_read_data, 
    // ===== MRAM interface ports =====
    input wire conv2d_done, 
    output reg [9:0] mram_addr_a, 
    output reg [31:0] mram_din_a, 
    output reg mram_en_a, 
    output reg [3:0] mram_we_a, 
    output reg mram_en_b, 
    input wire [31:0] mram_dout) ;
    reg [2:0] state ; // ===== State encoding =====
    localparam IDLE = 3'd0, 
        CONV_START = 3'd1, 
        WAIT_CONV_DONE = 3'd2, 
        READ = 3'd3, 
        COMPUTE_STORE = 3'd4, 
        COMPUTE_MAX = 3'd5, 
        WRITE = 3'd6, 
        DONE = 3'd7 ; // ===== Internal registers =====
    reg [3:0] buffer [0:3] ; 
    reg [5:0] ch ; 
    reg [5:0] row, 
        col ; 
    reg [2:0] byte_index ; 
    reg [2:0] max_count ; 
    reg [31:0] packed_word ; 
    reg [3:0] max_val ; // ===== Read data selection from MRAM =====
    assign read_data = ((read_addr[2:0] == 3'd0) ? mram_dout[31:28] : ((read_addr[2:0] == 3'd1) ? mram_dout[27:24] : ((read_addr[2:0] == 3'd2) ? mram_dout[23:20] : ((read_addr[2:0] == 3'd3) ? mram_dout[19:16] : ((read_addr[2:0] == 3'd4) ? mram_dout[15:12] : ((read_addr[2:0] == 3'd5) ? mram_dout[11:8] : ((read_addr[2:0] == 3'd6) ? mram_dout[7:4] : mram_dout[3:0]))))))) ; // ===== Main FSM =====
    always
        @(posedge clk)
        begin
            if ((!resetn)) 
                begin
                    state <=  IDLE ;
                    done <=  0 ;
                    mram_addr_a <=  0 ;
                    conv2d_read_addr <=  0 ;
                    mram_din_a <=  0 ;
                    ch <=  0 ;
                    row <=  0 ;
                    col <=  0 ;
                    byte_index <=  0 ;
                    max_count <=  0 ;
                    mram_en_a <=  0 ;
                    mram_we_a <=  4'd0 ;
                    mram_en_b <=  0 ;
                    conv2d_start <=  0 ;
                    packed_word <=  0 ;
                end
            else
                begin
                    mram_en_a <=  0 ;// Default signals each cycle
                    mram_we_a <=  4'd0 ;
                    conv2d_start <=  0 ;
                    done <=  0 ;
                    case (state)
                    IDLE : 
                        begin
                            if (start) 
                                begin
                                    conv2d_start <=  1 ;
                                    state <=  CONV_START ;
                                end
                        end
                    CONV_START : 
                        begin
                            conv2d_start <=  0 ;
                            state <=  WAIT_CONV_DONE ;
                        end
                    WAIT_CONV_DONE : 
                        begin
                            if (conv2d_done) 
                                begin
                                    ch <=  0 ;
                                    row <=  0 ;
                                    col <=  0 ;
                                    byte_index <=  0 ;
                                    max_count <=  0 ;
                                    packed_word <=  0 ;
                                    state <=  READ ;
                                end
                        end
                    READ : 
                        begin
                            conv2d_read_addr <=  ((ch * 1024) + ((row * 32) + col)) ;
                            state <=  COMPUTE_STORE ;
                        end
                    COMPUTE_STORE : 
                        begin
                            buffer[byte_index] <=  conv2d_read_data ;
                            byte_index <=  (byte_index + 1) ;
                            if ((byte_index == 2'd3)) 
                                state <=  COMPUTE_MAX ;
                            else
                                begin
                                    conv2d_read_addr <=  (conv2d_read_addr + 1) ;
                                    state <=  READ ;
                                end
                        end
                    COMPUTE_MAX : 
                        begin
                            max_val = buffer[0] ;
                            if ((buffer[1] > max_val)) 
                                max_val = buffer[1] ;
                            if ((buffer[2] > max_val)) 
                                max_val = buffer[2] ;
                            if ((buffer[3] > max_val)) 
                                max_val = buffer[3] ;
                            packed_word[(28 - (4 * max_count)) +: 4] <=  max_val ;
                            max_count <=  (max_count + 1) ;
                            byte_index <=  0 ;
                            if ((max_count == 3'd7)) 
                                state <=  WRITE ;
                            else
                                state <=  READ ;
                        end
                    WRITE : 
                        begin
                            mram_addr_a <=  ((((ch * 256) + (((row >> 1) * 16) + (col >> 1))) >> 3) * 4) ;
                            mram_din_a <=  packed_word ;
                            mram_en_a <=  1 ;
                            mram_we_a <=  4'b1111 ;
                            packed_word <=  0 ;
                            max_count <=  0 ;
                            if ((((ch == 31) && (row == 30)) && (col == 30))) 
                                state <=  DONE ;
                            else
                                begin
                                    if (((col + 2) >= 32)) 
                                        begin
                                            col <=  0 ;
                                            if (((row + 2) >= 32)) 
                                                begin
                                                    row <=  0 ;
                                                    ch <=  (ch + 1) ;
                                                end
                                            else
                                                row <=  (row + 2) ;
                                        end
                                    else
                                        col <=  (col + 2) ;
                                    state <=  READ ;
                                end
                        end
                    DONE : 
                        begin
                            done <=  1 ;
                            mram_en_a <=  0 ;
                            mram_en_b <=  1 ;
                            mram_we_a <=  4'b0000 ;
                            state <=  IDLE ;
                        end
                    endcase 
                end
        end
endmodule



