module dmem(
    input logic clk,
    input logic rst_n,
    
    input logic read_en,
    input logic write_en,
    input logic [1:0] width,

    input logic [31:0] addr,
    input logic [31:0] write_data,
    output logic [31:0] read_data
);
    import riscv_pkg::*;

    logic [7:0] ram [0:8191];

    initial begin
        $readmemh("dmem.hex", ram);
    end
    
    always_ff @(posedge clk) begin
        if (write_en) begin
            case (width)
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
        if (read_en) begin
            case (width)
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