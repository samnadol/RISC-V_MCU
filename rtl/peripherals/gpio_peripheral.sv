module gpio_peripheral(
    input logic clk,
    input logic rst_n,

    input logic read_en,
    input logic write_en,
    input logic [1:0] width,

    input logic [31:0] addr,
    input logic [31:0] wdata,
    output logic [31:0] rdata
);
    logic [7:0] pins;

    always_comb begin
       if (read_en) rdata = {24'b0, pins};
       else rdata = 32'b0;
   end

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) pins <= 8'b0;
        else if (write_en && addr == 32'h200) pins <= wdata[7:0];
    end
endmodule