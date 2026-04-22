library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memory_System is
    Port (
        clk   : in  std_logic;                     
        we    : in  std_logic;                     -- Write enable signal
        addr  : in  std_logic_vector(3 downto 0);  -- 4-bit address for 16 rows
        din   : in  std_logic_vector(31 downto 0); -- 32-bit input word
        dout  : out std_logic_vector(31 downto 0)  -- Output to Engine/Host
    );
end Memory_System;

architecture Behavioral of Memory_System is
    ---------------------------------------------------------------------------
    -- MEMORY CONFIG: 16x32 Aspect Ratio
    ---------------------------------------------------------------------------
    type ram_type is array (0 to 15) of std_logic_vector(31 downto 0);
    signal ram_block : ram_type := (others => (others => '0'));

begin

    -- Synchronous Write Process
    process(clk)
    begin
        if rising_edge(clk) then
            if (we = '1') then
                ram_block(to_integer(unsigned(addr))) <= din;
            end if;
        end if;
    end process;

    -- Asynchronous Read Logic for the Classification Engine
    dout <= ram_block(to_integer(unsigned(addr)));

end Behavioral;
