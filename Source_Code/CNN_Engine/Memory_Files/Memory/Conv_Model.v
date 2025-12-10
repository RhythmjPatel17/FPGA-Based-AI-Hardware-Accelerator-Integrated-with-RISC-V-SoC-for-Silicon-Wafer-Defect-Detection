
module mram_conv_model #(parameter ADDR_WIDTH = 10, 
        parameter DATA_WIDTH = 32) (
    input wire clk, 
    // =========================
    // Port A: Write/Read (from Conv2D / MaxPool)
    // =========================
    input wire resetn, 
    input wire [(ADDR_WIDTH - 1):0] mram_addr_a, 
    input wire [(DATA_WIDTH - 1):0] mram_din_a, 
    input wire mram_en_a, 
    input wire [3:0] mram_we_a, 
    // =========================
    // Port B: Read only (aligned address)
    // =========================
    output reg [(DATA_WIDTH - 1):0] mram_dout_a, 
    input wire mram_en_b, 
    input wire [31:0] read_addr_b, 
    output reg [(DATA_WIDTH - 1):0] mram_dout_b)  /* verific ram_style="block" */ ;
    reg [(DATA_WIDTH - 1):0] mram_mem [0:((1 << ADDR_WIDTH) - 1)] ; // =========================
// Internal MRAM storage
// =========================
    integer i ; // Aligned address for Port B
    wire [(ADDR_WIDTH - 1):0] aligned_addr_b ; 
    assign aligned_addr_b = ((read_addr_b >> 3) * 4) ; // =========================
// Port A: Write / Read + Reset
// =========================
    always
        @(posedge clk or 
            negedge resetn)
        begin
            if ((!resetn)) 
                begin
                    mram_dout_a <=  {DATA_WIDTH{1'b0}} ;
                    for (i = 0 ; (i < (1 << ADDR_WIDTH)) ; i = (i + 1))
                        mram_mem[i] <=  {DATA_WIDTH{1'b0}} ;
                end
            else
                if (mram_en_a) 
                    begin
                        if ((|mram_we_a)) // Write operation (byte-enable)
                            begin
                                if (mram_we_a[3]) 
                                    mram_mem[mram_addr_a][31:24] <=  mram_din_a[31:24] ;
                                if (mram_we_a[2]) 
                                    mram_mem[mram_addr_a][23:16] <=  mram_din_a[23:16] ;
                                if (mram_we_a[1]) 
                                    mram_mem[mram_addr_a][15:8] <=  mram_din_a[15:8] ;
                                if (mram_we_a[0]) 
                                    mram_mem[mram_addr_a][7:0] <=  mram_din_a[7:0] ;
                            end// Read-after-write behavior
                        mram_dout_a <=  mram_mem[mram_addr_a] ;
                    end
        end// =========================
// Port B: Read Only (Aligned)
// =========================
    always
        @(posedge clk or 
            negedge resetn)
        begin
            if ((!resetn)) 
                begin
                    mram_dout_b <=  {DATA_WIDTH{1'b0}} ;
                end
            else
                if (mram_en_b) 
                    begin
                        mram_dout_b <=  mram_mem[aligned_addr_b] ;
                    end
        end
endmodule



