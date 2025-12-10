
module shift_rom_dense_layer_1x_1280_256_128_bn_relu6 (
    input wire [7:0] addr, 
    output reg [7:0] data) ;
    reg [7:0] rom [0:127] ; 
    initial
        begin
            rom[0] = 8'h2e ;
            rom[1] = 8'h7f ;
            rom[2] = 8'hfd ;
            rom[3] = 8'h2f ;
            rom[4] = 8'hfc ;
            rom[5] = 8'h2f ;
            rom[6] = 8'h05 ;
            rom[7] = 8'hc6 ;
            rom[8] = 8'hfd ;
            rom[9] = 8'h30 ;
            rom[10] = 8'h40 ;
            rom[11] = 8'hfb ;
            rom[12] = 8'h44 ;
            rom[13] = 8'h0e ;
            rom[14] = 8'h11 ;
            rom[15] = 8'h48 ;
            rom[16] = 8'h32 ;
            rom[17] = 8'h16 ;
            rom[18] = 8'h1e ;
            rom[19] = 8'h3b ;
            rom[20] = 8'h0e ;
            rom[21] = 8'h4a ;
            rom[22] = 8'h47 ;
            rom[23] = 8'hf9 ;
            rom[24] = 8'h41 ;
            rom[25] = 8'h0e ;
            rom[26] = 8'h24 ;
            rom[27] = 8'h0c ;
            rom[28] = 8'h21 ;
            rom[29] = 8'h20 ;
            rom[30] = 8'h0d ;
            rom[31] = 8'h15 ;
            rom[32] = 8'hd1 ;
            rom[33] = 8'h38 ;
            rom[34] = 8'h2b ;
            rom[35] = 8'h31 ;
            rom[36] = 8'h41 ;
            rom[37] = 8'h24 ;
            rom[38] = 8'h44 ;
            rom[39] = 8'hdc ;
            rom[40] = 8'he8 ;
            rom[41] = 8'h16 ;
            rom[42] = 8'h19 ;
            rom[43] = 8'h2b ;
            rom[44] = 8'h29 ;
            rom[45] = 8'hf0 ;
            rom[46] = 8'h23 ;
            rom[47] = 8'h17 ;
            rom[48] = 8'h4f ;
            rom[49] = 8'hdf ;
            rom[50] = 8'h0b ;
            rom[51] = 8'h2a ;
            rom[52] = 8'h3f ;
            rom[53] = 8'h1e ;
            rom[54] = 8'h26 ;
            rom[55] = 8'h53 ;
            rom[56] = 8'h47 ;
            rom[57] = 8'h25 ;
            rom[58] = 8'h34 ;
            rom[59] = 8'h52 ;
            rom[60] = 8'h25 ;
            rom[61] = 8'h26 ;
            rom[62] = 8'h2f ;
            rom[63] = 8'h0c ;
            rom[64] = 8'h1d ;
            rom[65] = 8'hf7 ;
            rom[66] = 8'h25 ;
            rom[67] = 8'he8 ;
            rom[68] = 8'h21 ;
            rom[69] = 8'hff ;
            rom[70] = 8'h06 ;
            rom[71] = 8'h1b ;
            rom[72] = 8'h23 ;
            rom[73] = 8'h30 ;
            rom[74] = 8'h1a ;
            rom[75] = 8'h21 ;
            rom[76] = 8'h19 ;
            rom[77] = 8'h3c ;
            rom[78] = 8'h34 ;
            rom[79] = 8'h13 ;
            rom[80] = 8'h1d ;
            rom[81] = 8'h27 ;
            rom[82] = 8'h0f ;
            rom[83] = 8'h1a ;
            rom[84] = 8'hfe ;
            rom[85] = 8'h25 ;
            rom[86] = 8'h10 ;
            rom[87] = 8'h3b ;
            rom[88] = 8'hfb ;
            rom[89] = 8'he1 ;
            rom[90] = 8'heb ;
            rom[91] = 8'hfd ;
            rom[92] = 8'h63 ;
            rom[93] = 8'h0d ;
            rom[94] = 8'h0b ;
            rom[95] = 8'h14 ;
            rom[96] = 8'h17 ;
            rom[97] = 8'h2c ;
            rom[98] = 8'h29 ;
            rom[99] = 8'h37 ;
            rom[100] = 8'hfb ;
            rom[101] = 8'h36 ;
            rom[102] = 8'h0e ;
            rom[103] = 8'hd7 ;
            rom[104] = 8'h06 ;
            rom[105] = 8'h29 ;
            rom[106] = 8'h0a ;
            rom[107] = 8'h06 ;
            rom[108] = 8'h1e ;
            rom[109] = 8'h15 ;
            rom[110] = 8'h20 ;
            rom[111] = 8'h39 ;
            rom[112] = 8'h28 ;
            rom[113] = 8'h19 ;
            rom[114] = 8'h2b ;
            rom[115] = 8'h19 ;
            rom[116] = 8'h1b ;
            rom[117] = 8'h27 ;
            rom[118] = 8'h28 ;
            rom[119] = 8'h44 ;
            rom[120] = 8'h17 ;
            rom[121] = 8'h27 ;
            rom[122] = 8'h18 ;
            rom[123] = 8'he6 ;
            rom[124] = 8'h13 ;
            rom[125] = 8'h17 ;
            rom[126] = 8'h27 ;
            rom[127] = 8'h20 ;
        end
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



