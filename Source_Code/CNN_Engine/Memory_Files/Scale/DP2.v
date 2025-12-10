
module scale_rom_depthwise_pointwise_2 (
    input wire [5:0] addr, 
    output reg [7:0] data) ;
    reg [7:0] rom [0:63] ; 
    initial
        begin
            rom[0] = 8'h47 ;
            rom[1] = 8'h60 ;
            rom[2] = 8'h66 ;
            rom[3] = 8'h68 ;
            rom[4] = 8'h71 ;
            rom[5] = 8'h6e ;
            rom[6] = 8'h63 ;
            rom[7] = 8'h68 ;
            rom[8] = 8'h7c ;
            rom[9] = 8'h79 ;
            rom[10] = 8'h74 ;
            rom[11] = 8'h72 ;
            rom[12] = 8'h55 ;
            rom[13] = 8'h7f ;
            rom[14] = 8'h57 ;
            rom[15] = 8'h6d ;
            rom[16] = 8'h7e ;
            rom[17] = 8'h60 ;
            rom[18] = 8'h58 ;
            rom[19] = 8'h66 ;
            rom[20] = 8'h66 ;
            rom[21] = 8'h61 ;
            rom[22] = 8'h66 ;
            rom[23] = 8'h5a ;
            rom[24] = 8'h71 ;
            rom[25] = 8'h68 ;
            rom[26] = 8'h6c ;
            rom[27] = 8'h60 ;
            rom[28] = 8'h67 ;
            rom[29] = 8'h64 ;
            rom[30] = 8'h61 ;
            rom[31] = 8'h66 ;
            rom[32] = 8'h60 ;
            rom[33] = 8'h60 ;
            rom[34] = 8'h74 ;
            rom[35] = 8'h62 ;
            rom[36] = 8'h5b ;
            rom[37] = 8'h4d ;
            rom[38] = 8'h6b ;
            rom[39] = 8'h6f ;
            rom[40] = 8'h6e ;
            rom[41] = 8'h74 ;
            rom[42] = 8'h5b ;
            rom[43] = 8'h79 ;
            rom[44] = 8'h61 ;
            rom[45] = 8'h72 ;
            rom[46] = 8'h58 ;
            rom[47] = 8'h60 ;
            rom[48] = 8'h51 ;
            rom[49] = 8'h66 ;
            rom[50] = 8'h6e ;
            rom[51] = 8'h5f ;
            rom[52] = 8'h73 ;
            rom[53] = 8'h78 ;
            rom[54] = 8'h56 ;
            rom[55] = 8'h68 ;
            rom[56] = 8'h71 ;
            rom[57] = 8'h56 ;
            rom[58] = 8'h64 ;
            rom[59] = 8'h4e ;
            rom[60] = 8'h5e ;
            rom[61] = 8'h74 ;
            rom[62] = 8'h50 ;
            rom[63] = 8'h59 ;
        end
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



