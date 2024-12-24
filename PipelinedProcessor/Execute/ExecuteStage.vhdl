library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ExecuteStage is
    port(
        clk: in std_logic;
        reset: in std_logic;

        -- Inputs From Decode Stage
        i_next_pc: in std_logic_vector(15 downto 0);
        i_R1: in std_logic_vector(15 downto 0);
        i_R2: in std_logic_vector(15 downto 0);
        i_immediate: in std_logic_vector(15 downto 0);

        i_Rdest: in std_logic_vector(2 downto 0);
        i_Rsrc1: in std_logic_vector(2 downto 0);
        i_Rsrc2: in std_logic_vector(2 downto 0);

        -- Inputs From WB Stage (Control Signals)
        i_MEM_WB_Rdest: in std_logic_vector(2 downto 0);
        i_MEM_WB_RegWrite: in std_logic;
        i_WB_Data: in std_logic_vector(15 downto 0);

        -- Inputs From EX/MEM Buffer (Control Signals)
        i_EX_MEM_Rdest: in std_logic_vector(2 downto 0);
        i_EX_MEM_RegWrite: in std_logic;
        i_EX_MEM_Result: in std_logic_vector(15 downto 0);

        -- Control Signals
        i_control_signals: in std_logic_vector(39 downto 0);


        -- Outputs to Memory Stage

        o_next_pc: out std_logic_vector(15 downto 0);
        o_flags: out std_logic_vector(2 downto 0);
        o_Rdest: out std_logic_vector(2 downto 0);
        o_R1: out std_logic_vector(15 downto 0);
        o_immediate: out std_logic_vector(15 downto 0);
        o_Result: out std_logic_vector(15 downto 0);
        o_control_signals: out std_logic_vector(39 downto 0)
    );
end entity ExecuteStage;


-- alu_control : 3 
-- op1_sel : 1
-- op2_sel : 1
-- saveflag : 1
-- loadflag : 1
-- flag_enable : 1

-- length needed: 8
-- (Range Needed : 39 downto 32)

architecture ExecuteStage_RTL of ExecuteStage is

    -----------------------------------------
    -- OUTPUTS
    -----------------------------------------

    signal operand1: std_logic_vector(15 downto 0);
    signal operand2: std_logic_vector(15 downto 0);
    signal R1      : std_logic_vector(15 downto 0);
    signal result  : std_logic_vector(15 downto 0);
    
    -- FLAGS
    signal flagsReg   : std_logic_vector(2 downto 0);
    signal flags      : std_logic_vector(2 downto 0);

    -----------------------------------------
    -- Control Signals
    -----------------------------------------

    signal exec_signals: std_logic_vector(7 downto 0);
    
    -- disect the control signals
    signal alu_control: std_logic_vector(2 downto 0);
    signal op1_sel: std_logic;
    signal op2_sel: std_logic;
    signal saveflag: std_logic;
    signal loadflag: std_logic;
    signal flag_enable: std_logic;

begin

    -----------------------------------------
    -- Control Signals
    -----------------------------------------

    exec_signals <= i_control_signals(39 downto 32);

    alu_control <= exec_signals(7 downto 5); -- // 39 to 37
    op1_sel <= exec_signals(4); --// 36
    op2_sel <= exec_signals(3); --// 35
    saveflag <= exec_signals(2); --// 34
    loadflag <= exec_signals(1); --// 33
    flag_enable <= exec_signals(0); --// 32

    -----------------------------------------
    -- INSTANTIATE COMPONENTS
    -----------------------------------------

    ALU_Instance: entity work.ALU port map(
        i_op1 => i_R1,
        i_op2 => i_R2,
        i_alu_control => alu_control,
        o_result => result,
        o_flags => flags
    );

    Forward_Unit_Instance: entity work.ForwardUnit port map(
        i_Rsrc1 => i_Rsrc1,
        i_Rsrc2 => i_Rsrc2,
        i_EX_MEM_Rdest => i_EX_MEM_Rdest,
        i_MEM_WB_Rdest => i_MEM_WB_Rdest,
        i_EX_MEM_Result => i_EX_MEM_Result,
        i_WB_Data => i_WB_Data,
        i_EX_MEM_RegWrite => i_EX_MEM_RegWrite,
        i_MEM_WB_RegWrite => i_MEM_WB_RegWrite,
        i_op1_sel => op1_sel,
        i_op2_sel => op2_sel,
        i_R1 => i_R1,
        i_R2 => i_R2,
        i_Immediate => i_immediate,
        o_R1 => R1,
        o_operand1 => operand1,
        o_operand2 => operand2
    );

    o_control_signals <= i_control_signals;
    o_next_pc <= i_next_pc;
    o_Rdest <= i_Rdest;
    o_immediate <= i_immediate;
    o_R1 <= R1;
    o_flags <= flagsReg;
    o_Result <= result;

    with flag_enable select
        flagsReg <= flags when '1',
                    flagsReg when others;
    
    
end architecture ExecuteStage_RTL;