module regfile (
    input wire clk,
    input wire rst_n,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    input wire write_enable,
    input wire [4:0] rd,
    input wire [31:0] write_data
);
reg [31:0] registers [0:31];
integer i;
assign rs1_data = (rs1 == 0) ? 32'd0 : registers[rs1];
assign rs2_data = (rs2 == 0) ? 32'd0 : registers[rs2];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'd0;
    end else if (write_enable && rd != 0) begin
        registers[rd] <= write_data;
    end
end
endmodule
