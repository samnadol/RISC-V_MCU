module reg_file(
    input logic clk,
    input logic rst,

    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2,

    input logic rd_write,
    input logic [31:0] rd_write_val,

    output logic [31:0] rv1,
    output logic [31:0] rv2
);
    logic [31:0] registers [0:31];

    always_comb begin
        rv1 = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
        rv2 = (rs2 == 5'b0) ? 32'b0 : registers[rs2];
    end

    always_ff @(negedge clk) begin
        if (rd_write && rd != 5'b0)
            registers[rd] <= rd_write_val;
    end
endmodule