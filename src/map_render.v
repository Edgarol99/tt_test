

module map_render (
    input wire[2:0] hpos,
    input wire[2:0] vpos,
    input wire [63:0] shown,
    input wire [63:0] mines,
    input wire [255:0] count,
    input wire [2:0] player_x,
    input wire [2:0] player_y,
    output reg [5:0] color
);

    wire [5:0] index = {vpos,hpos};
    wire [3:0] num = count[index*4+:4];
    wire player = (hpos == player_x) && (vpos == player_y);

    // Colors
    localparam [5:0] BLACK = {2'b00, 2'b00, 2'b00};
    localparam [5:0] GRIS1 = {2'b01, 2'b01, 2'b01};
    localparam [5:0] GRIS2 = {2'b10, 2'b10, 2'b10};
    localparam [5:0] RED = {2'b11, 2'b00, 2'b00};

    always @(*) begin
        if (player)
            color = RED;
        else if (!shown[index])
            color = GRIS1;
        else if (mines[index])
            color = BLACK;
       else
           color = GRIS2;
    end 

endmodule