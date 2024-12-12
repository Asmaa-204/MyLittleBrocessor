library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RegisterFile is

    port(
        clk: in std_logic;
        reset: in std_logic;
        write_enable: in std_logic;
        read_addr1: in std_logic_vector(2 downto 0);
        read_addr2: in std_logic_vector(2 downto 0);
        write_addr: in std_logic_vector(2 downto 0);
        write_data: in std_logic_vector(15 downto 0);
        read_data1: out std_logic_vector(15 downto 0);
        read_data2: out std_logic_vector(15 downto 0)    
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
            if write_enable = '1' then
                RF(to_integer(unsigned(write_addr))) <= write_data;
            end if;
        end if;
    end process;

    read_data1 <= RF(to_integer(unsigned(read_addr1)));
    read_data2 <= RF(to_integer(unsigned(read_addr2)));

end RegisterFile_RTL; 