
module shift_rom_depthwise_pointwise_2 (
    input wire [5:0] addr, 
    output reg [7:0] data) ;
    reg [7:0] rom [0:63] ; 
    initial
        begin
            rom[0] = 8'h14 ;
            rom[1] = 8'h54 ;
            rom[2] = 8'h64 ;
            rom[3] = 8'hee ;
            rom[4] = 8'h03 ;
            rom[5] = 8'h44 ;
            rom[6] = 8'h26 ;
            rom[7] = 8'h31 ;
            rom[8] = 8'h05 ;
            rom[9] = 8'h6c ;
            rom[10] = 8'h43 ;
            rom[11] = 8'hee ;
            rom[12] = 8'h14 ;
            rom[13] = 8'h10 ;
            rom[14] = 8'h31 ;
            rom[15] = 8'h3d ;
            rom[16] = 8'h26 ;
            rom[17] = 8'h50 ;
            rom[18] = 8'h73 ;
            rom[19] = 8'h3b ;
            rom[20] = 8'h3d ;
            rom[21] = 8'h7f ;
            rom[22] = 8'hd9 ;
            rom[23] = 8'h3c ;
            rom[24] = 8'h07 ;
            rom[25] = 8'h45 ;
            rom[26] = 8'h39 ;
            rom[27] = 8'h27 ;
            rom[28] = 8'h7a ;
            rom[29] = 8'h01 ;
            rom[30] = 8'hf1 ;
            rom[31] = 8'h51 ;
            rom[32] = 8'h02 ;
            rom[33] = 8'h5b ;
            rom[34] = 8'h6d ;
            rom[35] = 8'h59 ;
            rom[36] = 8'h01 ;
            rom[37] = 8'h04 ;
            rom[38] = 8'h2d ;
            rom[39] = 8'h23 ;
            rom[40] = 8'h53 ;
            rom[41] = 8'h4f ;
            rom[42] = 8'h4f ;
            rom[43] = 8'h5e ;
            rom[44] = 8'h0b ;
            rom[45] = 8'hda ;
            rom[46] = 8'h41 ;
            rom[47] = 8'h47 ;
            rom[48] = 8'h4f ;
            rom[49] = 8'h7f ;
            rom[50] = 8'h2b ;
            rom[51] = 8'hf3 ;
            rom[52] = 8'h1d ;
            rom[53] = 8'h51 ;
            rom[54] = 8'hce ;
            rom[55] = 8'h0c ;
            rom[56] = 8'h29 ;
            rom[57] = 8'heb ;
            rom[58] = 8'h39 ;
            rom[59] = 8'h3a ;
            rom[60] = 8'h41 ;
            rom[61] = 8'h5b ;
            rom[62] = 8'hec ;
            rom[63] = 8'h06 ;
        end
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



