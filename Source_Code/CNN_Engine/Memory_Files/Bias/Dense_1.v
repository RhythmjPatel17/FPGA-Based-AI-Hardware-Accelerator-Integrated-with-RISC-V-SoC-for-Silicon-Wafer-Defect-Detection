
module biases_rom_dense_layer_1x_1280_256_128_bn_relu6 (
    input wire [7:0] addr, 
    output reg [7:0] data) ;
    reg [7:0] rom [0:127] ; 
    initial
        begin
            rom[0] = 8'h36 ;
            rom[1] = 8'h31 ;
            rom[2] = 8'h4e ;
            rom[3] = 8'h70 ;
            rom[4] = 8'h17 ;
            rom[5] = 8'h2c ;
            rom[6] = 8'h07 ;
            rom[7] = 8'hff ;
            rom[8] = 8'h0d ;
            rom[9] = 8'h1a ;
            rom[10] = 8'h36 ;
            rom[11] = 8'h63 ;
            rom[12] = 8'h7b ;
            rom[13] = 8'h4d ;
            rom[14] = 8'hec ;
            rom[15] = 8'h0e ;
            rom[16] = 8'hfd ;
            rom[17] = 8'h75 ;
            rom[18] = 8'h5e ;
            rom[19] = 8'h61 ;
            rom[20] = 8'h0f ;
            rom[21] = 8'h2f ;
            rom[22] = 8'h4d ;
            rom[23] = 8'h4d ;
            rom[24] = 8'h5f ;
            rom[25] = 8'h32 ;
            rom[26] = 8'h33 ;
            rom[27] = 8'h73 ;
            rom[28] = 8'hec ;
            rom[29] = 8'h11 ;
            rom[30] = 8'h48 ;
            rom[31] = 8'h3b ;
            rom[32] = 8'hef ;
            rom[33] = 8'h2e ;
            rom[34] = 8'h0f ;
            rom[35] = 8'h66 ;
            rom[36] = 8'h2c ;
            rom[37] = 8'h3b ;
            rom[38] = 8'h1c ;
            rom[39] = 8'h42 ;
            rom[40] = 8'h30 ;
            rom[41] = 8'h42 ;
            rom[42] = 8'h3e ;
            rom[43] = 8'h14 ;
            rom[44] = 8'h0e ;
            rom[45] = 8'h4c ;
            rom[46] = 8'h32 ;
            rom[47] = 8'h00 ;
            rom[48] = 8'h23 ;
            rom[49] = 8'h13 ;
            rom[50] = 8'h41 ;
            rom[51] = 8'h4f ;
            rom[52] = 8'h22 ;
            rom[53] = 8'h36 ;
            rom[54] = 8'h57 ;
            rom[55] = 8'h46 ;
            rom[56] = 8'h7a ;
            rom[57] = 8'h55 ;
            rom[58] = 8'h5b ;
            rom[59] = 8'h64 ;
            rom[60] = 8'he5 ;
            rom[61] = 8'h66 ;
            rom[62] = 8'h10 ;
            rom[63] = 8'h14 ;
            rom[64] = 8'hf5 ;
            rom[65] = 8'he4 ;
            rom[66] = 8'h5a ;
            rom[67] = 8'hf9 ;
            rom[68] = 8'h0a ;
            rom[69] = 8'hd4 ;
            rom[70] = 8'h0d ;
            rom[71] = 8'h68 ;
            rom[72] = 8'h15 ;
            rom[73] = 8'h5f ;
            rom[74] = 8'h55 ;
            rom[75] = 8'h35 ;
            rom[76] = 8'hf1 ;
            rom[77] = 8'h66 ;
            rom[78] = 8'h79 ;
            rom[79] = 8'hd3 ;
            rom[80] = 8'hec ;
            rom[81] = 8'h0f ;
            rom[82] = 8'h31 ;
            rom[83] = 8'h41 ;
            rom[84] = 8'h1e ;
            rom[85] = 8'h03 ;
            rom[86] = 8'h1a ;
            rom[87] = 8'h3a ;
            rom[88] = 8'h06 ;
            rom[89] = 8'h1e ;
            rom[90] = 8'h2e ;
            rom[91] = 8'h56 ;
            rom[92] = 8'h5f ;
            rom[93] = 8'h25 ;
            rom[94] = 8'h41 ;
            rom[95] = 8'h53 ;
            rom[96] = 8'h07 ;
            rom[97] = 8'h32 ;
            rom[98] = 8'h3c ;
            rom[99] = 8'h41 ;
            rom[100] = 8'h30 ;
            rom[101] = 8'h51 ;
            rom[102] = 8'h7f ;
            rom[103] = 8'h15 ;
            rom[104] = 8'h2e ;
            rom[105] = 8'hf8 ;
            rom[106] = 8'h44 ;
            rom[107] = 8'h08 ;
            rom[108] = 8'hfa ;
            rom[109] = 8'h42 ;
            rom[110] = 8'h28 ;
            rom[111] = 8'h25 ;
            rom[112] = 8'h26 ;
            rom[113] = 8'h50 ;
            rom[114] = 8'hca ;
            rom[115] = 8'h21 ;
            rom[116] = 8'h7c ;
            rom[117] = 8'h3a ;
            rom[118] = 8'h55 ;
            rom[119] = 8'h26 ;
            rom[120] = 8'hec ;
            rom[121] = 8'h54 ;
            rom[122] = 8'h57 ;
            rom[123] = 8'h43 ;
            rom[124] = 8'hf4 ;
            rom[125] = 8'he4 ;
            rom[126] = 8'h42 ;
            rom[127] = 8'h51 ;
        end
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



