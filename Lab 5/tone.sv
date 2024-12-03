module tone (
    input logic clk,                       // 48.8 kHz audio sampling clock
    input logic [13:0] pitch,              // frequency (in units of 0.745 Hz)
    output logic signed [15:0] data        // signed triangle wave out
);

    // Internal signals
    logic [15:0] count;                    // current phase of waveform
    logic [1:0] quad;                      // current quadrant of phase
    logic signed [15:0] index;             // index into current quadrant

    // Process to increment phase by pitch
    always_ff @(posedge clk) begin
        count <= count + pitch;
    end

    // Determine the quadrant
    assign quad = count[15:14];            // splits count range into 4 phases

    // Compute index for the current quadrant
    assign index = {2'b00, count[13:0]};

    // Generate triangle wave based on the quadrant
    always_comb begin
        case (quad)
            2'b00: data = index;                     // 1st quadrant
            2'b01: data = 16383 - index;    // 2nd quadrant
            2'b10: data = -index;                    // 3rd quadrant
            default: data = index - 16383;  // 4th quadrant
        endcase
    end

endmodule