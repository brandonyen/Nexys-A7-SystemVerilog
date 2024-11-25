module hexcount (
    input logic clk_100MHz,        // 100 MHz clock input
    output logic [7:0] anode,      // Anode outputs for the 7-segment displays
    output logic [6:0] seg         // Segment outputs for the 7-segment display
);

    // Counter component declaration
    logic [15:0] S; // Signal to hold the 16-bit counter value
    logic [2:0] md; // mpx selects displays
    logic [3:0] display; // Send digit for only one display to leddec

    counter C1 (
        .clk(clk_100MHz), 
        .count(S),
        .mpx(md)
    );

    // LED decoder component instantiation
    leddec L1 (
        .dig(md), 
        .data(display), 
        .anode, 
        .seg
    );
    
    always_comb begin
        case (md)
            3'b000: display = S[3:0];
            3'b001: display = S[7:4];
            3'b010: display = S[11:8];
            default: display = S[15:12];
        endcase
    end
endmodule