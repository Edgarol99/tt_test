
`timescale 1ns / 1ps

module map_tb;

wire [63:0] mines;
wire [63:0] zeros;
wire [255:0] counts;

map dut (mines,zeros,counts);

initial begin
    $dumpfile("map_tb.vcd");
    $dumpvars(0, map_tb);
    #50 $finish;
end

endmodule