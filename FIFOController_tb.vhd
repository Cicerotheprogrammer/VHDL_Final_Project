----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2026 01:07:15 PM
-- Design Name: 
-- Module Name: FIFOController_tb - Behavioral
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

entity FIFOController_tb is
--  Port ( );
end FIFOController_tb;

architecture Behavioral of FIFOController_tb is
signal wr: std_logic := '0';
signal rd: std_logic := '0';
signal full: std_logic;
signal empty: std_logic;
signal w_addr_cont: std_logic_vector(3 downto 0);
signal r_addr_cont: std_logic_vector(3 downto 0);
signal CLK: std_logic;
signal RST: std_logic;
--signal r_addr: std_logic_vector(3 downto 0);
signal w_data: std_logic_vector(7 downto 0);
signal r_data: std_logic_vector(7 downto 0);
signal w_addr: std_logic_vector(3 downto 0);
constant clk_period : time := 10 ns;

component FIFOController
port(
    wr: in std_logic;
    rd: in std_logic;
    full: out std_logic;
    empty: out std_logic;
    w_addr_cont: out std_logic_vector(3 downto 0);
    r_addr_cont: out std_logic_vector(3 downto 0);
    CLK: in std_logic;
    RST: in std_logic;
--    r_addr: in std_logic_vector(3 downto 0);
    w_data: in std_logic_vector(7 downto 0);
    r_data: out std_logic_vector(7 downto 0)

);

end component;
begin
UUT: FIFOController
    port map(
        CLK => CLK,
        RST => RST,
        wr => wr,
        rd => rd,
        full => full,
        empty => empty,
        w_addr_cont => w_addr_cont,
        r_addr_cont => r_addr_cont,
--        r_addr => r_addr,
        w_data => w_data,
        r_data => r_data

        
    );
 clk_process : process
  begin
    CLK <= '0';
    wait for clk_period / 2;  
    CLK <= '1';
    wait for clk_period / 2;  
end process;
sim:    process begin
    RST <= '1';
    wr <= '0';
    rd <= '0';
    w_data <= (others => '0');
    wait for 20 ns;	
    RST <= '0';
    wait for clk_period;
    wr <= '1';
    for i in 1 to 16 loop
        w_data <= std_logic_vector(TO_UNSIGNED(i*10, 8));
        wait for clk_period;
    end loop;
    w_data <= x"FF";
    
    wr <= '0';
    wait for clk_period * 2;
    rd <= '1';
    for i in 1 to 16 loop
         wait for clk_period*2;
    end loop;
    
    wait for clk_period;
    rd <= '0';
    wait for clk_period * 2;
    
    wait until falling_edge(CLK);
    w_data <= x"AA";
     wr <= '1';
    wait until falling_edge(CLK);
    w_data <= x"BB";
        
    -- Now read and write at the exact same time
    wr <= '1';
    w_data <= x"CC"; 
    rd <= '1'; 
    wait for clk_period;
        
    wr <= '0';
    rd <= '0';
    wait for 50 ns;
    wait;
    end process;

end Behavioral;
