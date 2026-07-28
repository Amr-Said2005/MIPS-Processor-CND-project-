module pipreg #(parameter N = 32) (
    input hold,
    input clear,
    input clk,
    input  [N-1:0] in,
    output reg [N-1:0] out
);

always @(posedge clk) begin
    if (clear)
        out <= {N{1'b0}};
    else if (hold) 
        out <= out; 
    else
        out <= in;  
end
endmodule