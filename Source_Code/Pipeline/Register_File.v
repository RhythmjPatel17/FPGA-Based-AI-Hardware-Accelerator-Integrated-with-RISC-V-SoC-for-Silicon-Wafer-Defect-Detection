module register_file (
    input  wire clk,
    input  wire rst,
    input  wire rd_write_enable,           // NEW: gated read enable
    input  wire [4:0] rs1,
    input  wire [4:0] rs2,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data
);

    (* rom_style = "distributed", keep = "true" *)
    reg [31:0] regs [0:63];

    integer i;

    // FPGA-synthesizable initialization
    initial begin
        for (i = 0; i < 64; i = i + 1)
            regs[i] = i * 32'd4679;
    end

    always @(posedge clk) begin
        if (rst) begin
            rs1_data <= 32'd0;
            rs2_data <= 32'd0;
        end 
        else if (rd_write_enable) begin
            // Read only when enable = 1
            rs1_data <= (rs1 == 0) ? 32'd0 : regs[rs1];
            rs2_data <= (rs2 == 0) ? 32'd0 : regs[rs2];
        end 
        else begin
            // Hold previous value when enable = 0
            rs1_data <= rs1_data;
            rs2_data <= rs2_data;
        end
    end

endmodule
