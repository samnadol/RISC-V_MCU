module imm_dec(
    input logic [2:0] imm_type,
    input logic [31:0] inst,
    output logic [31:0] imm
);
    import riscv_pkg::*;
    
    always_comb begin
        case (imm_type)
            IMM_I:      imm = {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20]};
            IMM_S:      imm = {{21{inst[31]}}, inst[30:25], inst[11:8], inst[7]};
            IMM_B:      imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            IMM_U:      imm = {inst[31], inst[30:20], inst[19:12], 12'b0};
            IMM_J:      imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
            IMM_NONE:   imm = 32'b0; // Explicitly zero out for no immediate (R-type instructions)
            default:    imm = 32'b0;
        endcase
    end
endmodule