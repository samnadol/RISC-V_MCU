typedef enum { IDLE, START, DATA, STOP, CLEAN } uart_state_t;

module uart #(
    parameter CLOCK_PSC = 868 // 100,000,000 (100Mhz) / 115200
) (
    input logic clk,
    input logic rst_n,

    input logic read_en,
    input logic write_en,
    input logic [1:0] width,

    input logic [31:0] addr,
    input logic [31:0] wdata,
    output logic [31:0] rdata
);
    logic [7:0] buf_tx, buf_rx, reg_status;
    logic [12:0] clk_count;
    logic uart_clk;

    always_comb begin
        if (read_en) begin
            rdata = { 32'b0 };
        end else begin
            rdata = 32'b0;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            buf_tx <= 8'b0;
            buf_rx <= 8'b0;
            reg_status <= 8'b0;

            clk_count <= 0;
        end else if (write_en) begin
            if (addr == 32'h0)
                buf_tx <= wdata[7:0];
            else if (addr == 32'h2)
                reg_status <= wdata[7:0];
        end

        if (clk_count < CLOCK_PSC - 1) begin
            uart_clk <= 0;
            clk_count <= clk_count + 1;
        end else begin
            uart_clk <= 1;
            clk_count <= 0;
        end
    end

    always_ff @(posedge uart_clk) begin

    end
endmodule