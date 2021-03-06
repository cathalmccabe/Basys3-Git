`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2014/05/23 15:48:40
// Design Name: 
// Module Name: vga
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


module vga(
input clk25,
output reg[3:0] vga_red,
output reg[3:0] vga_green,
output reg[3:0] vga_blue,
output reg vga_hsync,
output reg vga_vsync,
output [9:0] HCnt,
output [9:0] VCnt,

output [3:0]rom_addr_d,
input wire[0:15]M_d,
output [3:0]rom_addr_u,
input wire[0:15]M_u,
output [16:0] frame_addr,
input [15:0] frame_pixel
    );
    //Timing constants
      parameter hRez   = 640;
      parameter hStartSync   = 640+16;
      parameter hEndSync     = 640+16+96;
      parameter hMaxCount    = 800;
    
      parameter vRez         = 480;
      parameter vStartSync   = 480+10;
      parameter vEndSync     = 480+10+2;
      parameter vMaxCount    = 480+10+2+33;
    
    parameter hsync_active   =0;
    parameter vsync_active  = 0;
    reg[9:0] hCounter;
    reg[9:0] vCounter;    
    reg[16:0] address;  
    reg blank;
   initial   hCounter = 10'b0;
   initial   vCounter = 10'b0;  
   initial   address = 17'b0;   
   initial   blank = 1'b1;    
   
   assign frame_addr = address;
   assign HCnt = hCounter;
   assign VCnt = vCounter;
   
   wire[10:0] rom_pix_d;
   assign rom_pix_d=(HCnt-160)/4;
   assign rom_addr_d=(VCnt-120)/4;
   reg spriteon_d;
   always@(*)
    begin
     if((HCnt>=160)&&(HCnt<160+64)&&(VCnt>=120)&&(VCnt<120+64))
      spriteon_d=1;
     else
      spriteon_d=0;
    end

   wire[10:0] rom_pix_u;
   assign rom_pix_u=(HCnt-160-64)/4;
   assign rom_addr_u=(VCnt-120)/4;
   reg spriteon_u;
   always@(*)
    begin
     if((HCnt>=160+64)&&(HCnt<160+64+64)&&(VCnt>=120)&&(VCnt<120+64))
      spriteon_u=1;
     else
      spriteon_u=0;
    end
   
   always@(posedge clk25)begin
            if( hCounter == hMaxCount-1 )begin
   				hCounter <=  10'b0;
   				if (vCounter == vMaxCount-1 )
   					vCounter <=  10'b0;
   				else
   					vCounter <= vCounter+1;
   				end
   			else
   				hCounter <= hCounter+1;
   
   			if (blank ==0) begin
   			    if(spriteon_d)begin
   				vga_red   <= {frame_pixel[15]|M_d[rom_pix_d],frame_pixel[14]|M_d[rom_pix_d],frame_pixel[13]|M_d[rom_pix_d],frame_pixel[12]|M_d[rom_pix_d]};//frame_pixel[15:12];
   				vga_green <=  frame_pixel[10:7];
   				vga_blue  <= frame_pixel[4:1];
   				end
   				else if(spriteon_u)begin
              vga_red   <= {frame_pixel[15]|M_u[rom_pix_u],frame_pixel[14]|M_u[rom_pix_u],frame_pixel[13]|M_u[rom_pix_u],frame_pixel[12]|M_u[rom_pix_u]};//frame_pixel[15:12];
              vga_green <=  frame_pixel[10:7];
              vga_blue  <= frame_pixel[4:1];
              end
   				else begin
                vga_red   <= frame_pixel[15:12];
                vga_green <=  frame_pixel[10:7];
                vga_blue  <=  frame_pixel[4:1];
                end
                end
   			else begin
   				vga_red   <= 4'b0;
   				vga_green <= 4'b0;
   				vga_blue  <= 4'b0;
   			     end
   	
   			if(  vCounter  >= 360 || vCounter  < 120) begin
   				address <= 17'b0; 
   				blank <= 1;
   				end
   			else begin
   				if ( hCounter  < 480 && hCounter  >= 160) begin
   					blank <= 0;
   					address <= address+1;
   					end
   				else
   					blank <= 1;
   				end;
   	
   			// Are we in the hSync pulse? (one has been added to include frame_buffer_latency)
   			if( hCounter > hStartSync && hCounter <= hEndSync)
   				vga_hsync <= hsync_active;
   			else
   				vga_hsync <= ~ hsync_active;
   			
   
   			// Are we in the vSync pulse?
   			if( vCounter >= vStartSync && vCounter < vEndSync )
   				vga_vsync <= vsync_active;
   			else
   				vga_vsync <= ~ vsync_active;
   end 
endmodule
