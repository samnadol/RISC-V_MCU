module uart_tx #(
    parameter CLOCK_PSC = 868
) ( 
    input logic clk,
    input logic rst_n,

    input logic [7:0] data, // data to send
    input logic start,      // start flag
    output logic busy,      // busy flag
    output logic tx_out     // physical tx pin
);
    typedef enum { IDLE, START, DATA, STOP, CLEAN } uart_state_t;
    uart_state_t tx_state, next_tx_state;

    logic [$clog2(CLOCK_PSC)-1:0] clk_count, next_clk_count;
    logic [7:0] tx_shift_reg, next_tx_shift_reg;
    logic [2:0] tx_bit_idx, next_tx_bit_idx;
    logic next_tx_out;

    logic baud;
    assign baud = (clk_count == CLOCK_PSC - 1);
    assign busy = (tx_state != IDLE);

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            tx_state <= IDLE;
            clk_count <= 0;
            tx_shift_reg <= 8'b0;
            tx_out <= 1'b1;
            tx_bit_idx <= 3'b0;
        end else begin
            tx_state <= next_tx_state;
            clk_count <= next_clk_count;
            tx_shift_reg <= next_tx_shift_reg;
            tx_out <= next_tx_out;
            tx_bit_idx <= next_tx_bit_idx;
        end
    end

    always_comb begin
        next_tx_state = tx_state;
        next_clk_count = ((tx_state == IDLE || baud) ? 0 : (clk_count + 1));
        next_tx_shift_reg = tx_shift_reg;
        next_tx_out = 1'b1;
        next_tx_bit_idx = tx_bit_idx;
        
        case (tx_state)
            IDLE: begin
                next_tx_out = 1'b1;
                if (start) begin
                    next_tx_state = START;
                    next_tx_shift_reg = data;
                end
            end
            START: begin
                next_tx_out = 1'b0;
                if (baud) begin
                    next_tx_state = DATA;
                    next_tx_bit_idx = 0;
                end
            end
            DATA: begin
                next_tx_out = tx_shift_reg[0];
                if (baud) begin
                    next_tx_shift_reg = { 1'b0, tx_shift_reg[7:1] };
                    next_tx_bit_idx = tx_bit_idx + 1;
                    if (tx_bit_idx == 3'h7) begin
                        next_tx_state = STOP;
                    end
                end
            end
            STOP: begin
                next_tx_out = 1'b1;
                if (baud) begin
                    next_tx_state = IDLE;
                end
            end
            default:
                next_tx_state = IDLE;
        endcase
    end
endmodule