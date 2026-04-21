----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2026 08:03:09 PM
-- Design Name: 
-- Module Name: FIFOController - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FIFOController is
Port (
    wr: in std_logic;
    rd: in std_logic;
    full: out std_logic;
    empty: out std_logic;
    w_addr_cont: out std_logic_vector(3 downto 0);
    r_addr_cont: out std_logic_vector(3 downto 0);
    CLK: in std_logic;
    RST: in std_logic;
    r_addr: in std_logic_vector(3 downto 0);
    w_data: in std_logic_vector(7 downto 0);
    r_data: out std_logic_vector(7 downto 0)
   
    
    
 );
end FIFOController;

architecture Behavioral of FIFOController is

signal w_en:  std_logic;
signal full1: std_logic; 
signal w_addr_int: unsigned(3 downto 0) := (others => '0');
signal r_addr_int: unsigned(3 downto 0) := (others => '0');
type memory is array(0 to 15) of std_logic_vector(7 downto 0);
signal ram: memory := (others =>(others => '0'));
signal empty1: std_logic;
begin


full1 <= '0' when wr = '1' and w_addr_int < 8 and r_addr_int /= w_addr_int else '1';
empty1 <= '1' when full1 = '0' else '0';

w_en <= wr and not full1; 
process(w_en, CLK, RST)
begin
if (RST = '1') then
    w_addr_int <= "0000";
    r_addr_int <= "0000";
    r_data <= "00000000";
elsif (rising_edge(CLK)) then

if (w_en = '1' and full1 = '0') then
    ram(TO_INTEGER(w_addr_int)) <= w_data;
    w_addr_int <= w_addr_int + 1;
end if;     
if (rd = '1' and empty1 = '1') then
    r_data <= ram(TO_INTEGER(r_addr_int));
    r_addr_int <= r_addr_int + 1;
    
   
end if;

end if;
end process;
full <= full1;
empty <= empty1;
w_addr_cont <= std_logic_vector(w_addr_int);
r_addr_cont <= std_logic_vector(r_addr_int);
end Behavioral;
