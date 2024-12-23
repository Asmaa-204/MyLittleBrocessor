library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity FetchStage is

    port(
        clk: in std_logic;
        reset: in std_logic;

        -- Inputs to PC Select Mux
        i_next_pc: in std_logic_vector(15 downto 0);
        i_R1: in std_logic_vector(15 downto 0);
        i_WB_data: in std_logic_vector(15 downto 0);

        -- Outputs 
        o_instruction: out std_logic_vector(15 downto 0);
        o_next_pc: out std_logic_vector(15 downto 0);
        o_immediate: out std_logic_vector(15 downto 0)
    );

end entity FetchStage;

architecture RTL of FetchStage is

    signal instruction: std_logic_vector(15 downto 0);
    
    -- PC
    signal pc_register: std_logic_vector(15 downto 0);

    -- special instructions
    signal reset_instruction: std_logic_vector(15 downto 0);
    signal exception1_instruction: std_logic_vector(15 downto 0);
    signal exception2_instruction: std_logic_vector(15 downto 0);
    signal interrupt1_instruction: std_logic_vector(15 downto 0);
    signal interrupt2_instruction: std_logic_vector(15 downto 0);

    
    signal next_pc_sel: std_logic_vector(2 downto 0);


begin

    -- Update PC
    process(clk) 
    begin
        if rising_edge(clk) then
            pc_register <= i_next_pc;
        end if;
    end process;


    IM_Instance: entity work.InstructionMemory
        port map(
            i_pc => pc_register,
            reset => reset,
            o_instruction => instruction,
            o_reset_instruction => reset_instruction,
            o_exception1_instruction => exception1_instruction,
            o_exception2_instruction => exception2_instruction,
            o_interrupt1_instruction => interrupt1_instruction,
            o_interrupt2_instruction => interrupt2_instruction
        );

    FU_Instance: entity work.FetchControlUnit
        port map(
            clk => clk,
            i_instruction => instruction,
            o_instruction => o_instruction
        );



    -- Output to Decode Stage
    o_next_pc <= std_logic_vector(unsigned(pc_register) + 1);
    o_immediate <= instruction;

    


end architecture RTL;