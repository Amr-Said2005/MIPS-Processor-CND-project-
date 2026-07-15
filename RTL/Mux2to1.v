module Mux2to1 #(
    parameter WIDTH = 32            // override per instance (e.g. 5)
)(
    input  [WIDTH-1:0] A,           // Sel = 0
    input  [WIDTH-1:0] B,           // Sel = 1
    input              Sel,
    output [WIDTH-1:0] Y
);

    assign Y = Sel ? B : A;

endmodule
