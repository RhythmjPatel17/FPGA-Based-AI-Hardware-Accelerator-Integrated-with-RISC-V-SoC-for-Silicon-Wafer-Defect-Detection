
module scale_rom_1 (
    input wire [5:0] addr, 
    output reg [7:0] data) ;
    reg [7:0] rom [0:31] ; 
    initial
        begin
            rom[0] = 8'h75 ;
            rom[1] = 8'h53 ;
            rom[2] = 8'h70 ;
            rom[3] = 8'h4b ;
            rom[4] = 8'h56 ;
            rom[5] = 8'h5e ;
            rom[6] = 8'h56 ;
            rom[7] = 8'h6c ;
            rom[8] = 8'h51 ;
            rom[9] = 8'h45 ;
            rom[10] = 8'h4f ;
            rom[11] = 8'h4c ;
            rom[12] = 8'h2e ;
            rom[13] = 8'h3a ;
            rom[14] = 8'h51 ;
            rom[15] = 8'h4b ;
            rom[16] = 8'h74 ;
            rom[17] = 8'h7f ;
            rom[18] = 8'h4a ;
            rom[19] = 8'h45 ;
            rom[20] = 8'h41 ;
            rom[21] = 8'h41 ;
            rom[22] = 8'h52 ;
            rom[23] = 8'h44 ;
            rom[24] = 8'h5f ;
            rom[25] = 8'h55 ;
            rom[26] = 8'h55 ;
            rom[27] = 8'h52 ;
            rom[28] = 8'h55 ;
            rom[29] = 8'h43 ;
            rom[30] = 8'h46 ;
            rom[31] = 8'h3f ;
        end
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



