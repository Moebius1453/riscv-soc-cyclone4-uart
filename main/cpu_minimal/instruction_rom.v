module instruction_rom (
    input wire clk,
    input wire [31:0] address,
    output reg [31:0] data
);
reg [31:0] words [0:63];
integer i;
initial begin
    for (i = 0; i < 64; i = i + 1)
        words[i] = 32'h00000000;
    words[0] = 32'h00500093;
    words[1] = 32'h00300113;
    words[2] = 32'h002081b3;
    words[3] = 32'h0000006f;
end
always @(posedge clk) begin
    if (address[1:0] != 0 || address[31:8] != 0)
        data <= 32'h00000000;
    else
        data <= words[address[7:2]];
end
endmodule
