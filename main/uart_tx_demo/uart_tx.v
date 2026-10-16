module uart_tx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output reg        tx_busy,
    output reg        tx
);

localparam integer CLKS_PER_BIT = 5208;

reg [12:0] baud_cnt;
reg [7:0] data_buf;
reg [3:0] bit_cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_buf <= 8'd0;
        tx_busy  <= 1'b0;
        tx       <= 1'b1;
		  baud_cnt <= 13'd0;
		  bit_cnt <= 4'd0;
    
	end else begin
		 if (!tx_busy && tx_start) begin
			  data_buf <= tx_data;
			  tx_busy  <= 1'b1;
			  baud_cnt <= 13'd0;
			  bit_cnt <= 4'd0;
			  tx      <= 1'b0;
				end else if (tx_busy) begin
				if (baud_cnt == CLKS_PER_BIT - 1) begin
					baud_cnt <= 13'd0;	
					if (bit_cnt == 4'd9) begin											
						  tx_busy <= 1'b0;
					 end else begin
						  bit_cnt <= bit_cnt + 4'd1;

						  if (bit_cnt < 4'd8) begin
								tx <= data_buf[bit_cnt];
						  end else begin
								tx <= 1'b1;
						  end
					 end
				end else begin	 
					baud_cnt <= baud_cnt + 13'd1;	 	  
			   end
		 end
	end
end
endmodule