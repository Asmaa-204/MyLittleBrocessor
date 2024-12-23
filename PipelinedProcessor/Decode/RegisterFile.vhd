library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RegisterFile is

    port(
        clk: in std_logic;
        reset: in std_logic;

        i_write_enable: in std_logic;
        i_Rsrc1: in std_logic_vector(2 downto 0);
        i_Rsrc2: in std_logic_vector(2 downto 0);
        i_Rdest: in std_logic_vector(2 downto 0);
        i_write_data: in std_logic_vector(15 downto 0);
        
        o_read_data_1: out std_logic_vector(15 downto 0);
        o_read_data_2: out std_logic_vector(15 downto 0)    
    );

end entity RegisterFile;


architecture RegisterFile_RTL of RegisterFile is

    type RegisterFile is array (0 to 7) of std_logic_vector(15 downto 0);
    signal RF: RegisterFile := (others => (others => '0'));
begin

    process(clk, reset)
    begin
        if reset = '1' then 
            RF <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if i_write_enable = '1' then
                RF(to_integer(unsigned(i_Rdest))) <= i_write_data;
            end if;
        end if;
    end process;

    o_read_data_1 <= RF(to_integer(unsigned(i_Rsrc1)));
    o_read_data_2 <= RF(to_integer(unsigned(i_Rsrc2)));

end RegisterFile_RTL; 