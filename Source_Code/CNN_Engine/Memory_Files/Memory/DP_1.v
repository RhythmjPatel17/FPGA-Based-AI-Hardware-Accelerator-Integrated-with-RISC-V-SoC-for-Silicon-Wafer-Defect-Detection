
module depthwise_mram #(parameter ADDR_WIDTH = 10, 
        parameter DATA_WIDTH = 32) (
    // 64 KB address space
    input wire clk, 
    // --- Port A (used for writes from convolution output) ---
    input wire resetn, 
    // word address
    input wire [9:0] mram_addr_a, 
    input wire [31:0] mram_din_a, 
    input wire mram_en_a, 
    // --- Port B (used for reads like (read_addr >> 3) * 4) ---
    input wire [3:0] mram_we_a, 
    input wire mram_en_b, 
    // pixel index address
    input wire [31:0] read_addr, 
    output reg [31:0] mram_dout_b) //=========================================================================
// MRAM Module for depthandpointwise_conv2d_112_56_2x_144ch
// - Dual-port: Port A (R/W), Port B (Read-only)
// - Compatible with 32-bit packed feature map access
//=========================================================================
;
    reg [(DATA_WIDTH - 1):0] mram_array [0:((1 << ADDR_WIDTH) - 1)] ; // --- Internal 32-bit memory ---
    reg [31:0] mram_dout ; 
    integer i ; // --- Address alignment logic ---
    wire [(ADDR_WIDTH - 1):0] aligned_addr_b ; 
    assign aligned_addr_b = ((read_addr >> 3) * 4) ; // --- MRAM operations ---
    always
        @(posedge clk or 
            negedge resetn)
        begin
            if ((!resetn)) 
                begin
                    mram_dout <=  32'b0 ;
                    mram_dout_b <=  32'b0 ;
                    for (i = 0 ; (i < (1 << ADDR_WIDTH)) ; i = (i + 1))
                        mram_array[i] <=  32'b0 ;
                end
            else
                begin
                    if (mram_en_a) // --- Port A write / read ---
                        begin
                            if ((|mram_we_a)) 
                                begin
                                    if (mram_we_a[0]) 
                                        mram_array[mram_addr_a][7:0] <=  mram_din_a[7:0] ;
                                    if (mram_we_a[1]) 
                                        mram_array[mram_addr_a][15:8] <=  mram_din_a[15:8] ;
                                    if (mram_we_a[2]) 
                                        mram_array[mram_addr_a][23:16] <=  mram_din_a[23:16] ;
                                    if (mram_we_a[3]) 
                                        mram_array[mram_addr_a][31:24] <=  mram_din_a[31:24] ;
                                end
                            mram_dout <=  mram_array[mram_addr_a] ;
                        end// --- Port B read with address pattern (read_addr >> 3)*4 ---
                    if (mram_en_b) 
                        mram_dout_b <=  mram_array[aligned_addr_b] ;
                end
        end
//=========================================================================
// MRAM Module for depthandpointwise_conv2d_112_56_2x_144ch
// - Dual-port: Port A (R/W), Port B (Read-only)
// - Compatible with 32-bit packed feature map access
//=========================================================================
endmodule



