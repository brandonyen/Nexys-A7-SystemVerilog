module dac_if (
    input logic SCLK,                  // serial clock (1.56 MHz)
    input logic L_start,               // strobe to load LEFT data
    input logic R_start,               // strobe to load RIGHT data
    input logic signed [15:0] L_data, // LEFT data (15-bit signed)
    input logic signed [15:0] R_data, // RIGHT data (15-bit signed)
    output logic SDATA                 // serial data stream to DAC
);

    // 16-bit shift register for parallel to serial conversion
    logic [15:0] sreg;

    always_ff @(negedge SCLK) begin
        if (L_start) begin
            sreg <= L_data; // load LEFT data into sreg
        end else if (R_start) begin
            sreg <= R_data; // load RIGHT data into sreg
        end else begin
            sreg <= {sreg[14:0], 1'b0}; // shift sreg one bit left
        end
    end

    assign SDATA = sreg[15]; // serial data to DAC is MSBit of sreg

endmodule
