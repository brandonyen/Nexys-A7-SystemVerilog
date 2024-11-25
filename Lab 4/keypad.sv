module keypad (
    input logic samp_ck,               // clock to strobe columns
    output logic [4:1] col,            // output column lines
    input logic [4:1] row,             // input row lines
    output logic [3:0] value,          // hex value of key depressed
    output logic hit                   // indicates when a key has been pressed
);

    // Column vectors for each row
    logic [4:1] CV1 = 4'b1111;
    logic [4:1] CV2 = 4'b1111;
    logic [4:1] CV3 = 4'b1111;
    logic [4:1] CV4 = 4'b1111;
    logic [4:1] curr_col = 4'b1110;    // current column code

    // Process to test keypad button states
    always_ff @(posedge samp_ck) begin
        case (curr_col)
            4'b1110: begin
                CV1 <= row;
                curr_col <= 4'b1101;
            end
            4'b1101: begin
                CV2 <= row;
                curr_col <= 4'b1011;
            end
            4'b1011: begin
                CV3 <= row;
                curr_col <= 4'b0111;
            end
            4'b0111: begin
                CV4 <= row;
                curr_col <= 4'b1110;
            end
            default: curr_col <= 4'b1110;
        endcase
    end

    // Process to detect key presses and assign value based on pressed key
    always_comb begin
        hit = 1'b1;    // default to key press detected

        if (CV1[1] == 1'b0) begin
            value = 4'h1;
        end else if (CV1[2] == 1'b0) begin
            value = 4'h4;
        end else if (CV1[3] == 1'b0) begin
            value = 4'h7;
        end else if (CV1[4] == 1'b0) begin
            value = 4'h0;
        end else if (CV2[1] == 1'b0) begin
            value = 4'h2;
        end else if (CV2[2] == 1'b0) begin
            value = 4'h5;
        end else if (CV2[3] == 1'b0) begin
            value = 4'h8;
        end else if (CV2[4] == 1'b0) begin
            value = 4'hF;
        end else if (CV3[1] == 1'b0) begin
            value = 4'h3;
        end else if (CV3[2] == 1'b0) begin
            value = 4'h6;
        end else if (CV3[3] == 1'b0) begin
            value = 4'h9;
        end else if (CV3[4] == 1'b0) begin
            value = 4'hE;
        end else if (CV4[1] == 1'b0) begin
            value = 4'hA;
        end else if (CV4[2] == 1'b0) begin
            value = 4'hB;
        end else if (CV4[3] == 1'b0) begin
            value = 4'hC;
        end else if (CV4[4] == 1'b0) begin
            value = 4'hD;
        end else begin
            hit = 1'b0;    // no key pressed
            value = 4'h0;
        end
    end

    assign col = curr_col;

endmodule
