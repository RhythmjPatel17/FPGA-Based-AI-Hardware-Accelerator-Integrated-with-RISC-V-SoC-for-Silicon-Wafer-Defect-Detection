
module decode_stage (
    input wire clk, 
    // Input from IF/ID
    input wire reset, 
    input wire [31:0] instr_in, 
    // Register file inputs (READ)
    input wire instr_valid, 
    input wire [31:0] rf_rs1_data, 
    input wire [31:0] rf_rs2_data, 
    input wire [31:0] rf_rs1_data_1, 
    input wire [31:0] rf_rs2_data_1, 
    input wire [31:0] rf_rs1_data_2, 
    input wire [31:0] rf_rs2_data_2, 
    input wire [31:0] rf_rs1_data_3, 
    input wire [31:0] rf_rs2_data_3, 
    input wire [31:0] rf_rs1_data_4, 
    input wire [31:0] rf_rs2_data_4, 
    input wire [31:0] rf_rs1_data_5, 
    input wire [31:0] rf_rs2_data_5, 
    input wire [31:0] rf_rs1_data_6, 
    input wire [31:0] rf_rs2_data_6, 
    input wire [31:0] rf_rs1_data_7, 
    input wire [31:0] rf_rs2_data_7, 
    input wire [31:0] rf_rs1_data_8, 
    input wire [31:0] rf_rs2_data_8, 
    input wire [31:0] rf_rs1_data_9, 
    // Register file outputs (ADDRS)
    input wire [31:0] rf_rs2_data_9, 
    output reg [4:0] rf_rs1_addr, 
    // Outputs to ID/EX
    output reg [4:0] rf_rs2_addr, 
    output reg [31:0] rs1_data_out, 
    output reg [31:0] rs2_data_out, 
    output reg [31:0] instr_out, 
    output reg [4:0] rd_out, 
    output reg rd_valid_out, 
    output reg is_accel_out, 
    output reg [4:0] rs1_out, 
    output reg [4:0] rs2_out, 
    output reg [31:0] imm_out) ;
    wire [6:0] opcode = instr_in[6:0] ; // -------------------------------------------------------
// Basic Fields
// -------------------------------------------------------
    wire [4:0] rs1 = instr_in[19:15] ; 
    wire [4:0] rs2 = instr_in[24:20] ; 
    wire [4:0] rd = instr_in[11:7] ; // -------------------------------------------------------
// Recognize RISC-V Instruction Types
// -------------------------------------------------------
    wire is_r_type = (opcode == 7'b0110011) ; 
    wire is_i_type = (((opcode == 7'b0010011) || (opcode == 7'b0000011)) || (opcode == 7'b1100111)) ; 
    wire is_s_type = (opcode == 7'b0100011) ; 
    wire is_b_type = (opcode == 7'b1100011) ; 
    wire is_u_type = ((opcode == 7'b0110111) || (opcode == 7'b0010111)) ; 
    wire is_j_type = (opcode == 7'b1101111) ; // -------------------------------------------------------
// CUSTOM ACCELERATOR OPCODES
// -------------------------------------------------------
    wire is_accel = ((opcode == 7'b1111110) || (opcode == 7'b1111111)) ; // -------------------------------------------------------
// Imm generation
// -------------------------------------------------------
    reg [31:0] imm ; 
    always
        @(*)
        begin
            case (1'b1)
            is_i_type : 
                imm = {{20{instr_in[31]}},
                        instr_in[31:20]} ;
            is_s_type : 
                imm = {{20{instr_in[31]}},
                        instr_in[31:25],
                        instr_in[11:7]} ;
            is_b_type : 
                imm = {{19{instr_in[31]}},
                        instr_in[31],
                        instr_in[7],
                        instr_in[30:25],
                        instr_in[11:8],
                        1'b0} ;
            is_u_type : 
                imm = {instr_in[31:12],
                        12'b0} ;
            is_j_type : 
                imm = {{11{instr_in[31]}},
                        instr_in[31],
                        instr_in[19:12],
                        instr_in[20],
                        instr_in[30:21],
                        1'b0} ;
            is_accel : 
                imm = 32'd0 ;
            default : 
                imm = 32'd0 ;
            endcase 
        end// -------------------------------------------------------
// rd_valid logic
// -------------------------------------------------------
    reg rd_v ; 
    always
        @(*)
        begin
            case (opcode)
            7'b0100011,
                    7'b1100011 : 
                rd_v = 1'b0 ;// STORE
// BRANCH
            default : 
                rd_v = 1'b1 ;
            endcase 
        end// -------------------------------------------------------
// Outputs
// -------------------------------------------------------
    always
        @(*)
        begin
            instr_out = instr_in ;// ACCEL instruction: rd = instr[11:7], rs2 = 0, rs1_data = rs1 ID encoded
            rd_out = (is_accel ? instr_in[11:7] : rd) ;
            rs1_out = rs1 ;
            rs2_out = (is_accel ? 5'd0 : rs2) ;
            rf_rs1_addr = rs1 ;
            rf_rs2_addr = rs2 ;
            rs1_data_out = (is_accel ? {27'd0,
                    rs1} : rf_rs1_data) ;
            rs2_data_out = (is_accel ? 32'd0 : rf_rs2_data) ;
            rd_valid_out = (rd_v && instr_valid) ;
            is_accel_out = is_accel ;
            imm_out = imm ;
        end
endmodule



