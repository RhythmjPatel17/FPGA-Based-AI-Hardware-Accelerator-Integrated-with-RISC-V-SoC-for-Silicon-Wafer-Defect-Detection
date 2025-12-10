
module mram_model_maxpool (
    input wire clk, 
    // ===== Port A: Write/Read (used by MaxPool write) =====
    input wire resetn, 
    // word address
    input wire [9:0] mram_addr_a, 
    input wire [31:0] mram_din_a, 
    input wire mram_en_a, 
    // ===== Port B: Read only (used for external read) =====
    input wire [3:0] mram_we_a, 
    input wire mram_en_b, 
    // pixel index address (from conv/maxpool)
    input wire [31:0] read_addr, 
    output reg [31:0] mram_dout_b) //=====================================================================
// MRAM model for MaxPool 7x7 stride7 module
// Compatible with exposed BRAM/MRAM ports of maxpool2d module
//=====================================================================
;
    reg [31:0] mem [0:1024] ; // ===========================
// Internal MRAM storage
// ===========================
// 4K words (adjust size as needed)
    integer i ; 
    reg [31:0] mram_dout_a ; // Port B address alignment
    wire [11:0] aligned_addr_b ; 
    assign aligned_addr_b = ((read_addr >> 3) * 4) ; // ===========================
// Unified Sequential Logic
// ===========================
    always
        @(posedge clk or 
            negedge resetn)
        begin
            if ((!resetn)) 
                begin
                    for (i = 0 ; (i < 1024) ; i = (i + 1))
                        mem[i] <=  32'd0 ;
                    mram_dout_a <=  32'd0 ;
                    mram_dout_b <=  32'd0 ;
                end
            else
                begin
                    if ((mram_en_a && (|mram_we_a))) // ---- Port A: Write ----
                        begin
                            if (mram_we_a[3]) 
                                mem[mram_addr_a][31:24] <=  mram_din_a[31:24] ;
                            if (mram_we_a[2]) 
                                mem[mram_addr_a][23:16] <=  mram_din_a[23:16] ;
                            if (mram_we_a[1]) 
                                mem[mram_addr_a][15:8] <=  mram_din_a[15:8] ;
                            if (mram_we_a[0]) 
                                mem[mram_addr_a][7:0] <=  mram_din_a[7:0] ;
                        end// ---- Port A Read ----
                    if (mram_en_a) // ---- Port B Read ----
// Port A has higher priority
                        mram_dout_a <=  mem[mram_addr_a] ;
                    if (mram_en_a) // hold previous value
                        mram_dout_b <=  mram_dout_a ;
                    else
                        if (mram_en_b) 
                            mram_dout_b <=  mem[aligned_addr_b] ;
                        else
                            mram_dout_b <=  mram_dout_b ;
                end
        end
//=====================================================================
// MRAM model for MaxPool 7x7 stride7 module
// Compatible with exposed BRAM/MRAM ports of maxpool2d module
//=====================================================================
endmodule



