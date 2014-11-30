library verilog;
use verilog.vl_types.all;
entity cache is
    port(
        clk             : in     vl_logic;
        n_rst           : in     vl_logic;
        addr_enable     : in     vl_logic;
        addr_in         : in     vl_logic_vector(11 downto 0);
        data_in         : in     vl_logic_vector(31 downto 0);
        write_enable    : in     vl_logic;
        write_pointer   : in     vl_logic_vector(2 downto 0);
        read_enable     : in     vl_logic;
        read_pointer    : in     vl_logic_vector(2 downto 0);
        addr_out        : out    vl_logic_vector(11 downto 0);
        data_out        : out    vl_logic_vector(31 downto 0)
    );
end cache;
