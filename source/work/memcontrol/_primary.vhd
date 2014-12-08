library verilog;
use verilog.vl_types.all;
entity memcontrol is
    port(
        hclk            : in     vl_logic;
        nrst            : in     vl_logic;
        target_ba       : in     vl_logic_vector(1 downto 0);
        target_addr     : in     vl_logic_vector(11 downto 0);
        enable          : in     vl_logic;
        w_en            : in     vl_logic;
        r_en            : in     vl_logic;
        c_addr_o        : in     vl_logic_vector(11 downto 0);
        rollover_flag   : in     vl_logic;
        c_addr_en       : out    vl_logic;
        c_addr_i        : out    vl_logic_vector(11 downto 0);
        c_w_en          : out    vl_logic;
        c_w_addr        : out    vl_logic_vector(2 downto 0);
        c_r_en          : out    vl_logic;
        c_r_addr        : out    vl_logic_vector(2 downto 0);
        BUSYn           : out    vl_logic;
        mem_ba          : out    vl_logic_vector(1 downto 0);
        mem_addr        : out    vl_logic_vector(11 downto 0);
        mem_cke         : out    vl_logic;
        mem_CSn         : out    vl_logic;
        mem_RASn        : out    vl_logic;
        mem_CASn        : out    vl_logic;
        mem_WEn         : out    vl_logic;
        tim_clear       : out    vl_logic;
        tim_EN          : out    vl_logic;
        tim_ro_value    : out    vl_logic_vector(11 downto 0)
    );
end memcontrol;
