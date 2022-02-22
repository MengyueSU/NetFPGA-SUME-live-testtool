library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_assertion_test is 
    port(
        --AXI Input
        s_axis_clk : in std_logic;
        s_axis_resetn : in std_logic;
        s_axis_tdata : in std_logic_vector(255 downto 0);
        s_axis_tkeep : in std_logic_vector(31 downto 0);
        s_axis_tlast : in std_logic;
        s_axis_tuser : in std_logic_vector(127 downto 0);
        s_axis_tvalid : in std_logic;
        s_axis_tready : out std_logic;

        --AXI Stream Output Standard
        m_axis_clk : in std_logic;
        m_axis_resetn : in std_logic;
        m_axis_tdata : out std_logic_vector(255 downto 0);
        m_axis_tkeep : out std_logic_vector(31 downto 0);
        m_axis_tlast : out std_logic;
        m_axis_tuser : out std_logic_vector(127 downto 0);
        m_axis_tvalid : out std_logic;
        m_axis_tready : in std_logic;

        --Assertion
        out_assertion : out std_logic
    );
end entity;

architecture arch of axi_assertion_test is

    begin
        m_axis_tdata    <= s_axis_tdata ;
        m_axis_tkeep    <= s_axis_tkeep ;
        m_axis_tlast    <= s_axis_tlast ;
        m_axis_tuser    <= s_axis_tuser ;
        m_axis_tvalid   <= s_axis_tvalid;
        s_axis_tready   <= m_axis_tready;

    assert_pro : process(m_axis_clk,m_axis_resetn)
    begin
        if (m_axis_resetn = '0') then
            out_assertion <= '0';
        elsif(rising_edge(m_axis_clk)) then
            if((s_axis_tdata(111 downto 80) = x"646E6946") and (s_axis_tvalid = '1') and (m_axis_tready = '1')) then
                out_assertion <= '1';
            else
                out_assertion <= '0';
            end if;
        end if;
    end process;

end arch;