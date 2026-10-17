module uart_rx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    output reg  [7:0] rx_data,
    output reg        rx_valid
);

reg rx_meta;
reg rx_sync;

localparam [1:0] IDLE  = 2'd0;
localparam [1:0] START = 2'd1;
localparam [1:0] DATA  = 2'd2;
localparam [1:0] STOP  = 2'd3;

localparam integer CLKS_PER_BIT = 5208;

reg [1:0] state;
reg [12:0] baud_cnt;
reg [2:0] bit_cnt;
reg [7:0] data_buf;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_meta <= 1'b1;
        rx_sync <= 1'b1;
    end else begin
        rx_meta <= rx;
        rx_sync <= rx_meta;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state    <= IDLE;
        baud_cnt <= 13'd0;
        bit_cnt  <= 3'd0;
        data_buf <= 8'd0;
        rx_data  <= 8'd0;
        rx_valid <= 1'b0;
    end else begin
        rx_valid <= 1'b0;

        case (state)
            IDLE: begin
                baud_cnt <= 13'd0;
                bit_cnt  <= 3'd0;

                if (!rx_sync) begin
                    state <= START;
                end
            end

            START: begin
                if (baud_cnt == CLKS_PER_BIT / 2 - 1) begin
                    baud_cnt <= 13'd0;

                    if (!rx_sync) begin
                        state <= DATA;
                    end else begin
                        state <= IDLE;
                    end
                end else begin
                    baud_cnt <= baud_cnt + 13'd1;
                end
            end

            DATA: begin
						 if (baud_cnt == CLKS_PER_BIT - 1) begin
							  baud_cnt <= 13'd0;
							  data_buf[bit_cnt] <= rx_sync;

							  if (bit_cnt == 3'd7) begin
									state <= STOP;
							  end else begin
									bit_cnt <= bit_cnt + 3'd1;
							  end
						 end else begin
							  baud_cnt <= baud_cnt + 13'd1;
						 end
					end

            STOP: begin
						 if (baud_cnt == CLKS_PER_BIT - 1) begin
							  baud_cnt <= 13'd0;
							  state <= IDLE;

							  if (rx_sync) begin
									rx_data  <= data_buf;
									rx_valid <= 1'b1;
							  end
						 end else begin
							  baud_cnt <= baud_cnt + 13'd1;
						 end
					end

            default: begin
                state <= IDLE;
            end
        endcase
    end
end



endmodule