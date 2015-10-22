library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_out_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
		ac_mclk : in std_logic;
		ac_bclk : out std_logic;
		ac_muten : out std_logic;
		ac_pbdat : out std_logic;
		ac_pblrc : out std_logic;
		ac_recdat : out std_logic;
		ac_reclrc : out std_logic;
		led : out std_logic_vector(3 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Ports of Axi Slave Bus Interface S_AXI
		s_axi_aclk	: in std_logic;
		s_axi_aresetn	: in std_logic;
		s_axi_awaddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;
		s_axi_wdata	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;
		s_axi_bresp	: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;
		s_axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;
		s_axi_rdata	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic
	);
end i2s_out_v1_0;

architecture arch_imp of i2s_out_v1_0 is

	-- component declaration
	component i2s_out_v1_0_S_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component i2s_out_v1_0_S_AXI;

component audio_fifo_0 IS
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component;

signal reset : std_logic;
signal led_r : std_logic_vector(3 downto 0);
signal mc_count : integer range 0 to 12000000;
signal bc_count : integer range 0 to 2000000;
signal bclk : std_logic;
signal bclk_r : std_logic;
signal fs_cycle : integer range 0 to 250;
signal b_cycle : integer range 0 to 6;
signal f_cycle : integer range 0 to 109;
signal fdout : std_logic_vector(15 downto 0);
signal pblrc : std_logic;
signal pbdat : std_logic_vector(15 downto 0);

begin

-- Instantiation of Axi Bus Interface S_AXI
i2s_out_v1_0_S_AXI_inst : i2s_out_v1_0_S_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s_axi_aclk,
		S_AXI_ARESETN	=> s_axi_aresetn,
		S_AXI_AWADDR	=> s_axi_awaddr,
		S_AXI_AWPROT	=> s_axi_awprot,
		S_AXI_AWVALID	=> s_axi_awvalid,
		S_AXI_AWREADY	=> s_axi_awready,
		S_AXI_WDATA	=> s_axi_wdata,
		S_AXI_WSTRB	=> s_axi_wstrb,
		S_AXI_WVALID	=> s_axi_wvalid,
		S_AXI_WREADY	=> s_axi_wready,
		S_AXI_BRESP	=> s_axi_bresp,
		S_AXI_BVALID	=> s_axi_bvalid,
		S_AXI_BREADY	=> s_axi_bready,
		S_AXI_ARADDR	=> s_axi_araddr,
		S_AXI_ARPROT	=> s_axi_arprot,
		S_AXI_ARVALID	=> s_axi_arvalid,
		S_AXI_ARREADY	=> s_axi_arready,
		S_AXI_RDATA	=> s_axi_rdata,
		S_AXI_RRESP	=> s_axi_rresp,
		S_AXI_RVALID	=> s_axi_rvalid,
		S_AXI_RREADY	=> s_axi_rready
	);

	-- Add user logic here
--    ac_bclk <= '0';
--    ac_pbdat <= '0';
--    ac_pblrc <= '0';

    Inst_audio_fifo_0: audio_fifo_0 port map (
        rst => reset,
        wr_clk => s_axi_aclk,
        rd_clk => ac_mclk,
        din => "00000000000000000000000000000000",
        wr_en => '0',
        rd_en => '0',
        dout => open,
        full => open,
        empty => open
    );

	reset <= not s_axi_aresetn;
    ac_recdat <= '0';
    ac_reclrc <= '0';
    ac_muten <= '1';
    
    led <= led_r;
    led_r(0) <= '0';
    led_r(1) <= '0';

    process (ac_mclk, reset) begin
        if (reset = '1') then
            led_r(3) <= '1';
            mc_count <= 0;
        elsif (ac_mclk'event and ac_mclk = '1') then
            if (mc_count >= 6000000) then
                led_r(3) <= not led_r(3);
                mc_count <= 0;
            else
                mc_count <= mc_count + 1;
            end if;
        end if;
    end process;

    -- generate BCLK
    process (ac_mclk, reset) begin
        if (reset = '1') then
            fs_cycle <= 0;
            b_cycle <= 0;
            f_cycle <= 0;
            bclk <= '0';
        elsif (ac_mclk'event and ac_mclk = '1') then
            if (fs_cycle >= 249) then
                fs_cycle <= 0;
                b_cycle <= 0;
                if (f_cycle >= 107) then
                    f_cycle <= 0;
                else
                    f_cycle <= f_cycle + 1;
                end if;
                bclk <= '0';
            else
                fs_cycle <= fs_cycle + 1;
                if (b_cycle >= 5) then
                    b_cycle <= 0;
                else
                    b_cycle <= b_cycle + 1;
                end if;
                if (b_cycle = 2) then
                    bclk <= '1';
                elsif (b_cycle = 5) then
                    bclk <= '0';
                end if;
            end if;
        end if;
    end process;

    -- generate PBDAT/PBLRC version 1
    process (ac_mclk, reset) begin
        if (reset = '1') then
            fdout <= (others => '0');
            pblrc <= '0';
            pbdat <= (others => '0');
        elsif (ac_mclk'event and ac_mclk = '1') then
            if (fs_cycle >= 249) then
                pblrc <= '1';   -- RIGHT
                if (f_cycle = 107) then
                    fdout <= "0001000000000000";
                elsif (f_cycle = 53) then
                    fdout <= "0000000000000000";
                end if;
            elsif (fs_cycle >= 124) then
                pblrc <= '0';   -- LEFT
            end if;
            if (fs_cycle = 5) then
                pbdat <= fdout;
            else
                if (b_cycle = 5) then
                    pbdat <= pbdat(14 downto 0) & '0';
                end if;
            end if;
        end if;
    end process;
    ac_pbdat <= pbdat(15);
    ac_pblrc <= pblrc;
    ac_bclk <= bclk;

    -- generate PBDAT/PBLRC version 2
    process (ac_mclk, reset) begin
        if (reset = '1') then
        elsif (ac_mclk'event and ac_mclk = '1') then
            if (fs_cycle >= 249) then
            else
            end if;
        end if;
    end process;

    process (ac_mclk, reset) begin
        if (reset = '1') then
            bc_count <= 0;
            led_r(2) <= '1';
        elsif (ac_mclk'event and ac_mclk = '1') then
            if (bclk = '1' and bclk_r = '0') then
                if (bc_count >= 1000000) then
                    led_r(2) <= not led_r(2);
                    bc_count <= 0;
                else
                    bc_count <= bc_count + 1;
                end if;
            end if;
            bclk_r <= bclk;
        end if;
    end process;
    
    -- User logic ends

end arch_imp;
