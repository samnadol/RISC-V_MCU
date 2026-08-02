module imem(
    input logic [31:0] addr,
    output logic [31:0] data
);
    logic [7:0] mem [0:4095];

    initial begin
        $readmemh("imem.hex", mem);
    end

    assign data = { mem[addr+3], mem[addr+2], mem[addr+1], mem[addr] };
endmodule