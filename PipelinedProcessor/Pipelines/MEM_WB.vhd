library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity MEM_WB_Register is
    port(

        clk: in std_logic;
        flush: in std_logic;

        -- Inputs
        i_mem_read_data: in std_logic_vector(15 downto 0);
        i_Result: in std_logic_vector(15 downto 0);
        i_Rdest: in std_logic_vector(2 downto 0);
        i_control_signals: in std_logic_vector(39 downto 0);

        -- Outputs
        o_mem_read_data: out std_logic_vector(15 downto 0);
        o_Result: out std_logic_vector(15 downto 0);
        o_Rdest: out std_logic_vector(2 downto 0);
        o_control_signals: out std_logic_vector(39 downto 0)
    );
end entity MEM_WB_Register;


architecture RTL of MEM_WB_Register is

    signal mem_read_data_reg: std_logic_vector(15 downto 0);
    signal Result_reg: std_logic_vector(15 downto 0);
    signal Rdest_reg: std_logic_vector(2 downto 0);
    signal control_signals_reg: std_logic_vector(39 downto 0);

begin

    o_mem_read_data <= mem_read_data_reg;
    o_Result <= Result_reg;
    o_Rdest <= Rdest_reg;
    o_control_signals <= control_signals_reg;

    process(clk, flush)
    begin
        if rising_edge(clk) then
            if flush = '1' then
                mem_read_data_reg <= x"0000";
                Result_reg <= x"0000";
                Rdest_reg <= x"000";
                control_signals_reg <= x"0000000000";
            else
                mem_read_data_reg <= i_mem_read_data;
                Result_reg <= i_Result;
                Rdest_reg <= i_Rdest;
                control_signals_reg <= i_control_signals;
            end if;
        end if;
    end process;


end architecture RTL;