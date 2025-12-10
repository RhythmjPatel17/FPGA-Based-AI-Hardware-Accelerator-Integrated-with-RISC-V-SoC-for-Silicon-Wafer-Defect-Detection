
module spi_loader_spram # (parameter idw = 3, 
                                     FLASH_START_ADDR = 24'h300000,
                                     FLASH_END_ADDR   = 24'h400000)     //Write Data till (END_ADDR-1) Addr
(
input		resetn      , // 
input           clk         , // Clock (= RISC-V clock)
input           i_init      ,
input    [7:0]  i_burst_lmt , // max burst (burst_lmt + 1 beat)

output reg      SPI_CSS     , // SPI I/F for flash access
output reg      SPI_CLK     , // 
input           SPI_MISO    , // 
output reg      SPI_MOSI    , // 

output reg      o_load_done ,

// AXI4 Master port
// Write Address Channel
input             ACLK        ,
input             ARESETn     ,
output    [idw:0] AWID        ,
output reg [31:0] AWADDR      ,
output      [3:0] AWREGION    ,
output      [7:0] AWLEN       ,
output      [2:0] AWSIZE      ,
output      [1:0] AWBURST     ,
output            AWLOCK      ,
output      [3:0] AWCACHE     ,
output      [2:0] AWPROT      ,
output      [3:0] AWQOS       ,
output  reg       AWVALID     ,
input             AWREADY     ,
// Write Channel
output    [idw:0] WID         ,
output reg [63:0] WDATA       ,
output      [7:0] WSTRB       ,
output  reg       WLAST       ,
output  reg       WVALID      ,
input             WREADY      ,
// Write Response Channel
input     [idw:0] BID         ,
input       [1:0] BRESP       ,
input             BVALID      ,
output            BREADY 
);
    //================================================================================
    // Parameters
    //================================================================================
    parameter DUMMY_CYCLE  = 9'd7;
    parameter QUAD_SPRAM   = 1'b0;
    parameter IDLE         =  4'd0,         // SPI access FSM
              PREP         =  4'd1,         //
              CMD          =  4'd2,         //
	      SADDR        =  4'd3,         //
	      DUMMY        =  4'd4,         //
	      RDBYTE       =  4'd5,         //
              CHECK        =  4'd6,         // 
              TRANS        =  4'd7,         // 
              NEXT         =  4'd8,         // 
	      WAIT         =  4'd9,         //
	      WAIT10       =  4'd10;        // 10us wait for wake up from power down
    parameter NO_SCK       =  1'b1,         // OR mask for SCK
              ON_SCK       =  1'b0;         //
    parameter FAST_RD      =  8'h0b,        // Fast read flash command
              RLS_DPD      =  8'hab;        // Release from deep power-down

    reg        r_init;
    reg        prom_wr_en; // - IROM (PROM) write strobe
    reg [31:0] rom_data;   // 

    //================================================================================
    // Internal signals
    //================================================================================
    reg  [3  : 0] cst, nst;
    reg  [8 : 0] cnt;
    reg  [4  : 0] bit_cnt;  // Accumulate 32b of data
    reg	 [15 : 0] wd_cnt;
    reg           en;
    reg           phase;

