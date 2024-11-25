module tone (
    input  logic clk,                      // 48.8 kHz audio sampling clock
    input  logic unsigned [13:0] pitch,    // frequency (in units of 0.745 Hz)
    output logic signed [15:0] data        // signed triangle wave output
);

    // Internal signals
    logic unsigned [15:0] count;           // represents current phase of waveform
    logic [1:0] quad;                      // current quadrant of phase
    logic signed [15:0] index;             // index into current quadrant

    // Process to generate the sawtooth waveform based on pitch
    always_ff @(posedge clk) begin
        count <= count + pitch;
    end

    // Splits count range into 4 phases (quadrants)
    assign quad = count[15:14];            // extract two MSBs for quadrant
    assign index = signed'("00" & count[13:0]); // 14-bit index into current phase

    // Converts the unsigned sawtooth to a signed triangle wave
    always_comb begin
        case (quad)
            2'b00:    data = index;                 // 1st quadrant
            2'b01:    data = 16383 - index;         // 2nd quadrant
            2'b10:    data = -index;                // 3rd quadrant
            default:  data = index - 16383;         // 4th quadrant
        endcase
    end

endmodule
