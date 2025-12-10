
module shift_rom_1 (
    input wire [5:0] addr, 
    output reg [7:0] data) ;
    reg [7:0] rom [0:31] ; 
    initial
        begin
            rom[0] = 8'h2b ;
            rom[1] = 8'hc3 ;
            rom[2] = 8'h3c ;
            rom[3] = 8'h38 ;
            rom[4] = 8'h10 ;
            rom[5] = 8'h70 ;
            rom[6] = 8'h04 ;
            rom[7] = 8'h25 ;
            rom[8] = 8'hbc ;
            rom[9] = 8'hf9 ;
            rom[10] = 8'h73 ;
            rom[11] = 8'h4b ;
            rom[12] = 8'h33 ;
            rom[13] = 8'h22 ;
            rom[14] = 8'hff ;
            rom[15] = 8'h0a ;
            rom[16] = 8'h31 ;
            rom[17] = 8'h21 ;
            rom[18] = 8'hef ;
            rom[19] = 8'h26 ;
            rom[20] = 8'h49 ;
            rom[21] = 8'h21 ;
            rom[22] = 8'h2c ;
            rom[23] = 8'h58 ;
            rom[24] = 8'h2d ;
            rom[25] = 8'hfd ;
            rom[26] = 8'h12 ;
            rom[27] = 8'h7f ;
            rom[28] = 8'h1c ;
            rom[29] = 8'h38 ;
            rom[30] = 8'h5c ;
            rom[31] = 8'h45 ;
        end
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



