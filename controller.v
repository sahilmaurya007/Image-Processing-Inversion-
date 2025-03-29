`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Mandi
// Engineer: Anurag Sharma
// 
// Create Date: 18.03.2025 12:39:26
// Design Name: 
// Module Name: controller for Design path
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


////////////////////making the controller logic for the design path/////////////////



module controller(
input                    clk,
input                    rst,
input [7:0]              input_pixel_values,
input                    input_pixel_values_valid,
output reg [71:0]        output_pix_values,
output                   output_pix_values_valid,
output reg               output_interrupt
);

reg [8:0] Counter_Pixel;
reg [1:0] Wr_row_Buffer;
reg [3:0] RowBuffValid;
reg [3:0] Rd_Row_Buff_Valid;
reg [1:0] Rd_row_Buffer;
wire [23:0] Row_0_data;
wire [23:0] Row_1_data;
wire [23:0] Row_2_data;
wire [23:0] Row_3_data;
reg [8:0] Rd_data_counter;
reg Rd_Row_Buff;
reg [11:0] totalCounter_Pixel;
reg State;

localparam IDLE = 'b0,
           READ = 'b1;

assign output_pix_values_valid = Rd_Row_Buff;

always @(posedge clk)
begin
    if(rst)
        totalCounter_Pixel <= 0;
    else
    begin
        if(input_pixel_values_valid & !Rd_Row_Buff)
            totalCounter_Pixel <= totalCounter_Pixel + 1;
        else if(!input_pixel_values_valid & Rd_Row_Buff)
            totalCounter_Pixel <= totalCounter_Pixel - 1;
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        State <= IDLE;
        Rd_Row_Buff <= 1'b0;
        output_interrupt <= 1'b0;
    end
    else
    begin
        case(State)
            IDLE:begin
                output_interrupt <= 1'b0;
                if(totalCounter_Pixel >= 1536)
                begin
                    Rd_Row_Buff <= 1'b1;
                    State <= READ;
                end
            end
            READ:begin
                if(Rd_data_counter == 511)
                begin
                    State <= IDLE;
                    Rd_Row_Buff <= 1'b0;
                    output_interrupt <= 1'b1;
                end
            end
        endcase
    end
end
    
always @(posedge clk)
begin
    if(rst)
        Counter_Pixel <= 0;
    else 
    begin
        if(input_pixel_values_valid)
            Counter_Pixel <= Counter_Pixel + 1;
    end
end


always @(posedge clk)
begin
    if(rst)
        Wr_row_Buffer <= 0;
    else
    begin
        if(Counter_Pixel == 511 & input_pixel_values_valid)
            Wr_row_Buffer <= Wr_row_Buffer+1;
    end
end


always @(*)
begin
    RowBuffValid = 4'h0;
    RowBuffValid[Wr_row_Buffer] = input_pixel_values_valid;
end

always @(posedge clk)
begin
    if(rst)
        Rd_data_counter <= 0;
    else 
    begin
        if(Rd_Row_Buff)
            Rd_data_counter <= Rd_data_counter + 1;
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        Rd_row_Buffer <= 0;
    end
    else
    begin
        if(Rd_data_counter == 511 & Rd_Row_Buff)
            Rd_row_Buffer <= Rd_row_Buffer + 1;
    end
end


always @(*)
begin
    case(Rd_row_Buffer)
        0:begin
            output_pix_values = {Row_2_data,Row_1_data,Row_0_data};
        end
        1:begin
            output_pix_values = {Row_3_data,Row_2_data,Row_1_data};
        end
        2:begin
            output_pix_values = {Row_0_data,Row_3_data,Row_2_data};
        end
        3:begin
            output_pix_values = {Row_1_data,Row_0_data,Row_3_data};
        end
    endcase
end

always @(*)
begin
    case(Rd_row_Buffer)
        0:begin
            Rd_Row_Buff_Valid[0] = Rd_Row_Buff;
            Rd_Row_Buff_Valid[1] = Rd_Row_Buff;
            Rd_Row_Buff_Valid[2] = Rd_Row_Buff;
            Rd_Row_Buff_Valid[3] = 1'b0;
        end
       1:begin
            Rd_Row_Buff_Valid[0] = 1'b0;
            Rd_Row_Buff_Valid[1] = Rd_Row_Buff;
            Rd_Row_Buff_Valid[2] = Rd_Row_Buff;
            Rd_Row_Buff_Valid[3] = Rd_Row_Buff;
        end
       2:begin
             Rd_Row_Buff_Valid[0] = Rd_Row_Buff;
             Rd_Row_Buff_Valid[1] = 1'b0;
             Rd_Row_Buff_Valid[2] = Rd_Row_Buff;
             Rd_Row_Buff_Valid[3] = Rd_Row_Buff;
       end  
      3:begin
             Rd_Row_Buff_Valid[0] = Rd_Row_Buff;
             Rd_Row_Buff_Valid[1] = Rd_Row_Buff;
             Rd_Row_Buff_Valid[2] = 1'b0;
             Rd_Row_Buff_Valid[3] = Rd_Row_Buff;
       end        
    endcase
end
    
RowBuffer lB0(
    .clk(clk),
    .rst(rst),
    .in_data(input_pixel_values),
    .in_data_valid(RowBuffValid[0]),
    .output_data(Row_0_data),
    .input_data_rd(Rd_Row_Buff_Valid[0])
 ); 
 
 RowBuffer lB1(
     .clk(clk),
     .rst(rst),
     .in_data(input_pixel_values),
     .in_data_valid(RowBuffValid[1]),
     .output_data(Row_1_data),
     .input_data_rd(Rd_Row_Buff_Valid[1])
  ); 
  
  RowBuffer lB2(
      .clk(clk),
      .rst(rst),
      .in_data(input_pixel_values),
      .in_data_valid(RowBuffValid[2]),
      .output_data(Row_2_data),
      .input_data_rd(Rd_Row_Buff_Valid[2])
   ); 
   
   RowBuffer lB3(
       .clk(clk),
       .rst(rst),
       .in_data(input_pixel_values),
       .in_data_valid(RowBuffValid[3]),
       .output_data(Row_3_data),
       .input_data_rd(Rd_Row_Buff_Valid[3])
    );    
    
endmodule


