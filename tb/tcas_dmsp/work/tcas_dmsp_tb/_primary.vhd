library verilog;
use verilog.vl_types.all;
entity tcas_dmsp_tb is
    generic(
        WIDTH_IN        : integer := 24;
        WIDTH_OUT       : integer := 24;
        LENGTH_IN       : integer := 10000;
        LENGTH_OUT      : integer := 1900;
        DELAY_module    : integer := 1;
        INPUT_FILE      : string  := "input_tb.dat";
        INPUT_FILE_I    : string  := "input_i_tb.dat";
        INPUT_FILE_Q    : string  := "input_q_tb.dat";
        OUTPUT_FILE_I   : string  := "output_i_tb.dat";
        OUTPUT_FILE_Q   : string  := "output_q_tb.dat";
        OUTPUT_FILE_MAG : string  := "output_mag.dat"
    );
    port(
        sig_rom_out_1   : out    vl_logic_vector;
        sig_rom_out_2   : out    vl_logic_vector;
        sig_rom_out_3   : out    vl_logic_vector
    );
end tcas_dmsp_tb;
