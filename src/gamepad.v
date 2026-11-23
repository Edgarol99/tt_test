
module gamepad (
    input wire clk,
    input wire rst_n,
    input wire [7:0] ui_in,
    output wire up,
    output wire down,
    output wire left,
    output wire right,
    output wire btn
);

    // Gamepad Pmod
    wire inp_b, inp_y, inp_select, inp_start, inp_up, inp_down, inp_left, inp_right, inp_a, inp_x, inp_l, inp_r;

    gamepad_pmod_single ctrl(
        // Inputs:
        .rst_n(rst_n),
        .clk(clk),
        .pmod_data(ui_in[6]),
        .pmod_clk(ui_in[5]),
        .pmod_latch(ui_in[4]),
        // Outputs:
        .b(inp_b),
        .y(inp_y),
        .select(inp_select),
        .start(inp_start),
        .up(inp_up),
        .down(inp_down),
        .left(inp_left),
        .right(inp_right),
        .a(inp_a),
        .x(inp_x),
        .l(inp_l),
        .r(inp_r)
    );

    wire ctrl_up,ctrl_down,ctrl_left,ctrl_right,ctrl_btn;
    pulse pad_up(clk,inp_up,ctrl_up);
    pulse pad_down(clk,inp_up,ctrl_down);
    pulse pad_left(clk,inp_up,ctrl_left);
    pulse pad_right(clk,inp_up,ctrl_right);
    pulse pad_btn(clk,inp_up,ctrl_btn);

    assign up = ctrl_up;
    assign down = ctrl_down;
    assign left = ctrl_left;
    assign right = ctrl_right;
    assign btn = ctrl_btn;

endmodule
