library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;
use xil_defaultlib.fifo_package.all;


entity axi_write is 
    port(
        --AXI Stream Input
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

        --AXI Lite Write
        s_axi_clk : in std_logic;
        s_axi_resetn : in std_logic;
        s_axi_wdata : in std_logic_vector(31 downto 0);
        s_axi_wvalid : in std_logic;
        s_axi_wready : out std_logic;

        s_axi_bresp : out std_logic_vector(1 downto 0);
        s_axi_bvalid : out std_logic;
        s_axi_bready : in std_logic;

        s_axi_awaddr : in std_logic_vector(31 downto 0);
        s_axi_awvalid : in std_logic;
        s_axi_awready : out std_logic;

        --AXI Lite Read
        s_axi_rdata : out std_logic_vector(31 downto 0);
        s_axi_rvalid : out std_logic;
        s_axi_rready : in std_logic;
        s_axi_rresp : out std_logic_vector(1 downto 0);

        s_axi_araddr : in std_logic_vector(31 downto 0);
        s_axi_arvalid : in std_logic;
        s_axi_arready : out std_logic
    );
end entity;


architecture arch of axi_write is
    component insertion_fifo_generator
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


    --Control Signal
    signal control_signal		: STD_LOGIC;
    signal inter_axi_valid      : STD_LOGIC;
    signal inter_axi_ready      : STD_LOGIC;
    --signal inter_axi_ready      : STD_LOGIC;
    signal inter_response       : STD_LOGIC;

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

    --SLL Signal
    signal data_sll       : unsigned (DATABUSWidth-1 DOWNTO 0);
    signal data_sll_f       : unsigned (DATABUSWidth-1 DOWNTO 0);
    signal tuser_sll       : unsigned (TUSERWidth-1 DOWNTO 0);
    signal tuser_sll_f       : unsigned (TUSERWidth-1 DOWNTO 0);


