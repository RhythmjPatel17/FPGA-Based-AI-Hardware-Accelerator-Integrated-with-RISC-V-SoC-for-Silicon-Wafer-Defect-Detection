
module memory_stage (
    input wire clk, 
    // From EX/MEM
    input wire reset, 
    input wire [31:0] ex_val, 
    input wire [31:0] ex_rs2, 
    input wire [4:0] ex_rd, 
    input wire ex_valid, 
    // To MEM/WB
    input wire ex_is_cnn, 
    output reg [31:0] mem_wb_val, 
    output reg [4:0] mem_wb_rd, 
    output reg mem_wb_valid, 
    output reg mem_wb_is_cnn) ;
    always
        @(posedge clk or 
            posedge reset)
        begin
            if (reset) 
                begin
                    mem_wb_val <=  32'd0 ;
                    mem_wb_rd <=  5'd0 ;
                    mem_wb_valid <=  1'b0 ;
                    mem_wb_is_cnn <=  1'b0 ;
                end
            else
                begin
                    mem_wb_rd <=  ex_rd ;
                    mem_wb_valid <=  ex_valid ;
                    mem_wb_is_cnn <=  ex_is_cnn ;
                    mem_wb_val <=  ex_val ;
                end
        end
endmodule



