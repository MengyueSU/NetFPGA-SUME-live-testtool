library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;
use xil_defaultlib.fifo_package.all;

entity axi_extraction is 
    port(
        --AXI Input
        s_axis_clk : in std_logic;
        s_axis_resetn : in std_logic;
        s_axis_tdata : in std_logic_vector(DATABUSWidth-1 downto 0);
        s_axis_tkeep : in std_logic_vector(31 downto 0);
        s_axis_tlast : in std_logic;
        s_axis_tuser : in std_logic_vector(TUSERWidth-1 downto 0);
        s_axis_tvalid : in std_logic;
        s_axis_tready : out std_logic;

        --AXI Stream Output Standard
        m_axis_clk : in std_logic;
        m_axis_resetn : in std_logic;
        m_axis_tdata : out std_logic_vector(DATABUSWidth-1 downto 0);
        m_axis_tkeep : out std_logic_vector(31 downto 0);
        m_axis_tlast : out std_logic;
        m_axis_tuser : out std_logic_vector(TUSERWidth-1 downto 0);
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

architecture arch of axi_extraction is

    component extraction_fifo_generator
      PORT (
        wr_clk : IN STD_LOGIC;
        wr_rst : IN STD_LOGIC;
        rd_clk : IN STD_LOGIC;
        rd_rst : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(FIFOBusWidth-1 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(FIFOBusWidth-1 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC;
        wr_data_count : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
      );
    end component;
    
    --CONSTANT
    constant data_addr_max : integer := integer(DATABUSWidth/8);
    constant tuser_addr_max : integer := integer((DATABUSWidth+TUSERWidth)/8);

    --FIFO Signal
    signal full_data    : STD_LOGIC_VECTOR (FIFOBusWidth-1 DOWNTO 0);
    signal full_q		: STD_LOGIC_VECTOR (FIFOBusWidth-1 DOWNTO 0);

    signal fifo_data    : STD_LOGIC_VECTOR (DATABUSWidth-1 DOWNTO 0);
    signal rdreq		: STD_LOGIC;
    signal wrreq		: STD_LOGIC;
    signal empty		: STD_LOGIC;
    signal full		    : STD_LOGIC;
    signal q		    : STD_LOGIC_VECTOR (DATABUSWidth-1 DOWNTO 0);
    signal usedw		: STD_LOGIC_VECTOR (9 DOWNTO 0);
    signal rd_rst		: STD_LOGIC;
    signal wr_rst		: STD_LOGIC;

    -- TUSER FIFO Signal
    signal tuser_data       : STD_LOGIC_VECTOR (TUSERWidth-1 DOWNTO 0);
    signal tuser_q		    : STD_LOGIC_VECTOR (TUSERWidth-1 DOWNTO 0);

    -- TKEEP & TLAST FIFO Signal
    signal tkeep_data       : STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal tkeep_q		    : STD_LOGIC_VECTOR (31 DOWNTO 0);

    signal tlast_data       : STD_LOGIC;
    signal tlast_q		    : STD_LOGIC;

    --SRL signal
    signal q_srl    : STD_LOGIC_VECTOR (DATABUSWidth-1 DOWNTO 0);
    signal tuser_srl    : STD_LOGIC_VECTOR (TUSERWidth-1 DOWNTO 0);

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
    u0_fifo : extraction_fifo_generator
        port map(
            wr_clk      => s_axis_clk,
            wr_rst      => wr_rst,
            rd_clk      => s_axi_clk,
            rd_rst      => rd_rst,
            wr_en       => wrreq,
            din         => full_data,
            full        => full,
            rd_en       => rdreq,
            dout        => full_q,
            empty       => empty,
            wr_data_count     => usedw
        );

    full_data(FIFOBusWidth-1 downto FIFOBusWidth-DATABUSWidth) <= fifo_data;
    full_data(FIFOBusWidth-DATABUSWidth-1 downto 33) <= tuser_data;
    full_data(32 downto 1) <= tkeep_data;
    full_data(0) <= tlast_data;

    q <= full_q(FIFOBusWidth-1 downto FIFOBusWidth-DATABUSWidth);
    tuser_q <= full_q(FIFOBusWidth-DATABUSWidth-1 downto 33);
    tkeep_q <= full_q(32 downto 1);
    tlast_q <= full_q(0);

    q_srl <= std_logic_vector(unsigned(q) srl (to_integer((unsigned(s_axi_araddr)-4) sll 3)));
    tuser_srl <= std_logic_vector(unsigned(tuser_q) srl (to_integer((unsigned(s_axi_araddr)-data_addr_max-4) sll 3)));


    fifo_write_pro : process(m_axis_clk,m_axis_resetn)
    begin
        if (m_axis_resetn = '0') then
            wrreq <= '0';
        elsif(rising_edge(m_axis_clk)) then
            if((full = '0') and (s_axis_tvalid = '1') and (m_axis_tready = '1')) then
                wrreq <= '1';
                fifo_data <= s_axis_tdata;
                tuser_data <= s_axis_tuser;
                tkeep_data <= s_axis_tkeep;
                tlast_data <= s_axis_tlast;
            else
                wrreq <= '0';
            end if;
        end if;
    end process;
    --s_axi_arready <= not s_axi_rvalid;
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
                --s_axi_rdata <= s_axi_araddr;
                if(s_axi_araddr = std_logic_vector(to_unsigned(0, s_axi_araddr'length))) then
                    s_axi_rdata <= x"0000" & "00" & full & empty & "00" & usedw;
                elsif (s_axi_araddr = std_logic_vector(to_unsigned(4, s_axi_araddr'length))) then
                    s_axi_rdata <= q(31 downto 0);
                elsif (s_axi_araddr > std_logic_vector(to_unsigned(4, s_axi_araddr'length)) and s_axi_araddr < std_logic_vector(to_unsigned(data_addr_max+1, s_axi_araddr'length))) then
                    s_axi_rdata <= q_srl(31 downto 0);
                --TUSER Data read
                elsif (s_axi_araddr = std_logic_vector(to_unsigned(data_addr_max+4, s_axi_araddr'length))) then
                    s_axi_rdata <= tuser_q(31 downto 0);  
                elsif (s_axi_araddr > std_logic_vector(to_unsigned(data_addr_max+4, s_axi_araddr'length)) and s_axi_araddr < std_logic_vector(to_unsigned(tuser_addr_max+1, s_axi_araddr'length))) then
                    s_axi_rdata <= tuser_srl(31 downto 0);  
                --TKEEP
                elsif (s_axi_araddr = std_logic_vector(to_unsigned(tuser_addr_max+4, s_axi_araddr'length))) then
                    s_axi_rdata <= tkeep_q;   
                --TLAST
                elsif (s_axi_araddr = std_logic_vector(to_unsigned(tuser_addr_max+8, s_axi_araddr'length))) then
                    s_axi_rdata <= x"0000000" & "000" & tlast_q;   
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