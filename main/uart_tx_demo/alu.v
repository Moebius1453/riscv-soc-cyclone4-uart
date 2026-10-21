module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input wire  [1:0] op,
    output reg  [7:0] result
);

always @(*) begin
    case (op)
        2'b00: result = a + b;   // 加法
        2'b01: result = a & b;   // 按位与
        2'b10: result = a - b;   // 减法
        default: result = 8'd0;
    endcase
end

endmodule