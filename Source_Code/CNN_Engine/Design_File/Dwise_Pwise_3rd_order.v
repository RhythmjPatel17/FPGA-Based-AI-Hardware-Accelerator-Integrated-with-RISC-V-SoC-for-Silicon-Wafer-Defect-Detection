
module depthandpointwise_conv2d_28_7_3x_1280ch (
    input wire clk, 
    input wire resetn, 
    input wire start, 
    input wire [31:0] read_addr, 
    output wire [3:0] read_data, 
    // Pooling
    output reg done, 
    output reg pool_start, 
    input wire pool_done, 
    output reg [31:0] pool_read_addr, 
    // MRAM
    input wire [3:0] pool_read_data, 
    output reg [9:0] conv_out_addr_a, 
    output reg [31:0] conv_out_din_a, 
    output reg conv_out_en_a, 
    output reg [3:0] conv_out_we_a, 
    input wire [31:0] conv_out_dout, 
    output reg conv_out_en_b, 
    // ROM
    input wire [31:0] conv_out_dout_b, 
    output reg [15:0] weight_idx, 
    input wire signed [7:0] weight_data, 
    output reg [6:0] filter_idx, 
    input wire signed [7:0] bias_data, 
    input wire signed [7:0] scale_data, 
    input wire signed [7:0] shift_data) ;
    localparam IDLE = 4'd0 ; 
    localparam START_POOL = 4'd1 ; 
    localparam WAIT_POOL_DONE = 4'd2 ; 
    localparam LOAD_LAYER = 4'd3 ; 
    localparam CONV2D = 4'd4 ; 
    localparam LOAD_WIN = 4'd5 ; 
    localparam MAC = 4'd6 ; 
    localparam POST_PROCESS = 4'd7 ; 
    localparam DONE_STATE = 4'd8 ; 
    reg [3:0] state ; 
    reg [3:0] window [0:8] ; 
    reg [3:0] relu6_out ; 
    reg signed [31:0] acc ; 
    reg signed [15:0] bn_scaled ; 
    reg [31:0] packed_data ; 
    reg [3:0] row, 
        col ; 
    reg [6:0] ch ; 
    reg [3:0] win_idx ; 
    reg [10:0] out_idx ; // =========================================================================
// Safe output mux
// =========================================================================
    assign read_data = conv_out_dout[(31 - (4 * read_addr[2:0])) -: 4] ; // =========================================================================
