library verilog;
use verilog.vl_types.all;
entity cic_filter_stage is
    generic(
        WIDTH           : integer := 16;
        ORDER           : integer := 20
    );
    port(
        reset_b         : in     vl_logic;
        clk             : in     vl_logic;
        data_input      : in     vl_logic_vector;
        data_output     : out    vl_logic_vector
    );
end cic_filter_stage;
