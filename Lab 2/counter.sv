module counter (
    input logic clk,
    output logic [15:0] count,
    output logic [2:0] mpx
);
    
    logic [38:0] cnt; // 39 bit counter
    
    always_ff @(posedge clk) begin // on rising edge of clock
        cnt <= cnt + 1; // increment counter
    end
    
    assign count = cnt[38:23];
    assign mpx = cnt[19:17];
endmodule