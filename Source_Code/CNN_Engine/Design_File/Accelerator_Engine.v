
module CNN_Accelerator_Engine (
    input wire clk, 
    input wire resetn, 
    input wire start, 
    input wire [4:0] input_image_index, 
    output reg [3:0] predicted_class, 
    output reg done, 
    output reg dense_start, 
    input wire dense_done, 
    output reg [3:0] dense_read_addr, 
    input wire [31:0] dense_read_data, 
    output reg argmax_start, 
    input wire argmax_done, 
    output reg [31:0] argmax_data_in0, 
    output reg [31:0] argmax_data_in1, 
    output reg [31:0] argmax_data_in2, 
    output reg [31:0] argmax_data_in3, 
    output reg [31:0] argmax_data_in4, 
    output reg [31:0] argmax_data_in5, 
    output reg [31:0] argmax_data_in6, 
    output reg [31:0] argmax_data_in7, 
    output reg [31:0] argmax_data_in8, 
    output reg [4:0] argmax_img, 
    input wire [3:0] argmax_max_index) ;
    localparam IDLE = 3'd0 ; // =========================================================================
// FSM state encoding
// =========================================================================
    localparam START_DENSE = 3'd1 ; 
    localparam WAIT_DENSE = 3'd2 ; 
    localparam READ_OUTPUTS = 3'd3 ; 
    localparam START_ARGMAX = 3'd4 ; 
    localparam WAIT_ARGMAX = 3'd5 ; 
    localparam FINISH = 3'd6 ; 
    reg [2:0] state ; // =========================================================================
// Internal Registers
// =========================================================================
    reg [31:0] output_buffer [0:8] ; 
    reg [3:0] index ; 
    reg [31:0] wait_counter ; 
    reg [4:0] image [0:50] ; 
    reg [4:0] img ; 
    integer z, 
        j ; // =========================================================================
// Main FSM
// =========================================================================
    always
        @(posedge clk or 
            negedge resetn)
        begin
            if ((!resetn)) 
                begin
                    state <=  IDLE ;
                    dense_start <=  0 ;
                    argmax_start <=  0 ;
                    dense_read_addr <=  0 ;
                    predicted_class <=  0 ;
                    done <=  0 ;
                    index <=  0 ;
                    wait_counter <=  0 ;
                    img <=  0 ;
                    j <=  0 ;
                    for (z = 0 ; (z < 51) ; z = (z + 1))
                        image[z] <=  0 ;
                    for (z = 0 ; (z < 9) ; z = (z + 1))
                        output_buffer[z] <=  0 ;
                end
            else
                begin
                    case (state)
                    IDLE : 
                        begin
                            done <=  0 ;
                            image[input_image_index] <=  input_image_index ;
                            if (start) 
                                begin
                                    dense_start <=  1 ;
                                    state <=  START_DENSE ;
                                    wait_counter <=  0 ;
                                end
                        end// ------------------------------------------------------------
// ------------------------------------------------------------
                    START_DENSE : 
                        begin
                            dense_start <=  0 ;
                            state <=  WAIT_DENSE ;
                        end// ------------------------------------------------------------
                    WAIT_DENSE : 
                        begin
                            if (dense_done) 
                                begin
                                    index <=  0 ;
                                    dense_read_addr <=  0 ;
                                    state <=  READ_OUTPUTS ;
                                end
                            
                    READ_OUTPUTS : 
                        begin
                            output_buffer[index] <=  dense_read_data ;
                            index <=  (index + 1) ;
                            dense_read_addr <=  (index + 1) ;
                            if ((index == 8)) 
                                state <=  START_ARGMAX ;
                        end// ------------------------------------------------------------
                    START_ARGMAX : 
                        begin
                            argmax_data_in0 <=  output_buffer[0] ;
                            argmax_data_in1 <=  output_buffer[1] ;
                            argmax_data_in2 <=  output_buffer[2] ;
                            argmax_data_in3 <=  output_buffer[3] ;
                            argmax_data_in4 <=  output_buffer[4] ;
                            argmax_data_in5 <=  output_buffer[5] ;
                            argmax_data_in6 <=  output_buffer[6] ;
                            argmax_data_in7 <=  output_buffer[7] ;
                            argmax_data_in8 <=  output_buffer[8] ;
                            argmax_img <=  input_image_index ;
                            argmax_start <=  1 ;
                            state <=  WAIT_ARGMAX ;
                        end// ------------------------------------------------------------
                    WAIT_ARGMAX : 
                        begin
                            argmax_start <=  0 ;
                            if (argmax_done) 
                                begin
                                    predicted_class <=  argmax_max_index ;
                                    done <=  1 ;
                                    state <=  FINISH ;
                                end
                        end// ------------------------------------------------------------
                    FINISH : 
                        begin
                            done <=  1 ;
                            state <=  FINISH ;
                        end
                    default : 
                        state <=  IDLE ;
                    endcase 
                end
        end
endmodule



