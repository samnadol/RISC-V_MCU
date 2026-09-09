module dbus(
    input logic clk,
    input logic rst_n,

    input logic [31:0] addr,
    input logic [1:0]  width,
    input logic        ren,
    input logic        wen,

    input logic [31:0] wdata,
    output logic [31:0] rdata
);
    localparam logic [31:0] DMEM_BASE = 32'h0000_0000;
    localparam logic [31:0] DMEM_SIZE = 32'h0000_2000; // 8KB
    
    localparam logic [31:0] GPIO_BASE = 32'h1000_0000;
    localparam logic [31:0] GPIO_SIZE = 32'h0000_0100; // 256B

    localparam logic [31:0] UART_BASE = 32'h2000_0000;
    localparam logic [31:0] UART_SIZE = 32'h0000_0100; // 256B
    
    /* verilator lint_off UNSIGNED */
    assign dmem_select = (addr >= DMEM_BASE && addr < (DMEM_BASE + DMEM_SIZE));
    /* verilator lint_on UNSIGNED */
    assign gpio_select = (addr >= GPIO_BASE && addr < (GPIO_BASE + GPIO_SIZE));
    assign uart_select = (addr >= UART_BASE && addr < (UART_BASE + UART_SIZE));

    logic dmem_select, gpio_select, uart_select;
    logic [31:0] dmem_out, gpio_out, uart_out;

    dmem data_memory(
        .clk(clk),
        .rst_n(rst_n),

        .read_en(ren & dmem_select),
        .write_en(wen & dmem_select),
        .width(width),

        .addr(addr - DMEM_BASE),
        .write_data(wdata),
        .read_data(dmem_out)
    );

    gpio gpio_a(
        .clk(clk),
        .rst_n(rst_n),

        .read_en(ren & gpio_select),
        .write_en(wen & gpio_select),
        .width(width),

        .addr(addr - GPIO_BASE),
        .wdata(wdata),
        .rdata(gpio_out)
    );

    uart uart_a(
        .clk(clk),
        .rst_n(rst_n),

        .read_en(ren & uart_select),
        .write_en(wen & uart_select),
        .width(width),

        .addr(addr - UART_BASE),
        .wdata(wdata),
        .rdata(uart_out)
    );

    always_comb begin
        case ({ uart_select, gpio_select, dmem_select })
            3'b001: rdata = dmem_out;
            3'b010: rdata = gpio_out;
            3'b100: rdata = uart_out;
            default: rdata = 32'b0;
        endcase
    end
endmodule