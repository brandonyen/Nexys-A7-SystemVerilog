module counter (
    input logic clk,
    output logic [3:0] count
);
    
    logic [28:0] cnt; // 29 bit counter
    
    always_ff @(posedge clk) begin // on rising edge of clock
        cnt <= cnt + 1; // increment counter
    end
    
    assign count = cnt[28:25];
endmodule