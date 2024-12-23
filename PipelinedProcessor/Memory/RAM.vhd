library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RAM is
  port (
    clk          : in std_logic;
    reset        : in std_logic;
    write_enable : in std_logic;
    read_enable  : in std_logic;
    addr         : in std_logic_vector(15 downto 0);
    data_in      : in std_logic_vector(15 downto 0);
    data_out     : out std_logic_vector(15 downto 0)
  );
end RAM;

architecture Behavioral of RAM is
  
  type ram_type is array (0 to 4095) of std_logic_vector(15 downto 0);
  signal memory : ram_type := (others => (others => '0'));

begin

  process (read_enable, addr)
  begin
    if(read_enable = '1') then
      data_out <= memory(to_integer(unsigned(addr(11 downto 0))));
    else 
      data_out <= (others => 'Z');
    end if;
  end process;

  process (clk, reset)
  begin
    if reset = '1' then
      memory <= (others => (others => '0'));
    elsif rising_edge(clk) then
      if write_enable = '1' then
        memory(to_integer(unsigned(addr(11 downto 0)))) <= data_in;
      end if;
    end if;
  end process;

end architecture Behavioral;
