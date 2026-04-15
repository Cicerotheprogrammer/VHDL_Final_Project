library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity transmitter_tb is
end transmitter_tb;

architecture Behavioral of transmitter_tb is

    constant CLK_PERIOD: time := 20 ns;
    
    signal clk: std_logic := '0';
    signal reset: std_logic := '0';
    
    signal max_tick: std_logic;
    signal q: std_logic_vector(8 downto 0);
    
    signal transmitter_start: std_logic := '0';
    signal transmitter_done: std_logic;
    signal transmitter: std_logic;
    signal data_in: std_logic_vector(7 downto 0);
    
begin

    process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;
    
    process
    begin
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait;
    end process;
    
    baud_inst: entity work.baud_Gen
        generic map(
            N => 9,
            M => 326
        )
        port map(
            clk => clk,
            reset => reset,
            max_tick => max_tick,
            q => q
        );
        
    transmitter_DUT: entity work.transmitter
        port map(
            clk => clk,
            reset => reset,
            transmitter_start => transmitter_start,
            s_tick => max_tick,
            data_in => data_in,
            transmitter_done => transmitter_done,
            transmitter => transmitter
        );
        
    process
    begin
        wait until reset = '0';
        
        data_in <= "10101010";
        wait for 50 ns;
        transmitter_start <= '1';
        wait for CLK_PERIOD;
        transmitter_start <= '0';
        wait until transmitter_done = '1';
        
        wait for 200 ns;
        data_in <= "11001100";
        transmitter_start <= '1';
        wait for CLK_PERIOD;
        transmitter_start <= '0';
        wait until transmitter_done = '1';
        
        wait for 200 ns;
        assert false report " Transmitter Simulation Complete" severity failure;
    end process;

end Behavioral;

