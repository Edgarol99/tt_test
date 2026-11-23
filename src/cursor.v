// ---------------------------------------------------------------------------
// cursor.v : the selected cell. Wraps around the edges.
// ---------------------------------------------------------------------------
`default_nettype none

module cursor #(
    parameter W = 6
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       up,
    input  wire       down,
    input  wire       left,
    input  wire       right,
    output reg  [2:0] x,
    output reg  [2:0] y
);
    always @(posedge clk) begin
        if (!rst_n) begin
            x <= 3'd0;
            y <= 3'd0;
        end else begin
            if      (right) x <= (x == W - 1) ? 3'd0     : x + 3'd1;
            else if (left)  x <= (x == 3'd0)  ? W - 1    : x - 3'd1;

            if      (down)  y <= (y == W - 1) ? 3'd0     : y + 3'd1;
            else if (up)    y <= (y == 3'd0)  ? W - 1    : y - 3'd1;
        end
    end
endmodule
