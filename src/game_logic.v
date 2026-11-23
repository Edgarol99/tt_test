
module game_logic(
    input  wire clk,
    input  wire rst_n,
    input [63:0] mines,
    input [63:0] zeros,
    input btn,up,down,left,right,
    output reg [63:0] revealed_cells,
    output reg [2:0] player_x,
    output reg [2:0] player_y
);

    //SPREAD
    reg [63:0] pick;
    wire [63:0] spread;
    genvar x,y,dx,dy;
    generate
        for (y=0;y<8;y=y+1) begin
            for (x=0;x<8;x=x+1) begin
                wire[8:0] hit;
                for (dy=0;dy<3;dy=dy+1) begin
                    for (dx=0;dx<3;dx=dx+1) begin
                        localparam NX = x+dx-1;
                        localparam NY = x+dx-1;
                        if (NX>=0 && NX<8 && NY>=0 && NY<8 && (dx==1 && dy==1))
                            assign hit[dy*3+dx] = revealed_cells[NY*8+NX] & zeros[NY*8+NX];
                        else 
                            assign hit [dy*3+dx] = 1'b0;
                    end
                end
                assign spread[y*8+x] = |hit;
            end
        end
    endgenerate

    //STATES
    localparam START = 0;
    localparam PLAY = 1;
    localparam GAMEOVER = 2;
    localparam WIN = 3;

    reg [1:0] current_state;
    reg [1:0] next_state;
    
    always @ (posedge clk or negedge rst_n) begin: STATE_MEMORY
        if (!rst_n)
            current_state <= PLAY;
        else
            current_state<=next_state;
    end

    always @ (current_state) begin: NEXT_STATE_LOGIC_AND_OUTPUT_LOGIC
        case (current_state)
            START : begin
                player_x <= 0;
                player_y <= 0;
                revealed_cells = 64'b0;
                if (btn) begin
                    next_state <= PLAY;
                end
            end
            PLAY : begin
                if (down)
                    player_y <= player_y+1;
                if (up)
                    player_y <= player_y-1;
                if (left)
                    player_x <= player_x-1;
                if (right)
                    player_x <= player_x+1;
                if (btn) begin
                    if (!revealed_cells[player_id]) begin
                        pick[player_id] <= 1;
                        if (mines[player_id])
                            next_state <= GAMEOVER;
                    end
                end
                revealed_cells <= revealed_cells | spread | pick;
            end
            GAMEOVER : begin 
                if (btn) begin
                    next_state <= START;
                end
            end
         endcase
     end

    wire [7:0] player_id = {player_y, player_x};

endmodule
