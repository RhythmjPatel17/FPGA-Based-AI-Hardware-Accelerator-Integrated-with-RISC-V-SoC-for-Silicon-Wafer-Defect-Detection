
module std_conv2d_224_224_3_32batches_batchnorm_relu6_1x_32ch_27pes (
    input wire clk, 
    input wire resetn, 
    input wire start, 
    input wire [4:0] input_image_index, 
    input wire [31:0] read_addr, 
    output wire [3:0] read_data, 
    output reg done, 
    output reg [15:0] img_addr, 
    input wire signed [7:0] img_rom_data0, 
    input wire signed [7:0] img_rom_data1, 
    input wire signed [7:0] img_rom_data2, 
    input wire signed [7:0] img_rom_data3, 
    input wire signed [7:0] img_rom_data4, 
    input wire signed [7:0] img_rom_data5, 
    input wire signed [7:0] img_rom_data6, 
    input wire signed [7:0] img_rom_data7, 
    input wire signed [7:0] img_rom_data8, 
    input wire signed [7:0] img_rom_data9, 
    input wire signed [7:0] img_rom_data10, 
    input wire signed [7:0] img_rom_data11, 
    input wire signed [7:0] img_rom_data12, 
    input wire signed [7:0] img_rom_data13, 
    input wire signed [7:0] img_rom_data14, 
    input wire signed [7:0] img_rom_data15, 
    input wire signed [7:0] img_rom_data16, 
    input wire signed [7:0] img_rom_data17, 
    input wire signed [7:0] img_rom_data18, 
    input wire signed [7:0] img_rom_data19, 
    output reg [9:0] weight_addr, 
    input wire signed [7:0] weight_data, 
    output reg [5:0] bias_addr, 
    input wire signed [7:0] bias_data, 
    output reg [5:0] scale_addr, 
    input wire signed [7:0] scale_data, 
    output reg [5:0] shift_addr, 
    input wire signed [7:0] shift_data, 
    output reg [9:0] MRAM_PORTA_addr, 
    output reg [31:0] MRAM_PORTA_wdata, 
    output reg MRAM_PORTA_en, 
    output reg [3:0] MRAM_PORTA_we, 
    input wire [31:0] MRAM_PORTA_rdata, 
    output reg [9:0] MRAM_PORTB_addr, 
    output reg MRAM_PORTB_en, 
    input wire [31:0] MRAM_PORTB_rdata, 
    input wire MRAM_PORTB_rdata_valid) ;
    parameter IM_W = 32, 
        IM_H = 32, 
        NUM_CH = 3, 
        NUM_FILT = 32 ; 
    localparam IDLE = 3'd0, 
        LOAD_IMAGE = 3'd1, 
        WAIT_ONE_CYCLE = 3'd2, 
        CONV2D_COMPUTE = 3'd3, 
        DONE_STATE = 3'd4 ; 
    reg [2:0] state ; 
    reg [3:0] read_data_r ; 
    assign read_data = read_data_r ; 
    always
        @(*)
        begin
            case (read_addr[2:0])
            3'd0 : 
                read_data_r = MRAM_PORTB_rdata[31:28] ;
            3'd1 : 
                read_data_r = MRAM_PORTB_rdata[27:24] ;
            3'd2 : 
                read_data_r = MRAM_PORTB_rdata[23:20] ;
            3'd3 : 
                read_data_r = MRAM_PORTB_rdata[19:16] ;
            3'd4 : 
                read_data_r = MRAM_PORTB_rdata[15:12] ;
            3'd5 : 
                read_data_r = MRAM_PORTB_rdata[11:8] ;
            3'd6 : 
                read_data_r = MRAM_PORTB_rdata[7:4] ;
            default : 
                read_data_r = MRAM_PORTB_rdata[3:0] ;
            endcase 
        end
    reg signed [7:0] image_val ; 
    reg [9:0] row, 
        col ; 
    reg [12:0] out_idx ; 
    reg [5:0] filter_idx ; 
    reg signed [31:0] acc ; 
    reg [31:0] packed_data ; 
    reg signed [31:0] next_acc ; 
    reg [31:0] next_packed_data ; // -----------------------------------------
