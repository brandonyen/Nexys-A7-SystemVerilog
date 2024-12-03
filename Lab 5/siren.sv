module siren (
    input logic clk_50MHz,           // system clock (50 MHz)
    output logic dac_MCLK,           // outputs to PMODI2L DAC
    output logic dac_LRCK,           // left-right clock
    output logic dac_SCLK,           // serial clock
    output logic dac_SDIN            // serial data input to DAC
);

    // Constants for lower and upper pitch limits, and wailing speed
    localparam logic [13:0] lo_tone = 14'd344;  // lower limit of siren = 344 (256 Hz)
    localparam logic [13:0] hi_tone = 14'd687;  // upper limit of siren = 687 (512 Hz)
    localparam logic [7:0] wail_speed = 8'd8;   // sets wailing speed

    // Signals for components and timing
    logic [19:0] tcount;     // 20-bit timing counter
    logic signed [15:0] data_L, data_R;  // 16-bit signed audio data
    logic dac_load_L, dac_load_R;    // DAC load signals
    logic slo_clk, sclk, audio_CLK;  // clocks

    // Timing process (20-bit binary counter to generate timing signals)
    always_ff @(posedge clk_50MHz) begin
        if (tcount[9:0] >= 10'h00F && tcount[9:0] < 10'h02E)
            dac_load_L <= 1'b1;
        else
            dac_load_L <= 1'b0;

        if (tcount[9:0] >= 10'h20F && tcount[9:0] < 10'h22E)
            dac_load_R <= 1'b1;
        else
            dac_load_R <= 1'b0;

        tcount <= tcount + 1;
    end

    // Timing signal assignments
    assign dac_MCLK = ~tcount[1];    // DAC master clock (12.5 MHz)
    assign audio_CLK = tcount[9];    // audio sampling clock (48.8 kHz)
    assign dac_LRCK = audio_CLK;    // left-right clock for DAC
    assign sclk = tcount[4];         // serial clock (1.56 MHz)
    assign dac_SCLK = sclk;         // serial data clock
    assign slo_clk = tcount[19];    // clock to control wailing tone (47.6 Hz)

    // Instantiate DAC interface (dac_if module)
    dac_if dac_inst (
        .SCLK(sclk),
        .L_start(dac_load_L),
        .R_start(dac_load_R),
        .L_data(data_L),
        .R_data(data_R),
        .SDATA(dac_SDIN)
    );

    // Instantiate Wail component (wail module)
    wail wail_inst (
        .lo_pitch(lo_tone),
        .hi_pitch(hi_tone),
        .wspeed(wail_speed),
        .wclk(slo_clk),
        .audio_clk(audio_CLK),
        .audio_data(data_L)
    );

    // Duplicate left data to right channel
    assign data_R = data_L;

endmodule