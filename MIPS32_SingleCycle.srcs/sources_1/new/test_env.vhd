----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.03.2026 10:17:46
-- Design Name: 
-- Module Name: test_env - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env is
port(clk : in STD_LOGIC; 
     btn : in STD_LOGIC_VECTOR (4 downto 0);
     sw : in STD_LOGIC_VECTOR (15 downto 0);
     an : out STD_LOGIC_VECTOR (7 downto 0);
     cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
port(enable : out STD_LOGIC;
     btn : in STD_LOGIC;
     clk : in STD_LOGIC);
end component;

component SSD is
port(CLK : in STD_LOGIC; 
     DIGITS : in STD_LOGIC_VECTOR (31 downto 0); 
     AN : out STD_LOGIC_VECTOR (7 downto 0);
     CAT : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component RF is
port(clk : in std_logic;
     ra1 : in std_logic_vector(4 downto 0); 
     ra2 : in std_logic_vector(4 downto 0); 
     wa : in std_logic_vector(4 downto 0); 
     wd : in std_logic_vector(31 downto 0); 
     regwr : in std_logic; 
     rd1 : out std_logic_vector(31 downto 0); 
     rd2 : out std_logic_vector(31 downto 0));
end component;

component RAM_WR_1st is
port (  clk : in std_logic;
        we : in std_logic; 
        addr : in std_logic_vector(5 downto 0); 
        di : in std_logic_vector(31 downto 0); 
        dO :out std_logic_vector(31 downto 0)); 
end component;

component IFetch is
port(clk : in std_logic;
     rst : in std_logic; 
     en : in std_logic; 
     Jump : in std_logic; 
     JumpAddress : in std_logic_vector(31 downto 0); 
     PCSrc : in std_logic;
     BranchAddress : in std_logic_vector(31 downto 0);
     Instruction : out std_logic_vector(31 downto 0);
     PC_plus_4 : out std_logic_vector(31 downto 0));
end component;

component ID is
port(clk : in std_logic;
     en : in std_logic;
     Instr : in std_logic_vector (31 downto 0);
     WD : in std_logic_vector(31 downto 0);
     RegWrite : in std_logic;
     RegDst : in std_logic;
     ExtOp : in std_logic;
     RD1 : out std_logic_vector(31 downto 0);
     RD2 : out std_logic_vector(31 downto 0);
     Ext_Imm : out std_logic_vector(31 downto 0);
     func : out std_logic_vector(5 downto 0);
     sa : out std_logic_vector(4 downto 0));
end component;

component UC is
port(opcode : in std_logic_vector(5 downto 0);
     RegDst : out std_logic;
     ExtOp : out std_logic;
     ALUSrc : out std_logic; 
     Branch : out std_logic;
     Branch_NE : out std_logic;
     Branch_GEZ : out std_logic;
     Branch_GTZ : out std_logic;
     Jump : out std_logic;
     MemWrite : out std_logic;
     MemtoReg : out std_logic;
     RegWrite : out std_logic;
     ALUOp : out std_logic_vector(2 downto 0));
end component;

component EX is
port(RD1 : in std_logic_vector(31 downto 0);
     RD2 : in std_logic_vector(31 downto 0);
     ALUSrc : in std_logic;
     Ext_Imm : in std_logic_vector(31 downto 0);
     sa : in std_logic_vector(4 downto 0);
     func : in std_logic_vector(5 downto 0);
     ALUOp : in std_logic_vector(2 downto 0);
     PC_plus_4 : in std_logic_vector(31 downto 0);
     Zero : out std_logic;
     GTZ : out std_logic;
     ALURes : out std_logic_vector(31 downto 0);
     BranchAddress : out std_logic_vector(31 downto 0));
end component;

component MEM is
port(clk : in std_logic;
     en : in std_logic;
     MemWrite : in std_logic;
     ALUResIn : in std_logic_vector(31 downto 0);
     RD2 : in std_logic_vector(31 downto 0);        
     MemData : out std_logic_vector(31 downto 0);
     ALUResOut : out std_logic_vector(31 downto 0));
end component;

signal EN, WE, RST : std_logic;
signal RegDst, ExtOp, ALUSrc, Branch, Branch_NE, Jump, MemWrite, MemtoReg, RegWrite : std_logic;
signal ALUOp : std_logic_vector(2 downto 0);
signal Instr, PC4, RD1, RD2, WD, Ext_Imm, ALURes, ALUResOut, MemData, BrAddr, JAddr : std_logic_vector(31 downto 0);
signal func : std_logic_vector(5 downto 0);
signal sa : std_logic_vector(4 downto 0);
signal Zero, GTZ, PCSrc : std_logic;
signal DIGIT : std_logic_vector(31 downto 0);
signal cnt : std_logic_vector(5 downto 0) := (others => '0');
signal DO_RAM : std_logic_vector(31 downto 0);
signal Branch_GEZ, Branch_GTZ : std_logic;

begin

    c1 : MPG port map(EN, btn(0), clk);
    c2 : MPG port map(WE, btn(1), clk);
    c3 : SSD port map(clk, DIGIT, an, cat);
    c4 : ram_wr_1st port map(clk, WE, cnt, RD2, DO_RAM);
    
    RST <= btn(2);
    JAddr <= PC4(31 downto 28) & Instr(25 downto 0) & "00";
    PCSrc <= (Branch and Zero) or (Branch_NE and (not Zero));

    c5 : IFetch port map(clk, RST, EN, Jump, JAddr, PCSrc, BrAddr, Instr, PC4);
    c6 : ID port map(clk, EN, Instr, WD, RegWrite, RegDst, ExtOp, RD1, RD2, Ext_Imm, func, sa);
    c7 : UC port map(Instr(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Branch_NE, Branch_GEZ, Branch_GTZ, Jump, MemWrite, MemtoReg, RegWrite, ALUOp);
    c8 : EX port map(RD1, RD2, ALUSrc, Ext_Imm, sa, func, ALUOp, PC4, Zero, GTZ, ALURes, BrAddr);
    c9 : MEM port map(clk, EN, MemWrite, ALURes, RD2, MemData, ALUResOut);

    WD <= MemData when MemtoReg = '1' else ALUResOut;

    process(clk)
    begin
        if rising_edge(clk) then
            if EN = '1' then
                if sw(0) = '1' then cnt <= cnt + 1;
                else cnt <= cnt - 1;
                end if;
            end if;
        end if;
    end process;

    process(sw, Instr, PC4, RD1, RD2, ALURes, MemData, WD, DO_RAM)
    begin
        case sw(3 downto 1) is
            when "000" => DIGIT <= Instr;
            when "001" => DIGIT <= PC4;
            when "010" => DIGIT <= RD1;
            when "011" => DIGIT <= RD2;
            when "100" => DIGIT <= ALURes;
            when "101" => DIGIT <= MemData;
            when "110" => DIGIT <= WD;
            when "111" => DIGIT <= DO_RAM;
            when others => DIGIT <= (others => '0');
        end case;
    end process;

end Behavioral;