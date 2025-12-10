
module pipeline_cpu (
    input wire clk, 
    // -------------------------
    // FETCH -> IF/ID (inputs)
    // -------------------------
    input wire reset, 
    input wire [31:0] fetch_instr, 
    // -------------------------
    // DECODE -> ID/EX (inputs from external decode stage)
    // -------------------------
    // decoded instruction and operand values
    input wire fetch_valid, 
    // decode_stage.instr_out
    input wire [31:0] id_instr, 
    // decode_stage.rs1_data_out (from regfile)
    input wire [31:0] id_rs1_data, 
    // decode_stage.rs2_data_out (from regfile)
    input wire [31:0] id_rs2_data, 
    // decode_stage.rd_out
    input wire [4:0] id_rd, 
    // decode_stage.rd_valid_out
    input wire id_rd_valid, 
    // decode_stage.is_accel_out
    input wire id_is_accel, 
    // decode_stage.rs1_out (reg index)
    input wire [4:0] id_rs1, 
    // decode_stage.rs2_out (reg index)
    input wire [4:0] id_rs2, 
    // decode_stage.imm_out
    // -------------------------
    // EXTERNAL EX -> EX/MEM (inputs)
    // -------------------------
    input wire [31:0] id_imm, 
    input wire [31:0] ex_val, 
    input wire [31:0] ex_rs2, 
    input wire [4:0] ex_rd, 
    input wire ex_valid, 
    // -------------------------
    // EXTERNAL MEM -> MEM/WB (inputs)
    // -------------------------
    input wire ex_is_cnn, 
    input wire [31:0] mem_val, 
    input wire [4:0] mem_rd, 
    input wire mem_valid, 
    // -------------------------
    // OUTPUTS
    // -------------------------
    input wire mem_is_cnn, 
    // final writeback value (mem_wb_val)
    // Expose pipeline registers (so external modules can be wired)
    // IF/ID
    output wire [31:0] result, 
    output reg [31:0] if_id_instr, 
    // ID/EX
    output reg if_id_valid, 
    output reg [31:0] id_ex_instr, 
    output reg [31:0] id_ex_rs1, 
    output reg [31:0] id_ex_rs2, 
    output reg [4:0] id_ex_rd, 
    output reg id_ex_rd_valid, 
    output reg id_ex_is_accel, 
    output reg [4:0] id_ex_rs1_idx, 
    output reg [4:0] id_ex_rs2_idx, 
    // EX/MEM
    output reg [31:0] id_ex_imm, 
    output reg [31:0] ex_mem_val, 
    output reg [31:0] ex_mem_rs2, 
    output reg [4:0] ex_mem_rd, 
    output reg ex_mem_valid, 
    // MEM/WB
    output reg ex_mem_is_cnn, 
    output reg [31:0] mem_wb_val, 
    output reg [4:0] mem_wb_rd, 
    output reg mem_wb_valid, 
    output reg mem_wb_is_cnn) ;
    always// ------------------------------------------------------------------
// IF -> ID pipeline register
// ------------------------------------------------------------------
        @(posedge clk or 
            posedge reset)
        begin
            if (reset) 
                begin
                    if_id_instr <=  32'd0 ;
                    if_id_valid <=  1'b0 ;
                end
            else
                begin
                    if_id_instr <=  fetch_instr ;
                    if_id_valid <=  fetch_valid ;
                end
        end// ------------------------------------------------------------------
// ID -> EX pipeline register (latch outputs from external decode)
// ------------------------------------------------------------------
    always
        @(posedge clk or 
            posedge reset)
        begin
            if (reset) 
                begin
                    id_ex_instr <=  32'd0 ;
                    id_ex_rs1 <=  32'd0 ;
                    id_ex_rs2 <=  32'd0 ;
                    id_ex_rd <=  5'd0 ;
                    id_ex_rd_valid <=  1'b0 ;
                    id_ex_is_accel <=  1'b0 ;
                    id_ex_rs1_idx <=  5'd0 ;
                    id_ex_rs2_idx <=  5'd0 ;
                    id_ex_imm <=  32'd0 ;
                end
            else
                begin
                    id_ex_instr <=  id_instr ;// decode_stage.instr_out
                    id_ex_rs1 <=  id_rs1_data ;// register file read
                    id_ex_rs2 <=  id_rs2_data ;
                    id_ex_rd <=  id_rd ;
                    id_ex_rd_valid <=  id_rd_valid ;
                    id_ex_is_accel <=  id_is_accel ;
                    id_ex_rs1_idx <=  id_rs1 ;
                    id_ex_rs2_idx <=  id_rs2 ;
                    id_ex_imm <=  id_imm ;
                end
        end// ------------------------------------------------------------------
// EX -> MEM pipeline register (latch outputs from external EX stage)
// ------------------------------------------------------------------
    always
        @(posedge clk or 
            posedge reset)
        begin
            if (reset) 
                begin
                    ex_mem_val <=  32'd0 ;
                    ex_mem_rs2 <=  32'd0 ;
                    ex_mem_rd <=  5'd0 ;
                    ex_mem_valid <=  1'b0 ;
                    ex_mem_is_cnn <=  1'b0 ;
                end
            else
                begin
                    ex_mem_val <=  ex_val ;
                    ex_mem_rs2 <=  ex_rs2 ;
                    ex_mem_rd <=  ex_rd ;
                    ex_mem_valid <=  ex_valid ;
                    ex_mem_is_cnn <=  ex_is_cnn ;
                end
        end// ------------------------------------------------------------------
// MEM -> WB pipeline register (latch outputs from external MEM stage)
// ------------------------------------------------------------------
    always
        @(posedge clk or 
            posedge reset)
        begin
            if (reset) 
                begin
                    mem_wb_val <=  32'd0 ;
                    mem_wb_rd <=  5'd0 ;
                    mem_wb_valid <=  1'b0 ;
                    mem_wb_is_cnn <=  1'b0 ;
                end
            else
                begin
                    mem_wb_val <=  mem_val ;
                    mem_wb_rd <=  mem_rd ;
                    mem_wb_valid <=  mem_valid ;
                    mem_wb_is_cnn <=  mem_is_cnn ;
                end
        end// ------------------------------------------------------------------
// result / writeback output
// ------------------------------------------------------------------
    assign result = mem_wb_val ; 
endmodule



