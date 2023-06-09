----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/07/2023 11:24:06 PM
-- Design Name: 
-- Module Name: Processor - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Processor is
    Port ( Clk_in : in STD_LOGIC;
           Res : in STD_LOGIC;
           data_bus0_Output: out STD_LOGIC_VECTOR(3 downto 0);
           data_bus1_Output: out STD_LOGIC_VECTOR(3 downto 0);
           data_bus2_Output: out STD_LOGIC_VECTOR(3 downto 0);
           data_bus3_Output: out STD_LOGIC_VECTOR(3 downto 0);
           data_bus4_Output: out STD_LOGIC_VECTOR(3 downto 0);
           data_bus5_Output: out STD_LOGIC_VECTOR(3 downto 0);
           data_bus6_Output: out STD_LOGIC_VECTOR(3 downto 0);
           data_bus7_Output: out STD_LOGIC_VECTOR(3 downto 0);
           Adder_output: out Std_logic_vector(2 downto 0);
           instructionBus_Output :out std_logic_vector(11  downto 0)
           );
end Processor;

architecture Behavioral of Processor is

component Programme_Counter is
    Port ( D : in STD_LOGIC_VECTOR (2 downto 0);
           Q : out STD_LOGIC_VECTOR (2 downto 0) := "000";
           Clk: in STD_LOGIC;
           Res : in STD_LOGIC);
end component;

component Adder_3_bit is
    Port ( A : in STD_LOGIC_VECTOR(2 downto 0);
           S : out STD_LOGIC_VECTOR(2 downto 0));
end component;

component Slow_clk 
    Port ( Clk_in : in STD_LOGIC;
           Clk_out : out STD_LOGIC);
end component;

component ROM_3_TO_12 
    Port ( address : in STD_LOGIC_VECTOR (2 downto 0);
           data : out STD_LOGIC_VECTOR (11 downto 0));
end component;

component MUX_2_3 
    Port ( ADD : in STD_LOGIC_VECTOR (2 downto 0);
           JUMP_Val : in STD_LOGIC_VECTOR (2 downto 0);
           JUMP_F : in STD_LOGIC;
           O : out STD_LOGIC_VECTOR (2 downto 0));
end component;

