module bat_n_ball (
    input  logic         v_sync,
    input  logic [10:0]  pixel_row,
    input  logic [10:0]  pixel_col,
    input  logic [10:0]  bat_x,     // Current bat x position
    input  logic         serve,     // Initiates serve
    output logic         red,
    output logic         green,
    output logic         blue
);

    // Constants
    localparam int bsize = 8;         // Ball size in pixels
    localparam int bat_w = 20;        // Bat width in pixels
    localparam int bat_h = 3;         // Bat height in pixels
    localparam logic [10:0] ball_speed = 11'd6;

    // Signals
    logic ball_on;                    // Indicates if ball is at current pixel position
    logic bat_on;                     // Indicates if bat is at current pixel position
    logic game_on = 1'b0;             // Indicates if ball is in play
    logic [10:0] ball_x = 11'd400;    // Current ball x position (initial: center of screen)
    logic [10:0] ball_y = 11'd300;    // Current ball y position
    localparam logic [10:0] bat_y = 11'd500; // Bat vertical position
    logic [10:0] ball_x_motion = ball_speed; // Current ball x motion
    logic [10:0] ball_y_motion = ball_speed; // Current ball y motion

    // Assign colors: Red for ball, cyan for bat on white background
    assign red = ~bat_on;
    assign green = ~ball_on;
    assign blue = ~ball_on;

    // Process to determine if the current pixel is within the ball's position
    always_comb begin
        logic [10:0] vx, vy;
        
        if (pixel_col <= ball_x) vx = ball_x - pixel_col;
        else vx = pixel_col - ball_x;
        
        if (pixel_row <= ball_y) vy = ball_y - pixel_row;
        else vy = pixel_row - ball_y;
        
        if ((vx * vx) + (vy * vy) < (bsize * bsize)) ball_on = game_on;
        else ball_on = 1'b0;
    end

    // Process to determine if the current pixel is within the bat's position
    always_comb begin
        if (((pixel_col >= bat_x - bat_w) || (bat_x <= bat_w)) &&
             (pixel_col <= bat_x + bat_w) &&
             (pixel_row >= bat_y - bat_h) &&
             (pixel_row <= bat_y + bat_h)) 
            bat_on = 1'b1;
        else
            bat_on = 1'b0;
    end

    // Process to update the ball's position on each vsync pulse
    always_ff @(posedge v_sync) begin
        logic [11:0] temp;

        if (serve == 1 && game_on == 0) begin
            game_on <= 1;
            ball_y_motion <= ~ball_speed + 1; // set vertical speed to -ball_speed
            ball_x_motion <= ball_speed;
        end else if (ball_y <= bsize) begin // bounce off top wall
            ball_y_motion <= ball_speed;     // set vertical speed to +ball_speed
        end else if (ball_y + bsize >= 600) begin // bounce off bottom wall
            ball_y_motion <= ~ball_speed + 1; // set vertical speed to -ball_speed
            game_on <= 0;                    // ball out of play
        end

        // Horizontal wall bounces
        if (ball_x + bsize >= 800) begin
            ball_x_motion <= ~ball_speed + 1; // bounce off right wall
        end else if (ball_x <= bsize) begin
            ball_x_motion <= ball_speed;      // bounce off left wall
        end

        // Bat bounce detection
        if ((ball_x + bsize / 2 >= bat_x - bat_w) &&
            (ball_x - bsize / 2 <= bat_x + bat_w) &&
            (ball_y + bsize / 2 >= bat_y - bat_h) &&
            (ball_y - bsize / 2 <= bat_y + bat_h)) begin
            ball_y_motion <= ~ball_speed + 1; // bounce off bat
        end

        // Calculate new ball position for Y direction
        temp = {1'b0, ball_y} + {ball_y_motion[10], ball_y_motion};
        if (game_on == 0) ball_y <= 11'd440;
        else if (temp[11] == 1) ball_y <= 0;
        else ball_y <= temp[10:0];

        // Calculate new ball position for X direction
        temp = {1'b0, ball_x} + {ball_x_motion[10], ball_x_motion};
        if (temp[11] == 1) ball_x <= 0;
        else ball_x <= temp[10:0];
    end

endmodule