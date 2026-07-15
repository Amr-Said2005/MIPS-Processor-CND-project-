module sign_extend (
    input      [15:0] in,          // immediate = instruction[15:0]
    output     [31:0] out
);

    // replicate sign bit into upper 16 bits
    assign out = {{16{in[15]}}, in};

endmodule
