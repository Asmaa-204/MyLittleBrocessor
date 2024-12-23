library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity FetchStage_TB is
end entity FetchStage_TB;

architecture sim of FetchStage_TB is
    -- Clock and Reset
    signal clk: std_logic := '0';
    signal reset: std_logic := '0';
    
    -- Inputs
    signal i_next_pc: std_logic_vector(15 downto 0) := (others => '0');
    signal i_R1: std_logic_vector(15 downto 0) := (others => '0');
    signal i_WB_data: std_logic_vector(15 downto 0) := (others => '0');
    
    -- Outputs
    signal o_instruction: std_logic_vector(15 downto 0);
    signal o_next_pc: std_logic_vector(15 downto 0);
    signal o_immediate: std_logic_vector(15 downto 0);
    
    -- Internal signals
    signal pc: std_logic_vector(15 downto 0) := (others => '0');
    
    -- Test signals
    constant CLK_PERIOD: time := 10 ns;
    signal simulation_done: boolean := false;

begin
    -- DUT instantiation
    DUT: entity work.FetchStage
    port map (
        clk => clk,
        reset => reset,
        i_next_pc => pc,  -- Connect PC directly
        i_R1 => i_R1,
        i_WB_data => i_WB_data,
        o_instruction => o_instruction,
        o_next_pc => o_next_pc,
        o_immediate => o_immediate
    );
    
    -- Clock generation
    clock_gen: process
    begin
        while not simulation_done loop
            clk <= '1';
            wait for CLK_PERIOD/2;
            clk <= '0';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;
    
    -- PC and stimulus control process
    stim_proc: process
    begin


        -- Initialize PC to 0000
        pc <= x"0000";

        wait for CLK_PERIOD;

        assert (o_instruction = "0000000000000000") report "Error: o_instruction is not 0000" severity error;
        -- assert (i_instruction = x"0100000100000001") report "Error: i_instruction is not 0100000100000001" severity error;
    
    
        -- Set PC to 0001
        pc <= x"0001";

        wait for CLK_PERIOD;

        assert (o_instruction = "0100000100000001") report "Error: o_instruction is not 0100000100000001" severity error;
        -- assert (i_instruction = "0001001000110100") report "Error: i_instruction is not 0001001000110100" severity error;
        assert (o_immediate = "0001001000110100") report "Error: o_immediate is not 0001001000110100" severity error;
    
    
        -- Set PC to 0002
        pc <= x"0002";

        wait for CLK_PERIOD;

        assert (o_instruction = "0100001000000000") report "Error: o_instruction is not 0100001000000000" severity error;
        -- assert (i_instruction = "0100001000000000") report "Error: i_instruction is not 0100001000000000" severity error;
        assert (o_immediate = "0100001000000000") report "Error: o_immediate is not 0100001000000000" severity error;
    
    
        -- Set PC to 0003
        pc <= x"0003";

        wait for CLK_PERIOD;

        assert (o_instruction = "0101011001111000") report "Error: o_instruction is not 0101011001111000" severity error;
        -- assert (i_instruction = x"0101011001111000") report "Error: i_instruction is not 0101011001111000" severity error;
    
    
    end process;
    
    -- -- Monitor process to display what's happening
    -- monitor: process(clk)
    --     variable l: line;
    -- begin
    --     if rising_edge(clk) then
    --         write(l, string'("PC: 0x"));
    --         write(l, to_bitvector(pc));
    --         write(l, string'(" Instruction: 0x"));
    --         write(l, to_bitvector(o_instruction));
    --         write(l, string'(" Immediate: 0x"));
    --         write(l, to_bitvector(o_immediate));
    --         writeline(output, l);
    --     end if;
    -- end process;

end architecture sim;