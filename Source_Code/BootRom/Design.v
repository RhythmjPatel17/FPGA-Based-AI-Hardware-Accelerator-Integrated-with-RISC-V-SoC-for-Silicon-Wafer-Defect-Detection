
module Bootloader_ROM (
    input wire clk, 
    input wire reset, 
    // ===========================================================
    // MASTER AXI RESPONSE SIGNALS (SOC INPUTS ? NOW OUTPUTS)
    // ===========================================================
    input wire bootloader_start, 
    output reg m_axi_awready, 
    output reg m_axi_wready, 
    output reg m_axi_bvalid, 
    output reg [11:0] m_axi_bid, 
    output reg [1:0] m_axi_bresp, 
    output reg m_axi_arready, 
    output reg m_axi_rvalid, 
    output reg [11:0] m_axi_rid, 
    output reg m_axi_rlast, 
    // ===========================================================
    // SLAVE AXI WRITE ADDRESS CHANNEL (SOC INPUTS ? OUTPUTS)
    // ===========================================================
    output reg [1:0] m_axi_rresp, 
    output reg [11:0] s_axi_awid, 
    output reg [63:0] s_axi_awaddr, 
    output reg [7:0] s_axi_awlen, 
    output reg [2:0] s_axi_awsize, 
    output reg [1:0] s_axi_awburst, 
    output reg s_axi_awlock, 
    output reg [3:0] s_axi_awcache, 
    output reg [2:0] s_axi_awprot, 
    output reg [3:0] s_axi_awqos, 
    // ===========================================================
    // SLAVE AXI WRITE DATA CHANNEL
    // ===========================================================
    output reg s_axi_awvalid, 
    output reg [127:0] s_axi_wdata, 
    output reg [15:0] s_axi_wstrb, 
    output reg s_axi_wlast, 
    // ===========================================================
    // SLAVE AXI WRITE RESPONSE CHANNEL
    // ===========================================================
    output reg s_axi_wvalid, 
    // ===========================================================
    // SLAVE AXI READ ADDRESS CHANNEL
    // ===========================================================
    output reg s_axi_bready, 
    output reg [11:0] s_axi_arid, 
    output reg [63:0] s_axi_araddr, 
    output reg [7:0] s_axi_arlen, 
    output reg [2:0] s_axi_arsize, 
    output reg [1:0] s_axi_arburst, 
    output reg s_axi_arlock, 
    output reg [3:0] s_axi_arcache, 
    output reg [2:0] s_axi_arprot, 
    output reg [3:0] s_axi_arqos, 
    // ===========================================================
    // SLAVE AXI READ DATA CHANNEL
    // ===========================================================
    output reg s_axi_arvalid, 
    output reg s_axi_rready) ;
    always// ===========================================================
// ALWAYS DRIVING DUMMY SAFE VALUES
// ===========================================================
        @(*)
        begin
            m_axi_awready = 1'b1 ;// MASTER SIDE RESPONSES (SOC behaves as master)
            m_axi_wready = 1'b1 ;
            m_axi_bvalid = 1'b1 ;
            m_axi_bresp = 2'b00 ;
            m_axi_bid = 12'd0 ;
            m_axi_arready = 1'b1 ;
            m_axi_rvalid = 1'b1 ;
            m_axi_rresp = 2'b00 ;
            m_axi_rlast = 1'b1 ;
            m_axi_rid = 12'd0 ;// =====================================================
// SLAVE SIDE INPUTS (SOC behaves as slave)
// Drive them as harmless defaults
// =====================================================
            s_axi_awid = 12'd0 ;
            s_axi_awaddr = 64'd0 ;
            s_axi_awlen = 8'd0 ;
            s_axi_awsize = 3'd0 ;
            s_axi_awburst = 2'd0 ;
            s_axi_awlock = 1'b0 ;
            s_axi_awcache = 4'd0 ;
            s_axi_awprot = 3'd0 ;
            s_axi_awqos = 4'd0 ;
            s_axi_awvalid = 1'b0 ;
            s_axi_wdata = 128'd0 ;
            s_axi_wstrb = 16'd0 ;
            s_axi_wlast = 1'b0 ;
            s_axi_wvalid = 1'b0 ;
            s_axi_bready = 1'b1 ;
            s_axi_arid = 12'd0 ;
            s_axi_araddr = 64'd0 ;
            s_axi_arlen = 8'd0 ;
            s_axi_arsize = 3'd0 ;
            s_axi_arburst = 2'd0 ;
            s_axi_arlock = 1'b0 ;
            s_axi_arcache = 4'd0 ;
            s_axi_arprot = 3'd0 ;
            s_axi_arqos = 4'd0 ;
            s_axi_arvalid = 1'b0 ;
            s_axi_rready = 1'b1 ;
        end
endmodule



