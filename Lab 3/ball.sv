module ball (
    input  logic            v_sync,
    input  logic [10:0]     pixel_row,
    input  logic [10:0]     pixel_col,
    output logic            red,
    output logic            green,
    output logic            blue
);

    // Constants
    localparam int size = 8;

    // Signals
    logic ball_on;                  // Indicates if ball is over the current pixel position
    logic [10:0] ball_x = 11'd400;  // Initial X position of the ball (centered on screen)
    logic [10:0] ball_y = 11'd300;  // Initial Y position of the ball (centered on screen)
    logic [10:0] ball_y_motion = 11'd4; // Initial Y motion of the ball (+4 pixels/frame)

    // Output color setup: red ball on white background
    assign red   = 1;
    assign green = ~ball_on;
    assign blue  = ~ball_on;

    // Process to draw the ball based on the current pixel position
    always_comb begin
        if ((pixel_col >= ball_x - size) && (pixel_col <= ball_x + size) &&
            (pixel_row >= ball_y - size) && (pixel_row <= ball_y + size)) begin
            ball_on = 1;
        end else begin
            ball_on = 0;
        end
    end

    // Process to move the ball on each frame (on each v_sync pulse)
    always_ff @(posedge v_sync) begin
        // Bounce off top or bottom of screen
        if (ball_y + size >= 600) begin
            ball_y_motion <= -11'd4; // -4 pixels
        end else if (ball_y <= size) begin
            ball_y_motion <= 11'd4;  // +4 pixels
        end
        ball_y <= ball_y + ball_y_motion; // Compute next ball position
    end

endmodule