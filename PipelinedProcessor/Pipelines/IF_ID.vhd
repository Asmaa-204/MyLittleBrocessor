library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_ID_Register is
    port(
        clk: in std_logic;
        flush: in std_logic;

        -- Inputs
        i_instruction: in std_logic_vector(15 downto 0);
        i_immediate: in std_logic_vector(15 downto 0);
        i_next_pc: in std_logic_vector(15 downto 0);

        -- Outputs
        o_instruction: out std_logic_vector(15 downto 0);
        o_immediate: out std_logic_vector(15 downto 0);
        o_next_pc: out std_logic_vector(15 downto 0)
    );
end entity IF_ID_Register;

architecture RTL of IF_ID_Register is
    
    signal instruction_reg: std_logic_vector(15 downto 0) := (others => '0');
    signal immediate_reg: std_logic_vector(15 downto 0) := (others => '0');
    signal next_pc_reg: std_logic_vector(15 downto 0) := (others => '0');
begin

    process(clk, flush)
    begin
        if rising_edge(clk) then
            if flush = '1' then
                instruction_reg <= x"0000";
                immediate_reg <= x"0000";
                next_pc_reg <= x"0000";
            else
                instruction_reg <= i_instruction;
                immediate_reg <= i_immediate;
                next_pc_reg <= i_next_pc;
            end if;
        end if;
    end process;

    -- Assign internal registers to outputs
    o_instruction <= instruction_reg;
    o_immediate <= immediate_reg;
    o_next_pc <= next_pc_reg;

end architecture RTL;
