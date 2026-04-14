library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_gen_tb is

end baud_gen_tb;

architecture sim of baud_gen_tb is

    constant N : integer := 4; --9;
    constant M : integer := 10; --326;
    
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal max_tick : std_logic;
    signal q        : std_logic_vector(N-1 downto 0);

begin
    clk <= not clk after 5 ns;
    UUT: entity work.baud_Gen
        generic map(
            N => N, 
            M => M
        )
        port map(
            clk      => clk,
            reset    => reset,
            max_tick => max_tick,
            q        => q
        );

    stim_proc: process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 500 ns;
        wait; 
    end process;

end sim;