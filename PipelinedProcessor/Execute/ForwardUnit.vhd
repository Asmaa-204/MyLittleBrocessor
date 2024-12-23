library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ForwardUnit is
    port(
        i_Rsrc1: in std_logic_vector(2 downto 0);
        i_Rsrc2: in std_logic_vector(2 downto 0);

        i_EX_MEM_Rdest: in std_logic_vector(2 downto 0);
        i_MEM_WB_Rdest: in std_logic_vector(2 downto 0);
        
        i_EX_MEM_Result: in std_logic_vector(15 downto 0);
        i_WB_Data: in std_logic_vector(15 downto 0);

        i_EX_MEM_RegWrite: in std_logic;
        i_MEM_WB_RegWrite: in std_logic;

        i_op1_sel: in std_logic;
        i_op2_sel: in std_logic;

        i_R1: in std_logic_vector(15 downto 0);
        i_R2: in std_logic_vector(15 downto 0);
        i_Immediate: in std_logic_vector(15 downto 0);
        
        
        o_R1: out std_logic_vector(15 downto 0);
        o_operand1: out std_logic_vector(15 downto 0);
        o_operand2: out std_logic_vector(15 downto 0)
    );
end entity ForwardUnit;


architecture Behavioral of ForwardUnit is

    signal original_operand1: std_logic_vector(15 downto 0);
    signal original_operand2: std_logic_vector(15 downto 0);

begin

    with i_op1_sel select
        original_operand1 <= i_R1 when '0',
                             i_Immediate when others;

    with i_op2_sel select
        original_operand2 <= i_R2 when '0',
                             i_Immediate when others;


    process(i_Rsrc1, i_Rsrc2, i_EX_MEM_Rdest, i_MEM_WB_Rdest, i_EX_MEM_Result, i_WB_Data, i_EX_MEM_RegWrite, i_MEM_WB_RegWrite, i_R1, i_R2, i_Immediate)
    begin
        if i_EX_MEM_RegWrite = '1' and i_EX_MEM_Rdest = i_Rsrc1 then
            o_operand1 <= i_EX_MEM_Result;
        elsif i_MEM_WB_RegWrite = '1' and i_MEM_WB_Rdest = i_Rsrc1 then
            o_operand1 <= i_WB_Data;
        else
            o_operand1 <= original_operand1;
        end if;


        if i_EX_MEM_RegWrite = '1' and i_EX_MEM_Rdest = i_Rsrc2 then
            o_operand2 <= i_EX_MEM_Result;
        elsif i_MEM_WB_RegWrite = '1' and i_MEM_WB_Rdest = i_Rsrc2 then
            o_operand2 <= i_WB_Data;
        else
            o_operand2 <= original_operand2;
        end if;

        -- Forwarding in case of LOAD THEN STORE 
        -- //TODO: Change this
        o_R1 <= i_R1;
    end process;


end architecture Behavioral;