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
    output logic [31:0] rdata,

    input logic rx,  // external interface
    output logic tx
);
    localparam UART_REG_STATUS  = 32'h0; // status register, r
    localparam UART_BUF_TX      = 32'h1; // tx buffer, w
    localparam UART_BUF_RX      = 32'h2; // rx buffer, r

    localparam UART_STATUS_IDLE = (1<<0); // peripheral idle

    logic [7:0] buf_tx, buf_rx, reg_status;
    logic tx_busy;

    always_comb begin
        if (read_en) begin
            if (addr == UART_REG_STATUS)
                rdata = { 24'b0, reg_status };
            else if (addr == UART_BUF_RX)
                rdata = { 24'b0, buf_rx };
            else
                rdata = { 32'b0 };
        end else begin
            rdata = 32'b0;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            buf_tx <= 8'b0;
            buf_rx <= 8'b0;
        end else if (write_en) begin
            if (addr == UART_BUF_TX)
                buf_tx <= wdata[7:0];
        end
    end

    uart_tx #(.CLOCK_PSC(CLOCK_PSC)) tx_unit (
        .clk(clk),
        .rst_n(rst_n),

        .data(wdata[7:0]), // change to tx_buf when FIFO is added
        .start(write_en && addr == UART_BUF_TX),
        .busy(tx_busy),
        .tx_out(tx)
    );

    assign reg_status = { 7'b0, !tx_busy };
endmodule