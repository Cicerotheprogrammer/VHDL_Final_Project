library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is

    component top is
        Port (
            clk   : in  std_logic;
            reset : in  std_logic;
            rx    : in  std_logic;
            tx    : out std_logic;
            led   : out std_logic_vector(3 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 8 ns;
    constant BIT_PERIOD : time := 813 * 16 * CLK_PERIOD;

    signal clk     : std_logic := '0';
    signal reset   : std_logic := '1';
    signal rx      : std_logic := '1';
    signal tx      : std_logic;
    signal led     : std_logic_vector(3 downto 0);

    -- Decoded byte values visible in waveform
    signal rx_byte : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_byte : std_logic_vector(7 downto 0) := (others => '0');

    procedure uart_send(
        data           : in  std_logic_vector(7 downto 0);
        signal rx_line : out std_logic
    ) is
    begin
        rx_line <= '0';
        wait for BIT_PERIOD;
        for i in 0 to 7 loop
            rx_line <= data(i);
            wait for BIT_PERIOD;
        end loop;
        rx_line <= '1';
        wait for BIT_PERIOD;
    end procedure;

begin

    clk <= not clk after CLK_PERIOD / 2;

    UUT : top
        port map(
            clk   => clk,
            reset => reset,
            rx    => rx,
            tx    => tx,
            led   => led
        );

    -- Decode incoming RX byte (samples at mid-bit)
    process
    begin
        loop
            wait until falling_edge(rx);       -- start bit
            wait for BIT_PERIOD + BIT_PERIOD / 2;  -- skip start, land mid bit 0
            for i in 0 to 7 loop
                rx_byte(i) <= rx;
                wait for BIT_PERIOD;
            end loop;
        end loop;
    end process;

    -- Decode outgoing TX byte (samples at mid-bit)
    process
    begin
        loop
            wait until falling_edge(tx);       -- start bit
            wait for BIT_PERIOD + BIT_PERIOD / 2;  -- skip start, land mid bit 0
            for i in 0 to 7 loop
                tx_byte(i) <= tx;
                wait for BIT_PERIOD;
            end loop;
        end loop;
    end process;

    -- Stimulus
    process
    begin
        reset <= '1';
        wait for 20 * CLK_PERIOD;
        reset <= '0';
        wait for 10 * CLK_PERIOD;

        uart_send(x"41", rx);   -- 'A' = 0x41
        wait for 5 * BIT_PERIOD;

        uart_send(x"FF", rx);
        wait for 5 * BIT_PERIOD;

        uart_send(x"00", rx);
        wait for 5 * BIT_PERIOD;

        uart_send(x"A0", rx);
        wait for 5 * BIT_PERIOD;

        wait;
    end process;

end Behavioral;
