module fifo #(
  parameter WIDTH = 8,
  parameter DEPTH = 32
) (
  input logic clk,
  input logic n_rst,
  
  input logic write_en,
  input logic [WIDTH-1:0] write_data,
  
  output logic read_en,
  output logic [WIDTH-1:0] read_data,
  
  output logic full,
  output logic empty
);
  localparam ADDR_WIDTH = $clog2(DEPTH);
  logic [ADDR_WIDTH-1:0] rptr, wptr;
  logic last_op; // 0 = read, 1 = write
  logic [WIDTH-1:0] memory [0:DEPTH-1];
  
  always_ff @(posedge clk, negedge n_rst) begin
    if (!n_rst) begin
      rptr <= 0;
      wptr <= 0;
      last_op <= 0;
    end else begin
      if (write_en & !full) begin
        memory[wptr] <= write_data;
        wptr <= wptr + 1;
        last_op <= 1;
      end else if (read_en & !empty) begin
        rptr <= rptr + 1;
        read_data <= memory[rptr];
        last_op <= 0;
      end else begin
        last_op <= last_op;
      end
    end
  end
  
  always_comb begin
    full = last_op && (wptr == rptr);
    full = !empty && (wptr == rptr);
  end
endmodule