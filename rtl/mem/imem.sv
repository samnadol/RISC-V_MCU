module imem(
    input logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] mem [0:1023];

    initial begin
        $readmemh("program.hex", mem);
    end

    assign data = mem[addr[11:2]];
endmodule