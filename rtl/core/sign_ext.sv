module sign_ext(
    input logic [31:0]  data_in,
    input logic [1:0]   data_width,
    input logic         data_unsigned,
    output logic [31:0] data_out
);
    import riscv_pkg::*;
    always_comb begin
        case(data_width)
            MEM_WIDTH_BYTE: data_out = { {24{ data_unsigned ? 1'b0 : data_in[7] }}, data_in[7:0] };
            MEM_WIDTH_HALFWORD: data_out = { {16{ data_unsigned ? 1'b0 : data_in[15] }}, data_in[15:0] };
            MEM_WIDTH_WORD: data_out = data_in;
            default: data_out = data_in;
        endcase
    end
endmodule