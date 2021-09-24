library verilog;
use verilog.vl_types.all;
entity rounding is
    generic(
        WIDTH           : integer := 32;
        START_BIT       : integer := 30;
        END_BIT         : integer := 16
    );
    port(
        reset_b         : in     vl_logic;
        clk             : in     vl_logic;
        data_input      : in     vl_logic_vector;
        data_output     : out    vl_logic_vector
    );
end rounding;
