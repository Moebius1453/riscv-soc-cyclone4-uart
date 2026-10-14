module uart_tx_demo (
    input  wire clk,
    input  wire rst_n,
    output reg  uart_tx
	 
);
	reg [12:0] baud_cnt;
	reg [3:0] bit_cnt;
	always @(posedge clk or negedge rst_n)begin
	
	if (!rst_n) begin
    uart_tx <= 1'b1;
	 baud_cnt <= 13'd0;
	 bit_cnt <= 4'd0;
	end else begin
	case (bit_cnt)
    4'd0: uart_tx <= 1'b0;
	 4'd1: uart_tx <= 1'b1;
	 4'd2: uart_tx <= 1'b0;
	 4'd3: uart_tx <= 1'b1;
	 4'd4: uart_tx <= 1'b0;
	 4'd5: uart_tx <= 1'b1;
	 4'd6: uart_tx <= 1'b0;
	 4'd7: uart_tx <= 1'b1;
	 4'd8: uart_tx <= 1'b0;
    4'd9: uart_tx <= 1'b1;
    default: uart_tx <= 1'b1;
	endcase
    if (baud_cnt == 13'd5207) begin
        baud_cnt <= 13'd0;
		  if (bit_cnt == 4'd9) begin
		  bit_cnt <= 4'd0;
		  end else begin
		  bit_cnt <= bit_cnt + 4'd1;
	 end
		  
    end else begin
        baud_cnt <= baud_cnt + 13'd1;
		end
    end
	end

endmodule