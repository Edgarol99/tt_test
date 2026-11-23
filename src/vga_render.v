// ---------------------------------------------------------------------------
// vga_render.v : pixel position -> color (purely combinational).
//
// Layout: W x W cells of 64x64 pixels, centered on the 640x480 screen.
// Cell sizes are powers of two, so (pixel -> cell) is just bit slicing.
// Adjacent counts are shown as colors instead of digits (much smaller).
//
//   unrevealed = light gray     mine (after losing) = magenta
//   0 = dark gray, 1 = blue, 2 = green, 3 = red, 4 = purple, 5 = orange, 6 = cyan, 7 = yellow
//   cursor = white frame        outside the board: black / dark green (won) / dark red (lost)
// ---------------------------------------------------------------------------
`default_nettype none

module vga_render #(
    parameter W = 6,
    parameter N = W * W
) (
    input  wire [9:0]     hpos,
    input  wire [9:0]     vpos,
    input  wire           active,
    input  wire [N-1:0]   revealed,
    input  wire [N-1:0]   mines,
    input  wire [4*N-1:0] counts,
    input  wire [2:0]     cursor_x,
    input  wire [2:0]     cursor_y,
    input  wire           won,
    input  wire           lost,
    output wire [1:0]     r,
    output wire [1:0]     g,
    output wire [1:0]     b
);
    localparam X0 = (640 - W*64) / 2;
    localparam Y0 = (480 - W*64) / 2;

    wire in_board = (hpos >= X0) && (hpos < X0 + W*64) &&
                    (vpos >= Y0) && (vpos < Y0 + W*64);

    wire [9:0] hx = hpos - X0;
    wire [9:0] vy = vpos - Y0;

    wire [2:0] col = hx[8:6];           // which cell
    wire [2:0] row = vy[8:6];
    wire [5:0] px  = hx[5:0];           // position inside the cell
    wire [5:0] py  = vy[5:0];

    wire [5:0] idx   = row * W + col;
    wire       valid = in_board && (idx < N);

    wire       is_mine = valid ? mines[idx]            : 1'b0;
    wire [3:0] count   = valid ? counts[idx*4 +: 4]    : 4'd0;
    wire       rev     = valid ? revealed[idx]         : 1'b0;
    wire       show    = rev || (lost && is_mine);

    wire is_cursor    = (col == cursor_x) && (row == cursor_y);
    wire thin_border  = (px < 2) || (px >= 62) || (py < 2) || (py >= 62);
    wire thick_border = (px < 4) || (px >= 60) || (py < 4) || (py >= 60);

    reg [5:0] rgb;                      // {r[1:0], g[1:0], b[1:0]}

    always @* begin
        if (!active)
            rgb = 6'b00_00_00;
        else if (!valid)                // background around the board
            rgb = won ? 6'b00_01_00 : lost ? 6'b01_00_00 : 6'b00_00_00;
        else if (is_cursor && thick_border)
            rgb = 6'b11_11_11;
        else if (thin_border)
            rgb = 6'b00_00_00;
        else if (!show)
            rgb = 6'b10_10_10;          // hidden cell
        else if (is_mine)
            rgb = 6'b11_00_11;
        else begin
            case (count)
                4'd0:    rgb = 6'b01_01_01;
                4'd1:    rgb = 6'b00_01_11;
                4'd2:    rgb = 6'b00_11_00;
                4'd3:    rgb = 6'b11_00_00;
                4'd4:    rgb = 6'b01_00_11;
                4'd5:    rgb = 6'b11_01_00;
                4'd6:    rgb = 6'b00_11_11;
                4'd7:    rgb = 6'b11_11_00;
                default: rgb = 6'b11_10_01;
            endcase
        end
    end

    assign r = rgb[5:4];
    assign g = rgb[3:2];
    assign b = rgb[1:0];
endmodule
