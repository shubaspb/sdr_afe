library verilog;
use verilog.vl_types.all;
entity dds_signal_generator is
    generic(
        WIDTH_NCO       : integer := 16;
        WIDTH_PHASE     : integer := 32;
        WIDHT_ADDR_ROM  : integer := 10;
        INIT_ROM_FILE   : string  := "sin_nco.dat"
    );
    port(
        clk             : in     vl_logic;
        reset_b         : in     vl_logic;
        frequency       : in     vl_logic_vector;
        phase           : in     vl_logic_vector;
        amplitude       : in     vl_logic_vector;
        ena_output      : in     vl_logic;
        start           : in     vl_logic;
        real_sig        : out    vl_logic_vector;
        imag_sig        : out    vl_logic_vector;
        tst             : out    vl_logic_vector(67 downto 0)
    );
end dds_signal_generator;
