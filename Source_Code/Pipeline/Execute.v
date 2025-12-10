
module execute_stage (
    input wire clk, 
    // From ID/EX (pipeline)
    input wire reset, 
    input wire [31:0] instr_in, 
    input wire [31:0] rs1_in, 
    input wire [31:0] rs2_in, 
    input wire [31:0] imm_in, 
    input wire [4:0] rd_in, 
    // Outputs ? EX/MEM
    input wire rd_valid_in, 
    output reg [31:0] ex_val, 
    output reg [31:0] ex_rs2, 
    output reg [4:0] ex_rd, 
    output reg ex_valid, 
    output reg ex_is_cnn, 
    input wire id_ex_is_accel, 
    input wire [4:0] id_ex_rs1_idx, 
    // CNN Accelerator interface
    input wire [4:0] id_ex_rs2_idx, 
    output reg cnn_start, 
    output reg [4:0] cnn_img_index, 
    input wire [3:0] cnn_pred, 
    input wire cnn_done) ;
    wire [6:0] opcode = instr_in[6:0] ; // Extract opcode/funct fields
    wire [2:0] funct3 = instr_in[14:12] ; 
    wire [6:0] funct7 = instr_in[31:25] ; // Forwarded registers
    wire [31:0] rs1 = rs1_in ; 
    wire [31:0] rs2 = rs2_in ; // Detect CNN instruction
    wire is_cnn = ((opcode == 7'b1111110) || (opcode == 7'b1111111)) ; // ALU computation for non-CNN instructions
    reg [31:0] alu_out ; 
    always
        @(*)
        begin
            alu_out = 32'b0 ;
            if ((!is_cnn)) 
                begin
                    case (opcode)
                    7'b0110011 : 
                        begin
                            case (funct3)
                            3'b000 : 
                                alu_out = ((funct7 == 7'b0100000) ? (rs1 - rs2) : (rs1 + rs2)) ;
                            3'b001 : 
                                alu_out = (rs1 << rs2[4:0]) ;
                            3'b010 : 
                                alu_out = (($signed(rs1) < $signed(rs2)) ? 1 : 0) ;
                            3'b011 : 
                                alu_out = ((rs1 < rs2) ? 1 : 0) ;
                            3'b100 : 
                                alu_out = (rs1 ^ rs2) ;
                            3'b101 : 
                                alu_out = ((funct7 == 7'b0100000) ? ($signed(rs1) >>> rs2[4:0]) : (rs1 >> rs2[4:0])) ;
                            3'b110 : 
                                alu_out = (rs1 | rs2) ;
                            3'b111 : 
                                alu_out = (rs1 & rs2) ;
                            endcase // R-type
                        end
                    7'b0010011 : 
                        begin
                            case (funct3)
                            3'b000 : 
                                alu_out = (rs1 + imm_in) ;
                            3'b010 : 
                                alu_out = (($signed(rs1) < $signed(imm_in)) ? 1 : 0) ;
                            3'b011 : 
                                alu_out = ((rs1 < imm_in) ? 1 : 0) ;
                            3'b100 : 
                                alu_out = (rs1 ^ imm_in) ;
                            3'b110 : 
                                alu_out = (rs1 | imm_in) ;
                            3'b111 : 
                                alu_out = (rs1 & imm_in) ;
                            3'b001 : 
                                alu_out = (rs1 << imm_in[4:0]) ;
                            3'b101 : 
                                alu_out = ((funct7 == 7'b0100000) ? ($signed(rs1) >>> imm_in[4:0]) : (rs1 >> imm_in[4:0])) ;
                            endcase // I-type
                        end
                    7'b0000011,
                            7'b0100011,
                            7'b1100111 : 
                        alu_out = (rs1 + imm_in) ;
                    7'b0110111,
                            7'b0010111 : 
                        alu_out = imm_in ;
                    7'b1101111 : 
                        alu_out = 32'b0 ;
                    endcase 
                end
        end// Main EX pipeline outputs
    always
        @(posedge clk or 
            posedge reset)
        begin
            if (reset) 
                begin
                    ex_val <=  0 ;
                    ex_rs2 <=  0 ;
                    ex_rd <=  0 ;
                    ex_valid <=  0 ;
                    ex_is_cnn <=  0 ;
                    cnn_start <=  0 ;
                    cnn_img_index <=  0 ;
                end
            else
                begin
                    ex_rd <=  rd_in ;
                    ex_valid <=  rd_valid_in ;
                    ex_rs2 <=  rs2 ;
                    ex_is_cnn <=  is_cnn ;
                    if (is_cnn) 
                        begin
                            cnn_start <=  rd_valid_in ;// trigger CNN accelerator
                            cnn_img_index <=  rs1[4:0] ;// image index from rs1
                            ex_val <=  {28'b0,
                                    cnn_pred} ;// CNN prediction sent as result
                        end
                    else
                        begin
                            cnn_start <=  0 ;
                            cnn_img_index <=  0 ;
                            ex_val <=  alu_out ;
                        end
                end
        end
endmodule



