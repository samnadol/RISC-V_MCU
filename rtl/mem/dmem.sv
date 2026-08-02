module dmem(
    input logic clk,
    
    input logic mem_read,
    input logic mem_write,
    input logic [1:0] mem_width,

    input logic [31:0] addr,
    input logic [31:0] write_data,
    output logic [31:0] read_data
);
    import riscv_pkg::*;

    logic [7:0] ram [0:8191];

    initial begin
        $readmemh("dmem.hex", ram);
    end

    logic mem_active, mem_write_active, mem_read_active;
    assign mem_active = (addr < 32'h2000);
    assign mem_write_active = mem_active & mem_write;
    assign mem_read_active = mem_active & mem_read;
    
    // device selector for MMIO (memory valid from 0x00000000 - 0x0000FFFF theoretically, 0x00000000 - 0x00000800 with current implementation)
    // for UART peripheral, for example, mem_active would be addr[31:16] == 4'h0001, giving it 65535 memory addresses for its stuff

    // write path
    always_ff @(negedge clk) begin
        if (mem_write_active) begin
            case (mem_width)
                MEM_WIDTH_WORD: begin
                    ram[addr + 0] <= write_data[7:0];
                    ram[addr + 1] <= write_data[15:8];
                    ram[addr + 2] <= write_data[23:16];
                    ram[addr + 3] <= write_data[31:24];
                end

                MEM_WIDTH_HALFWORD: begin
                    ram[addr + 0] <= write_data[7:0];
                    ram[addr + 1] <= write_data[15:8];
                end

                MEM_WIDTH_BYTE: begin
                    ram[addr] <= write_data[7:0];
                end

                default: begin end
            endcase
        end
    end

    always_comb begin
        read_data = 32'b0;
        if (mem_read_active) begin
            case (mem_width)
                MEM_WIDTH_WORD: begin
                    read_data = { ram[addr + 3], ram[addr + 2], ram[addr + 1], ram[addr + 0] };
                end

                MEM_WIDTH_HALFWORD: begin
                    read_data = { 16'b0, ram[addr + 1], ram[addr + 0] };
                end

                MEM_WIDTH_BYTE: begin
                    read_data = { 24'b0, ram[addr] };
                end

                default: read_data = 32'b0;
            endcase
        end
    end
endmodule