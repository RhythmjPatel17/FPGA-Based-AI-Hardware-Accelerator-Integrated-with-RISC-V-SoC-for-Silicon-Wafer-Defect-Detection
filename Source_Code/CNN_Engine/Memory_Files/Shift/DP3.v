
module shift_rom_depthwise_pointwise_3 (
    input wire [6:0] addr, 
    output reg [7:0] data) ;
    reg [7:0] rom [0:127] ; 
    initial
        begin
            rom[0] = 8'h47 ;
            rom[1] = 8'h32 ;
            rom[2] = 8'h24 ;
            rom[3] = 8'h63 ;
            rom[4] = 8'h3e ;
            rom[5] = 8'h45 ;
            rom[6] = 8'h2a ;
            rom[7] = 8'h3c ;
            rom[8] = 8'h6f ;
            rom[9] = 8'h38 ;
            rom[10] = 8'h62 ;
            rom[11] = 8'h2d ;
            rom[12] = 8'h2d ;
            rom[13] = 8'h43 ;
            rom[14] = 8'h43 ;
            rom[15] = 8'h31 ;
            rom[16] = 8'h2a ;
            rom[17] = 8'h34 ;
            rom[18] = 8'hfa ;
            rom[19] = 8'h35 ;
            rom[20] = 8'h21 ;
            rom[21] = 8'he2 ;
            rom[22] = 8'hfa ;
            rom[23] = 8'h2a ;
            rom[24] = 8'hd1 ;
            rom[25] = 8'h63 ;
            rom[26] = 8'h51 ;
            rom[27] = 8'h03 ;
            rom[28] = 8'h47 ;
            rom[29] = 8'hfd ;
            rom[30] = 8'h5e ;
            rom[31] = 8'h30 ;
            rom[32] = 8'h20 ;
            rom[33] = 8'h5d ;
            rom[34] = 8'hfd ;
            rom[35] = 8'h27 ;
            rom[36] = 8'h0f ;
            rom[37] = 8'h09 ;
            rom[38] = 8'h30 ;
            rom[39] = 8'h6e ;
            rom[40] = 8'h35 ;
            rom[41] = 8'h47 ;
            rom[42] = 8'h28 ;
            rom[43] = 8'h33 ;
            rom[44] = 8'h56 ;
            rom[45] = 8'h47 ;
            rom[46] = 8'h10 ;
            rom[47] = 8'hfa ;
            rom[48] = 8'h0e ;
            rom[49] = 8'h0d ;
            rom[50] = 8'h04 ;
            rom[51] = 8'h0b ;
            rom[52] = 8'h16 ;
            rom[53] = 8'h30 ;
            rom[54] = 8'h0c ;
            rom[55] = 8'h34 ;
            rom[56] = 8'h36 ;
            rom[57] = 8'h3d ;
            rom[58] = 8'h42 ;
            rom[59] = 8'h10 ;
            rom[60] = 8'h22 ;
            rom[61] = 8'h71 ;
            rom[62] = 8'h5f ;
            rom[63] = 8'h45 ;
            rom[64] = 8'h2a ;
            rom[65] = 8'h31 ;
            rom[66] = 8'hf7 ;
            rom[67] = 8'hf3 ;
            rom[68] = 8'h7f ;
            rom[69] = 8'h19 ;
            rom[70] = 8'h4e ;
            rom[71] = 8'h06 ;
            rom[72] = 8'h74 ;
            rom[73] = 8'h1f ;
            rom[74] = 8'h3e ;
            rom[75] = 8'h08 ;
            rom[76] = 8'h38 ;
            rom[77] = 8'h20 ;
            rom[78] = 8'h3b ;
            rom[79] = 8'h54 ;
            rom[80] = 8'h4c ;
            rom[81] = 8'h18 ;
            rom[82] = 8'h1b ;
            rom[83] = 8'h10 ;
            rom[84] = 8'h6f ;
            rom[85] = 8'h1e ;
            rom[86] = 8'h48 ;
            rom[87] = 8'h18 ;
            rom[88] = 8'h1d ;
            rom[89] = 8'h27 ;
            rom[90] = 8'h21 ;
            rom[91] = 8'hf2 ;
            rom[92] = 8'h20 ;
            rom[93] = 8'h36 ;
            rom[94] = 8'h27 ;
            rom[95] = 8'h08 ;
            rom[96] = 8'h0b ;
            rom[97] = 8'hf8 ;
            rom[98] = 8'h4f ;
            rom[99] = 8'h2d ;
            rom[100] = 8'h3b ;
            rom[101] = 8'h1f ;
            rom[102] = 8'h2c ;
            rom[103] = 8'h2a ;
            rom[104] = 8'h1f ;
            rom[105] = 8'h33 ;
            rom[106] = 8'h31 ;
            rom[107] = 8'h31 ;
            rom[108] = 8'h1e ;
            rom[109] = 8'h25 ;
            rom[110] = 8'h43 ;
            rom[111] = 8'h25 ;
            rom[112] = 8'h0a ;
            rom[113] = 8'he2 ;
            rom[114] = 8'h11 ;
            rom[115] = 8'h49 ;
            rom[116] = 8'h3c ;
            rom[117] = 8'h0b ;
            rom[118] = 8'h2f ;
            rom[119] = 8'h18 ;
            rom[120] = 8'h3b ;
            rom[121] = 8'h50 ;
            rom[122] = 8'h59 ;
            rom[123] = 8'h31 ;
            rom[124] = 8'hf5 ;
            rom[125] = 8'h49 ;
            rom[126] = 8'h2f ;
            rom[127] = 8'h22 ;
        end
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



