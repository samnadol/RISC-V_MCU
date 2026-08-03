module pc(
    input logic clk,
    input logic rst_n,

    input logic pc_jmp_en, // 0 = pc inc by 32'd4, 1 = pc jmp to pc_jmp_target
    input logic [31:0] pc_jmp_target,

    output logic [31:0] pc_curr
);
    localparam logic [31:0] BOOT_ADDR = 32'h0;

    logic [31:0] pc_next;
    assign pc_next = (pc_jmp_en ? pc_jmp_target : (pc_curr + 32'd4));

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n)
            pc_curr <= BOOT_ADDR;
        else
            pc_curr <= pc_next;
    end
endmodule