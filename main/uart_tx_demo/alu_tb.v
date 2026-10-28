module alu_tb;

reg  [31:0] a;
reg  [31:0] b;
reg  [1:0] op;
wire [31:0] result;
wire zero;

alu u_alu (
    .a      (a),
    .b      (b),
    .op     (op),
    .result (result),
    .zero   (zero)
);

initial begin
    a = 32'd5; b = 32'd3; op = 2'b00;
    #10 $display("5 + 3 = %0d, zero = %0b", result, zero);
    if (result !== 32'd8 || zero !== 1'b0) $fatal(1, "addition failed");

    op = 2'b01;
    #10 $display("5 & 3 = %0d, zero = %0b", result, zero);
    if (result !== 32'd1 || zero !== 1'b0) $fatal(1, "bitwise AND failed");

    a = 32'd250; b = 32'd10; op = 2'b00;
    #10 $display("250 + 10 = %0d, zero = %0b", result, zero);
    if (result !== 32'd260 || zero !== 1'b0) $fatal(1, "widened addition failed");

    a = 32'hffff_ffff; b = 32'd1;
    #10 $display("ffffffff + 1 = %08h, zero = %0b", result, zero);
    if (result !== 32'd0 || zero !== 1'b1) $fatal(1, "wraparound failed");

    a = 32'd5; b = 32'd3; op = 2'b10;
    #10 $display("5 - 3 = %0d, zero = %0b", result, zero);
    if (result !== 32'd2 || zero !== 1'b0) $fatal(1, "subtraction failed");

    a = 32'd3; b = 32'd5;
    #10 $display("3 - 5 = %08h, zero = %0b", result, zero);
    if (result !== 32'hffff_fffe || zero !== 1'b0) $fatal(1, "negative subtraction failed");

    op = 2'b11;
    #10 $display("unused op = %0d, zero = %0b", result, zero);
    if (result !== 32'd0 || zero !== 1'b1) $fatal(1, "default operation failed");

    a = 32'd5; b = 32'd5; op = 2'b10;
    #10 $display("5 - 5 = %0d, zero = %0b", result, zero);
    if (result !== 32'd0 || zero !== 1'b1) $fatal(1, "zero assertion failed");

    b = 32'd3;
    #10 $display("5 - 3 = %0d, zero = %0b", result, zero);
    if (result !== 32'd2 || zero !== 1'b0) $fatal(1, "zero clearing failed");

    $display("PASS: all 9 ALU checks passed");
    $finish;
end

endmodule
