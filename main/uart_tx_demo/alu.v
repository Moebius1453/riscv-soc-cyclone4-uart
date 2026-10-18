module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire       op,
    output reg  [7:0] result
);

always @(*) begin
    if (op == 1'b0) begin
        result = a + b;
    end else begin
        result = a & b;
    end
end

endmodule