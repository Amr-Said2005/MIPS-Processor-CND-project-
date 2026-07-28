module sign_extend (
    input      [15:0] in,          // immediate = instruction[15:0]
    input             Extd,        // 1 = sign-extend, 0 = zero-extend (andi)
    output     [31:0] out
);

    // Extd=1: replicate sign bit (addi/lw/sw/beq keep signed offsets)
    // Extd=0: fill with zeros (andi masks against the raw 16-bit value)
    assign out = Extd ? {{16{in[15]}}, in}
                      : {16'b0,       in};

endmodule
