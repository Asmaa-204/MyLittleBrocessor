library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InstructionMemory is
    port (
        pc: in std_logic_vector(15 downto 0);
        reset: in std_logic;
        instruction: out std_logic_vector(15 downto 0)
    );
end entity InstructionMemory;

architecture InstructionMemory_RTL of InstructionMemory is
    -- Instruction Memory (IM) is a 4K x 16-bit memory
    type Memory is array (0 to 4095) of std_logic_vector(15 downto 0);
    signal IM: Memory := (others => (others => '0')); -- Initialize with zeros

begin
    process(reset)
    begin
        if reset = '1' then
            IM <= (others => (others => '0'));
        end if;
    end process;

    instruction <= IM(to_integer(unsigned(pc(11 downto 0))));
    
end architecture InstructionMemory_RTL;
