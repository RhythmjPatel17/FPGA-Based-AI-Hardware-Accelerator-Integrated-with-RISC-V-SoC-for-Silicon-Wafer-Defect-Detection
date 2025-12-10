
module dense_layer_1x_1280_256_128_bn_relu6_top (
    input wire clk, 
    input wire resetn, 
    input wire start, 
    input wire [6:0] read_addr, 
    output wire [3:0] read_data, 
    output reg done, 
    output reg mp_start, 
    input wire mp_done, 
    output reg [31:0] mp_read_addr, 
    input wire [3:0] mp_read_data, 
    output wire [17:0] weights_addr, 
    input wire [7:0] weights_data, 
    output wire [7:0] bias_addr, 
    input wire [7:0] bias_data, 
    output wire [7:0] scale_addr, 
    input wire [7:0] scale_data, 
    output wire [7:0] shift_addr, 
    input wire [7:0] shift_data) ;
    parameter IN_DIM = 1900 ; 
    parameter OUT_DIM = 128 ; 
    parameter CHUNK_SIZE = 256 ; 
    parameter NUM_CHUNKS = 8 ;
    reg [2:0] state ; 
    localparam IDLE = 3'd0, 
        MAX_WAIT = 3'd1, 
        LOAD_INPUT = 3'd2, 
        COMPUTE = 3'd3, 
        DONE_STATE = 3'd4 ; 
    reg signed [31:0] acc, 
        temp_acc ; 
    reg signed [15:0] bn_scaled ; 
    reg [3:0] relu6_out ; 
    reg [10:0] in_idx ; 
    reg [7:0] out_idx ; 
    reg [2:0] chunk_idx ; // Internal memory to store inputs and outputs
    reg signed [7:0] input_vector [0:(IN_DIM - 1)] ; 
    reg [3:0] output_vector [0:(OUT_DIM - 1)] ; // External read access (read 4-bit output data)
    assign read_data = output_vector[read_addr] ; // Weight, bias, scale, shift ROM addressing
    assign weights_addr = (((out_idx * IN_DIM) + (chunk_idx * CHUNK_SIZE)) + in_idx) ; 
    assign bias_addr = out_idx ; 
    assign scale_addr = out_idx ; 
    assign shift_addr = out_idx ; 
    integer i ; // ==================================================
// Sequential logic
// ==================================================
    always
        @(posedge clk)
        begin
            if ((!resetn)) 
                begin
                    state <=  IDLE ;
                    done <=  0 ;
                    in_idx <=  0 ;
                    out_idx <=  0 ;
                    chunk_idx <=  0 ;
                    acc <=  0 ;
                    mp_start <=  0 ;
                    mp_read_addr <=  0 ;
                    for (i = 0 ; (i < IN_DIM) ; i = (i + 1))
                        input_vector[i] <=  0 ;
                    for (i = 0 ; (i < OUT_DIM) ; i = (i + 1))
                        output_vector[i] <=  0 ;
                end
            else
                begin
                    done <=  0 ;
                    mp_start <=  0 ;
                    case (state)
                    IDLE : 
                        begin
                            if (start) 
                                begin
                                    mp_start <=  1 ;
                                    state <=  MAX_WAIT ;
                                end
                        end// ------------------------------------------------
// ------------------------------------------------
                    MAX_WAIT : 
                        begin
                            if (mp_done) 
                                begin
                                    in_idx <=  0 ;
                                    state <=  LOAD_INPUT ;
                                end
                        end// ------------------------------------------------
                    LOAD_INPUT : 
                        begin
                            mp_read_addr <=  in_idx ;
                            input_vector[in_idx] <=  mp_read_data ;
                            if ((in_idx == (IN_DIM - 1))) 
                                begin
                                    in_idx <=  0 ;
                                    chunk_idx <=  0 ;
                                    out_idx <=  0 ;
                                    acc <=  0 ;
                                    state <=  COMPUTE ;
                                end
                            else
                                begin
                                    in_idx <=  (in_idx + 1) ;
                                end
                        end// ------------------------------------------------
                    COMPUTE : 
                        begin
                            if ((out_idx < OUT_DIM)) 
                                begin
                                    temp_acc <=  0 ;
                                    if (((^acc) === 1'bx)) 
                                        acc <=  0 ;
                                    if (((chunk_idx == 0) && (in_idx == 0))) 
                                        acc <=  $signed(bias_data) ;
                                    temp_acc <=  ($signed(input_vector[((chunk_idx * CHUNK_SIZE) + in_idx)]) * $signed(weights_data)) ;
                                    acc <=  (acc + temp_acc) ;
                                    if ((in_idx == (CHUNK_SIZE - 1))) 
                                        begin
                                            in_idx <=  0 ;
                                            if ((chunk_idx == (NUM_CHUNKS - 1))) 
                                                begin
                                                    acc <=  (acc >>> 5) ;// BatchNorm + ReLU6
                                                    acc <=  ((acc > 127) ? 127 : ((acc < (-128)) ? (-128) : acc)) ;
                                                    bn_scaled <=  (((acc * scale_data) + shift_data) >>> 7) ;
                                                    bn_scaled <=  ((bn_scaled > 127) ? 127 : ((bn_scaled < (-128)) ? (-128) : bn_scaled)) ;
                                                    relu6_out <=  ((bn_scaled + 128) / 42) ;
                                                    relu6_out <=  ((relu6_out > 6) ? 6 : ((relu6_out < 0) ? 0 : relu6_out)) ;// Store result locally
                                                    output_vector[out_idx] <=  relu6_out ;
                                                    if ((out_idx == (OUT_DIM - 1))) 
                                                        begin
                                                            state <=  DONE_STATE ;
                                                        end
                                                    else
                                                        begin
                                                            out_idx <=  (out_idx + 1) ;
                                                            chunk_idx <=  0 ;
                                                            acc <=  0 ;
                                                        end
                                                end
                                            else
                                                begin
                                                    chunk_idx <=  (chunk_idx + 1) ;
                                                end
                                        end
                                    else
                                        begin
                                            in_idx <=  (in_idx + 1) ;
                                        end
                                end
                        end// ------------------------------------------------
                    DONE_STATE : 
                        begin
                            done <=  1 ;
                            state <=  IDLE ;
                        end
                    endcase 
                end
        end
endmodule



