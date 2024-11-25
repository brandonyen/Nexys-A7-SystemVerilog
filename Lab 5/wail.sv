module wail (
    input  logic unsigned [13:0] lo_pitch,    // lowest pitch (in units of 0.745 Hz)
    input  logic unsigned [13:0] hi_pitch,    // highest pitch (in units of 0.745 Hz)
    input  logic unsigned [7:0] wspeed,       // speed of wail in pitch units per wclk
    input  logic wclk,                        // wailing clock (47.6 Hz)
    input  logic audio_clk,                   // audio sampling clock (48.8 kHz)
    output logic signed [15:0] audio_data     // output audio sequence (wailing tone)
);

    // Internal signals
    logic unsigned [13:0] curr_pitch;         // current wailing pitch
    logic updn;                               // direction of pitch modulation: 1 = up, 0 = down

    // Tone component instantiation
    tone tgen (
        .clk(audio_clk),
        .pitch(curr_pitch),
        .data(audio_data)
    );

    // Modulates the current pitch to create the wail effect
    always_ff @(posedge wclk) begin
        // Adjust direction when limits are reached
        if (curr_pitch >= hi_pitch) 
            updn <= 0;                         // Change direction to down
        else if (curr_pitch <= lo_pitch)
            updn <= 1;                         // Change direction to up

        // Update pitch based on direction
        if (updn)
            curr_pitch <= curr_pitch + wspeed; // Increase pitch
        else
            curr_pitch <= curr_pitch - wspeed; // Decrease pitch
    end

endmodule
