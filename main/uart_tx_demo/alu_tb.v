module alu_tb;

reg  [7:0] a;
reg  [7:0] b;
reg        op;
wire [7:0] result;

alu u_alu (
    .a      (a),
    .b      (b),
    .op     (op),
    .result (result)
);

initial begin
    a = 8'd5; b = 8'd3; op = 1'b0;
    #10 $display("5 + 3 = %0d", result);

    op = 1'b1;
    #10 $display("5 & 3 = %0d", result);

    a = 8'd250; b = 8'd10; op = 1'b0;
    #10 $display("250 + 10 = %0d", result);

    $finish;
end

endmodule