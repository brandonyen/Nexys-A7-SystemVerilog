module vga_top (
    input  logic clk_in,
    output logic [2:0] vga_red,
    output logic [2:0] vga_green,
    output logic [1:0] vga_blue,
    output logic vga_hsync,
    output logic vga_vsync
);

    // Internal signals
    logic pxl_clk;
    logic S_red, S_green, S_blue;
    logic S_vsync;
    logic [10:0] S_pixel_row, S_pixel_col;

    // Instantiate the ball module
    ball add_ball (
        .v_sync(S_vsync),
        .pixel_row(S_pixel_row),
        .pixel_col(S_pixel_col),
        .red(S_red),
        .green(S_green),
        .blue(S_blue)
    );

    // Instantiate the vga_sync module
    vga_sync vga_driver (
        .pixel_clk(pxl_clk),
        .red_in(S_red),
        .green_in(S_green),
        .blue_in(S_blue),
        .red_out(vga_red[2]),
        .green_out(vga_green[2]),
        .blue_out(vga_blue[1]),
        .pixel_row(S_pixel_row),
        .pixel_col(S_pixel_col),
        .hsync(vga_hsync),
        .vsync(S_vsync)
    );

    // Connect the vsync output to vga_vsync
    assign vga_vsync = S_vsync;

    // Instantiate the clk_wiz_0 module for clock generation
    clk_wiz_0 clk_wiz_0_inst (
        .clk_in1(clk_in),
        .clk_out1(pxl_clk)
    );

    // Set unused bits of vga output to zero
    assign vga_red[1:0] = 2'b00;
    assign vga_green[1:0] = 2'b00;
    assign vga_blue[0] = 1'b0;

endmodule
