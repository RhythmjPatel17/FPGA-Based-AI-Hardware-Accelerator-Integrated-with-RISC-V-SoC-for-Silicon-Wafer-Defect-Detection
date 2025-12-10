
module writeback_stage (
    input wire clk, 
    // Inputs from MEM stage
    input wire reset, 
    input wire [31:0] mem_val, 
    input wire [4:0] mem_rd, 
    input wire mem_valid, 
    // Output to register file
    input wire mem_is_cnn, 
    output reg wb_valid) ;
    always// Latch MEM/WB pipeline outputs
        @(posedge clk or 
            posedge reset)
        begin
            if (reset) 
                begin
                    wb_valid <=  1'b0 ;
                end
            else
                begin
                    wb_valid <=  mem_valid ;// enable write to register file
                end
        end
endmodule