//    reg     [3:0] blank_cnt;
//    reg           blank_flag;
    reg           do_trans_clk;
    reg     [1:0] do_trans_aclk;
    reg           trans_done_clk;
    reg           trans_done_aclk;
    reg	   [23:0] addr;

    wire   [31:0] fifo_in   ;
    wire          fifo_wr   ;
    wire          fifo_rd   ;
    reg	          fifo_vld  ;
    wire   [63:0] fifo_out  ;
    wire          fifo_full ;
    wire          fifo_afull;
    wire          fifo_empty;
    wire    [8:0] fifo_rdcnt;
    reg	   [15:0] wcnt;
    
    reg	          running;
    reg	          wait_write;
    wire          data_rdy;
    reg	          cmd_accepted;

    always @(posedge clk or negedge resetn)
        if(!resetn) 
	    r_init <= 1'b0;
	else
	    r_init <= i_init;

    //================================================================================
    // Toggling "en" to make two cycle per state FSM
    // - FSM moves to next state if "en=1"
    //================================================================================
    always @(posedge clk or negedge resetn)
        if(!resetn) 
	    en <= 1'b0;
	else
	    en <= ~en;

    //================================================================================
    // Flash access FSM
    // - 9 cycles of dummy (not 8) for fast reading
    //================================================================================
    always @(posedge clk or negedge resetn)
        if     (!resetn      ) phase <= 1'b0; // Wake up phase
	else if(cst == WAIT10) phase <= 1'b1; // Read    phase

    always @(posedge clk or negedge resetn)
        if     (!resetn) 
	    cst <= IDLE;
	else if(en)
	    cst <= nst;

    always @(*)
        case(cst)
	IDLE   : nst = r_init ? PREP : IDLE;
	PREP   : nst =           CMD;
	CMD    : nst =  |cnt   ? CMD    : 
	                 phase ? SADDR  : WAIT10;
	SADDR  : nst = ~|cnt   ? DUMMY  : SADDR;
	DUMMY  : nst = ~|cnt   ? RDBYTE : DUMMY;
	RDBYTE : nst = (wd_cnt == 16'd128) ? CHECK : RDBYTE;
	CHECK  : nst = TRANS;
	TRANS  : nst = (trans_done_clk) ? NEXT : TRANS;
	NEXT   : nst = (addr == (FLASH_END_ADDR - 24'd512)) ? WAIT : PREP;
	WAIT   : nst = r_init  ? WAIT : IDLE;
	WAIT10 : nst =  |cnt   ? WAIT10 : IDLE   ;
	default: nst =           PREP;
	endcase

    always @(posedge clk) // or negedge resetn)
//        if(!resetn) cnt <= 20'b0;
//	else 
	if(en)
	    case(cst)
	    IDLE   : cnt <=                  9'd00;         //  
	    PREP   : cnt <=                  9'd07;         //  8 bits  of CMD
	    CMD    : cnt <= |cnt   ? cnt - 9'd1 : 
	                     phase ? 9'd23  :               // 24 bits  of Start Address
			             9'd500  ;               // 10us+ delay after power up    
	    SADDR  : cnt <= |cnt   ? cnt - 9'd1 : DUMMY_CYCLE;  //  m bits  of DUMMY
	    DUMMY  : cnt <= |cnt   ? cnt - 9'd1 : 9'd0;  //  n bytes of data
	    RDBYTE : cnt <=                    9'd0;
	    WAIT   : cnt <=                    9'd0;
	    default: cnt <= |cnt   ? cnt - 9'd1 : 9'd0;
	    endcase

    //================================================================================
    // SPI signal generation 
    // - SPI_CSS is the CS_B
    //================================================================================
    always @(posedge clk or negedge resetn)
        if(!resetn) {SPI_CSS, SPI_MOSI} <= {1'b1, 1'b1};
	else if(en )
	    case(cst)
	    IDLE   : begin
		    SPI_CSS  <= 1'b0; 
		    SPI_MOSI  <= 1'b1;
		end
	    PREP   : begin
		    SPI_CSS  <= 1'b0;
		    SPI_MOSI  <= phase ? FAST_RD[7] : RLS_DPD[7];
		end
	    CMD    : if(|cnt) begin // Command
		    SPI_CSS  <= 1'b0; 
		    SPI_MOSI  <= phase ? FAST_RD[cnt-1] : RLS_DPD[cnt-1];
		end else begin      // S-Addr
		    SPI_CSS  <= phase ? 1'b0        : 1'b1; 
		    SPI_MOSI  <= phase ? addr[23] : 1'b1;
		end
	    SADDR  : if(|cnt) begin // S-Addr
		    SPI_CSS  <= 1'b0;
		    SPI_MOSI  <= addr[cnt-1];
		end else begin      // Dummy
		    SPI_CSS  <= 1'b0; 
		    SPI_MOSI  <= 1'b1; // Dummy
		end
	    DUMMY  : if(|cnt) begin // Dummy
		    SPI_CSS  <= 1'b0;
		    SPI_MOSI  <= 1'b1;
		end else begin      // Read byte
		    SPI_CSS  <= 1'b0; 
		    SPI_MOSI  <= 1'b1; // Don't care
		end
	    RDBYTE : if(r_init) begin // Read byte
		    SPI_CSS  <= 1'b0;
		    SPI_MOSI  <= 1'b1;
		end else begin   
		    SPI_CSS  <= 1'b1;
		    SPI_MOSI  <= 1'b1;
		end
	    WAIT   : {SPI_CSS, SPI_MOSI} <= {1'b1, 1'b1};
	    default: {SPI_CSS, SPI_MOSI} <= {1'b1, 1'b1};
	    endcase

    always @(posedge clk)// or negedge resetn)
        //if(!resetn) SPI_CLK <= 1'b1;
	//else 
	    case(cst)
		PREP, SADDR, DUMMY  : SPI_CLK <= ~en;
		CMD                 : SPI_CLK <= phase || |cnt ? ~en : 1'b1;
		RDBYTE              : SPI_CLK <= (r_init) ? ~en : 1'b1;
		default             : SPI_CLK <= 1'b1;
		endcase

    //================================================================================
    // SPSRAM access (write) FSM
    // - Direct access using rom_acc, prom_wr_en, and rom_data (32b)
    // - If rom_acc & prom_wr_en, rom_data is written to SPSRAM at every cycle w/
    //   auto increased address
    //================================================================================
    always @(posedge clk or negedge resetn)
        if(!resetn) begin
	    bit_cnt    <= 5'd31;
	    prom_wr_en <=  1'b0;
	    rom_data   <= 32'b0;
        end else if(cst == RDBYTE) begin
          if(!en) begin
	    bit_cnt    <= bit_cnt - 5'd1;
	    prom_wr_en <= (~|bit_cnt); 
	    rom_data   <= {rom_data[30 : 0], SPI_MISO};
          end else begin
	    prom_wr_en <=  1'b0;
          end
	end
        else begin
	    bit_cnt    <= 5'd31;
	    prom_wr_en <=  1'b0;
	    rom_data   <= 32'b0;
        end

    always @(posedge clk or negedge resetn)
        if(!resetn)
	    wd_cnt  <= 16'b0;
	else if(!r_init || (cst == PREP))
	    wd_cnt  <= 16'b0;
	else if(prom_wr_en)
	    wd_cnt  <= wd_cnt + 16'd1;

    always @(posedge clk or negedge resetn)
        if(!resetn)
	    o_load_done <= 1'b0;
	else if(!r_init)
	    o_load_done <= 1'b0;
	else
	    o_load_done <= (cst == WAIT);

//always @(posedge clk or negedge resetn)
//begin
//    if(resetn == 1'b0)
//	blank_flag <= 1'b0;
//    else if(cst == DUMMY)
//	blank_flag <= 1'b1;
//    else if((prom_wr_en == 1'b1) && (rom_data != 32'b0))
//	blank_flag <= 1'b0;
//end
//
//always @(posedge clk or negedge resetn)
//begin
//    if(resetn == 1'b0)
//	blank_cnt <= 4'b0;
//    else if(cst == IDLE)
//	blank_cnt <= 4'b0;
//    else if((cst == CHECK) && en)
//	blank_cnt <= blank_flag ? (blank_cnt + 4'd1) : 4'd0;
//end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	addr <= 24'b0;
    else if(cst == IDLE)
	addr <= FLASH_START_ADDR;
    else if((cst == NEXT) && en)
	addr <= addr + 24'd512;
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	do_trans_clk <= 1'b0;
    else 
	do_trans_clk <= (cst == TRANS);
end

always @(posedge clk or negedge resetn)
begin
    if(resetn == 1'b0)
	trans_done_clk <= 1'b0;
    else 
	trans_done_clk <= trans_done_aclk;
end

// Write BUS FIFO 
fifo_32in_64out_level u_fifo_32in_64out_level (
    .rst_i         (!resetn   ),
    .rp_rst_i      (!resetn   ),
    .wr_clk_i      (clk       ),
    .rd_clk_i      (ACLK      ),
    .wr_data_i     (fifo_in   ),
    .wr_en_i       (fifo_wr   ),
    .rd_en_i       (fifo_rd   ),
    .rd_data_o     (fifo_out  ),
    .full_o        (fifo_full ),
    .empty_o       (fifo_empty),
    .rd_data_cnt_o (fifo_rdcnt)
);

assign fifo_in = {rom_data[7:0], rom_data[15:8], rom_data[23:16], rom_data[31:24]};
assign fifo_wr = prom_wr_en;

// AXI BUS
//
// Write bus constant
assign AWID     = 0;
assign WID      = 0;
assign AWREGION = 4'b0;
assign AWPROT   = 3'b0;
assign AWQOS    = 4'b0;
assign AWSIZE   = 3'b011; // 64 bits
assign AWLOC    = 2'b0;
assign AWBURST  = 2'b01; // increment
assign AWCACHE  = 4'b0;
assign WSTRB    = 8'hff;
assign BREADY   = 1'b1;   // ignore B channel

assign WLEN     = 8'd63;

always @(posedge ACLK or negedge ARESETn)
begin
    if(ARESETn == 1'b0)
	do_trans_aclk <= 2'b0;
    else
	do_trans_aclk <= {do_trans_aclk[0], do_trans_clk};
end

always @(posedge ACLK or negedge ARESETn)
begin
    if(ARESETn == 1'b0) 
	running <= 1'b0;
    else if(do_trans_aclk == 2'b01)
	running <= 1'b1;
    else if((WLAST & WVALID & WREADY) && (fifo_empty))
	running <= 1'b0;
end

assign data_rdy = (fifo_rdcnt > {1'b0, i_burst_lmt}) || (fifo_rdcnt != 9'd0);

always @(posedge ACLK or negedge ARESETn)
begin
    if(ARESETn == 1'b0)         
	AWADDR <= 32'b0;
    else if(do_trans_aclk == 2'b01)
	AWADDR <= {4'd0,{(addr - FLASH_START_ADDR)}};             //Start from 0th address in HRAM
    else if(AWVALID & AWREADY)
	AWADDR <= AWADDR + {21'b0, AWLEN, 3'b0} + 32'h08;
end

always @(posedge ACLK or negedge ARESETn)
begin
    if(ARESETn == 1'b0)         
	AWVALID <= 1'b0;
    else if(running & data_rdy & (!wait_write))
	AWVALID <= 1'b1;
    else if(AWREADY) 
	AWVALID <= 1'b0;
end

always @(posedge ACLK or negedge ARESETn)
begin
    if(ARESETn == 1'b0)         
	wait_write <= 1'b0;
    else if(running & data_rdy & (!wait_write))
	wait_write <= 1'b1;
    else if(WLAST & WVALID & WREADY)
	wait_write <= 1'b0;
end

assign AWLEN = i_burst_lmt;

always @(posedge ACLK or negedge ARESETn)
begin
    if(ARESETn == 1'b0)         
	wcnt <= 16'b0;
    else if(AWVALID && AWREADY)
	wcnt <= {8'b0, AWLEN};
    else if((wcnt > 0) & WVALID & WREADY)
	wcnt <= wcnt - 16'd1;
end

always @(posedge ACLK or negedge ARESETn)
begin
    if(ARESETn == 1'b0)         
	cmd_accepted <= 1'b0;
    else if(AWVALID & AWREADY)
	cmd_accepted <= 1'b1;
    else if(((wcnt == 16'd1) & WVALID & WREADY) || ((wcnt == 16'd0) & WVALID & (WREADY == 1'b0)))
	cmd_accepted <= 1'b0;
end

always @(posedge ACLK or negedge ARESETn)
begin
    if(ARESETn == 1'b0)         
	fifo_vld <= 1'b0;
    else if(fifo_rd)
	fifo_vld <= !fifo_empty;
end

assign fifo_rd = (((!fifo_empty) & (!fifo_vld)) || 
                  (fifo_vld && (!WVALID))       || 
		  (WVALID & WREADY))             & wait_write & cmd_accepted; //& (!WLAST)

always @(posedge ACLK)
begin
    if(fifo_rd)
	WDATA <= fifo_out;
end

always @(posedge ACLK or negedge ARESETn)
begin
    if(ARESETn == 1'b0)         
	WLAST <= 1'b0;
    else if(wait_write == 1'b0)
	WLAST <= 1'b0;
    else if((wcnt == 16'd1) & WVALID & WREADY)
	WLAST <= 1'b1;
    else if((wcnt == 16'd0) & WVALID & (WREADY == 1'b0))
	WLAST <= 1'b1;
    else
	WLAST <= 1'b0;
end

always @(posedge ACLK or negedge ARESETn)
begin
    if(ARESETn == 1'b0)         
	WVALID <= 1'b0;
    else if(fifo_rd) 
	WVALID <= fifo_vld;
    else if(WREADY)
	WVALID <= 1'b0;
end

always @(posedge ACLK or negedge ARESETn)
begin
    if(ARESETn == 1'b0)         
	trans_done_aclk <= 1'b0;
    else if(do_trans_aclk[0] == 1'b0)
	trans_done_aclk <= 1'b0;
    else if(fifo_empty)
	trans_done_aclk <= 1'b1;
end

endmodule
//================================================================================
// End of file
//================================================================================

// vim: ts=8 sw=4
