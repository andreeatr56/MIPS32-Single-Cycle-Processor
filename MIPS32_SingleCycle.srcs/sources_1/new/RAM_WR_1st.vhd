----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.03.2026 12:29:50
-- Design Name: 
-- Module Name: RAM_WR_1st - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM_WR_1st is
    port(
        clk  : in std_logic;
        we   : in std_logic;
        addr : in std_logic_vector(5 downto 0);
        di   : in std_logic_vector(31 downto 0);
        do   : out std_logic_vector(31 downto 0)
    );
end RAM_WR_1st;

architecture Behavioral of RAM_WR_1st is

type ram_type is array (0 to 63) of std_logic_vector (31 downto 0);
 signal mem : ram_type := (
    0 => x"00000000",
    1 => x"00000001",
    2 => x"00000002",
    3 => x"00000003",
    4 => x"00000004",
    others => x"00000000");

begin

process(clk)
begin
    if rising_edge(clk) then
        if we = '1' then
            mem(to_integer(unsigned(addr))) <= di;
            do <= di; -- write-first ?
        else
            do <= mem(to_integer(unsigned(addr)));
        end if;
    end if;
end process;

end Behavioral;