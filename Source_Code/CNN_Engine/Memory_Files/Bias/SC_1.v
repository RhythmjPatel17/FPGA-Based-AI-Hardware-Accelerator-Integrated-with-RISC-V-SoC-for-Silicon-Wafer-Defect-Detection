
module biases_rom_1 (
    input wire [5:0] addr, 
    output reg [7:0] data) ;
    reg [7:0] rom [0:31] ; 
    initial
        begin
            rom[0] = 8'h39 ;
            rom[1] = 8'hde ;
            rom[2] = 8'h52 ;
            rom[3] = 8'h27 ;
            rom[4] = 8'hea ;
            rom[5] = 8'h2e ;
            rom[6] = 8'h14 ;
            rom[7] = 8'h4b ;
            rom[8] = 8'hf0 ;
            rom[9] = 8'hef ;
            rom[10] = 8'h0d ;
            rom[11] = 8'h2b ;
            rom[12] = 8'h60 ;
            rom[13] = 8'h21 ;
            rom[14] = 8'hf9 ;
            rom[15] = 8'h05 ;
            rom[16] = 8'h5a ;
            rom[17] = 8'h54 ;
            rom[18] = 8'h34 ;
            rom[19] = 8'h49 ;
            rom[20] = 8'h7f ;
            rom[21] = 8'hb4 ;
            rom[22] = 8'hdb ;
            rom[23] = 8'hfd ;
            rom[24] = 8'h38 ;
            rom[25] = 8'h01 ;
            rom[26] = 8'h69 ;
            rom[27] = 8'h28 ;
            rom[28] = 8'h20 ;
            rom[29] = 8'h1f ;
            rom[30] = 8'h25 ;
            rom[31] = 8'h35 ;
        end
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



