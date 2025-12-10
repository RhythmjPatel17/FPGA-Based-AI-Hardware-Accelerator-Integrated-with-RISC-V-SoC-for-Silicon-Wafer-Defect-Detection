
module biases_rom_depthwise_pointwise_3 (
    input wire [6:0] addr, 
    output reg [7:0] data) ;
    reg [7:0] rom [0:127] ; 
    initial
        begin
            rom[0] = 8'ha6 ;
            rom[1] = 8'hc5 ;
            rom[2] = 8'hd1 ;
            rom[3] = 8'hd0 ;
            rom[4] = 8'hcd ;
            rom[5] = 8'he4 ;
            rom[6] = 8'hbe ;
            rom[7] = 8'hd0 ;
            rom[8] = 8'hc9 ;
            rom[9] = 8'hb6 ;
            rom[10] = 8'haa ;
            rom[11] = 8'hd4 ;
            rom[12] = 8'hf9 ;
            rom[13] = 8'hd6 ;
            rom[14] = 8'hb1 ;
            rom[15] = 8'hca ;
            rom[16] = 8'ha5 ;
            rom[17] = 8'hea ;
            rom[18] = 8'hba ;
            rom[19] = 8'hdd ;
            rom[20] = 8'hc6 ;
            rom[21] = 8'hb2 ;
            rom[22] = 8'hd5 ;
            rom[23] = 8'hcc ;
            rom[24] = 8'hdb ;
            rom[25] = 8'hf2 ;
            rom[26] = 8'h96 ;
            rom[27] = 8'hb7 ;
            rom[28] = 8'hb9 ;
            rom[29] = 8'hd5 ;
            rom[30] = 8'hb3 ;
            rom[31] = 8'hd4 ;
            rom[32] = 8'he6 ;
            rom[33] = 8'h82 ;
            rom[34] = 8'hcb ;
            rom[35] = 8'he9 ;
            rom[36] = 8'hc6 ;
            rom[37] = 8'hd0 ;
            rom[38] = 8'hfa ;
            rom[39] = 8'hb7 ;
            rom[40] = 8'hfa ;
            rom[41] = 8'hd9 ;
            rom[42] = 8'hdc ;
            rom[43] = 8'h91 ;
            rom[44] = 8'hd3 ;
            rom[45] = 8'hb7 ;
            rom[46] = 8'hf5 ;
            rom[47] = 8'hb0 ;
            rom[48] = 8'hd0 ;
            rom[49] = 8'hcf ;
            rom[50] = 8'ha3 ;
            rom[51] = 8'hf7 ;
            rom[52] = 8'hdb ;
            rom[53] = 8'hda ;
            rom[54] = 8'hbd ;
            rom[55] = 8'hec ;
            rom[56] = 8'h9e ;
            rom[57] = 8'hde ;
            rom[58] = 8'hcf ;
            rom[59] = 8'hca ;
            rom[60] = 8'hc2 ;
            rom[61] = 8'hd4 ;
            rom[62] = 8'haa ;
            rom[63] = 8'h09 ;
            rom[64] = 8'hcf ;
            rom[65] = 8'hbc ;
            rom[66] = 8'hbf ;
            rom[67] = 8'hca ;
            rom[68] = 8'hf8 ;
            rom[69] = 8'hdd ;
            rom[70] = 8'heb ;
            rom[71] = 8'hc4 ;
            rom[72] = 8'hc6 ;
            rom[73] = 8'hcc ;
            rom[74] = 8'hcb ;
            rom[75] = 8'he3 ;
            rom[76] = 8'hbb ;
            rom[77] = 8'hce ;
            rom[78] = 8'hdf ;
            rom[79] = 8'hdb ;
            rom[80] = 8'hf9 ;
            rom[81] = 8'hd8 ;
            rom[82] = 8'hb9 ;
            rom[83] = 8'hd2 ;
            rom[84] = 8'h81 ;
            rom[85] = 8'hd2 ;
            rom[86] = 8'hfd ;
            rom[87] = 8'hbe ;
            rom[88] = 8'hd9 ;
            rom[89] = 8'hc5 ;
            rom[90] = 8'hd1 ;
            rom[91] = 8'hc9 ;
            rom[92] = 8'h9c ;
            rom[93] = 8'hae ;
            rom[94] = 8'hc3 ;
            rom[95] = 8'hc8 ;
            rom[96] = 8'hd7 ;
            rom[97] = 8'hcd ;
            rom[98] = 8'hbf ;
            rom[99] = 8'h9e ;
            rom[100] = 8'hc1 ;
            rom[101] = 8'haf ;
            rom[102] = 8'hc9 ;
            rom[103] = 8'h0e ;
            rom[104] = 8'he4 ;
            rom[105] = 8'hbc ;
            rom[106] = 8'hc6 ;
            rom[107] = 8'hcf ;
            rom[108] = 8'hed ;
            rom[109] = 8'hcc ;
            rom[110] = 8'hc3 ;
            rom[111] = 8'hd3 ;
            rom[112] = 8'ha1 ;
            rom[113] = 8'hb0 ;
            rom[114] = 8'hdd ;
            rom[115] = 8'h95 ;
            rom[116] = 8'hd1 ;
            rom[117] = 8'hbe ;
            rom[118] = 8'hbd ;
            rom[119] = 8'hd2 ;
            rom[120] = 8'hac ;
            rom[121] = 8'hbd ;
            rom[122] = 8'hed ;
            rom[123] = 8'hcd ;
            rom[124] = 8'ha2 ;
            rom[125] = 8'hd5 ;
            rom[126] = 8'h9f ;
            rom[127] = 8'hd8 ;
        end
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



