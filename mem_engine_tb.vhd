library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mem_engine_tb is
end mem_engine_tb;

architecture Behavioral of mem_engine_tb is
    -- Timing Constants 
    constant CLK_PERIOD : time := 20 ns;

    -- Signals for Memory_System 
    signal clk          : std_logic := '0';
    signal we           : std_logic := '0';
    signal addr         : std_logic_vector(3 downto 0) := (others => '0');
    signal din          : std_logic_vector(31 downto 0) := (others => '0');
    signal dout         : std_logic_vector(31 downto 0);

    -- Signals for Classification_Engine 
    signal reset        : std_logic := '0';
    signal start_class  : std_logic := '0';
    signal ready        : std_logic;
    signal class_out    : std_logic_vector(1 downto 0);

begin
    -- 1. Instantiate Units Under Test (UUT)
    -- Requires Memory_System.vhd and Classification_Engine.vhd 
    UUT_MEM: entity work.Memory_System
        port map (
            clk  => clk,
            we   => we,
            addr => addr,
            din  => din,
            dout => dout
        );

    UUT_ENG: entity work.Classification_Engine
        port map (
            clk         => clk,
            reset       => reset,
            data_in     => dout, 
            start_class => start_class,
            ready       => ready,
            class_out   => class_out
        );

    -- 2. Clock Generation Process
    clk_process : process
    begin
        while true loop
            clk <= '0'; 
            wait for CLK_PERIOD/2;
            clk <= '1'; 
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- 3. Stimulus Process 
    stim_proc: process
    begin
        -- STEP 1: INITIALIZE THE SYSTEM
        -- Drive reset HIGH 
        reset <= '1';
        wait for 40 ns; 
        reset <= '0';
        
        -- Wait for first falling edge after reset to ensure stable data setup
        wait until falling_edge(clk); 

        -- TEST 1: Write Zero to Address 0
        addr <= "0000"; 
        din  <= x"00000000"; 
        we   <= '1';
        wait until falling_edge(clk); 
        we   <= '0';

        -- TEST 2: Write Max Value to Address 1
        addr <= "0001"; 
        din  <= x"FFFFFFFF"; 
        we   <= '1';
        wait until falling_edge(clk); 
        we   <= '0';
        
        -- STEP 2: Trigger classification engine
        -- FSM should read from RAM Address 1 (FFFFFFFF)
        start_class <= '1';
        wait until falling_edge(clk);
        start_class <= '0';
        
        -- STEP 3: Wait for results
        wait until ready = '1';
        
        -- End of Test
        report "Memory and Classification Simulation Complete" severity note;
        wait; 
    end process;

end Behavioral;
