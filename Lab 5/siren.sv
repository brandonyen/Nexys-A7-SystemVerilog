module siren (
    input  logic clk_50MHz,            // system clock (50 MHz)
    output logic dac_MCLK,             // outputs to PMODI2L DAC
    output logic dac_LRCK,
    output logic dac_SCLK,
    output logic dac_SDIN
);

    // Constants
    localparam logic unsigned [13:0] lo_tone = 14'd344; // lower limit of siren = 256 Hz
    localparam logic unsigned [13:0] hi_tone = 14'd687; // upper limit of siren = 512 Hz
    localparam logic unsigned [7:0] wail_speed = 8'd8;  // sets wailing speed

    // Internal signals
    logic unsigned [19:0] tcount = 20'd0;  // timing counter
    logic signed [15:0] data_L, data_R;    // 16-bit signed audio data
    logic dac_load_L, dac_load_R;          // timing pulses to load DAC shift reg.
    logic slo_clk, sclk, audio_CLK;

    // DAC interface instantiation
    dac_if dac (
        .SCLK(sclk),
        .L_start(dac_load_L),
        .R_start(dac_load_R),
        .L_data(data_L),
        .R_data(data_R),
        .SDATA(dac_SDIN)
    );

    // Wail module instantiation
    wail w1 (
        .lo_pitch(lo_tone),
        .hi_pitch(hi_tone),
        .wspeed(wail_speed),
        .wclk(slo_clk),
        .audio_clk(audio_CLK),
        .audio_data(data_L)
    );

    // Duplicate data on the right channel
    assign data_R = data_L;

    // Generate necessary timing signals
    always_ff @(posedge clk_50MHz) begin
        tcount <= tcount + 1;

        // dac_load_L pulse generation
        if ((tcount[9:0] >= 10'h00F) && (tcount[9:0] < 10'h02E))
            dac_load_L <= 1;
        else
            dac_load_L <= 0;

        // dac_load_R pulse generation
        if ((tcount[9:0] >= 10'h20F) && (tcount[9:0] < 10'h22E))
            dac_load_R <= 1;
        else
            dac_load_R <= 0;
    end

    // Assign outputs
    assign dac_MCLK = ~tcount[1];      // DAC master clock (12.5 MHz)
    assign audio_CLK = tcount[9];      // audio sampling rate (48.8 kHz)
    assign dac_LRCK = audio_CLK;       // left/right clock for DAC
    assign sclk = tcount[4];           // serial data clock (1.56 MHz)
    assign dac_SCLK = sclk;            // SCLK for DAC
    assign slo_clk = tcount[19];       // clock to control wailing of tone (47.6 Hz)

endmodule
