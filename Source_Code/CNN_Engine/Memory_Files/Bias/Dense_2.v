
module biases_rom_dense_layer_2x_128_to_9 (
    input wire [3:0] addr, 
    output reg signed [7:0] data) ;
    reg signed [7:0] rom [0:8] ; 
    initial
        begin
            rom[0] = 8'h22 ;
            rom[1] = 8'h94 ;
            rom[2] = 8'h4b ;
            rom[3] = 8'h7f ;
            rom[4] = 8'h08 ;
            rom[5] = 8'h00 ;
            rom[6] = 8'h7f ;
            rom[7] = 8'hd3 ;
            rom[8] = 8'hb5 ;
        end
    always
        @(*)
        begin
            data = rom[addr] ;
        end
endmodule



