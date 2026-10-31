module cpu_minimal (
    input wire clk,
    input wire rst_n,
    output wire [31:0] instruction_address,
    input wire [31:0] instruction_data,
    output reg [31:0] pc,
    output reg fault,
    output reg retired,
    output reg [31:0] retired_pc,
    output reg [31:0] retired_instruction,
    output reg [4:0] retired_rd,
    output reg [31:0] retired_data
);
localparam FETCH = 1'b0, EXECUTE = 1'b1;
reg state;
wire [6:0] opcode = instruction_data[6:0];
wire [4:0] rd = instruction_data[11:7];
wire [31:0] rs1_data, rs2_data;
wire [31:0] immediate_i = {{20{instruction_data[31]}}, instruction_data[31:20]};
wire [31:0] immediate_j = {{11{instruction_data[31]}}, instruction_data[31],
    instruction_data[19:12], instruction_data[20], instruction_data[30:21], 1'b0};
reg valid_instruction;
reg [31:0] next_pc;
reg [31:0] write_data;
reg [31:0] alu_b;
wire [31:0] alu_result;
wire alu_zero;
wire write_enable = (state == EXECUTE) && !fault && valid_instruction &&
    (next_pc[1:0] == 2'b00);
assign instruction_address = pc;

alu u_alu (.a(rs1_data), .b(alu_b), .op(2'b00),
    .result(alu_result), .zero(alu_zero));
regfile u_registers (
    .clk(clk), .rst_n(rst_n), .rs1(instruction_data[19:15]),
    .rs2(instruction_data[24:20]), .rs1_data(rs1_data), .rs2_data(rs2_data),
    .write_enable(write_enable), .rd(rd), .write_data(write_data)
);

always @(*) begin
    valid_instruction = 1'b0;
    next_pc = pc + 32'd4;
    alu_b = rs2_data;
    write_data = alu_result;
    case (opcode)
        7'b0010011: begin
            alu_b = immediate_i;
            valid_instruction = (instruction_data[14:12] == 3'b000);
        end
        7'b0110011: begin
            valid_instruction = (instruction_data[14:12] == 3'b000) &&
                (instruction_data[31:25] == 7'b0000000);
        end
        7'b1101111: begin
            valid_instruction = 1'b1;
            next_pc = pc + immediate_j;
            write_data = pc + 32'd4;
        end
        default: valid_instruction = 1'b0;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= 32'd0;
        state <= FETCH;
        fault <= 1'b0;
        retired <= 1'b0;
        retired_pc <= 32'd0;
        retired_instruction <= 32'd0;
        retired_rd <= 5'd0;
        retired_data <= 32'd0;
    end else begin
        retired <= 1'b0;
        if (!fault) begin
            if (state == FETCH) begin
                state <= EXECUTE;
            end else if (!valid_instruction || next_pc[1:0] != 2'b00) begin
                fault <= 1'b1;
            end else begin
                pc <= next_pc;
                state <= FETCH;
                retired <= 1'b1;
                retired_pc <= pc;
                retired_instruction <= instruction_data;
                retired_rd <= rd;
                retired_data <= (rd == 0) ? 32'd0 : write_data;
            end
        end
    end
end
endmodule
