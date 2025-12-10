
module depthandpointwise_conv2d_112_56_2x_144ch (
    input wire clk, 
    input wire resetn, 
    input wire start, 
    input wire [31:0] read_addr, 
    output wire [3:0] read_data, 
    output reg done, 
    output reg pool_start, 
    input wire pool_done, 
    output reg [31:0] pool_read_addr, 
    input wire [3:0] pool_read_data, 
    output reg [9:0] mram_addr_a, 
    output reg [31:0] mram_din_a, 
    input wire [31:0] mram_dout, 
    output reg mram_en_a, 
    output reg [3:0] mram_we_a, 
    output reg mram_en_b, 
    output reg [15:0] weight_idx, 
    input wire signed [7:0] weight_data, 
    output reg [5:0] filter_idx, 
    input wire signed [7:0] bias_data, 
    input wire signed [7:0] scale_data, 
    input wire signed [7:0] shift_data) ;
    localparam IDLE = 4'd0 ; // PARAMETERS
    localparam START_POOL = 4'd1 ; 
    localparam WAIT_POOL_DONE = 4'd2 ; 
    localparam LOAD_LAYER = 4'd3 ; 
    localparam CONV2D = 4'd4 ; 
    localparam LOAD_WINDOW_0 = 4'd5 ; 
    localparam WAIT_FOR_READ0 = 4'd6 ; 
    localparam WAIT_FOR_READ1 = 4'd7 ; 
    localparam WAIT_FOR_READ2 = 4'd8 ; 
    localparam MUL_ACCUMULATE = 4'd9 ; 
    localparam POST_PROCESS = 4'd10 ; 
    localparam DONE_STATE = 4'd11 ; 
    reg [3:0] state ; 
    reg [4:0] row, 
        col ; 
    reg [10:0] out_idx ; 
    reg [5:0] ch ; 
    reg signed [31:0] acc, 
        temp_acc ; 
    reg [31:0] packed_data ; 
    reg [3:0] relu6_out ; 
    reg signed [15:0] bn_scaled ; 
    reg [3:0] window [0:8] ; 
    integer i ; // PREVENT MIXED ASSIGNMENTS USING BLOCKING HERE
    integer k ; 
    reg signed [31:0] sum ; // READ MUX
    assign read_data = ((read_addr[2:0] == 3'd0) ? mram_dout[31:28] : ((read_addr[2:0] == 3'd1) ? mram_dout[27:24] : ((read_addr[2:0] == 3'd2) ? mram_dout[23:20] : ((read_addr[2:0] == 3'd3) ? mram_dout[19:16] : ((read_addr[2:0] == 3'd4) ? mram_dout[15:12] : ((read_addr[2:0] == 3'd5) ? mram_dout[11:8] : ((read_addr[2:0] == 3'd6) ? mram_dout[7:4] : mram_dout[3:0]))))))) ; // FSM
    always
        @(posedge clk)
        begin
            if ((!resetn)) 
                begin
                    state <=  IDLE ;
                    pool_start <=  0 ;
                    done <=  0 ;
                    mram_en_a <=  0 ;
                    mram_we_a <=  0 ;
                    mram_en_b <=  0 ;
                    row <=  0 ;
                    col <=  0 ;
                    out_idx <=  0 ;
                    filter_idx <=  0 ;
                    ch <=  0 ;
                    acc <=  0 ;
                    packed_data <=  0 ;
                    weight_idx <=  0 ;
                end
            else
                begin
                    pool_start <=  0 ;
                    mram_en_a <=  0 ;
                    mram_we_a <=  0 ;
                    done <=  0 ;
                    case (state)
                    IDLE : 
                        if (start) 
                            state <=  START_POOL ;
                    START_POOL : 
                        begin
                            pool_start <=  1 ;
                            state <=  WAIT_POOL_DONE ;
                        end
                    WAIT_POOL_DONE : 
                        begin
                            if (pool_done) 
                                begin
                                    row <=  0 ;
                                    col <=  0 ;
                                    out_idx <=  0 ;
                                    filter_idx <=  0 ;
                                    ch <=  0 ;
                                    acc <=  0 ;
                                    packed_data <=  0 ;
                                    state <=  LOAD_LAYER ;
                                end
                        end
                    LOAD_LAYER : 
                        state <=  CONV2D ;
                    CONV2D : 
                        begin
                            if ((row < 16)) 
                                begin
                                    if ((col < 16)) 
                                        begin
                                            if ((ch < 32)) 
                                                begin
                                                    i <=  0 ;
                                                    state <=  LOAD_WINDOW_0 ;
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
                                    if ((filter_idx < 63)) 
                                        begin
                                            filter_idx <=  (filter_idx + 1) ;
                                            row <=  0 ;
                                            col <=  0 ;
                                            out_idx <=  0 ;
                                            ch <=  0 ;
                                            acc <=  0 ;
                                            packed_data <=  0 ;
                                        end
                                    else
                                        begin
                                            state <=  DONE_STATE ;
                                        end
                                end
                        end
                    LOAD_WINDOW_0 : 
                        begin
                            pool_read_addr <=  (((ch * 256) + ((row + i) * 16)) + col) ;
                            state <=  WAIT_FOR_READ0 ;
                        end
                    WAIT_FOR_READ0 : 
                        begin
                            window[((i * 3) + 0)] <=  pool_read_data ;
                            pool_read_addr <=  ((((ch * 256) + ((row + i) * 16)) + col) + 1) ;
                            state <=  WAIT_FOR_READ1 ;
                        end
                    WAIT_FOR_READ1 : 
                        begin
                            window[((i * 3) + 1)] <=  pool_read_data ;
                            pool_read_addr <=  ((((ch * 256) + ((row + i) * 16)) + col) + 2) ;
                            state <=  WAIT_FOR_READ2 ;
                        end
                    WAIT_FOR_READ2 : 
                        begin
                            window[((i * 3) + 2)] <=  pool_read_data ;
                            if ((i == 2)) 
                                begin
                                    state <=  MUL_ACCUMULATE ;
                                end
                            else
                                begin
                                    i <=  (i + 1) ;
                                    state <=  LOAD_WINDOW_0 ;
                                end
                        end// ? FIXED VERSION
                    MUL_ACCUMULATE : 
                        begin
                            sum = 0 ;
                            for (k = 0 ; (k < 9) ; k = (k + 1))
                                sum = (sum + ($signed(window[k]) * $signed(weight_data))) ;
                            temp_acc <=  sum ;
                            acc <=  (acc + sum) ;
                            weight_idx <=  (((filter_idx * 32) * 9) + (ch * 9)) ;
                            ch <=  (ch + 1) ;
                            state <=  CONV2D ;
                        end
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
                            relu6_out <=  ((bn_scaled + 128) >>> 5) ;
                            if ((relu6_out > 6)) 
                                relu6_out <=  6 ;
                            else
                                if ((relu6_out < 0)) 
                                    relu6_out <=  0 ;
                            case ((out_idx % 8))
                            0 : 
                                packed_data[31:28] <=  relu6_out ;
                            1 : 
                                packed_data[27:24] <=  relu6_out ;
                            2 : 
                                packed_data[23:20] <=  relu6_out ;
                            3 : 
                                packed_data[19:16] <=  relu6_out ;
                            4 : 
                                packed_data[15:12] <=  relu6_out ;
                            5 : 
                                packed_data[11:8] <=  relu6_out ;
                            6 : 
                                packed_data[7:4] <=  relu6_out ;
                            7 : 
                                begin
                                    packed_data[3:0] <=  relu6_out ;
                                    mram_din_a <=  packed_data ;
                                    mram_addr_a <=  ((((filter_idx * 256) + out_idx) >> 3) * 4) ;
                                    mram_en_a <=  1 ;
                                    mram_we_a <=  4'b1111 ;
                                    packed_data <=  0 ;
                                end
                            endcase 
                            acc <=  0 ;
                            ch <=  0 ;
                            col <=  (col + 1) ;
                            out_idx <=  (out_idx + 1) ;
                            state <=  CONV2D ;
                        end
                    DONE_STATE : 
                        begin
                            done <=  1 ;
                            mram_en_b <=  1 ;
                            state <=  IDLE ;
                        end
                    endcase 
                end
        end
		

endmodule



