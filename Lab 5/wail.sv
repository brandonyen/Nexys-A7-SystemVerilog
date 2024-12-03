module wail (
    input logic [13:0] lo_pitch,           // lowest pitch (in units of 0.745 Hz)
    input logic [13:0] hi_pitch,           // highest pitch (in units of 0.745 Hz)
    input logic [7:0] wspeed,              // speed of wail in pitch units/wclk
    input logic wclk,                      // wailing clock (47.6 Hz)
    input logic audio_clk,                 // audio sampling clock (48.8 kHz)
    output logic signed [15:0] audio_data  // output audio sequence (wailing tone)
);

    // Internal signal
    logic [13:0] curr_pitch;               // current wailing pitch
    logic updn;                            // direction of pitch modulation (1 = up, 0 = down)

    // Instance of the tone module
    tone tgen (
        .clk(audio_clk),
        .pitch(curr_pitch),
        .data(audio_data)
    );

    // Process to modulate pitch
    always_ff @(posedge wclk) begin
        if (curr_pitch >= hi_pitch) begin
            updn = 1'b0;                  // Change direction to down
        end else if (curr_pitch <= lo_pitch) begin
            updn = 1'b1;                  // Change direction to up
        end

        // Modulate pitch up or down based on direction
        if (updn) begin
            curr_pitch <= curr_pitch + wspeed; // Increment pitch
        end else begin
            curr_pitch <= curr_pitch - wspeed; // Decrement pitch
        end
    end

endmodule