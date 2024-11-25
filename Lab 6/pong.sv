module pong (
    input logic clk_in,                // system clock
    output logic [3:0] VGA_red,        // VGA outputs
    output logic [3:0] VGA_green,
    output logic [3:0] VGA_blue,
    output logic VGA_hsync,
    output logic VGA_vsync,
    input logic btnl,                  // left button
    input logic btnr,                  // right button
    input logic btn0,                  // serve button
    output logic [7:0] SEG7_anode,     // anodes of seven-segment displays
    output logic [6:0] SEG7_seg        // segments of seven-segment display
);

    // Internal signals
    logic pxl_clk;                 // 25 MHz clock to VGA sync module
    logic S_red, S_green, S_blue;      // color signals
    logic S_vsync;
    logic [10:0] S_pixel_row, S_pixel_col;
    logic [10:0] batpos;               // paddle position
    logic [20:0] count;                // counter for delay
    logic [15:0] display;              // display data
    logic [2:0] led_mpx;               // seven-segment multiplexing clock

    // Instantiate components
    bat_n_ball add_bb (
        .v_sync(S_vsync),
        .pixel_row(S_pixel_row),
        .pixel_col(S_pixel_col),
        .bat_x(batpos),
        .serve(btn0),
        .red(S_red),
        .green(S_green),
        .blue(S_blue)
    );

    vga_sync vga_driver (
        .pixel_clk(pxl_clk),
        .red_in({S_red, 3'b000}),
        .green_in({S_green, 3'b000}),
        .blue_in({S_blue, 3'b000}),
        .red_out(VGA_red),
        .green_out(VGA_green),
        .blue_out(VGA_blue),
        .hsync(VGA_hsync),
        .vsync(S_vsync),
        .pixel_row(S_pixel_row),
        .pixel_col(S_pixel_col)
    );

    clk_wiz_0 clk_wiz_0_inst (
        .clk_in1(clk_in),
        .clk_out1(pxl_clk)
    );

    leddec16 led1 (
        .dig(led_mpx),
        .data(display),
        .anode(SEG7_anode),
        .seg(SEG7_seg)
    );

    // Main process for button control and counter
    always_ff @(posedge clk_in) begin
        count <= count + 1;
        
        if (btnl == 1 && count == 0 && batpos > 0) begin
            batpos <= batpos - 10;
        end else if (btnr == 1 && count == 0 && batpos < 800) begin
            batpos <= batpos + 10;
        end
    end

    // Assign multiplexing clock for 7-segment display
    assign led_mpx = count[19:17];

    // Connect vsync output to VGA vsync
    assign VGA_vsync = S_vsync;

endmodule
