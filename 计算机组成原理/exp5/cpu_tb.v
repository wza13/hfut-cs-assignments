module cpu_tb;

    reg clk, reset;

    always#5 clk = ~clk;

    cpu uut(
        .clk(clk), .reset(reset)
    );
    
    initial begin
        clk = 0;
        reset = 1;

        #10 reset = 0;

        #150 $stop;
    end

endmodule
