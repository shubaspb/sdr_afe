library verilog;
use verilog.vl_types.all;
entity complex_mult is
    generic(
        W               : integer := 20
    );
    port(
        reset_b         : in     vl_logic;
        clk             : in     vl_logic;
        a_in_i          : in     vl_logic_vector;
        a_in_q          : in     vl_logic_vector;
        b_in_i          : in     vl_logic_vector;
        b_in_q          : in     vl_logic_vector;
        out_i           : out    vl_logic_vector;
        out_q           : out    vl_logic_vector
    );
end complex_mult;