// Main FSM
// =========================================================================
    always
        @(posedge clk)
        begin
            if ((!resetn)) 
                begin
                    state <=  IDLE ;
                    done <=  0 ;
                    pool_start <=  0 ;
                    conv_out_en_a <=  0 ;
                    conv_out_we_a <=  0 ;
                    conv_out_en_b <=  0 ;
                    packed_data <=  0 ;
                    acc <=  0 ;
                    win_idx <=  0 ;
                    out_idx <=  0 ;
                    filter_idx <=  0 ;
                    ch <=  0 ;
                    row <=  0 ;
                    col <=  0 ;
                end
            else
                begin
                    pool_start <=  0 ;// defaults
                    conv_out_en_a <=  0 ;
                    conv_out_we_a <=  0 ;
                    done <=  0 ;
                    case (state)
                    IDLE : 
                        begin
                            if (start) 
                                begin
                                    pool_start <=  1 ;
                                    state <=  START_POOL ;
                                end
                        end// -----------------------------------------------------
                    START_POOL : 
                        begin
                            state <=  WAIT_POOL_DONE ;
                        end
                    WAIT_POOL_DONE : 
                        begin
                            if (pool_done) 
                                begin
                                    row <=  0 ;
                                    col <=  0 ;
                                    ch <=  0 ;
                                    out_idx <=  0 ;
                                    acc <=  0 ;
                                    state <=  LOAD_LAYER ;
                                end
                        end
                    LOAD_LAYER : 
                        begin
                            state <=  CONV2D ;
                        end
                    CONV2D : 
                        begin
                            if ((row < 8)) 
                                begin
                                    if ((col < 8)) 
                                        begin
                                            if ((ch < 64)) 
                                                begin
                                                    win_idx <=  0 ;
                                                    state <=  LOAD_WIN ;
                                                end
                                            else
                                                begin
                                                    state <=  POST_PROCESS ;
                                                end
                                        end
                                    else
                                        begin
                                            col <=  0 ;
                                            row <=  (row + 1) ;
                                        end
                                end
                            else
                                begin
                                    if ((filter_idx < 127)) 
                                        begin
                                            filter_idx <=  (filter_idx + 1) ;
                                            row <=  0 ;
                                            col <=  0 ;
                                            out_idx <=  0 ;
                                            acc <=  0 ;
                                            packed_data <=  0 ;
                                        end
                                    else
                                        begin
                                            state <=  DONE_STATE ;
                                        end
                                end
                        end// ------------------------ Load 3x3 Window -------------------
                    LOAD_WIN : 
                        begin
                            pool_read_addr <=  ((((ch * 64) + ((row + (win_idx / 3)) * 8)) + col) + (win_idx % 3)) ;
                            state <=  MAC ;
                        end
                    MAC : 
                        begin
                            window[win_idx] <=  pool_read_data ;
                            if ((win_idx == 8)) 
                                begin
                                    acc <=  (((((((((acc + (window[0] * weight_data)) + (window[1] * weight_data)) + (window[2] * weight_data)) + (window[3] * weight_data)) + (window[4] * weight_data)) + (window[5] * weight_data)) + (window[6] * weight_data)) + (window[7] * weight_data)) + (window[8] * weight_data)) ;
                                    ch <=  (ch + 1) ;
                                    state <=  CONV2D ;
                                end
                            else
                                begin
                                    win_idx <=  (win_idx + 1) ;
                                    state <=  LOAD_WIN ;
                                end
                        end// ------------------------ BatchNorm + ReLU6 -------------------
                    POST_PROCESS : 
                        begin
                            acc <=  ((acc + bias_data) >>> 4) ;
                            if ((acc > 127)) 
                                acc <=  127 ;
                            else
                                if ((acc < (-128))) 
                                    acc <=  (-128) ;
                            bn_scaled <=  (((acc * scale_data) + shift_data) >>> 6) ;
                            if ((bn_scaled > 127)) 
                                bn_scaled <=  127 ;
                            else
                                if ((bn_scaled < (-128))) 
                                    bn_scaled <=  (-128) ;
                            relu6_out <=  ((bn_scaled + 128) / 21) ;
                            if ((relu6_out > 6)) // pack nibble
                                relu6_out <=  6 ;
                            case (out_idx[2:0])
                            3'd0 : 
                                packed_data[31:28] <=  relu6_out ;
                            3'd1 : 
                                packed_data[27:24] <=  relu6_out ;
                            3'd2 : 
                                packed_data[23:20] <=  relu6_out ;
                            3'd3 : 
                                packed_data[19:16] <=  relu6_out ;
                            3'd4 : 
                                packed_data[15:12] <=  relu6_out ;
                            3'd5 : 
                                packed_data[11:8] <=  relu6_out ;
                            3'd6 : 
                                packed_data[7:4] <=  relu6_out ;
                            3'd7 : 
                                begin
                                    packed_data[3:0] <=  relu6_out ;
                                    conv_out_din_a <=  packed_data ;
                                    conv_out_addr_a <=  (((filter_idx * 64) + out_idx) >> 3) ;
                                    conv_out_en_a <=  1 ;
                                    conv_out_we_a <=  4'b1111 ;
                                    packed_data <=  0 ;
                                end
                            endcase 
                            col <=  (col + 1) ;
                            out_idx <=  (out_idx + 1) ;
                            ch <=  0 ;
                            acc <=  0 ;
                            state <=  CONV2D ;
                        end// ------------------------ DONE -------------------
                    DONE_STATE : 
                        begin
                            done <=  1 ;
                            conv_out_en_b <=  1 ;
                            state <=  IDLE ;
                        end
                    endcase 
                end
        end
endmodule



