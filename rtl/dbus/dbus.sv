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
    logic dmem_select, gpio_select;
    assign dmem_select = (addr < 32'h200);
    assign gpio_select = (addr >= 32'h200 && addr < 32'h300);

    logic [31:0] dmem_out, gpio_out;

    dmem data_memory(
        .clk(clk),
        .rst_n(rst_n),

        .read_en(ren & dmem_select),
        .write_en(wen & dmem_select),
        .width(width),

        .addr(addr),
        .write_data(wdata),
        .read_data(dmem_out)
    );

    gpio_peripheral gpio_a(
        .clk(clk),
        .rst_n(rst_n),

        .read_en(ren & gpio_select),
        .write_en(wen & gpio_select),
        .width(width),

        .addr(addr),
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