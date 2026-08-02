module inst_dec(
    input logic [31:0] inst,            // input instruction

    output logic [4:0] rs1,             // source register 1
    output logic [4:0] rs2,             // source register 2
    output logic [4:0] rd,              // destination register

    output logic [31:0] imm,            // immediate value
    
    // control signals
    output logic rd_write,              // write alu result to destination register

    output logic [2:0] branch_op,       // type of branching to perform
    output logic [2:0] mem_width,       // width of memory access

    output logic [3:0] alu_op,          // alu operation to perform
    output logic alu_src_a,             // alu operand one source, 0 = rs1, 1 = pc
    output logic alu_src_b,             // alu operand two source, 0 = rs2, 2 = imm

    output logic mem_read,              // read value at address from alu result (rs1 + imm) to rd
    output logic mem_write,             // write value from rs2 at mem address from alu result (rs1 + imm)
    output logic branch,                // enable branching (to alu result) if cond. met
    output logic jump,                  // enable jumping (to alu result) if cond. met
    output logic system_halt            // permanently stop the system
);
    import riscv_pkg::*;

    logic [6:0] opcode;
    logic [2:0] funct3; 
    logic [6:0] funct7; 

    assign opcode = inst[6:0];
    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];

    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign rd = inst[11:7];

    logic [2:0] imm_type;
    always_comb begin
        rd_write    = 1'b0;
        alu_op      = ALU_ADD;
        branch_op   = BRANCH_BEQ;
        mem_width   = MEM_WIDTH_WORD;
        alu_src_a   = 1'b0;
        alu_src_b   = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        branch      = 1'b0;
        jump        = 1'b0;
        imm_type    = IMM_NONE;
        system_halt = 1'b0;

        case (opcode)
            OP_REG: begin
                rd_write = 1'b1;
                alu_src_a = 1'b0;
                alu_src_b = 1'b0;
                imm_type = IMM_NONE;
                alu_op = alu_op_e'({ funct7[5], funct3 });
            end

            OP_REG_IMM: begin 
                rd_write = 1'b1;
                alu_src_a = 1'b0;
                alu_src_b = 1'b1;
                imm_type = IMM_I;

                if ((funct3 == 3'b001) || (funct3 == 3'b101))
                    alu_op = alu_op_e'({ funct7[5], funct3 });
                else
                    alu_op = alu_op_e'({1'b0, funct3});
            end

            OP_LUI: begin
                rd_write = 1'b1;
                alu_src_a = 1'b0;
                alu_src_b = 1'b1;
                imm_type = IMM_U;
                alu_op = ALU_COPY_B;
            end

            OP_AUIPC: begin
                rd_write = 1'b1;
                alu_src_a = 1'b1;
                alu_src_b = 1'b1;
                imm_type = IMM_U;
                alu_op = ALU_ADD;
            end

            OP_LOAD: begin
                rd_write = 1'b1;
                alu_src_a = 1'b0;
                alu_src_b = 1'b1;
                imm_type = IMM_I;
                alu_op = ALU_ADD;
                mem_read = 1'b1;
                mem_width = mem_width_e'(funct3);
            end

            OP_STORE: begin
                rd_write = 1'b0;
                alu_src_a = 1'b0;
                alu_src_b = 1'b1;
                imm_type = IMM_S;
                alu_op = ALU_ADD;
                mem_write = 1'b1;
                mem_width = mem_width_e'(funct3);
            end

            OP_BRANCH: begin
                rd_write = 1'b0;
                alu_src_a = 1'b1;
                alu_src_b = 1'b1;
                imm_type = IMM_B;
                alu_op = ALU_ADD;
                branch = 1'b1;
                branch_op = branch_type_e'(funct3);
            end

            OP_JAL: begin
                rd_write = 1'b1;
                alu_src_a = 1'b1;
                alu_src_b = 1'b1;
                imm_type = IMM_J;
                alu_op = ALU_ADD;
                jump = 1'b1;
            end

            OP_JALR: begin
                rd_write = 1'b1;
                alu_src_a = 1'b0;
                alu_src_b = 1'b1;
                imm_type = IMM_I;
                alu_op = ALU_ADD;
                jump = 1'b1;
            end

            OP_MISC_MEM: begin // handle FENCE instructions. single-cycle cpu needs no extra work here.
                imm_type = IMM_I;
                rd_write = 1'b0;
                mem_write = 1'b0;
            end

            OP_SYSTEM: begin
                if (inst == 32'h00000073 || inst == 32'h00100073) begin
                    system_halt = 1'b1;
                end
            end

            default: begin end
        endcase
    end

    imm_dec immediate_decoder(
        .imm_type(imm_type),
        .inst(inst),
        .imm(imm)
    );
endmodule