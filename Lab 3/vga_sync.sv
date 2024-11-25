module vga_sync (
    input  logic pixel_clk,
    input  logic red_in,
    input  logic green_in,
    input  logic blue_in,
    output logic red_out,
    output logic green_out,
    output logic blue_out,
    output logic hsync,
    output logic vsync,
    output logic [10:0] pixel_row,
    output logic [10:0] pixel_col
);

    // Internal counters
    logic [10:0] h_cnt, v_cnt;
    logic video_on;

    // VGA timing constants
    localparam int H       = 800;
    localparam int V       = 600;
    localparam int H_FP    = 40;
    localparam int H_BP    = 88;
    localparam int H_SYNC  = 128;
    localparam int V_FP    = 1;
    localparam int V_BP    = 23;
    localparam int V_SYNC  = 4;
    localparam int FREQ    = 60;

    always_ff @(posedge pixel_clk) begin
        // Horizontal Counter
        if (h_cnt >= H + H_FP + H_SYNC + H_BP - 1)
            h_cnt <= 0;
        else
            h_cnt <= h_cnt + 1;

        // Horizontal Sync Signal
        if (h_cnt >= H + H_FP && h_cnt < H + H_FP + H_SYNC)
            hsync <= 0;
        else
            hsync <= 1;

        // Vertical Counter
        if ((v_cnt >= V + V_FP + V_SYNC + V_BP - 1) && (h_cnt == H + FREQ - 1))
            v_cnt <= 0;
        else if (h_cnt == H + FREQ - 1)
            v_cnt <= v_cnt + 1;

        // Vertical Sync Signal
        if (v_cnt >= V + V_FP && v_cnt < V + V_FP + V_SYNC)
            vsync <= 0;
        else
            vsync <= 1;

        // Generate Video On Signal
        video_on = (h_cnt < H) && (v_cnt < V);

        // Assign Pixel Position
        pixel_col <= h_cnt;
        pixel_row <= v_cnt;

        // Output video signals, blank during sync periods
        red_out   <= red_in & video_on;
        green_out <= green_in & video_on;
        blue_out  <= blue_in & video_on;
    end
endmodule
