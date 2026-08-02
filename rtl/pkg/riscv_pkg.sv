package riscv_pkg;
    // RISC-V 7-bit Opcodes
    typedef enum logic [6:0] {
        OP_REG      = 7'b0110011,
        OP_REG_IMM  = 7'b0010011,
        OP_LUI      = 7'b0110111,
        OP_AUIPC    = 7'b0010111,

        OP_LOAD     = 7'b0000011,
        OP_STORE    = 7'b0100011,

        OP_BRANCH   = 7'b1100011,
        OP_JAL      = 7'b1101111,
        OP_JALR     = 7'b1100111,

        OP_SYSTEM   = 7'b1110011,
        OP_MISC_MEM = 7'b0001111,

        OP_ILLEGAL  = 7'b0000000
    } opcode_e;

    // immediate types
    typedef enum logic[2:0] {
        IMM_I = 3'b000,
        IMM_S = 3'b001,
        IMM_B = 3'b010,
        IMM_U = 3'b011,
        IMM_J = 3'b100,
        IMM_NONE = 3'b111
    } immediate_type_e;

    // branch types
    typedef enum logic[2:0] {
        BRANCH_BEQ  = 3'b000,
        BRANCH_BNE  = 3'b001,
        BRANCH_BLT  = 3'b100,
        BRANCH_BGE  = 3'b101,
        BRANCH_BLTU = 3'b110,
        BRANCH_BGEU = 3'b111
    } branch_type_e;

    typedef enum logic[1:0] {
        MEM_WIDTH_BYTE          = 2'b00,
        MEM_WIDTH_HALFWORD      = 2'b01,
        MEM_WIDTH_WORD          = 2'b10
    } mem_width_e;

    // ALU Operation Selectors, { funct7[5], funct3 }
    typedef enum logic [3:0] {
        // arithmetic 
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b1000,

        // bitwise 
        ALU_OR   = 4'b0110,
        ALU_AND  = 4'b0111,
        ALU_XOR  = 4'b0100,

        // shift
        ALU_SLL  = 4'b0001,
        ALU_SRL  = 4'b0101,
        ALU_SRA  = 4'b1101,

        // comparison
        ALU_SLT  = 4'b0010,
        ALU_SLTU = 4'b0011,

        // helpers
        ALU_COPY_B = 4'b1111 // copy src b to rd
    } alu_op_e;
endpackage