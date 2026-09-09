module soc_top(
    input logic clk,
    input logic rst_n,
    output logic [31:0] debug_pc,
    output logic simulation_end,

    // external pins
    output logic [7:0] gpio_pins,
    input  logic       uart_rx,
    output logic       uart_tx
);
    logic [31:0] imem_addr, imem_data;
    logic [31:0] dbus_addr, dbus_rdata, dbus_wdata;
    logic dbus_read, dbus_write;
    logic [1:0] dbus_width;

    cpu_top core(
        .clk(clk),
        .rst_n(rst_n),

        .imem_addr(imem_addr),
        .imem_data(imem_data),

        .dbus_addr(dbus_addr),
        .dbus_read(dbus_read),
        .dbus_rdata(dbus_rdata),
        .dbus_write(dbus_write),
        .dbus_wdata(dbus_wdata),
        .dbus_width(dbus_width),

        .debug_pc(debug_pc),
        .simulation_end(simulation_end)
    );

    imem instuction_memory(
        .addr(imem_addr),
        .data(imem_data)
    );

    dbus data_bus(
        .clk(clk),
        .rst_n(rst_n),

        .addr(dbus_addr),
        .width(dbus_width),
        .ren(dbus_read),
        .wen(dbus_write),
        .wdata(dbus_wdata),
        .rdata(dbus_rdata),

        .gpio_pins(gpio_pins),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );
endmodule