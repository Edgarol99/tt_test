/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // VGA signals
    wire hsync;
    wire vsync;
    reg [1:0] R;
    reg [1:0] G;
    reg [1:0] B;
    wire video_active;
    wire [9:0] pix_x;
    wire [9:0] pix_y;

    // Tiny VGA Pmod    
    assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    hvsync_generator vga_sync_gen (
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .hpos(pix_x),
        .vpos(pix_y)    
    );

    // RGB output logic
    always @(posedge clk) begin
        if (~rst_n) begin
            R <= 0;
            G <= 0;
            B <= 0;
        end else begin
            if (video_active) begin
            { R,G,B} <= color;
            end else
          { R,G,B} <= BLACK;
        end
    end

    wire [2:0] pos_x = pix_x/80;
    wire [2:0] pos_y = pix_y/60;

    wire up,down,left,right,btn;
    gamepad control(clk,rst_n,ui_in,up,down,left,right,btn);

    wire [63:0] mines;
    wire [63:0] zeros;
    wire [255:0] counts;
    map minefield(mines,zeros,counts);

    wire [5:0] color;
    map_render field(pos_x,pos_y,0,mines,counts,0,0,color);

endmodule
