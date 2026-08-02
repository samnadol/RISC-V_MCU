module alu(
    input logic [31:0] alu_in_a,
    input logic [31:0] alu_in_b,
    input logic [3:0] alu_op,

    output logic [31:0] alu_out,
    output logic zero               // 0 = alu output not zero, 1 = alu output zero
);
    import riscv_pkg::*;
    
    always_comb begin
        alu_out = 32'b0;

        case (alu_op)
            // arithmetic 
            ALU_ADD: alu_out = alu_in_a + alu_in_b;
            ALU_SUB: alu_out = alu_in_a - alu_in_b;

            // bitwise 
            ALU_OR:  alu_out = alu_in_a | alu_in_b;
            ALU_AND: alu_out = alu_in_a & alu_in_b;
            ALU_XOR: alu_out = alu_in_a ^ alu_in_b;

            // shift
            ALU_SLL: alu_out = alu_in_a << alu_in_b[4:0];
            ALU_SRL: alu_out = alu_in_a >> alu_in_b[4:0];
            ALU_SRA: alu_out = alu_in_a >>> alu_in_b[4:0];

            // comparison
            ALU_SLT: begin
                if (signed'(alu_in_a) < signed'(alu_in_b)) alu_out = 32'b1;
                else                                       alu_out = 32'b0;
            end
            ALU_SLTU: begin
                if (alu_in_a < alu_in_b) alu_out = 32'b1;
                else                     alu_out = 32'b0;
            end

            // helpers
            ALU_COPY_B: alu_out = alu_in_b;

            default: alu_out = 32'b0;
        endcase
    end
    assign zero = (alu_out == 32'b0);
endmodule