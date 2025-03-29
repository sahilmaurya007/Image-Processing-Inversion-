`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Mandi
// Engineer: Anurag Sharma
// 
// Create Date: 18.03.2025 12:57:21
// Design Name: 
// Module Name: top
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



/////////top module //////////

module top(
input   axi_clk,
input   axi_reset_n,
input   input_pixel_data_valid,  //////slave interface
input [7:0] input_pixel_data, //////slave interface
output  ouput_pixel_data_ready,  /////slave interface
output  output_data_valid,  //////master interface
output [7:0] output_data,  //master interface
input   input_pixel_data_ready,   /////master interface
output  output_interrupt
    );

wire [71:0] pixel_data;
wire pixel_data_valid;
wire axis_prog_full;
wire [7:0] convolved_data;
wire convolved_data_valid;

assign ouput_pixel_data_ready = !axis_prog_full;
    

    
    
controller control_uut(
    .clk(axi_clk),
    .rst(!axi_reset_n),
    .input_pixel_values(input_pixel_data),
    .input_pixel_values_valid(input_pixel_data_valid),
    .output_pix_values(pixel_data),
    .output_pix_values_valid(pixel_data_valid),
    .output_interrupt(output_interrupt)
  );    
  
  

  
 MAC_for_conv convolution 
 (
     .clk(axi_clk),
     .input_pixel_values(pixel_data),
     .input_pixel_values_valid(pixel_data_valid),
     .mac_o_data(convolved_data),
     .mac_o_data_valid(convolved_data_valid)
 ); 
 
 fifo_generator_0 fifo_op_buffer (
   .wr_rst_busy(),        // output wire wr_rst_busy
   .rd_rst_busy(),        // output wire rd_rst_busy
   .s_aclk(axi_clk),                  // input wire s_aclk
   .s_aresetn(axi_reset_n),            // input wire s_aresetn
   .s_axis_tvalid(convolved_data_valid),    // input wire s_axis_tvalid
   .s_axis_tready(),    // output wire s_axis_tready
   .s_axis_tdata(convolved_data),      // input wire [7 : 0] s_axis_tdata
   .m_axis_tvalid(output_data_valid),    // output wire m_axis_tvalid
   .m_axis_tready(input_pixel_data_ready),    // input wire m_axis_tready
   .m_axis_tdata(output_data),      // output wire [7 : 0] m_axis_tdata
   .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
 );
  

    
endmodule
