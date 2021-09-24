library verilog;
use verilog.vl_types.all;
entity fir_filter_23 is
    port(
        clk             : in     vl_logic;
        reset_b         : in     vl_logic;
        data_input      : in     vl_logic_vector(19 downto 0);
        data_output     : out    vl_logic_vector(19 downto 0)
    );
end fir_filter_23;
