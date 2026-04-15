library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity receiver_tb is
end receiver_tb;

architecture Behavioral of receiver_tb is

    constant CLK_PERIOD: time := 20 ns;
    
    signal clk: std_logic := '0';
    signal reset: std_logic := '0';
    
    signal max_tick: std_logic;
    signal q: std_logic_vector(8 downto 0);
    
    signal receiver: std_logic := '1';
    signal receiver_done: std_logic;
    signal data_out: std_logic_vector(7 downto 0);
    
    procedure send_uart(signal receiver_line: out std_logic; data: std_logic_vector(7 downto 0)) is
    begin
        receiver_line <= '0';
        for i in 0 to 7 loop
            wait until max_tick = '1';
        end loop;
        
        for i in 0 to 7 loop
            receiver_line <= data(i);
            for j in 0 to 15 loop
                wait until max_tick = '1';
            end loop;
        end loop;
        
        receiver_line <= '1';
        for i in 0 to 15 loop
            wait until max_tick = '1';
        end loop;
    end procedure;
    
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
        
    receiver_DUT: entity work.receiver
        port map(
            clk => clk,
            reset => reset,
            receiver => receiver,
            s_tick => max_tick,
            receiver_done => receiver_done,
            data_out => data_out
        );
    
    process
    begin
        wait until reset = '0';
        wait for 200 ns;
        send_uart(receiver, "10101010");
        wait until receiver_done = '1';
        assert data_out = "10101010"
        report "ERROR: Receiver mismatch (Test 1)" severity error;
        
        wait for 200 ns;
        send_uart(receiver, "11001100");
        wait until receiver_done = '1';
        assert data_out = "11001100"
        report "ERROR: Receiver mismatch (Test 2)" severity error;
        
        wait for 200 ns;
        report "Receiver Simulation Complete" severity failure;
    end process;

end Behavioral;
