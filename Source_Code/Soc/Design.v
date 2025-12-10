module SoC (
    input wire clk, 
    input wire reset, 
    input wire [31:0] instruction, 
    output reg [3:0] prediction, 
    output reg done, 
    output reg bootloader_start, 
    output reg [11:0] m_axi_awid, 
    output reg m_axi_awvalid, 
    output reg [7:0] m_axi_awlen, 
    output reg [2:0] m_axi_awsize, 
    output reg [1:0] m_axi_awburst, 
    output reg m_axi_awlock, 
    output reg [3:0] m_axi_awcache, 
    output reg [3:0] m_axi_awqos, 
    output reg [63:0] m_axi_awaddr, 
    output reg [2:0] m_axi_awprot, 
    input wire m_axi_awready, 
    output reg m_axi_wvalid, 
    output reg m_axi_wlast, 
    output reg [127:0] m_axi_wdata, 
    output reg [15:0] m_axi_wstrb, 
    input wire m_axi_wready, 
    output reg m_axi_bready, 
    input wire m_axi_bvalid, 
    input wire [11:0] m_axi_bid, 
    input wire [1:0] m_axi_bresp, 
    output reg m_axi_arvalid, 
    output reg [11:0] m_axi_arid, 
    output reg [7:0] m_axi_arlen, 
    output reg [2:0] m_axi_arsize, 
    output reg [1:0] m_axi_arburst, 
    output reg m_axi_arlock, 
    output reg [3:0] m_axi_arcache, 
    output reg [3:0] m_axi_arqos, 
    output reg [63:0] m_axi_araddr, 
    output reg [2:0] m_axi_arprot, 
    input wire m_axi_arready, 
    output reg m_axi_rready, 
    input wire m_axi_rvalid, 
    input wire [11:0] m_axi_rid, 
    input wire m_axi_rlast, 
    input wire [1:0] m_axi_rresp, 
    // master read data is INPUT
    // ===========================================================
    // SLAVE AXI PORTS
    // ===========================================================
    input wire [127:0] m_axi_rdata, 
    input wire [11:0] s_axi_awid, 
    input wire [63:0] s_axi_awaddr, 
    input wire [7:0] s_axi_awlen, 
    input wire [2:0] s_axi_awsize, 
    input wire [1:0] s_axi_awburst, 
    input wire s_axi_awlock, 
    input wire [3:0] s_axi_awcache, 
    input wire [2:0] s_axi_awprot, 
    input wire [3:0] s_axi_awqos, 
    input wire s_axi_awvalid, 
    output reg s_axi_awready, 
    input wire [127:0] s_axi_wdata, 
    input wire [15:0] s_axi_wstrb, 
    input wire s_axi_wlast, 
    input wire s_axi_wvalid, 
    output reg s_axi_wready, 
    input wire s_axi_bready, 
    output reg [11:0] s_axi_bid, 
    output reg [1:0] s_axi_bresp, 
    output reg s_axi_bvalid, 
    input wire [11:0] s_axi_arid, 
    input wire [63:0] s_axi_araddr, 
    input wire [7:0] s_axi_arlen, 
    input wire [2:0] s_axi_arsize, 
    input wire [1:0] s_axi_arburst, 
    input wire s_axi_arlock, 
    input wire [3:0] s_axi_arcache, 
    input wire [2:0] s_axi_arprot, 
    input wire [3:0] s_axi_arqos, 
    input wire s_axi_arvalid, 
    output reg s_axi_arready, 
    input wire s_axi_rready, 
    output reg [11:0] s_axi_rid, 
    output reg [127:0] s_axi_rdata, 
    output reg [1:0] s_axi_rresp, 
    output reg s_axi_rlast, 
    output reg s_axi_rvalid) ;
    always// ===========================================================
