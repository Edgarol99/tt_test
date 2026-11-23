// ---------------------------------------------------------------------------
// tt_um_minesweeper.v : Tiny Tapeout top level. Only wiring lives here.
//
//   ui_in[0] up      ui_in[1] down     ui_in[2] left    ui_in[3] right
//   ui_in[4] reveal  ui_in[5] new game
//   uo_out = Tiny VGA PMOD: {hsync, B0, G0, R0, vsync, B1, G1, R1}
//
//   input_ctrl --pulses--> cursor ---+
//        |                           +--> game_logic --revealed--> vga_render --> uo_out
//        +--- tick <--- vga_sync ----+--------------------------------^
//   board_map (constants) feeds game_logic and vga_render
// ---------------------------------------------------------------------------
`default_nettype none

module tt_um_minesweeper (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    localparam W = 6;
    localparam N = W * W;

    // ---- constants ----
    wire [N-1:0]   mines, zeros;
    wire [4*N-1:0] counts;
    board_map #(.W(W)) u_map (.mines(mines), .zeros(zeros), .counts(counts));

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

    // Input
    wire up,down,left,right,btn;
    gamepad control(clk,rst_n,ui_in,up,down,left,right,btn);

    wire [2:0] cur_x, cur_y;
    cursor #(.W(W)) u_cur (
        .clk(clk), .rst_n(rst_n),
        .up(up), .down(down), .left(left), .right(right),
        .x(cur_x), .y(cur_y)
    );

    // ---- game ----
    wire [N-1:0] revealed;
    wire         won, lost;
    game_logic #(.W(W)) u_game (
        .clk(clk), .rst_n(rst_n),
        .new_game(new_game), .reveal(reveal),
        .cursor_x(cur_x), .cursor_y(cur_y),
        .mines(mines), .zeros(zeros),
        .revealed(revealed), .won(won), .lost(lost)
    );

    // ---- output ----
    wire [1:0] r, g, b;
    vga_render #(.W(W)) u_render (
        .hpos(hpos), 
        .vpos(vpos), 
        .active(active),
        .revealed(revealed), 
        .mines(mines), 
        .counts(counts),
        .cursor_x(cur_x), 
        .cursor_y(cur_y),
        .won(won), 
        .lost(lost),
        .r(r), 
        .g(g), 
        .b(b)
    );

    // Register the outputs so colors and syncs stay aligned and glitch-free.
    // (8 flops; remove if you need the area.)
/*    reg [7:0] vga_reg;
    always @(posedge clk) begin
        if (!rst_n) vga_reg <= 8'h00;
        else        vga_reg <= {hsync, b[0], g[0], r[0], vsync, b[1], g[1], r[1]};
    end
*/

    // Unused outputs assigned to 0.
    assign uio_out = 0;
    assign uio_oe  = 0;

    // Suppress unused signals warning
    wire _unused_ok = &{ena, ui_in[7], ui_in[4:0], uio_in};

endmodule
