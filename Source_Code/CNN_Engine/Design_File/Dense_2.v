
module dense_layer_2x_128_to_9 (
    input wire clk, 
    input wire resetn, 
    // ---- Read interface for output (like MRAM read ports) ----
    input wire start, 
    input wire [3:0] read_addr, 
    output wire [31:0] read_data, 
    // ---- Connections to dense_layer_1x_1280_256_128_bn_relu6 ----
    output reg done, 
    output reg dense_start, 
    output reg [6:0] dense_read_addr, 
    input wire [3:0] dense_read_data, 
    // ---- Connections to Weights ROM ----
    input wire dense_done, 
    output reg [10:0] weight_addr, 
    // ---- Connections to Bias ROM ----
    input wire signed [7:0] weight_data, 
    output reg [3:0] bias_addr, 
    input wire signed [7:0] bias_data) ;
    localparam IDLE = 4'd0 ; // FSM States (Verilog style)
    localparam LOAD_BIASES = 4'd1 ; 
    localparam LOAD_WEIGHTS = 4'd2 ; 
    localparam WAIT_PREV = 4'd3 ; 
    localparam LOAD_INPUT = 4'd4 ; 
    localparam COMPUTE = 4'd5 ; 
    localparam STORE = 4'd6 ; 
    localparam DONE_STATE = 4'd7 ; 
    reg [3:0] state ; // Layer parameters
    localparam IN_DIM = 128 ; 
    localparam OUT_DIM = 9 ; 
    localparam TOTAL_WEIGHTS = (IN_DIM * OUT_DIM) ; // Internal memory/registers
    reg signed [7:0] weights [0:(TOTAL_WEIGHTS - 1)] ; 
    reg signed [7:0] biases [0:(OUT_DIM - 1)] ; 
    reg signed [7:0] input_vector [0:(IN_DIM - 1)] ; 
    reg [31:0] output_bram [0:(OUT_DIM - 1)] ; // Internal variables
    integer i ; 
    reg [10:0] load_weight_idx ; 
    reg [3:0] load_bias_idx ; 
    reg [3:0] out_idx ; 
    reg [7:0] in_idx ; 
    reg signed [31:0] sum ; // Read data mapping for external read port
    assign read_data = output_bram[read_addr] ; // =========================================================================
// Main FSM
// =========================================================================
    always
        @(posedge clk)
        begin
            if ((!resetn)) 
                begin
                    state <=  IDLE ;
                    done <=  0 ;
                    load_weight_idx <=  0 ;
                    load_bias_idx <=  0 ;
                    dense_start <=  0 ;
                    dense_read_addr <=  0 ;
                    out_idx <=  0 ;
                    in_idx <=  0 ;
                    sum <=  0 ;
                    bias_addr <=  0 ;
                    weight_addr <=  0 ;
                    for (i = 0 ; (i < IN_DIM) ; i = (i + 1))
                        input_vector[i] <=  0 ;
                    for (i = 0 ; (i < OUT_DIM) ; i = (i + 1))
                        output_bram[i] <=  32'd0 ;
                end
            else
                begin
                    case (state)
                    IDLE : 
                        begin
                            done <=  0 ;
                            if (start) 
                                begin
                                    load_bias_idx <=  0 ;
                                    state <=  LOAD_BIASES ;
                                end
                        end
                    LOAD_BIASES : 
                        begin
                            bias_addr <=  load_bias_idx ;
                            biases[load_bias_idx] <=  bias_data ;
                            if ((load_bias_idx == (OUT_DIM - 1))) 
                                begin
                                    load_weight_idx <=  0 ;
                                    state <=  LOAD_WEIGHTS ;
                                end
                            else
                                begin
                                    load_bias_idx <=  (load_bias_idx + 1) ;
                                end
                        end
                    LOAD_WEIGHTS : 
                        begin
                            weight_addr <=  load_weight_idx ;
                            weights[load_weight_idx] <=  weight_data ;
                            if ((load_weight_idx == (TOTAL_WEIGHTS - 1))) 
                                begin
                                    dense_start <=  1 ;
                                    state <=  WAIT_PREV ;
                                end
                            else
                                begin
                                    load_weight_idx <=  (load_weight_idx + 1) ;
                                end
                        end
                    WAIT_PREV : 
                        begin
                            dense_start <=  0 ;
                            if (dense_done) 
                                state <=  LOAD_INPUT ;
                        end
                    LOAD_INPUT : 
                        begin
                            if ((in_idx < IN_DIM)) 
                                begin
                                    dense_read_addr <=  in_idx ;
                                    input_vector[in_idx] <=  dense_read_data ;
                                    in_idx <=  (in_idx + 1) ;
                                end
                            else
                                begin
                                    in_idx <=  0 ;
                                    out_idx <=  0 ;
                                    state <=  COMPUTE ;
                                end
                        end
                    COMPUTE : 
                        begin
                            if ((out_idx < OUT_DIM)) 
                                begin
                                    if ((in_idx == 0)) 
                                        sum <=  biases[out_idx] ;
                                    if ((in_idx < IN_DIM)) 
                                        begin
                                            sum <=  (sum + (weights[((out_idx * IN_DIM) + in_idx)] * input_vector[in_idx])) ;
                                            in_idx <=  (in_idx + 1) ;
                                        end
                                    else
                                        begin
                                            output_bram[out_idx] <=  sum ;
                                            out_idx <=  (out_idx + 1) ;
                                            in_idx <=  0 ;
                                        end
                                end
                            else
                                begin
                                    state <=  STORE ;
                                end
                        end
                    STORE : 
                        begin
                            done <=  1 ;
                            state <=  DONE_STATE ;
                        end
                    DONE_STATE : 
                        begin
                            done <=  1 ;
                        end
                    default : 
                        state <=  IDLE ;
                    endcase 
                end
        end
endmodule



