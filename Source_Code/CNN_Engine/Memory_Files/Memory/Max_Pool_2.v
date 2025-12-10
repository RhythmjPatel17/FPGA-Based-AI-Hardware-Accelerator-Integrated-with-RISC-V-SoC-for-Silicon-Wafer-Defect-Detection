
module mram_model_max_pool_2 (
    input wire clk, 
    // ===== Port A: Write/Read (used by MaxPool / Conv Output) =====
    input wire resetn, 
    // word address
    input wire [9:0] mram_addr_a, 
    input wire [31:0] mram_din_a, 
    input wire mram_en_a, 
    input wire [3:0] mram_we_a, 
    // ===== Port B: Read only (used for external read) =====
    output reg [31:0] mram_dout, 
    input wire mram_en_b, 
    input wire [31:0] // pixel index address (from conv)
        read_addr) ;
    reg [31:0] mram_mem [0:((1 << 10) - 1)] ; // ===========================
// Internal MRAM storage
// ===========================
    integer i ; // Address alignment for Port B
    wire [11:0] aligned_addr_b ; 
    assign aligned_addr_b = ((read_addr >> 3) * 4) ; // ===========================
// Unified Sequential Block
// ===========================
    always
        @(posedge clk or 
            negedge resetn)
        begin
            if ((!resetn)) 
                begin
                    for (i = 0 ; (i < (1 << 10)) ; i = (i + 1))
                        mram_mem[i] <=  32'd0 ;
                    mram_dout <=  32'd0 ;
                end
            else
                begin
                    if ((mram_en_a && (|mram_we_a))) // ---- Port A: Write ----
                        begin
                            if (mram_we_a[3]) 
                                mram_mem[mram_addr_a][31:24] <=  mram_din_a[31:24] ;
                            if (mram_we_a[2]) 
                                mram_mem[mram_addr_a][23:16] <=  mram_din_a[23:16] ;
                            if (mram_we_a[1]) 
                                mram_mem[mram_addr_a][15:8] <=  mram_din_a[15:8] ;
                            if (mram_we_a[0]) 
                                mram_mem[mram_addr_a][7:0] <=  mram_din_a[7:0] ;
                        end// ---- Port Priority ----
// Port A read has higher priority than Port B
                    if (mram_en_a) // hold last value
                        mram_dout <=  mram_mem[mram_addr_a] ;
                    else
                        if (mram_en_b) 
                            mram_dout <=  mram_mem[aligned_addr_b] ;
                        else
                            mram_dout <=  mram_dout ;
                end
        end
endmodule



