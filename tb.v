`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Mandi
// Engineer: Anurag Sharma
// 
// Create Date: 18.03.2025 14:16:20
// Design Name: 
// Module Name: tb
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


`define headerSize 1080
`define imageSize 512*512

module tb();
    
 reg clk;
 reg rst;
 reg [7:0] pixel_img_data;
 integer file,file1,i;
 reg pixel_img_dataValid;
 integer pixel_Sent_Size;
 wire intr;
 wire [7:0] output_data;
 wire output_dataValid;
 integer Data_received=0;




 top dut(
    .axi_clk(clk),
    .axi_reset_n(rst),
    .input_pixel_data_valid(pixel_img_dataValid),
    .input_pixel_data(pixel_img_data),
    .ouput_pixel_data_ready(),
    .output_data_valid(output_dataValid),
    .output_data(output_data),
    .input_pixel_data_ready(1'b1),
    .output_interrupt(intr)
);   



 initial
 begin
    clk = 1'b0;
    forever
    begin
        #5 clk = ~clk;
    end
 end
 
 initial
 begin
    rst = 0;
    pixel_Sent_Size = 0;
    pixel_img_dataValid = 0;
    #100;
    rst = 1;
    #100;
    file = $fopen("input_image.bmp","rb");
    file1 = $fopen("output_image.bmp","wb");
    for(i=0;i<`headerSize;i=i+1)
    begin
        $fscanf(file,"%c",pixel_img_data);
        $fwrite(file1,"%c",pixel_img_data);
    end
    
    for(i=0;i<4*512;i=i+1)
    begin
        @(posedge clk);
        $fscanf(file,"%c",pixel_img_data);
        pixel_img_dataValid <= 1'b1;
    end
    pixel_Sent_Size = 4*512;
    @(posedge clk);
    pixel_img_dataValid <= 1'b0;
    while(pixel_Sent_Size < `imageSize)
    begin
        @(posedge intr);
        for(i=0;i<512;i=i+1)
        begin
            @(posedge clk);
            $fscanf(file,"%c",pixel_img_data);
            pixel_img_dataValid <= 1'b1;    
        end
        @(posedge clk);
        pixel_img_dataValid <= 1'b0;
        pixel_Sent_Size = pixel_Sent_Size+512;
    end
    @(posedge clk);
    pixel_img_dataValid <= 1'b0;
    @(posedge intr);
    for(i=0;i<512;i=i+1)
    begin
        @(posedge clk);
        pixel_img_data <= 0;
        pixel_img_dataValid <= 1'b1;    
    end
    @(posedge clk);
    pixel_img_dataValid <= 1'b0;
    @(posedge intr);
    for(i=0;i<512;i=i+1)
    begin
        @(posedge clk);
        pixel_img_data <= 0;
        pixel_img_dataValid <= 1'b1;    
    end
    @(posedge clk);
    pixel_img_dataValid <= 1'b0;
    $fclose(file);
 end
 
 always @(posedge clk)
 begin
     if(output_dataValid)
     begin
         $fwrite(file1,"%c",output_data);
         Data_received = Data_received+1;
     end 
     if(Data_received == `imageSize)
     begin
        $fclose(file1);
        $stop;
     end
 end
 
 
 
 
 
    
endmodule
