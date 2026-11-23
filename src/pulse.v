
module pulse (
    input wire clk,
    input wire btn,   
    output reg press 
);

    reg last;
    always @(posedge clk) begin
        if (~rst_n)
            press <= 1'b0;
        else 
            press <= btn && ~last;
        last <= btn;
    end

endmodule