// Safe ROM selection (combinational)
// -----------------------------------------
    always
        @(*)
        begin
            case (input_image_index)
            5'd0 : 
                image_val = img_rom_data0 ;
            5'd1 : 
                image_val = img_rom_data1 ;
            5'd2 : 
                image_val = img_rom_data2 ;
            5'd3 : 
                image_val = img_rom_data3 ;
            5'd4 : 
                image_val = img_rom_data4 ;
            5'd5 : 
                image_val = img_rom_data5 ;
            5'd6 : 
                image_val = img_rom_data6 ;
            5'd7 : 
                image_val = img_rom_data7 ;
            5'd8 : 
                image_val = img_rom_data8 ;
            5'd9 : 
                image_val = img_rom_data9 ;
            5'd10 : 
                image_val = img_rom_data10 ;
            5'd11 : 
                image_val = img_rom_data11 ;
            5'd12 : 
                image_val = img_rom_data12 ;
            5'd13 : 
                image_val = img_rom_data13 ;
            5'd14 : 
                image_val = img_rom_data14 ;
            5'd15 : 
                image_val = img_rom_data15 ;
            default : 
                image_val = 0 ;
            endcase 
        end// -----------------------------------------
// Sequential FSM
// -----------------------------------------
    always
        @(posedge clk)
        begin
            if ((!resetn)) 
                begin
                    state <=  IDLE ;
                    done <=  0 ;
                    MRAM_PORTA_en <=  0 ;
                    MRAM_PORTA_we <=  0 ;
                    MRAM_PORTB_en <=  0 ;
                    row <=  0 ;
                    col <=  0 ;
                    filter_idx <=  0 ;
                    out_idx <=  0 ;
                    acc <=  0 ;
                    packed_data <=  0 ;
                end
            else
                begin
                    MRAM_PORTA_en <=  0 ;
                    MRAM_PORTA_we <=  0 ;
                    MRAM_PORTB_en <=  0 ;
                    done <=  0 ;
                    case (state)
                    IDLE : 
                        begin
                            if (start) 
                                begin
                                    row <=  0 ;
                                    col <=  0 ;
                                    filter_idx <=  0 ;
                                    out_idx <=  0 ;
                                    acc <=  0 ;
                                    packed_data <=  0 ;
                                    state <=  LOAD_IMAGE ;
                                end
                        end
                    LOAD_IMAGE : 
                        state <=  WAIT_ONE_CYCLE ;
                    WAIT_ONE_CYCLE : 
                        state <=  CONV2D_COMPUTE ;
                    CONV2D_COMPUTE : 
                        begin
                            if ((row < IM_H)) 
                                begin
                                    if ((col < IM_W)) 
                                        begin
                                            next_acc = (acc + (image_val * weight_data)) ;
                                            if ((next_acc > 127)) 
                                                next_acc = 127 ;
                                            else
                                                if ((next_acc < (-128))) 
                                                    next_acc = (-128) ;
                                            acc <=  next_acc ;
                                            next_packed_data = packed_data ;
                                            next_packed_data[3:0] = next_acc[3:0] ;
                                            packed_data <=  next_packed_data ;
                                            MRAM_PORTA_addr <=  (out_idx >> 3) ;
                                            MRAM_PORTA_wdata <=  next_packed_data ;
                                            MRAM_PORTA_en <=  1 ;
                                            MRAM_PORTA_we <=  4'b1111 ;
                                            col <=  (col + 1) ;
                                            out_idx <=  (out_idx + 1) ;
                                        end
                                    else
                                        begin
                                            col <=  0 ;
                                            row <=  (row + 1) ;
                                        end
                                end
                            else
                                begin
                                    if ((filter_idx < (NUM_FILT - 1))) 
                                        begin
                                            filter_idx <=  (filter_idx + 1) ;
                                            row <=  0 ;
                                            col <=  0 ;
                                            out_idx <=  0 ;
                                            acc <=  0 ;
                                            packed_data <=  0 ;
                                        end
                                    else
                                        begin
                                            state <=  DONE_STATE ;
                                        end
                                end
                        end
                    DONE_STATE : 
                        begin
                            MRAM_PORTB_en <=  1 ;
                            MRAM_PORTB_addr <=  (read_addr >> 3) ;
                            done <=  1 ;
                            state <=  IDLE ;
                        end
                    endcase 
                end
        end
endmodule