component MUX_2_4 
    Port ( Sel : in STD_LOGIC;
           IM_VAL : in STD_LOGIC_VECTOR (3 downto 0);
           AD_VAL : in STD_LOGIC_VECTOR (3 downto 0);
           O : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component MUX_8_4 is
    Port ( 
           R0 : in STD_LOGIC_VECTOR (3 downto 0);
           R1 : in STD_LOGIC_VECTOR (3 downto 0);
           R2 : in STD_LOGIC_VECTOR (3 downto 0);
           R3 : in STD_LOGIC_VECTOR (3 downto 0);
           R4 : in STD_LOGIC_VECTOR (3 downto 0);
           R5 : in STD_LOGIC_VECTOR (3 downto 0);
           R6 : in STD_LOGIC_VECTOR (3 downto 0);
           R7 : in STD_LOGIC_VECTOR (3 downto 0);
           Ctrl : in STD_LOGIC_VECTOR (2 downto 0);
           O : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component LUT_16_7 is
    Port ( address : in STD_LOGIC_VECTOR (3 downto 0);
           data : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component Add_Sub_Unit is
    Port ( sel : in STD_LOGIC;
           firstNo : in STD_LOGIC_VECTOR (3 downto 0);
           secNo : in STD_LOGIC_VECTOR (3 downto 0);
           OverFlow : out STD_LOGIC;
           Zero : out STD_LOGIC;
           addsubOut : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component Instruction_Decoder 
    Port ( INS : in STD_LOGIC_VECTOR (11 downto 0);
           Jump_Check : in STD_LOGIC_VECTOR (3 downto 0);
           Add_Sub_Sel : out STD_LOGIC;
           R_SEL_1 : out STD_LOGIC_VECTOR (2 downto 0);
           R_SEL_2 : out STD_LOGIC_VECTOR (2 downto 0);
           L_SEL : out STD_LOGIC;
           IM_VAL : out STD_LOGIC_VECTOR (3 downto 0);
           R_EN : out STD_LOGIC_VECTOR (2 downto 0);
           J_FL : out STD_LOGIC;
           J_ADR : out STD_LOGIC_VECTOR (2 downto 0));
end component;

component Reg_Bank is
    Port ( Clock : in STD_LOGIC;
           Reg_En : in STD_LOGIC_VECTOR (2 downto 0);
           Val_Store : in STD_LOGIC_VECTOR (3 downto 0);
           Clear : in STD_LOGIC;
           Reg_0_out : out STD_LOGIC_VECTOR (3 downto 0);
           Reg_1_out : out STD_LOGIC_VECTOR (3 downto 0);
           Reg_2_out : out STD_LOGIC_VECTOR (3 downto 0);
           Reg_3_out : out STD_LOGIC_VECTOR (3 downto 0);
           Reg_4_out : out STD_LOGIC_VECTOR (3 downto 0);
           Reg_5_out : out STD_LOGIC_VECTOR (3 downto 0);
           Reg_6_out : out STD_LOGIC_VECTOR (3 downto 0);
           Reg_7_out : out STD_LOGIC_VECTOR (3 downto 0));
end component;



-- 3 bit adder and PC
signal Current_C, Adder_3B_out, PC_Mux_Out: STD_LOGIC_VECTOR(2 downto 0) := "000";
signal I : STD_LOGIC_VECTOR(11 downto 0);
type d_bus is array (0 to 7) of std_logic_vector(3 downto 0);
signal Data_bus : d_bus;
--registers
SIGNAL R1_sel, R2_sel, R_En, J_Addr : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL R, ImmediateValue, RegUpdate, Mux_1_out, Mux_2_out : STD_LOGIC_VECTOR(3 downto 0);
Signal Clk_out, Load_Select, Add_Sub_Sel: STD_LOGIC;
signal J_flag : STD_LOGIC;
signal display: STD_LOGIC_VECTOR(6 downto 0);
signal overflow, Zero: STD_LOGIC;

begin

Clk_0 : Slow_clk
    port map (
    Clk_in => Clk_in,
    Clk_out => Clk_out);
    
PC : Programme_Counter
        port map (
        D => PC_Mux_Out,
        Clk => Clk_out,
        Res => Res,
        Q => Current_C
        );
        
    
Rom_0 : ROM_3_TO_12
    port map (
        address => Current_C,
        data => I);
        
ID : Instruction_Decoder
    port map (
        INS => I,
        Jump_Check => Mux_1_out,
        Add_Sub_Sel => Add_Sub_Sel,
        R_SEL_1 => R1_sel,    
        R_SEL_2 => R2_sel,
        L_SEL => Load_Select,
        IM_VAL => ImmediateValue,
        R_EN => R_En,
        J_FL => J_flag,
        J_ADR => J_Addr
        );

Adder_3_bit_0 : Adder_3_bit
    port map (
        A => Current_C,
        S => Adder_3B_Out);        
    

Mux_2_3_0 : MUX_2_3
    port map (
        ADD => Adder_3B_Out,
        JUMP_Val => J_Addr,
        JUMP_F => J_flag,
        O => PC_Mux_Out);      
        
Mux_2_4_0 : MUX_2_4
    port map (
        Sel => Load_Select,
        IM_VAL => ImmediateValue,
        AD_VAL => R,
        O => RegUpdate);   
 
 Register_bank : Reg_Bank
    port map (
        Clock => Clk_out,
        Reg_En => R_En,
        Val_Store => RegUpdate,
        Clear => Res,
        Reg_0_out => Data_Bus(0),
        Reg_1_out => Data_Bus(1),
        Reg_2_out => Data_Bus(2),
        Reg_3_out => Data_Bus(3),
        Reg_4_out => Data_Bus(4),
        Reg_5_out => Data_Bus(5),
        Reg_6_out => Data_Bus(6),
        Reg_7_out => Data_Bus(7));
        
 Mux_8_4_1: MUX_8_4
    port map (
        R0 => Data_Bus(0),
        R1 => Data_Bus(1),
        R2 => Data_Bus(2),
        R3 => Data_Bus(3),
        R4 => Data_Bus(4),
        R5 => Data_Bus(5),
        R6 => Data_Bus(6),
        R7 => Data_Bus(7),
        Ctrl => R1_sel,
        O => Mux_1_out);
        
 Mux_8_4_2: MUX_8_4
    port map (
        R0 => Data_Bus(0),
        R1 => Data_Bus(1),
        R2 => Data_Bus(2),
        R3 => Data_Bus(3),
        R4 => Data_Bus(4),
        R5 => Data_Bus(5),
        R6 => Data_Bus(6),
        R7 => Data_Bus(7),
        Ctrl => R2_sel,
        O => Mux_2_out);
        
Add_Sub : Add_Sub_Unit
    port map (
        sel => Add_Sub_Sel,
        firstNo => Mux_1_out,
        secNo => Mux_2_out,
        OverFlow => overflow,
        Zero => Zero,
        addsubOut => R);
        
display_lut : LUT_16_7
    port map (
        address => Data_bus(7),
        data => display
        );
        
        
data_bus7_Output <= Data_Bus(7);
data_bus6_Output <= Data_Bus(6);
data_bus5_Output <= Data_Bus(5);
data_bus4_Output <= Data_Bus(4);
data_bus3_Output <= Data_Bus(3);
data_bus2_Output <= Data_Bus(2);
data_bus1_Output <= Data_Bus(1);
data_bus0_Output <= Data_Bus(0);
Adder_output <= Adder_3B_Out;
instructionBus_Output <= I;

end Behavioral;
 