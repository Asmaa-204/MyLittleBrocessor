library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity InstructionMemory is
    port (
        i_pc: in std_logic_vector(15 downto 0);
        reset: in std_logic;
        o_instruction: out std_logic_vector(15 downto 0);
        o_reset_instruction: out std_logic_vector(15 downto 0);
        o_interrupt1_instruction: out std_logic_vector(15 downto 0);
        o_interrupt2_instruction: out std_logic_vector(15 downto 0);
        o_exception1_instruction: out std_logic_vector(15 downto 0);
        o_exception2_instruction: out std_logic_vector(15 downto 0)
    );
end entity InstructionMemory;

architecture InstructionMemory_RTL of InstructionMemory is
    
    -- Instruction Memory (IM) is a 4K x 16-bit memory
    type Memory is array (0 to 4095) of std_logic_vector(15 downto 0);

    impure function load_memory_from_file (filename: string) return Memory is
        file text_file: text open read_mode is filename;
        variable line_content: line;
        variable memory_content: Memory;
        variable instruction_bits: bit_vector(15 downto 0);
        variable i: integer := 0;
    begin  
        while not endfile(text_file) loop
            readline(text_file, line_content);
            read(line_content, instruction_bits);
            memory_content(i) := To_StdLogicVector(instruction_bits);
            i := i + 1;
        end loop;
        return memory_content;
    end function load_memory_from_file;

    signal IM: Memory := load_memory_from_file("IM.mem");

begin

    process(reset)
    begin
        if reset = '1' then
            IM <= load_memory_from_file("IM.mem");
        end if;
    end process;

    o_instruction <= IM(to_integer(unsigned(i_pc(11 downto 0))));
    
    -- Special instructions
    o_reset_instruction <= IM(0);
    o_exception1_instruction <= IM(1);
    o_exception2_instruction <= IM(2);
    o_interrupt1_instruction <= IM(3);
    o_interrupt2_instruction <= IM(4);

    
end architecture InstructionMemory_RTL;
