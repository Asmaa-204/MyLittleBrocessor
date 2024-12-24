library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity HazardUnit is 

    port(
        -- Inputs From Decode Stage
        i_IF_ID_Rsrc1: in std_logic_vector(2 downto 0);
        i_IF_ID_Rsrc2: in std_logic_vector(2 downto 0);

        -- Inputs From Execute Stage
        i_ID_EX_Rdest: in std_logic_vector(2 downto 0);
        i_ID_EX_mem_read_enable: in std_logic;
        i_flags: in std_logic_vector(2 downto 0);

        -- Input From Control Signals
        i_jump_enable: in std_logic;
        i_jump_type: in std_logic_vector(1 downto 0)

        o_stall: out std_logic;
    );

end entity HazardUnit;


architecture RTL of HazardUnit is


-- Check if IF/ID.Rsrc1 == ID/EX.Rdest
-- Check if IF/ID.Rsrc2 == ID/EX.Rdest
-- ID/Ex.mem_read_enable == 1


    signal carry: std_logic;
    signal zero: std_logic;
    signal negative: std_logic;

begin

    zero <= i_flags(2);
    negative <= i_flags(1);
    carry <= i_flags(0);

    process(i_IF_ID_Rsrc1, i_IF_ID_Rsrc2, i_ID_EX_Rdest, i_ID_EX_mem_read_enable, i_jump_enable, i_jump_type)
    begin
        if (i_IF_ID_Rsrc1 = i_ID_EX_Rdest or i_IF_ID_Rsrc2 = i_ID_EX_Rdest) and i_ID_EX_mem_read_enable = '1' then
            -- Stall the pipeline
        end if;
    end process;


    process(i_flags, i_jump_enable, i_jump_type)
    begin
        if i_flags = "001" and i_jump_enable = '1' and i_jump_type = "00" then
            -- Flush the pipeline
        end if;
    end process;

    -- JC  00
    -- JN  01
    -- JZ  10

    -- JMP  11
    -- CALL 11

    process(i_flags, i_jump_enable, i_jump_type)
    begin

        if zero = '1' and i_jump_enable = '1' and i_jump_type = "10" then
            o_stall <= '1';
        elsif negative = '1' and i_jump_enable = '1' and i_jump_type = "01" then
            o_stall <= '1';
        elsif carry = '1' and i_jump_enable = '1' and i_jump_type = "00" then
            o_stall <= '1';
        elsif i_jump_enable = '1' and i_jump_type = "11" then
            o_stall <= '1';
        end if;


    end process;



    



end architecture RTL;