// SLAVE SIDE ALWAYS READY
// ===========================================================
        @(*)
        begin
            s_axi_awready = 1'b1 ;
            s_axi_wready = 1'b1 ;
            s_axi_bid = s_axi_awid ;
            s_axi_bresp = 2'b00 ;
            s_axi_bvalid = s_axi_wvalid ;
            s_axi_arready = 1'b1 ;
            s_axi_rid = s_axi_arid ;
            s_axi_rresp = 2'b00 ;
            s_axi_rdata = 128'd0 ;
            s_axi_rlast = 1'b1 ;
            s_axi_rvalid = s_axi_arvalid ;
        end// ===========================================================
// FSM STATES
// ===========================================================
    localparam IDLE = 0, 
        WRITE = 1, 
        READ = 2, 
        DONE = 3 ; 
    reg [1:0] state, 
        next_state ; 
    always
        @(posedge clk or 
            posedge reset)
        begin
            if (reset) 
                state <=  IDLE ;
            else
                state <=  next_state ;
        end
    always
        @(*)
        begin
            next_state = state ;
            case (state)
            IDLE : 
                next_state = WRITE ;
            WRITE : 
                if ((m_axi_awready && m_axi_wready)) 
                    next_state = READ ;
            READ : 
                if (m_axi_rvalid) 
                    next_state = DONE ;
            DONE : 
                next_state = DONE ;
            endcase 
        end// ===========================================================
// MASTER + BOOTLOADER LOGIC
// ===========================================================
    always
        @(posedge clk or 
            posedge reset)
        begin
            if (reset) 
                begin
                    m_axi_awvalid <=  0 ;
                    m_axi_wvalid <=  0 ;
                    m_axi_arvalid <=  0 ;
                    m_axi_bready <=  1 ;
                    m_axi_rready <=  1 ;
                    done <=  0 ;
                    prediction <=  0 ;
                    bootloader_start <=  0 ;// Default constants
                    m_axi_awid <=  0 ;
                    m_axi_awlen <=  0 ;
                    m_axi_awsize <=  3'b010 ;
                    m_axi_awburst <=  2'b01 ;
                    m_axi_awlock <=  0 ;
                    m_axi_awcache <=  4'b0011 ;
                    m_axi_awqos <=  0 ;
                    m_axi_awprot <=  0 ;
                    m_axi_arid <=  0 ;
                    m_axi_arlen <=  0 ;
                    m_axi_arsize <=  3'b010 ;
                    m_axi_arburst <=  2'b01 ;
                    m_axi_arlock <=  0 ;
                    m_axi_arcache <=  4'b0011 ;
                    m_axi_arqos <=  0 ;
                    m_axi_arprot <=  0 ;
                    m_axi_wstrb <=  16'hFFFF ;
                    m_axi_wlast <=  1 ;
                    m_axi_wdata <=  0 ;
                end
            else
                begin
                    case (state)
                    IDLE : 
                        begin
                            done <=  0 ;
                            bootloader_start <=  1 ;
                            m_axi_awaddr <=  64'h0000_0000 ;
                            m_axi_awvalid <=  1 ;
                            m_axi_wdata <=  {96'd0,
                                    instruction} ;
                            m_axi_wvalid <=  1 ;
                        end
                    WRITE : 
                        begin
                            bootloader_start <=  0 ;
                            if (m_axi_awready) 
                                m_axi_awvalid <=  0 ;
                            if (m_axi_wready) 
                                m_axi_wvalid <=  0 ;
                            if ((m_axi_awready && m_axi_wready)) 
                                begin
                                    m_axi_araddr <=  64'h0000_1000 ;
                                    m_axi_arvalid <=  1 ;
                                end
                        end
                    READ : 
                        begin
                            bootloader_start <=  0 ;
                            if (m_axi_arready) 
                                m_axi_arvalid <=  0 ;
                            if (m_axi_rvalid) 
                                prediction <=  m_axi_rdata[3:0] ;
                        end
                    DONE : 
                        begin
                            bootloader_start <=  0 ;
                            done <=  1 ;
                        end
                    endcase 
                end
        end
endmodule



