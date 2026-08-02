module soc_top(
    input logic clk,
    input logic rst,
    output logic [31:0] debug_pc,
    output logic simulation_end
);
    logic [31:0] imem_addr, imem_data;
    logic [31:0] dmem_addr, dmem_rdata, dmem_wdata;
    logic dmem_read, dmem_write;
    logic [2:0] dmem_width;

    cpu_top core(
        .clk(clk),
        .rst(rst),

        .imem_addr(imem_addr),
        .imem_data(imem_data),

        .dmem_addr(dmem_addr),
        .dmem_read(dmem_read),
        .dmem_rdata(dmem_rdata),
        .dmem_write(dmem_write),
        .dmem_wdata(dmem_wdata),
        .dmem_width(dmem_width),

        .debug_pc(debug_pc),
        .simulation_end(simulation_end)
    );

    imem instuction_memory(
        .addr(imem_addr),
        .data(imem_data)
    );

    // replace with dbus, in bus/. that then manages MMIO regions, instantiates dmem and peripherals like UART, in peripherals/
    dmem data_memory(
        .clk(clk),

        .mem_read(dmem_read),
        .mem_write(dmem_write),
        .mem_width(dmem_width),

        .addr(dmem_addr),
        .write_data(dmem_wdata),
        .read_data(dmem_rdata)
    );
endmodule