`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Mandi
// Engineer: Anurag Sharma
// 
// Create Date: 18.03.2025 12:23:29
// Design Name: 
// Module Name: Rowbuffer
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

/////////////Buffers to store the 512 pixels from each row of the image (512*512)



module RowBuffer(
input   clk,
input   rst,
input input_data_rd,
input   in_data_valid,
input [7:0] in_data,
output [23:0] output_data

);

reg [7:0] line [511:0]; 
reg [8:0] wrPntr;
reg [8:0] rdPntr;

always @(posedge clk)
begin
    if(in_data_valid)
        line[wrPntr] <= in_data;
end

always @(posedge clk)
begin
    if(rst)
        wrPntr <= 'd0;
    else if(in_data_valid)
        wrPntr <= wrPntr + 'd1;
end

assign output_data = {line[rdPntr],line[rdPntr+1],line[rdPntr+2]};

always @(posedge clk)
begin
    if(rst)
        rdPntr <= 'd0;
    else if(input_data_rd)
        rdPntr <= rdPntr + 'd1;
end


endmodule
