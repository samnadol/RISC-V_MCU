module dmem(
    input logic clk,
    
    input logic mem_read,
    input logic mem_write,
    input logic [2:0] mem_width,

    input logic [31:0] addr,
    input logic [31:0] write_data,
    output logic [31:0] read_data
);
    import riscv_pkg::*;

    logic [3:0][7:0] ram [0:2047];

    logic [10:0] addr_word_index;
    logic [1:0]  addr_byte_offset;
    assign addr_word_index  = addr[12:2];
    assign addr_byte_offset = addr[1:0];

    logic [1:0] mem_width_select;
    logic       mem_width_unsigned;
    assign mem_width_select   = mem_width[1:0];
    assign mem_width_unsigned = mem_width[2];

    logic mem_active, mem_write_active, mem_read_active;
    assign mem_active = (addr < 32'h2000); // valid range: 0x0000 - 0x1FFF (2048 words * 4 bytes)
    assign mem_write_active = mem_active & mem_write;
    assign mem_read_active = mem_active & mem_read;
    
    // device selector for MMIO (memory valid from 0x00000000 - 0x0000FFFF theoretically, 0x00000000 - 0x00000800 with current implementation)
    // for UART peripheral, for example, mem_active would be addr[31:16] == 4'h0001, giving it 65535 memory addresses for its stuff

    // write path
    always_ff @(negedge clk) begin
        if (mem_write_active) begin
            casez (mem_width)
                MEM_WIDTH_WORD: begin
                    ram[addr_word_index] <= write_data;
                end

                MEM_WIDTH_HALFWORD: begin
                    if (addr_byte_offset[1])    ram[addr_word_index][3:2] <= write_data[15:0];
                    else                        ram[addr_word_index][1:0] <= write_data[15:0];
                end

                MEM_WIDTH_BYTE: begin
                    ram[addr_word_index][addr_byte_offset] <= write_data[7:0];
                end

                default: begin end
            endcase
        end
    end

    // read path
    logic [3:0][7:0] raw_word;
    assign raw_word = ram[addr_word_index];

    always_comb begin
        read_data = 32'b0;
        if (mem_read_active) begin
            casez (mem_width)
                MEM_WIDTH_WORD: begin
                    read_data = raw_word;
                end

                MEM_WIDTH_HALFWORD: begin
                    if (addr_byte_offset[1]) begin
                        read_data = {{16{mem_width_unsigned ? 1'b0 : raw_word[3][7]}}, raw_word[3:2]};
                    end else begin
                        read_data = {{16{mem_width_unsigned ? 1'b0 : raw_word[1][7]}}, raw_word[1:0]};
                    end
                end

                MEM_WIDTH_BYTE: begin
                    read_data = {{24{mem_width_unsigned ? 1'b0 : raw_word[addr_byte_offset][7]}}, raw_word[addr_byte_offset]};
                end

                default: read_data = 32'b0;
            endcase
        end
    end
endmodule