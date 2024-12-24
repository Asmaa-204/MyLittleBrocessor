library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity CPU_TB is
end entity CPU_TB;


architecture test of CPU_TB is

    -- Clock Signal
    signal clk: std_logic := '0';
    signal reset: std_logic := '0';


    -- Outputs
    signal o_output: std_logic_vector(15 downto 0);
    signal o_error_pc: std_logic_vector(15 downto 0);

    signal i_input: std_logic_vector(15 downto 0);

    signal simulation_done: boolean := false;

    constant CLK_PERIOD: time := 10 ns;


begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.CPU
        port map(
            clk => clk,
            reset => reset,

            i_input => i_input,
            o_output => o_output,


            o_error_pc => o_error_pc
        );

    -- Clock generation
    clock_gen: process
    begin
        while not simulation_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;


end architecture test;



