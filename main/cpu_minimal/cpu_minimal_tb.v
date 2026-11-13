`timescale 1ns/1ps
module cpu_minimal_tb;
reg clk = 0;
reg rst_n = 0;
wire [31:0] address, instruction, pc;
wire fault, retired;
wire [31:0] retired_pc, retired_instruction, retired_data;
wire [4:0] retired_rd;
integer count;
always #5 clk = ~clk;
instruction_rom rom (.clk(clk), .address(address), .data(instruction));
cpu_minimal dut (.clk(clk), .rst_n(rst_n), .instruction_address(address),
    .instruction_data(instruction), .pc(pc), .fault(fault), .retired(retired),
    .retired_pc(retired_pc), .retired_instruction(retired_instruction),
    .retired_rd(retired_rd), .retired_data(retired_data));

function [31:0] addi;
    input [4:0] rd, rs1;
    input [11:0] imm;
    begin addi = {imm, rs1, 3'b000, rd, 7'b0010011}; end
endfunction
function [31:0] jal;
    input [4:0] rd;
    input [20:0] offset;
    begin jal = {offset[20], offset[10:1], offset[11], offset[19:12], rd, 7'b1101111}; end
endfunction

function [31:0] branch;
    input [4:0] rs1, rs2;
    input [2:0] funct3;
    input [12:0] offset;
    begin branch = {offset[12], offset[10:5], rs2, rs1, funct3,
        offset[4:1], offset[11], 7'b1100011}; end
endfunction

task reset_cpu;
    begin
        @(negedge clk); rst_n = 0;
        repeat (2) @(negedge clk);
        rst_n = 1;
    end
endtask

task expect_retire;
    input [31:0] expected_pc;
    input [4:0] expected_rd;
    input [31:0] expected_data;
    begin
        count = 0;
        begin : wait_retire
            repeat (6) begin
                @(posedge clk); #1;
                if (fault) $fatal(1, "unexpected fault pc=%h", pc);
                if (retired) begin
                    if (retired_pc !== expected_pc || retired_rd !== expected_rd ||
                        retired_data !== expected_data)
                        $fatal(1, "retirement mismatch pc=%h rd=%d data=%h", retired_pc, retired_rd, retired_data);
                    $display("TRACE pc=%08h instruction=%08h rd=x%0d data=%08h", retired_pc, retired_instruction, retired_rd, retired_data);
                    count = 1;
                    disable wait_retire;
                end
            end
        end
        if (count != 1) $fatal(1, "retirement timeout");
    end
endtask

task expect_fault;
    input [31:0] expected_pc;
    begin
        repeat (4) begin @(posedge clk); #1; end
        if (fault !== 1'b1 || pc !== expected_pc || retired !== 1'b0)
            $fatal(1, "fault state mismatch");
        repeat (3) begin
            @(posedge clk); #1;
            if (pc !== expected_pc || fault !== 1'b1 || retired !== 1'b0)
                $fatal(1, "fault did not freeze CPU");
        end
    end
endtask

initial begin
    #10000; $fatal(1, "global timeout");
end
initial begin
    reset_cpu;
    expect_retire(0, 1, 5);
    expect_retire(4, 2, 3);
    expect_retire(8, 3, 8);
    expect_retire(12, 0, 0);
    expect_retire(12, 0, 0);
    if (dut.u_registers.registers[3] !== 8) $fatal(1, "sum missing");
    $display("PASS: boot program and loop");

    @(negedge clk); rst_n = 0;
    rom.words[0] = addi(0, 0, 12'd99);
    rom.words[1] = addi(1, 0, -12'd1);
    rom.words[2] = addi(2, 1, 12'd1);
    rom.words[3] = jal(4, 21'd8);
    rom.words[4] = addi(5, 0, 12'd99);
    rom.words[5] = addi(6, 0, 12'd7);
    rom.words[6] = jal(0, -21'd4);
    reset_cpu;
    expect_retire(0, 0, 0);
    expect_retire(4, 1, 32'hffffffff);
    expect_retire(8, 2, 0);
    expect_retire(12, 4, 16);
    expect_retire(20, 6, 7);
    expect_retire(24, 0, 0);
    expect_retire(20, 6, 7);
    if (dut.u_registers.registers[0] !== 0 || dut.u_registers.registers[5] !== 0)
        $fatal(1, "x0 or skipped instruction changed");
    $display("PASS: x0, dependencies, sign extension, wraparound and bidirectional JAL");

    @(negedge clk); rst_n = 0;
	 rom.words[0] = addi(3, 0, 12'd7);
	 rom.words[1] = 32'h402081b3;
	 reset_cpu;
	 expect_retire(0, 3, 7);
	 expect_fault(4);
	 if (dut.u_registers.registers[3] !== 7)
		 $fatal(1, "unsupported SUB changed x3");
	 $display("PASS: unsupported SUB preserves x3");
	 
    @(negedge clk); rst_n = 0;
    rom.words[0] = jal(1, 21'd2);
    reset_cpu;
    expect_fault(0);
    if (dut.u_registers.registers[1] !== 0) $fatal(1, "misaligned JAL wrote link");
    $display("PASS: misaligned jump faults without writeback");

    @(negedge clk); rst_n = 0;
    rom.words[0] = jal(1, 21'd256);
    reset_cpu;
    expect_retire(0, 1, 4);
    expect_fault(256);
    $display("PASS: ROM address range does not alias");
    @(negedge clk); rst_n = 0;
    rom.words[0] = addi(1, 0, 12'd0);
    rom.words[1] = addi(2, 0, 12'd3);
    rom.words[2] = addi(1, 1, 12'd1);
    rom.words[3] = branch(1, 2, 3'b001, -13'd4);
    rom.words[4] = branch(1, 2, 3'b000, 13'd8);
    rom.words[5] = addi(3, 0, 12'd99);
    rom.words[6] = branch(1, 2, 3'b001, 13'd8);
    rom.words[7] = branch(1, 0, 3'b000, 13'd8);
    rom.words[8] = addi(4, 0, 12'd7);
    reset_cpu;
    expect_retire(0, 1, 0);
    expect_retire(4, 2, 3);
    expect_retire(8, 1, 1);
    expect_retire(12, 0, 0);
    expect_retire(8, 1, 2);
    expect_retire(12, 0, 0);
    expect_retire(8, 1, 3);
    expect_retire(12, 0, 0);
    expect_retire(16, 0, 0);
    expect_retire(24, 0, 0);
    expect_retire(28, 0, 0);
    expect_retire(32, 4, 7);
    if (dut.u_registers.registers[1] !== 3 ||
        dut.u_registers.registers[3] !== 0 || dut.u_registers.registers[4] !== 7 ||
        dut.u_registers.registers[8] !== 0 || dut.u_registers.registers[29] !== 0)
        $fatal(1, "branch changed registers or failed to skip");
    $display("PASS: BEQ/BNE taken and not taken, countdown-free counting loop, no branch writeback");

    @(negedge clk); rst_n = 0;
    rom.words[0] = branch(0, 0, 3'b000, 13'd2);
    reset_cpu;
    expect_fault(0);
    $display("PASS: taken misaligned branch faults");

    @(negedge clk); rst_n = 0;
    rom.words[0] = branch(0, 0, 3'b001, 13'd2);
    rom.words[1] = addi(1, 0, 12'd9);
    reset_cpu;
    expect_retire(0, 0, 0);
    expect_retire(4, 1, 9);
    $display("PASS: untaken misaligned branch target does not fault");

    @(negedge clk); rst_n = 0;
    rom.words[0] = branch(0, 0, 3'b100, 13'd4);
    reset_cpu;
    expect_fault(0);
    $display("PASS: unsupported branch condition faults");
    $display("PASS: all CPU scenarios passed");
    $finish;
end
endmodule
