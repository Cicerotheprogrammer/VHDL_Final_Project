library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Classification_Engine is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        -- Input directly from Memory_System dout
        data_in     : in  std_logic_vector(31 downto 0); 
        -- Control signals from FSM 
        start_class : in  std_logic;
        ready       : out std_logic;
        -- 2-bit result sent back to UART Transmitter 
        class_out   : out std_logic_vector(1 downto 0)
    );
end Classification_Engine;

architecture Behavioral of Classification_Engine is
    type state_type is (IDLE, CLASSIFY, DONE);
    signal state_reg, state_next : state_type;
    signal class_reg, class_next : std_logic_vector(1 downto 0);

begin
    process(clk, reset)
    begin
        if reset = '1' then
            state_reg <= IDLE;
            class_reg <= "00";
        elsif rising_edge(clk) then
            state_reg <= state_next;
            class_reg <= class_next;
        end if;
    end process;

    process(state_reg, start_class, data_in, class_reg)
    begin
        state_next <= state_reg;
        class_next <= class_reg;
        ready      <= '0';

        case state_reg is
            when IDLE =>
                if start_class = '1' then
                    state_next <= CLASSIFY;
                end if;

            when CLASSIFY =>
                -- Classifies based on magnitude
                if data_in = x"00000000" then
                    class_next <= "00"; -- Class 0: Zero
                elsif unsigned(data_in) = x"FFFFFFFF" then
                    class_next <= "11"; -- Class 3: Max/Full
                elsif unsigned(data_in) < x"80000000" then
                    class_next <= "01"; -- Class 1: Low Mag
                else
                    class_next <= "10"; -- Class 2: High Mag
                end if;
                state_next <= DONE;

            when DONE =>
                ready <= '1';
                state_next <= IDLE;
        end case;
    end process;

    class_out <= class_reg;

end Behavioral;
