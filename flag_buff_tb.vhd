library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity flag_buff_tb is
end flag_buff_tb;

architecture Behavioral of flag_buff_tb is
    constant W : integer := 8;

    signal clk            : std_logic := '0';
    signal reset          : std_logic := '0';
    signal clr_flag       : std_logic := '0';
    signal set_flag       : std_logic := '0';
    signal din            : std_logic_vector(W-1 downto 0) := (others => '0');
    signal dout           : std_logic_vector(W-1 downto 0);
    signal flag           : std_logic;

    component flag_buff
        generic(W : integer := 8);
        port(
            clk, reset        : in  std_logic;
            clr_flag, set_flag: in  std_logic;
            din               : in  std_logic_vector(W-1 downto 0);
            dout              : out std_logic_vector(W-1 downto 0);
            flag              : out std_logic
        );
    end component;

begin

    UUT: flag_buff
        generic map (W => W)
        port map (
            clk      => clk,
            reset    => reset,
            clr_flag => clr_flag,
            set_flag => set_flag,
            din      => din,
            dout     => dout,
            flag     => flag
        );
    clk <= not clk after 5 ns;

    process begin
        -- hold reset
        reset <= '1'; wait for 20 ns;
        reset <= '0'; wait for 10 ns;

        din <= x"AB"; set_flag <= '1'; wait for 10 ns;
        set_flag <= '0'; wait for 10 ns;

        clr_flag <= '1'; wait for 10 ns;
        clr_flag <= '0'; wait for 10 ns;

        din <= x"CD"; set_flag <= '1'; wait for 10 ns;
        set_flag <= '0'; wait for 10 ns;

        din <= x"FF"; set_flag <= '1'; clr_flag <= '1'; wait for 10 ns;
        set_flag <= '0'; clr_flag <= '0'; wait for 20 ns;
        
        reset <= '1'; wait for 20 ns;
        wait;
    end process;

end Behavioral;