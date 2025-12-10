
module scale_rom_depthwise_pointwise_3 (
    input wire [6:0] addr, 
    output reg [7:0] data) ;
    reg [7:0] rom [0:127] ; 
    initial
        begin
            rom[0] = 8'h68 ;
            rom[1] = 8'h5c ;
            rom[2] = 8'h54 ;
            rom[3] = 8'h53 ;
            rom[4] = 8'h66 ;
            rom[5] = 8'h68 ;
            rom[6] = 8'h5a ;
            rom[7] = 8'h56 ;
            rom[8] = 8'h5f ;
            rom[9] = 8'h6a ;
            rom[10] = 8'h51 ;
            rom[11] = 8'h73 ;
            rom[12] = 8'h72 ;
            rom[13] = 8'h50 ;
            rom[14] = 8'h58 ;
            rom[15] = 8'h67 ;
            rom[16] = 8'h69 ;
            rom[17] = 8'h60 ;
            rom[18] = 8'h65 ;
            rom[19] = 8'h5a ;
            rom[20] = 8'h46 ;
            rom[21] = 8'h5f ;
            rom[22] = 8'h64 ;
            rom[23] = 8'h65 ;
            rom[24] = 8'h65 ;
            rom[25] = 8'h66 ;
            rom[26] = 8'h59 ;
            rom[27] = 8'h5c ;
            rom[28] = 8'h68 ;
            rom[29] = 8'h4e ;
            rom[30] = 8'h4e ;
            rom[31] = 8'h6c ;
            rom[32] = 8'h61 ;
            rom[33] = 8'h58 ;
            rom[34] = 8'h54 ;
            rom[35] = 8'h67 ;
            rom[36] = 8'h63 ;
            rom[37] = 8'h72 ;
            rom[38] = 8'h67 ;
            rom[39] = 8'h71 ;
            rom[40] = 8'h59 ;
            rom[41] = 8'h60 ;
            rom[42] = 8'h4c ;
            rom[43] = 8'h69 ;
            rom[44] = 8'h67 ;
            rom[45] = 8'h66 ;
            rom[46] = 8'h6d ;
            rom[47] = 8'h70 ;
            rom[48] = 8'h67 ;
            rom[49] = 8'h59 ;
            rom[50] = 8'h53 ;
            rom[51] = 8'h67 ;
            rom[52] = 8'h67 ;
            rom[53] = 8'h5b ;
            rom[54] = 8'h60 ;
            rom[55] = 8'h73 ;
            rom[56] = 8'h65 ;
            rom[57] = 8'h54 ;
            rom[58] = 8'h65 ;
            rom[59] = 8'h7d ;
            rom[60] = 8'h68 ;
            rom[61] = 8'h6d ;
            rom[62] = 8'h4e ;
            rom[63] = 8'h69 ;
            rom[64] = 8'h5a ;
            rom[65] = 8'h7f ;
            rom[66] = 8'h5d ;
            rom[67] = 8'h77 ;
            rom[68] = 8'h6c ;
            rom[69] = 8'h59 ;
            rom[70] = 8'h78 ;
            rom[71] = 8'h59 ;
            rom[72] = 8'h5e ;
            rom[73] = 8'h5f ;
            rom[74] = 8'h62 ;
            rom[75] = 8'h44 ;
            rom[76] = 8'h76 ;
            rom[77] = 8'h6c ;
            rom[78] = 8'h5f ;
            rom[79] = 8'h5a ;
            rom[80] = 8'h60 ;
            rom[81] = 8'h5f ;
            rom[82] = 8'h54 ;
            rom[83] = 8'h69 ;
            rom[84] = 8'h6d ;
            rom[85] = 8'h6f ;
            rom[86] = 8'h63 ;
            rom[87] = 8'h66 ;
            rom[88] = 8'h6a ;
            rom[89] = 8'h6a ;
            rom[90] = 8'h62 ;
            rom[91] = 8'h57 ;
            rom[92] = 8'h69 ;
            rom[93] = 8'h61 ;
            rom[94] = 8'h5e ;
            rom[95] = 8'h56 ;
            rom[96] = 8'h6f ;
            rom[97] = 8'h44 ;
            rom[98] = 8'h63 ;
            rom[99] = 8'h62 ;
            rom[100] = 8'h68 ;
            rom[101] = 8'h69 ;
            rom[102] = 8'h5c ;
            rom[103] = 8'h60 ;
            rom[104] = 8'h67 ;
            rom[105] = 8'h60 ;
            rom[106] = 8'h6e ;
            rom[107] = 8'h40 ;
            rom[108] = 8'h59 ;
            rom[109] = 8'h5e ;
            rom[110] = 8'h57 ;
            rom[111] = 8'h59 ;
            rom[112] = 8'h63 ;
            rom[113] = 8'h68 ;
            rom[114] = 8'h49 ;
            rom[115] = 8'h61 ;
            rom[116] = 8'h5a ;
            rom[117] = 8'h61 ;
            rom[118] = 8'h6e ;
            rom[119] = 8'h66 ;
            rom[120] = 8'h60 ;
            rom[121] = 8'h5b ;
            rom[122] = 8'h7c ;
            rom[123] = 8'h50 ;
            rom[124] = 8'h7d ;
            rom[125] = 8'h61 ;
            rom[126] = 8'h6f ;
            rom[127] = 8'h6c ;
        end
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



