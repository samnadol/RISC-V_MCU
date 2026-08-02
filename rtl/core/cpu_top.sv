module cpu_top(
    input logic clk,
    input logic rst,

    output logic [31:0] imem_addr,
    input logic [31:0] imem_data,

    output logic [31:0] dmem_addr,
    output logic dmem_read,
    output logic dmem_write,
    input logic [31:0] dmem_rdata,
    output logic [31:0] dmem_wdata,
    output logic [2:0] dmem_width,

    output logic [31:0] debug_pc,
    output logic simulation_end
);
    import riscv_pkg::*;

    logic [31:0] pc, imm, rv1, rv2, alu_out, rd_write_val;
    logic [4:0] rs1, rs2, rd;
    logic [3:0] alu_op;
    logic [2:0] branch_op;
    logic pc_override, rd_write, alu_src_a, alu_src_b, alu_zero, jump, branch_en, branch_pass, system_halt;

    assign rd_write_val = jump ? (pc + 32'd4) : (dmem_read ? dmem_rdata : alu_out);
    reg_file registers(
        .clk(clk),
        .rst(rst),

        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),

        .rd_write(rd_write),
        .rd_write_val(rd_write_val),

        .rv1(rv1),
        .rv2(rv2)
    ); 
    
    bcu branch_control (
        .branch_op(branch_op),
        .rv1(rv1),
        .rv2(rv2),
        .branch(branch_pass)
    );

    assign pc_override = jump | (branch_en & branch_pass);
    pc program_counter(
        .clk(clk),
        .rst(rst),

        .pc_jmp_en(pc_override),
        .pc_jmp_target(alu_out),

        .pc_curr(pc)
    );

    inst_dec instruction_decoder(
        .inst(imem_data),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .imm(imm),
        
        .rd_write(rd_write),

        .branch_op(branch_op),
        .mem_width(dmem_width),

        .alu_op(alu_op),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),

        .mem_read(dmem_read),
        .mem_write(dmem_write),
        .branch(branch_en),
        .jump(jump),
        .system_halt(system_halt)
    );

    alu arithmetic(
        .alu_in_a(alu_src_a ? pc  : rv1),
        .alu_in_b(alu_src_b ? imm : rv2),
        .alu_op(alu_op),

        .alu_out(alu_out),
        .zero(alu_zero)
    );

    assign imem_addr = pc;
    assign dmem_addr = alu_out;
    assign dmem_wdata = rv2;

    assign debug_pc = pc;
    assign simulation_end = system_halt | (debug_pc == 32'hFF);
endmodule