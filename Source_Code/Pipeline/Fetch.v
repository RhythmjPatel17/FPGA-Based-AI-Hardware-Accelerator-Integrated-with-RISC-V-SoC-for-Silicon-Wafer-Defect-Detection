
module fetch_stage (
    input wire clk, 
    input wire reset, 
    // instruction from memory
    // Outputs to CPU pipeline
    input wire [31:0] instr_from_mem, 
    // add this
    output reg [31:0] fetch_instr, 
    output reg fetch_valid) ;
    always
        @(posedge clk or 
            posedge reset)
        begin
            if (reset) 
                begin
                    fetch_instr <=  32'd0 ;
                    fetch_valid <=  1'b0 ;
                end
            else
                begin
                    fetch_instr <=  instr_from_mem ;// latch input instruction
                    fetch_valid <=  1'b1 ;
                end
        end
endmodule