begin

    --FIFO connection
    u0_fifo : insertion_fifo_generator
        port map(
            wr_clk      => s_axi_clk,
            wr_rst      => wr_rst,
            rd_clk      => s_axis_clk,
            rd_rst      => rd_rst,
            wr_en       => wrreq,
            din         => full_data,
            full        => full,
            rd_en       => rdreq,
            dout        => full_q,
            empty       => empty,
            wr_data_count     => usedw
        );


    m_axis_tdata    <= s_axis_tdata when control_signal = '0' else q;
    m_axis_tkeep    <= s_axis_tkeep when control_signal = '0' else tkeep_q;
    m_axis_tlast    <= s_axis_tlast when control_signal = '0' else tlast_q;
    m_axis_tuser    <= s_axis_tuser when control_signal = '0' else tuser_q;
    m_axis_tvalid   <= s_axis_tvalid when control_signal = '0' else not(empty);
    s_axis_tready   <= m_axis_tready;-- when control_signal = '0' else '0'

    rdreq <= m_axis_tready when (control_signal = '1' and empty = '0') else '0';

    rd_rst <= not(s_axis_resetn);
    wr_rst <= not(s_axi_resetn);

    full_data(FIFOBusWidth-1 downto FIFOBusWidth-DATABUSWidth) <= fifo_data;
    full_data(FIFOBusWidth-DATABUSWidth-1 downto 33) <= tuser_data;
    full_data(32 downto 1) <= tkeep_data;
    full_data(0) <= tlast_data;

    q <= full_q(FIFOBusWidth-1 downto FIFOBusWidth-DATABUSWidth);
    tuser_q <= full_q(FIFOBusWidth-DATABUSWidth-1 downto 33);
    tkeep_q <= full_q(32 downto 1);
    tlast_q <= full_q(0);

    data_sll(DATABUSWidth-1 downto 32) <= (others => '0');
    data_sll(31 downto 0) <= unsigned(s_axi_wdata);
    data_sll_f <= data_sll sll (to_integer(((unsigned(s_axi_araddr)-4) sll 3)-1));

    tuser_sll(TUSERWidth-1 downto 32) <= (others => '0');
    tuser_sll(31 downto 0) <= unsigned(s_axi_wdata);
    tuser_sll_f <= tuser_sll sll (to_integer(((unsigned(s_axi_araddr)-data_addr_max-4) sll 3)-1));

    axi_lite_pro: process(s_axi_clk, s_axi_resetn)
    begin
        if (s_axi_resetn = '0') then
            s_axi_wready <= '0';
            s_axi_bresp <= "00";
            s_axi_bvalid <= '0';
            s_axi_awready <= '0';
            s_axi_rdata <= (others => '0');
            s_axi_rvalid <= '0';
            s_axi_rresp <= "00";
            s_axi_arready <= '0';
            inter_response <= '0';
            control_signal <= '0';
        elsif(rising_edge(s_axi_clk)) then
            s_axi_arready <= '1';
            wrreq <= '0';
            inter_response <= '0';
            if((s_axi_arvalid = '1') and (s_axi_rready = '1')) then
                s_axi_rvalid <= '1';
                s_axi_rresp <= "00";
                s_axi_arready <= '0';
                s_axi_wready <= '0';
                s_axi_bvalid <= '0';
                s_axi_awready <= '0';
                if(s_axi_araddr = std_logic_vector(to_unsigned(0, s_axi_araddr'length))) then
                    s_axi_rdata <= x"0000" & "00" & full & empty & "00" & usedw;
                else
                    s_axi_rdata <= s_axi_araddr;
                end if;
            elsif ((s_axi_awvalid = '1') and (s_axi_wvalid = '1') and (s_axi_bready = '1')) then
                s_axi_rvalid <= '0';
                s_axi_arready <= '0';
                inter_response <= '1';
                s_axi_wready <= '1';
                s_axi_awready <= '1';
                if (s_axi_awaddr = std_logic_vector(to_unsigned(4, s_axi_awaddr'length))) then
                    fifo_data(31 downto 0) <= s_axi_wdata;
                    fifo_data(DATABUSWidth-1 downto 32) <= (others => '0');
                elsif (s_axi_araddr > std_logic_vector(to_unsigned(4, s_axi_araddr'length)) and s_axi_araddr < std_logic_vector(to_unsigned(data_addr_max+1, s_axi_araddr'length))) then
                    fifo_data <= std_logic_vector(unsigned(fifo_data) + data_sll_f);  
                --TUSER Data write
                elsif (s_axi_awaddr = std_logic_vector(to_unsigned(data_addr_max+4, s_axi_awaddr'length))) then
                    tuser_data(31 downto 0) <= s_axi_wdata;
                    tuser_data(TUSERWidth-1 downto 32) <= (others => '0');
                elsif (s_axi_araddr > std_logic_vector(to_unsigned(data_addr_max+4, s_axi_araddr'length)) and s_axi_araddr < std_logic_vector(to_unsigned(tuser_addr_max+1, s_axi_araddr'length))) then
                    tuser_data <= std_logic_vector(unsigned(tuser_data) + tuser_sll_f);  
                --TKEEP
                elsif (s_axi_awaddr = std_logic_vector(to_unsigned(tuser_addr_max+4, s_axi_awaddr'length))) then
                    tkeep_data <= s_axi_wdata;   
                --TLAST
                elsif (s_axi_awaddr = std_logic_vector(to_unsigned(tuser_addr_max+8, s_axi_awaddr'length)) and full = '0') then
                    tlast_data <= s_axi_wdata(0);   
                    wrreq <= '1';
                elsif (s_axi_awaddr = std_logic_vector(to_unsigned(tuser_addr_max+12, s_axi_awaddr'length))) then
                    control_signal <= s_axi_wdata(0);
                end if;
            else
                s_axi_rvalid <= '0';
                s_axi_wready <= '0';
                s_axi_awready <= '0';
            end if;
            if((inter_response = '1') and (s_axi_bready = '1')) then
                inter_response <= '0';
                s_axi_bvalid <= '1';
            else
                s_axi_bvalid <= '0';
            end if;
            if(wrreq = '1') then
                wrreq <= '0';
            end if;
        end if;
    end process;

    --axi_stream_pro: process(s_axis_clk, s_axis_resetn)
    --begin
    --    if (s_axis_resetn = '0') then
    --        rdreq <= '0';
    --        tuser_rdreq <= '0';
    --        tkeep_rdreq <= '0';
    --    elsif(rising_edge(s_axis_clk)) then
    --        if(empty = '0' and control_signal = '1') then
    --            --inter_axi_valid <= '1';
    --            rdreq <= m_axis_tready;
    --            tuser_rdreq <= m_axis_tready;
    --            tkeep_rdreq <= m_axis_tready;
    --        else
    --            rdreq <= '0';
    --            tuser_rdreq <= '0';
    --            tkeep_rdreq <= '0';
    --            --inter_axi_valid <= '0';
    --        end if;
    --    end if;
    --end process;
end architecture;

                


