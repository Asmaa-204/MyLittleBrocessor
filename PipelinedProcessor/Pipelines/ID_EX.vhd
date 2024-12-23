library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ID_EX_Register is
    port(

        clk: in std_logic;
        flush: in std_logic;

        -- Inputs
        i_next_pc: in std_logic_vector(15 downto 0);
        i_R1: in std_logic_vector(15 downto 0);
        i_R2: in std_logic_vector(15 downto 0);
        i_immediate: in std_logic_vector(15 downto 0);
        i_Rsrc1: in std_logic_vector(2 downto 0);
        i_Rsrc2: in std_logic_vector(2 downto 0);
        i_Rdest: in std_logic_vector(2 downto 0);
        i_control_signals: in std_logic_vector(39 downto 0);

        -- Outputs
        o_next_pc: out std_logic_vector(15 downto 0);
        o_R1: out std_logic_vector(15 downto 0);
        o_R2: out std_logic_vector(15 downto 0);
        o_immediate: out std_logic_vector(15 downto 0);
        o_Rsrc1: out std_logic_vector(2 downto 0);
        o_Rsrc2: out std_logic_vector(2 downto 0);
        o_Rdest: out std_logic_vector(2 downto 0);
        o_control_signals: out std_logic_vector(39 downto 0)
    );
end entity ID_EX_Register;


architecture RTL of ID_EX_Register is

    signal next_pc_reg: std_logic_vector(15 downto 0);
    signal R1_reg: std_logic_vector(15 downto 0);
    signal R2_reg: std_logic_vector(15 downto 0);
    signal immediate_reg: std_logic_vector(15 downto 0);
    signal Rsrc1_reg: std_logic_vector(2 downto 0);
    signal Rsrc2_reg: std_logic_vector(2 downto 0);
    signal Rdest_reg: std_logic_vector(2 downto 0);
    signal control_signals_reg: std_logic_vector(39 downto 0);
    
begin

    o_next_pc <= next_pc_reg;
    o_R1 <= R1_reg;
    o_R2 <= R2_reg;
    o_immediate <= immediate_reg;
    o_Rsrc1 <= Rsrc1_reg;
    o_Rsrc2 <= Rsrc2_reg;
    o_Rdest <= Rdest_reg;
    o_control_signals <= control_signals_reg;


    process(clk, flush)
    begin
        if rising_edge(clk) then
            if flush = '1' then
                next_pc_reg <= x"0000";
                R1_reg <= x"0000";
                R2_reg <= x"0000";
                immediate_reg <= x"0000";
                Rsrc1_reg <= x"000";
                Rsrc2_reg <= x"000";
                Rdest_reg <= x"000";
                control_signals_reg <= x"0000000000";
            else
                next_pc_reg <= i_next_pc;
                R1_reg <= i_R1;
                R2_reg <= i_R2;
                immediate_reg <= i_immediate;
                Rsrc1_reg <= i_Rsrc1;
                Rsrc2_reg <= i_Rsrc2;
                Rdest_reg <= i_Rdest;
                control_signals_reg <= i_control_signals;
            end if;
        end if;
    end process;




end architecture RTL;