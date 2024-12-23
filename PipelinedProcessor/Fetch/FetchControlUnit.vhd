library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FetchControlUnit is
    port(
        clk: in std_logic;
        -- Inputs
        i_instruction: in std_logic_vector(15 downto 0);
        -- Outputs
        o_instruction: out std_logic_vector(15 downto 0)
    );
end entity FetchControlUnit;

architecture RTL of FetchControlUnit is
    constant zeros: std_logic_vector(15 downto 0) := x"0000";
    signal instruction_mid_register: std_logic_vector(15 downto 0);
    -- Dissecting Instruction
    signal instruction_type: std_logic_vector(1 downto 0);
    -- counters
    signal immediate_counter: integer range 0 to 3 := 0;
    signal immediate_counter_reg: integer range 0 to 3 := 0;
begin
    instruction_type <= i_instruction(1 downto 0); 

    -- mid_register_update
    process(clk)
    begin
        if rising_edge(clk) then
            instruction_mid_register <= i_instruction;


            if immediate_counter_reg > 0 then
                immediate_counter_reg <= immediate_counter_reg - 1;
            end if;

            immediate_counter_reg <= immediate_counter;
        end if;
    end process;


    process(i_instruction, instruction_mid_register, immediate_counter, instruction_type, immediate_counter_reg)  
    begin
        if immediate_counter_reg = 1 then
            o_instruction <= instruction_mid_register;
            immediate_counter <= 0;
        elsif instruction_type = "01" then
            o_instruction <= zeros;
            immediate_counter <= 1;
        else
            o_instruction <= i_instruction;
        end if;
    end process;
end architecture RTL;