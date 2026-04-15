library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity transmitter is
    generic(
        BITS: integer := 8;
        SB_TICKS: integer := 16
    );
    port(
        clk: in std_logic;
        reset: in std_logic;
        transmitter_start: in std_logic;
        s_tick: in std_logic;
        data_in: in std_logic_vector(7 downto 0);
        transmitter_done: out std_logic;
        transmitter: out std_logic
        );
end transmitter;

architecture Behavioral of transmitter is
    type state_type is (idle, start, data, stop);
    signal state_reg, state_next : state_type;
    
    signal s_reg, s_next: unsigned(3 downto 0);
    signal n_reg, n_next: unsigned(2 downto 0);
    signal b_reg, b_next: std_logic_vector(7 downto 0);
    signal transmitter_reg, transmitter_next: std_logic;
begin
    process(clk, reset)
    begin
        if (reset = '1') then
            state_reg <= idle;
            s_reg <= (others => '0');
            n_reg <= (others => '0');
            b_reg <= (others => '0');
            transmitter_reg <= '1';
        elsif rising_edge(clk) then
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            transmitter_reg <= transmitter_next;
        end if;
    end process;
    
    process(state_reg, s_reg, n_reg, b_reg, s_tick, transmitter_reg, transmitter_start, data_in)
    begin
        state_next <= state_reg;
        s_next <= s_reg;
        n_next <= n_reg;
        b_next <= b_reg;
        transmitter_next <= transmitter_reg; 
        transmitter_done <= '0';
        
    case state_reg is
            when idle =>
                transmitter_next <= '1';
                if (transmitter_start = '1') then
                    state_next <= start;
                    b_next <= data_in;
                    s_next <= (others => '0');
                end if;
            when start =>
                transmitter_next <= '0';
                if (s_tick = '1') then
                    if (s_reg = 15) then
                        state_next <= data;
                        s_next <= (others => '0');
                        n_next <= (others => '0');
                    else
                        s_next <= s_reg + 1;
                    end if;
                end if;
            when data =>
                transmitter_next <= b_reg(0);
                if (s_tick = '1') then
                    if (s_reg = 15) then
                        s_next <= (others => '0');
                        b_next <= '0' & b_reg(7 downto 1);
                        if (n_reg = (BITS - 1)) then
                            state_next <= stop;
                        else
                            n_next <= n_reg + 1;
                        end if;
                    else
                        s_next <= s_reg + 1;
                    end if;
                end if;
            when stop =>
                transmitter_next <= '1';
                if (s_tick = '1') then
                    if (s_reg = (SB_TICKS - 1)) then
                        state_next <= idle;
                        transmitter_done <= '1';
                    else
                        s_next <= s_reg + 1;
                    end if;
                end if;
        end case;
    end process;
    
    transmitter <= transmitter_reg;                  

end Behavioral;