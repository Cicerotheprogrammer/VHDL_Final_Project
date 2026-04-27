library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        clk   : in  std_logic;
        reset : in  std_logic;
        rx    : in  std_logic;
        tx    : out std_logic;
        led   : out std_logic_vector(3 downto 0)
    );
end top;

architecture Behavioral of top is

    component baud_Gen is
        generic(
            N : integer := 9;
            M : integer := 326
        );
        port(
            clk      : in  std_logic;
            reset    : in  std_logic;
            max_tick : out std_logic;
            q        : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component receiver is
        generic(
            BITS     : integer := 8;
            SB_TICKS : integer := 16
        );
        port(
            clk           : in  std_logic;
            reset         : in  std_logic;
            receiver      : in  std_logic;
            s_tick        : in  std_logic;
            receiver_done : out std_logic;
            data_out      : out std_logic_vector(7 downto 0)
        );
    end component;

    component FIFOController is
        port(
            CLK         : in  std_logic;
            RST         : in  std_logic;
            wr          : in  std_logic;
            rd          : in  std_logic;
            w_data      : in  std_logic_vector(7 downto 0);
            r_data      : out std_logic_vector(7 downto 0);
            full        : out std_logic;
            empty       : out std_logic;
            w_addr_cont : out std_logic_vector(3 downto 0);
            r_addr_cont : out std_logic_vector(3 downto 0)
        );
    end component;

    component Memory_System is
        port(
            clk  : in  std_logic;
            we   : in  std_logic;
            addr : in  std_logic_vector(3 downto 0);
            din  : in  std_logic_vector(31 downto 0);
            dout : out std_logic_vector(31 downto 0)
        );
    end component;

    component Classification_Engine is
        port(
            clk         : in  std_logic;
            reset       : in  std_logic;
            data_in     : in  std_logic_vector(31 downto 0);
            start_class : in  std_logic;
            ready       : out std_logic;
            class_out   : out std_logic_vector(1 downto 0)
        );
    end component;

    component flag_buff is
        generic(
            W : integer := 8
        );
        port(
            clk      : in  std_logic;
            reset    : in  std_logic;
            clr_flag : in  std_logic;
            set_flag : in  std_logic;
            din      : in  std_logic_vector(W-1 downto 0);
            dout     : out std_logic_vector(W-1 downto 0);
            flag     : out std_logic
        );
    end component;

    component transmitter is
        generic(
            BITS     : integer := 8;
            SB_TICKS : integer := 16
        );
        port(
            clk               : in  std_logic;
            reset             : in  std_logic;
            s_tick            : in  std_logic;
            transmitter_start : in  std_logic;
            data_in           : in  std_logic_vector(7 downto 0);
            transmitter_done  : out std_logic;
            transmitter       : out std_logic
        );
    end component;

    -- Internal signals
    signal s_tick       : std_logic;
    signal rx_data      : std_logic_vector(7 downto 0);
    signal rx_done      : std_logic;
    signal fifo_r_data  : std_logic_vector(7 downto 0);
    signal fifo_full    : std_logic;
    signal fifo_empty   : std_logic;
    signal fifo_r_addr  : std_logic_vector(3 downto 0);
    signal fifo_w_addr  : std_logic_vector(3 downto 0);
    signal fifo_rd      : std_logic;
    signal start_class  : std_logic;  -- fifo_rd delayed 1 cycle for FIFO r_data to settle
    signal class_busy   : std_logic;  -- high while classification is in progress
    signal mem_dout     : std_logic_vector(31 downto 0);
    signal class_out    : std_logic_vector(1 downto 0);
    signal class_ready  : std_logic;
    signal tx_done      : std_logic;
    signal flag_dout    : std_logic_vector(7 downto 0);
    signal flag         : std_logic;

begin

    -- Read FIFO whenever data is available and engine is not busy
    fifo_rd <= (not fifo_empty) and (not class_busy);

    -- Pipeline control: delay start_class by 1 cycle so FIFO r_data is valid,
    -- and hold class_busy high until classification finishes
    process(clk, reset)
    begin
        if reset = '1' then
            start_class <= '0';
            class_busy  <= '0';
        elsif rising_edge(clk) then
            start_class <= fifo_rd;          -- 1 cycle after FIFO read
            if fifo_rd = '1' then
                class_busy <= '1';           -- lock until engine is done
            elsif class_ready = '1' then
                class_busy <= '0';
            end if;
        end if;
    end process;

    -- Baud Rate Generator
    -- M=813, N=10 for 9600 baud at 125 MHz (Zybo Z7-10)
    U_BAUD : baud_Gen
        generic map(
            N => 10,
            M => 813
        )
        port map(
            clk      => clk,
            reset    => reset,
            max_tick => s_tick,
            q        => open
        );

    -- UART Receiver
    U_RX : receiver
        port map(
            clk           => clk,
            reset         => reset,
            receiver      => rx,
            s_tick        => s_tick,
            receiver_done => rx_done,
            data_out      => rx_data
        );

    -- FIFO: buffer received bytes
    U_FIFO : FIFOController
        port map(
            CLK         => clk,
            RST         => reset,
            wr          => rx_done,
            rd          => fifo_rd,
            w_data      => rx_data,
            r_data      => fifo_r_data,
            full        => fifo_full,
            empty       => fifo_empty,
            w_addr_cont => fifo_w_addr,
            r_addr_cont => fifo_r_addr
        );

    -- Memory System: write 1 cycle after FIFO read so r_data is valid
    U_MEM : Memory_System
        port map(
            clk  => clk,
            we   => start_class,
            addr => fifo_r_addr,
            din  => x"000000" & fifo_r_data,
            dout => mem_dout
        );

    -- Classification Engine: start 1 cycle after FIFO read (data now stable)
    U_CLASS : Classification_Engine
        port map(
            clk         => clk,
            reset       => reset,
            data_in     => mem_dout,
            start_class => start_class,
            ready       => class_ready,
            class_out   => class_out
        );

    -- Flag Buffer: latch classification result
    U_FLAGS : flag_buff
        port map(
            clk      => clk,
            reset    => reset,
            set_flag => class_ready,
            clr_flag => tx_done,
            din      => "000000" & class_out,
            dout     => flag_dout,
            flag     => flag
        );

    -- UART Transmitter: send classification result back
    U_TX : transmitter
        port map(
            clk               => clk,
            reset             => reset,
            s_tick            => s_tick,
            transmitter_start => class_ready,
            data_in           => "000000" & class_out,
            transmitter_done  => tx_done,
            transmitter       => tx
        );

    -- LEDs: flag, class result, FIFO status
    led <= flag & class_out & fifo_empty;

end Behavioral;
