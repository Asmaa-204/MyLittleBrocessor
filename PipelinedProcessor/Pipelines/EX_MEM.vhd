library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity EX_MEM_Register is
    port(

        clk: in std_logic;
        flush: in std_logic;

        -- Inputs
        i_next_pc: in std_logic_vector(15 downto 0);
        i_flags: in std_logic_vector(2 downto 0);
        i_Rdest: in std_logic_vector(2 downto 0);
        i_R1: in std_logic_vector(15 downto 0);
        i_immediate: in std_logic_vector(15 downto 0);
        i_Result: in std_logic_vector(15 downto 0);
        i_control_signals: in std_logic_vector(39 downto 0);

        -- Outputs
        o_next_pc: out std_logic_vector(15 downto 0);
        o_flags: out std_logic_vector(2 downto 0);
        o_Rdest: out std_logic_vector(2 downto 0);
        o_R1: out std_logic_vector(15 downto 0);
        o_immediate: out std_logic_vector(15 downto 0);
        o_Result: out std_logic_vector(15 downto 0);
        o_control_signals: out std_logic_vector(39 downto 0)
    );
end entity EX_MEM_Register;


architecture RTL of EX_MEM_Register is

    signal next_pc_reg: std_logic_vector(15 downto 0);
    signal flags_reg: std_logic_vector(2 downto 0);
    signal Rdest_reg: std_logic_vector(2 downto 0);
    signal R1_reg: std_logic_vector(15 downto 0);
    signal immediate_reg: std_logic_vector(15 downto 0);
    signal Result_reg: std_logic_vector(15 downto 0);
    signal control_signals_reg: std_logic_vector(39 downto 0);
    
begin

    o_next_pc <= next_pc_reg;
    o_flags <= flags_reg;
    o_Rdest <= Rdest_reg;
    o_R1 <= R1_reg;
    o_immediate <= immediate_reg;
    o_Result <= Result_reg;
    o_control_signals <= control_signals_reg;

    process(clk, flush)
    begin
        if rising_edge(clk) then
            if flush = '1' then
                next_pc_reg <= x"0000";
                flags_reg <= x"0000";
                Rdest_reg <= x"000";
                R1_reg <= x"0000";
                immediate_reg <= x"0000";
                Result_reg <= x"0000";
                control_signals_reg <= x"0000000000";
            else
                next_pc_reg <= i_next_pc;
                flags_reg <= i_flags;
                Rdest_reg <= i_Rdest;
                R1_reg <= i_R1;
                immediate_reg <= i_immediate;
                Result_reg <= i_Result;
                control_signals_reg <= i_control_signals;
            end if;
        end if;
    end process; 

end architecture RTL;