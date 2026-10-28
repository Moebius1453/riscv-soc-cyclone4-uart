module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input wire  [1:0] op,
    output reg  [31:0] result,
	 output wire zero
);

always @(*) begin
    case (op)
        2'b00: result = a + b;   // 加法
        2'b01: result = a & b;   // 按位与
        2'b10: result = a - b;   // 减法
        default: result = 32'd0;
    endcase
end

assign zero = (result == 32'd0);

endmodule