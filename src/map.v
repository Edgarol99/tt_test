
module map (
    output [63-1:0] mines,
    output [63-1:0] zeros,
    output [255-1:0] counts
);
    localparam [63:0] MINES = {
        8'b00001000,
        8'b01000000,
        8'b00000100,
        8'b00000000,
        8'b00010010,
        8'b01100000,
        8'b00011100,
        8'b00000100
    };

    function [3:0] adj(input integer i);
        integer x,y,dx,dy,nx,ny,c;
        begin
            x = i%8;
            x = i/8;
            c = 0;
            for (dy =-1; dy<=1; dy = dy+1)
                for (dx =-1; dx<=1; dx = dx+1) begin
                    nx = x+dx;
                    ny = y+dy;
                    if ((dx != 0 || dy != 0) && nx >= 0 && nx < 8 && ny >= 0 && ny < 8)
                        if (MINES[ny*8+nx])
                            c = c + 1;
                end
            adj = c;
        end
    endfunction

    assign mines = MINES;

    genvar g;
    generate
        for (g=0;g<64; g=g+1) begin
            assign counts[g*4+:4] = adj(g);
            assign zeros[g] = !MINES[g] && (adj(g)==0);
        end
    endgenerate
endmodule
