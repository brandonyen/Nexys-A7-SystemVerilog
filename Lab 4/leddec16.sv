module leddec16 (
    input  logic [2:0]  dig,      // Which digit to currently display
    input  logic [15:0] data,     // 16-bit (4-digit) data
    output logic [7:0]  anode,    // Which anode to turn on
    output logic [6:0]  seg       // Segment code for the current digit
);

    logic [3:0] data4; // Binary value of the current digit

    // Select digit data to be displayed in this multiplexing period
    always_comb begin
        case (dig)
            3'b000: data4 = data[3:0];    // Digit 0
            3'b001: data4 = data[7:4];    // Digit 1
            3'b010: data4 = data[11:8];   // Digit 2
            3'b011: data4 = data[15:12];  // Digit 3
            default: data4 = 4'b0000;     // Default case
        endcase
    end

    // Turn on segments corresponding to the 4-bit data word
    always_comb begin
        case (data4)
            4'b0000: seg = 7'b0000001; // 0
            4'b0001: seg = 7'b1001111; // 1
            4'b0010: seg = 7'b0010010; // 2
            4'b0011: seg = 7'b0000110; // 3
            4'b0100: seg = 7'b1001100; // 4
            4'b0101: seg = 7'b0100100; // 5
            4'b0110: seg = 7'b0100000; // 6
            4'b0111: seg = 7'b0001111; // 7
            4'b1000: seg = 7'b0000000; // 8
            4'b1001: seg = 7'b0000100; // 9
            4'b1010: seg = 7'b0001000; // A
            4'b1011: seg = 7'b1100000; // B
            4'b1100: seg = 7'b0110001; // C
            4'b1101: seg = 7'b1000010; // D
            4'b1110: seg = 7'b0110000; // E
            4'b1111: seg = 7'b0111000; // F
            default: seg = 7'b1111111; // Default (all off)
        endcase
    end

    // Turn on the anode of the 7-segment display addressed by the digit selector
    always_comb begin
        case (dig)
            3'b000: anode = 8'b11111110; // Digit 0
            3'b001: anode = 8'b11111101; // Digit 1
            3'b010: anode = 8'b11111011; // Digit 2
            3'b011: anode = 8'b11110111; // Digit 3
            default: anode = 8'b11111111; // Default (all off)
        endcase
    end

endmodule
