
module AXI_Interface_Minimal (
    input wire clk, 
    input wire reset, 
    output reg [31:0] instruction, 
    // ===========================================================
    // INPUT FROM PIPELINE
    // ===========================================================
    output reg [127:0] rdata, 
    // ===========================================================
    // INPUTS FROM SOC OUTPUTS (MASTER + SLAVE AXI PORTS)
    // ===========================================================
    input wire [31:0] prediction, 
    input wire [11:0] m_axi_awid, 
    input wire m_axi_awvalid, 
    input wire [7:0] m_axi_awlen, 
    input wire [2:0] m_axi_awsize, 
    input wire [1:0] m_axi_awburst, 
    input wire m_axi_awlock, 
    input wire [3:0] m_axi_awcache, 
    input wire [3:0] m_axi_awqos, 
    input wire [63:0] m_axi_awaddr, 
    input wire [2:0] m_axi_awprot, 
    input wire m_axi_wvalid, 
    input wire m_axi_wlast, 
    input wire [127:0] m_axi_wdata, 
    input wire [15:0] m_axi_wstrb, 
    input wire m_axi_bready, 
    input wire m_axi_arvalid, 
    input wire [11:0] m_axi_arid, 
    input wire [7:0] m_axi_arlen, 
    input wire [2:0] m_axi_arsize, 
    input wire [1:0] m_axi_arburst, 
    input wire m_axi_arlock, 
    input wire [3:0] m_axi_arcache, 
    input wire [3:0] m_axi_arqos, 
    input wire [63:0] m_axi_araddr, 
    input wire [2:0] m_axi_arprot, 
    // ===========================================================
    // SLAVE AXI INPUTS FROM SOC OUTPUTS
    // ===========================================================
    input wire m_axi_rready, 
    input wire s_axi_awready, 
    input wire s_axi_wready, 
    input wire [11:0] s_axi_bid, 
    input wire [1:0] s_axi_bresp, 
    input wire s_axi_bvalid, 
    input wire s_axi_arready, 
    input wire [11:0] s_axi_rid, 
    input wire [127:0] s_axi_rdata, 
    input wire [1:0] s_axi_rresp, 
    input wire s_axi_rlast, 
    input wire s_axi_rvalid) ;
    always// ===========================================================
// EXTRACT INSTRUCTION FROM WDATA
// ===========================================================
        @(posedge clk or 
            posedge reset)
        begin
            if (reset) 
                instruction <=  32'd0 ;
            else
                if ((m_axi_wvalid && m_axi_wlast)) 
                    instruction <=  m_axi_wdata[31:0] ;
        end// ===========================================================
// PACK PREDICTION INTO RDATA (BACK TO SOC)
// ===========================================================
    always
        @(*)
        begin
            rdata = {96'd0,
                    prediction} ;
        end
endmodule



