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
    r_data: out std_logic_vector(7 downto 0);
    r_addr0: out std_logic_vector(3 downto 0)
   
    
    
 );
end FIFOController;

architecture Behavioral of FIFOController is

signal w_en:  std_logic;
signal full1: std_logic; 
signal w_addr_int: unsigned(3 downto 0) := (others => '0');
signal r_addr_int: unsigned(3 downto 0) := (others => '0');
begin

w_addr_cont <= "0000";
full <= '0' when wr = '1' else '1';
full1 <= '0' when wr = '1' else '1';
empty <= '1' when full1 = '0' else '0';
w_en <= wr and not full1; 
process(w_en, CLK, RST)
begin
if (w_en = '1' and rising_edge(CLK)) then
    w_addr_int <= w_addr_int + 1;     
elsif (RST = '1' and rising_edge(CLK)) then
    w_addr_int <= "0000";
end if;
end process;
process(rd, CLK, RST)
begin

if (rd = '1' and rising_edge(CLK)) then
    r_addr_int <= w_addr_int;
    r_data <= w_data;
    w_addr_int <= w_addr_int - 1;
    
elsif (RST = '1' and rising_edge(CLK)) then
    r_addr_int <= "0000";
end if; 
end process;

w_addr_cont <= std_logic_vector(w_addr_int);
r_addr_cont <= std_logic_vector(r_addr_int);
end Behavioral;
