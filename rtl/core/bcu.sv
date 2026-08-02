module bcu(
    input logic [2:0] branch_op,
    input logic [31:0] rv1,
    input logic [31:0] rv2,

    output logic branch
);
    import riscv_pkg::*;

    always_comb begin
        case (branch_op)
            BRANCH_BEQ: branch = (rv1 == rv2);                      // BEQ
            BRANCH_BNE: branch = (rv1 != rv2);                      // BNE

            BRANCH_BLT: branch = (signed'(rv1) < signed'(rv2));     // BLT
            BRANCH_BGE: branch = (signed'(rv1) >= signed'(rv2));    // BGE

            BRANCH_BLTU: branch = (rv1 < rv2);                       // BLTU
            BRANCH_BGEU: branch = (rv1 >= rv2);                      // BGEU

            default: branch = 1'b0;
        endcase
    end
endmodule