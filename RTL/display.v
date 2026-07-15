// Shows a WIDTH-bit value as two decimal digits (tens, ones) on two HEX displays.
// Two digits cover 0..99.
module display #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] data_in,
    output wire [6:0]       Hex_Ones,
    output wire [6:0]       Hex_Tens
);

    wire [3:0] ones = data_in % 10;
    wire [3:0] tens = (data_in / 10) % 10;

    SevenSegDecoder u_ones (.bin(ones), .seg(Hex_Ones));
    SevenSegDecoder u_tens (.bin(tens), .seg(Hex_Tens));

endmodule

//test comment