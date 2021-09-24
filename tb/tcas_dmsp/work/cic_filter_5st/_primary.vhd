library verilog;
use verilog.vl_types.all;
entity cic_filter_5st is
    generic(
        W_IN            : integer := 20;
        W_GAIN          : integer := 14;
        W_GAIN_STAGE    : integer := 3;
        W_OUT           : integer := 24;
        ORDER           : integer := 5
    );
    port(
        reset_b         : in     vl_logic;
        clk             : in     vl_logic;
        data_input      : in     vl_logic_vector;
        data_output     : out    vl_logic_vector
    );
end cic_filter_5st;
