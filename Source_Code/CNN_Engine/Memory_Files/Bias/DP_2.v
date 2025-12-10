(* keep_hierarchy = "yes", dont_touch = "true" *)

module biases_rom_depthwise_pointwise_2 (
    input wire [5:0] addr, 
    output reg [7:0] data) ;
    reg [7:0] rom [0:63] ; // Declare memory
// Initialize ROM contents
    initial
        begin
            rom[0] = 8'hb6 ;
            rom[1] = 8'hd0 ;
            rom[2] = 8'h81 ;
            rom[3] = 8'hf6 ;
            rom[4] = 8'hd6 ;
            rom[5] = 8'hd9 ;
            rom[6] = 8'hf6 ;
            rom[7] = 8'hfd ;
            rom[8] = 8'hd9 ;
            rom[9] = 8'h1e ;
            rom[10] = 8'hae ;
            rom[11] = 8'he5 ;
            rom[12] = 8'h13 ;
            rom[13] = 8'hb9 ;
            rom[14] = 8'hfd ;
            rom[15] = 8'hee ;
            rom[16] = 8'hc2 ;
            rom[17] = 8'hd7 ;
            rom[18] = 8'hbd ;
            rom[19] = 8'hff ;
            rom[20] = 8'hf0 ;
            rom[21] = 8'hf2 ;
            rom[22] = 8'hdf ;
            rom[23] = 8'h05 ;
            rom[24] = 8'h12 ;
            rom[25] = 8'hcd ;
            rom[26] = 8'hdb ;
            rom[27] = 8'he4 ;
            rom[28] = 8'he5 ;
            rom[29] = 8'hca ;
            rom[30] = 8'hbc ;
            rom[31] = 8'haa ;
            rom[32] = 8'he7 ;
            rom[33] = 8'hc3 ;
            rom[34] = 8'hc8 ;
            rom[35] = 8'hbf ;
            rom[36] = 8'hea ;
            rom[37] = 8'hf1 ;
            rom[38] = 8'ha7 ;
            rom[39] = 8'hb7 ;
            rom[40] = 8'h1d ;
            rom[41] = 8'hd3 ;
            rom[42] = 8'h21 ;
            rom[43] = 8'h17 ;
            rom[44] = 8'hcf ;
            rom[45] = 8'hde ;
            rom[46] = 8'hec ;
            rom[47] = 8'h15 ;
            rom[48] = 8'hda ;
            rom[49] = 8'he1 ;
            rom[50] = 8'hff ;
            rom[51] = 8'hcb ;
            rom[52] = 8'he6 ;
            rom[53] = 8'hd0 ;
            rom[54] = 8'hf3 ;
            rom[55] = 8'hcc ;
            rom[56] = 8'he1 ;
            rom[57] = 8'hf4 ;
            rom[58] = 8'hf6 ;
            rom[59] = 8'hd9 ;
            rom[60] = 8'h00 ;
            rom[61] = 8'hfb ;
            rom[62] = 8'hfc ;
            rom[63] = 8'hca ;
        end// Output data based on address
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



