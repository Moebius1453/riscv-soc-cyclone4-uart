module uart_echo (
    input  wire clk,
    input  wire rst_n,
    input  wire uart_rx,
    output wire uart_tx
);

wire [7:0] rx_data;
wire       rx_valid;

reg  [7:0] tx_data;
reg        tx_start;
wire       tx_busy;

uart_rx u_rx (
    .clk      (clk),
    .rst_n    (rst_n),
    .rx       (uart_rx),
    .rx_data  (rx_data),
    .rx_valid (rx_valid)
);

always @(posedge clk or negedge rst_n)begin
	if (!rst_n) begin
		tx_data  <= 8'd0;
		tx_start <= 1'b0;
		end else begin
			tx_start <= 1'b0;
				if (rx_valid && !tx_busy) begin
					tx_data <= rx_data; 
					tx_data  <= rx_data;
					tx_start <= 1'b1;
		end	
	end
end


uart_tx u_tx (
    .clk      (clk),
    .rst_n    (rst_n),
    .tx_data  (tx_data),
    .tx_start (tx_start),
    .tx_busy  (tx_busy),
    .tx       (uart_tx)
);

endmodule