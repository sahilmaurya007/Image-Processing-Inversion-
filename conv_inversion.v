`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Mandi
// Engineer: Anurag Sharma
// 
// Create Date: 20.03.2025 15:37:29
// Design Name: 
// Module Name: conv_inversion
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



///////////to perform the inversion on the input image pixels/////////////////////


module MAC_for_conv(
input        clk,
input [71:0] input_pixel_values,
input        input_pixel_values_valid,
output reg [7:0] mac_o_data,
output reg   mac_o_data_valid
    );
    
integer i; 
reg [7:0] shapen_kernel [8:0];
reg [15:0] multData[8:0];
reg [15:0] add_out_data_buf;
reg [15:0] add_out_data;
reg mul_out_data;
reg add_out_dataValid;
reg convolved_data_valid;


///Anurag Sharma //Update: inversion

always @(posedge clk)
begin
    for (i = 0; i < 9; i = i + 1)
    begin
        multData[i] <= 8'd255 - input_pixel_values[i*8 +: 8];
//          multData[i] <= ~(input_pixel_values[i*8 +: 8]);
    end
    mul_out_data <= input_pixel_values_valid;
end

always @(*)
begin
    add_out_data_buf = 0;
    for(i=0;i<9;i=i+1)
    begin
        add_out_data_buf =  multData[i];
    end
end


always @(posedge clk)
begin
    add_out_data <= add_out_data_buf;
    add_out_dataValid <= mul_out_data;
end
    
always @(posedge clk)
begin
    mac_o_data <= add_out_data;          /// Anurag: update 
    mac_o_data_valid <= add_out_dataValid;
end
    
endmodule
