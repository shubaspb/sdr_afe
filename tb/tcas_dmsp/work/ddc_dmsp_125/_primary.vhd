library verilog;
use verilog.vl_types.all;
entity ddc_dmsp_125 is
    port(
        link_clk        : in     vl_logic;
        clk_125         : in     vl_logic;
        clk_25          : in     vl_logic;
        clk_100         : in     vl_logic;
        clk_20          : in     vl_logic;
        reset_b         : in     vl_logic;
        get_i           : in     vl_logic_vector(15 downto 0);
        get_q           : in     vl_logic_vector(15 downto 0);
        sig_in_i        : in     vl_logic_vector(15 downto 0);
        sig_in_q        : in     vl_logic_vector(15 downto 0);
        sig_out_i       : out    vl_logic_vector(19 downto 0);
        sig_out_q       : out    vl_logic_vector(19 downto 0)
    );
end ddc_dmsp_125;
