module hexcount (
    input logic [2:0] dig,
    input logic clk_100MHz,        // 100 MHz clock input
    output logic [7:0] anode,      // Anode outputs for the 7-segment displays
    output logic [6:0] seg         // Segment outputs for the 7-segment display
);

    // Counter component declaration
    logic [3:0] S; // Signal to hold the 4-bit counter value

    counter C1 (
        .clk(clk_100MHz), 
        .count(S)
    );

    // LED decoder component instantiation
    leddec L1 (
        .dig(3'b000), 
        .data(S), 
        .anode, 
        .seg
    );
endmodule