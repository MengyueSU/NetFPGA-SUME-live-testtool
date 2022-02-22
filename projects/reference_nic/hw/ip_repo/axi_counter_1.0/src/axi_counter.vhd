library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_counter is 
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

        --AXI Lite
        s_axi_clk : in std_logic;
        s_axi_resetn : in std_logic;
        s_axi_rdata : out std_logic_vector(31 downto 0);
        s_axi_rvalid : out std_logic;
        s_axi_rready : in std_logic;
        s_axi_rresp : out std_logic_vector(1 downto 0);

        s_axi_araddr : in std_logic_vector(31 downto 0);
        s_axi_arvalid : in std_logic;
        s_axi_arready : out std_logic
    );
end entity;

architecture arch of axi_counter is

    signal flag_last : std_logic;
    signal counter : unsigned(63 downto 0);
    
    --FIFO Signal
    signal rdreq		: STD_LOGIC;
    signal wrreq		: STD_LOGIC;
    signal empty		: STD_LOGIC;
    signal full		    : STD_LOGIC;
    signal q		    : STD_LOGIC_VECTOR (63 DOWNTO 0);
    signal usedw		: STD_LOGIC_VECTOR (8 DOWNTO 0);
    signal rd_rst		: STD_LOGIC;
    signal wr_rst		: STD_LOGIC;

    component counter_fifo_generator
    PORT (
      wr_clk : IN STD_LOGIC;
      wr_rst : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      rd_rst : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      wr_data_count : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
    );
    end component;

    begin
        m_axis_tdata    <= s_axis_tdata ;
        m_axis_tkeep    <= s_axis_tkeep ;
        m_axis_tlast    <= s_axis_tlast ;
        m_axis_tuser    <= s_axis_tuser ;
        m_axis_tvalid   <= s_axis_tvalid;
        s_axis_tready   <= m_axis_tready;
        
        rd_rst <= not(s_axi_resetn);
        wr_rst <= not(s_axis_resetn);
    --FIFO connection
    counter_fifo : counter_fifo_generator
        port map(
            wr_clk      => s_axis_clk,
            wr_rst      => wr_rst,
            rd_clk      => s_axi_clk,
            rd_rst      => rd_rst,
            wr_en       => wrreq,
            din         => std_logic_vector(counter),
            full        => full,
            rd_en       => rdreq,
            dout        => q,
            empty       => empty,
            wr_data_count     => usedw
        );
        
    counter_pro : process(m_axis_clk,m_axis_resetn)
    begin
        if (m_axis_resetn = '0') then
            counter <= (others => '0');
        elsif(rising_edge(m_axis_clk)) then
            counter <= counter + 1;
        end if;
    end process;

    fifo_pro : process(m_axis_clk,m_axis_resetn)
    begin
        if (m_axis_resetn = '0') then
            flag_last <= '1';
            wrreq <= '0';
        elsif(rising_edge(m_axis_clk)) then
            if((s_axis_tvalid = '1') and (m_axis_tready = '1')) then
                flag_last <= s_axis_tlast;
                if(flag_last = '1') then
                    wrreq <= '1';
                else
                    wrreq <= '0';
                end if;    
            else
                wrreq <= '0';
            end if;
        end if;
    end process;

    axi_lite_read_pro: process(s_axi_clk, s_axi_resetn)
    begin
        if (s_axi_resetn = '0') then
            rdreq <= '0';
            s_axi_arready <= '0';
            s_axi_rvalid <= '0';
            s_axi_rresp <= "00";
        elsif(rising_edge(s_axi_clk)) then
            rdreq <= '0';
            s_axi_arready <= '1';
            if((s_axi_arvalid = '1') and (s_axi_rready = '1')) then
                s_axi_rvalid <= '1';
                s_axi_rresp <= "00";
                s_axi_arready <= '0';
                if(s_axi_araddr = std_logic_vector(to_unsigned(0, s_axi_araddr'length))) then
                    s_axi_rdata <= x"0000" & "00" & full & empty & "000" & usedw;
                elsif (s_axi_araddr = std_logic_vector(to_unsigned(4, s_axi_araddr'length))) then
                    s_axi_rdata <= q(63 downto 32);
                elsif (s_axi_araddr = std_logic_vector(to_unsigned(8, s_axi_araddr'length))) then
                    s_axi_rdata <= q(31 downto 0);
                    rdreq <= '1';
                else
                    s_axi_rdata <= s_axi_araddr;
                end if;
            else
                s_axi_rvalid <= '0';
            end if;
        end if;
    end process;

end arch;