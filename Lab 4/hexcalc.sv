module hexcalc (
    input logic clk_50MHz,            // system clock (50 MHz)
    output logic [7:0] SEG7_anode,    // anodes of eight 7-segment displays
    output logic [6:0] SEG7_seg,      // common segments of 7-segment displays
    input logic bt_clr,               // calculator "clear" button
    input logic bt_plus,              // calculator "+" button
    input logic bt_eq,                // calculator "=" button
    output logic [4:1] KB_col,        // keypad column pins
    input logic [4:1] KB_row          // keypad row pins
);

    // Signal declarations
    logic [20:0] cnt;                 // counter to generate timing signals
    logic kp_clk, kp_hit, sm_clk;
    logic [3:0] kp_value;
    logic [15:0] nx_acc, acc;         // accumulated sum
    logic [15:0] nx_operand, operand; // operand
    logic [15:0] display;             // value to be displayed
    logic [2:0] led_mpx;              // 7-segment multiplexing clock
    typedef enum logic [2:0] {ENTER_ACC, ACC_RELEASE, START_OP, OP_RELEASE, 
                              ENTER_OP, SHOW_RESULT} state_t;
    state_t pr_state, nx_state;

    // Forward declare components for instantiation
    keypad kp1 (
        .samp_ck(kp_clk),
        .col(KB_col),
        .row(KB_row),
        .value(kp_value),
        .hit(kp_hit)
    );

    leddec16 led1 (
        .dig(led_mpx),
        .data(display),
        .anode(SEG7_anode),
        .seg(SEG7_seg)
    );

    // Clock process for counting
    always_ff @(posedge clk_50MHz) begin
        cnt <= cnt + 1; // increment counter
    end

    // Derived clocks
    assign kp_clk = cnt[15];        // keypad interrogation clock
    assign sm_clk = cnt[20];        // state machine clock
    assign led_mpx = cnt[19:17];    // 7-segment multiplexing clock

    // State machine clock process
    always_ff @(posedge sm_clk or posedge bt_clr) begin
        if (bt_clr) begin
            acc <= 16'h0000;
            operand <= 16'h0000;
            pr_state <= ENTER_ACC;
        end else begin
            pr_state <= nx_state;
            acc <= nx_acc;
            operand <= nx_operand;
        end
    end

    // State machine combinational logic process
    always_comb begin
        // Default values of nx_acc, nx_operand, and display
        nx_acc = acc;
        nx_operand = operand;
        display = acc;

        // Determine next state and outputs based on present state
        case (pr_state)
            ENTER_ACC: begin
                if (kp_hit) begin
                    nx_acc = {acc[11:0], kp_value};
                    nx_state = ACC_RELEASE;
                end else if (bt_plus) begin
                    nx_state = START_OP;
                end else begin
                    nx_state = ENTER_ACC;
                end
            end
            ACC_RELEASE: begin
                if (!kp_hit) begin
                    nx_state = ENTER_ACC;
                end else begin
                    nx_state = ACC_RELEASE;
                end
            end
            START_OP: begin
                if (kp_hit) begin
                    nx_operand = {12'h000, kp_value};
                    nx_state = OP_RELEASE;
                    display = operand;
                end else begin
                    nx_state = START_OP;
                end
            end
            OP_RELEASE: begin
                display = operand;
                if (!kp_hit) begin
                    nx_state = ENTER_OP;
                end else begin
                    nx_state = OP_RELEASE;
                end
            end
            ENTER_OP: begin
                display = operand;
                if (bt_eq) begin
                    nx_acc = acc + operand;
                    nx_state = SHOW_RESULT;
                end else if (kp_hit) begin
                    nx_operand = {operand[11:0], kp_value};
                    nx_state = OP_RELEASE;
                end else begin
                    nx_state = ENTER_OP;
                end
            end
            SHOW_RESULT: begin
                if (kp_hit) begin
                    nx_acc = {12'h000, kp_value};
                    nx_state = ACC_RELEASE;
                end else begin
                    nx_state = SHOW_RESULT;
                end
            end
            default: nx_state = ENTER_ACC;
        endcase
    end

endmodule
