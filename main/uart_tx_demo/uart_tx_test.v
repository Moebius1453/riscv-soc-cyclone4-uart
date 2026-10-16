module uart_tx_test (
    input  wire clk,
    input  wire rst_n,
    output wire uart_tx
);

reg [7:0] tx_data;
reg       tx_start;
wire      tx_busy;
reg [25:0] interval_cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        interval_cnt <= 26'd0;
        tx_data      <= 8'h41;
        tx_start     <= 1'b0;
		  
    end else begin
        tx_start <= 1'b0;
			if (tx_start && !tx_busy) begin
						 if (tx_data == 8'h41) begin
							  tx_data <= 8'h42;
						 end else begin
							  tx_data <= 8'h41;
						 end
					end
        if (interval_cnt == 26'd49999999) begin
            interval_cnt <= 26'd0;

            if (!tx_busy) begin
                tx_start <= 1'b1;
            end
        end else begin
            interval_cnt <= interval_cnt + 26'd1;
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