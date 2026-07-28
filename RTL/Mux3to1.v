// 3-to-1 mux for forwarding paths
module Mux3to1 #(parameter WIDTH = 32) (
    input  [WIDTH-1:0] A,   // Sel = 2'b00
    input  [WIDTH-1:0] B,   // Sel = 2'b01
    input  [WIDTH-1:0] C,   // Sel = 2'b10
    input  [1:0]        Sel,
    output reg [WIDTH-1:0] Y
);
    always @(*) begin
        case (Sel)
            2'b00: Y = A;
            2'b01: Y = B;
            2'b10: Y = C;
            default: Y = A;
        endcase
    end
endmodule