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

    logic dmem_select, gpio_select;
    
    /* verilator lint_off UNSIGNED */
    assign dmem_select = (addr >= DMEM_BASE && addr < (DMEM_BASE + DMEM_SIZE));
    /* verilator lint_on UNSIGNED */
    assign gpio_select = (addr >= GPIO_BASE && addr < (GPIO_BASE + GPIO_SIZE));

    logic [31:0] dmem_out, gpio_out;

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

    gpio_peripheral gpio_a(
        .clk(clk),
        .rst_n(rst_n),

        .read_en(ren & gpio_select),
        .write_en(wen & gpio_select),
        .width(width),

        .addr(addr - GPIO_BASE),
        .wdata(wdata),
        .rdata(gpio_out)
    );

    always_comb begin
        case ({ gpio_select, dmem_select })
            2'b01: rdata = dmem_out;
            2'b10: rdata = gpio_out;
            default: rdata = 32'b0;
        endcase
    end
endmodule