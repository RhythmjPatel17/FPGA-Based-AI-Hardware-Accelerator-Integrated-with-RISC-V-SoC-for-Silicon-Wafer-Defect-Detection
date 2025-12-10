
module mram_dual_port #(parameter ADDR_WIDTH = 10, 
        parameter DATA_WIDTH = 32) (
    // Supports 1024 addresses (adjustable)
    // Each address stores 8 feature pixels (4 bits each)
    input wire clk, 
    // ---------------------------
    // Port A - Write Interface (From Conv2D Engine)
    // ---------------------------
    input wire resetn, 
    input wire [(ADDR_WIDTH - 1):0] MRAM_PORTA_addr, 
    input wire [(DATA_WIDTH - 1):0] MRAM_PORTA_wdata, 
    input wire MRAM_PORTA_en, 
    input wire [3:0] MRAM_PORTA_we, 
    // ---------------------------
    // Port B - Read Interface (System / Next Layer)
    // ---------------------------
    output reg [(DATA_WIDTH - 1):0] MRAM_PORTA_rdata, 
    input wire [(ADDR_WIDTH - 1):0] MRAM_PORTB_addr, 
    input wire MRAM_PORTB_en, 
    output reg [(DATA_WIDTH - 1):0] MRAM_PORTB_rdata, 
    output reg MRAM_PORTB_rdata_valid) // ============================================================================
// MRAM Dual-Port Memory Module (Fixed Version)
// Synchronous reset included in single always block to avoid multi-driver issue
// ============================================================================
;
    reg [(DATA_WIDTH - 1):0] rom [((1 << ADDR_WIDTH) - 1):0] ; // Internal MRAM storage
    integer i ; // ---------------------------
// Unified Dual-Port + Reset (single always block)
// ---------------------------
    always
        @(posedge clk)
        begin
            if ((!resetn)) 
                begin
                    for (i = 0 ; (i < (1 << ADDR_WIDTH)) ; i = (i + 1))
                        rom[i] <=  {DATA_WIDTH{1'b0}} ;
                    MRAM_PORTA_rdata <=  {DATA_WIDTH{1'b0}} ;
                    MRAM_PORTB_rdata <=  {DATA_WIDTH{1'b0}} ;
                    MRAM_PORTB_rdata_valid <=  1'b0 ;
                end
            else
                begin
                    if (MRAM_PORTA_en) // ========================
// Port A: Write + Readback
// ========================
                        begin
                            if ((|MRAM_PORTA_we)) 
                                begin
                                    if (MRAM_PORTA_we[3]) 
                                        rom[MRAM_PORTA_addr][31:24] <=  MRAM_PORTA_wdata[31:24] ;
                                    if (MRAM_PORTA_we[2]) 
                                        rom[MRAM_PORTA_addr][23:16] <=  MRAM_PORTA_wdata[23:16] ;
                                    if (MRAM_PORTA_we[1]) 
                                        rom[MRAM_PORTA_addr][15:8] <=  MRAM_PORTA_wdata[15:8] ;
                                    if (MRAM_PORTA_we[0]) 
                                        rom[MRAM_PORTA_addr][7:0] <=  MRAM_PORTA_wdata[7:0] ;
                                end
                            MRAM_PORTA_rdata <=  rom[MRAM_PORTA_addr] ;
                        end// ========================
// Port B: Read Only
// ========================
                    if (MRAM_PORTB_en) 
                        begin
                            MRAM_PORTB_rdata <=  rom[MRAM_PORTB_addr] ;
                            MRAM_PORTB_rdata_valid <=  1'b1 ;
                        end
                    else
                        begin
                            MRAM_PORTB_rdata_valid <=  1'b0 ;
                        end
                end
        end
// ============================================================================
// MRAM Dual-Port Memory Module (Fixed Version)
// Synchronous reset included in single always block to avoid multi-driver issue
// ============================================================================
endmodule



