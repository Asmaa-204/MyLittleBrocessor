library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- NOP:    0x0000000000
-- SETC:   0x2100000000
-- MOV:    0x2000000000
-- IN:     0xD000010000
-- OUT:    0xC000040000

-- NOT:    0x4100100000
-- ADD:    0x6100100000
-- SUB:    0x8100010000
-- AND:    0xA100010000
-- INC:    0x0100010000
-- PUSH:   0x0054000000
-- POP:    0x009D900000
-- IADD:   0x6900010000
-- LDM:    0xD000010000
-- LDD:    0x6880100000
-- STD:    0x7040000000

entity ControlUnit is 
    port(
        clk: in std_logic;
        i_opcode: in std_logic_vector(4 downto 0);
        i_extra_two_bits: in std_logic_vector(1 downto 0);
        o_control_signals: out std_logic_vector(39 downto 0)
    );
end entity ControlUnit;

architecture RTL of ControlUnit is

    constant CONTROL_WIDTH: integer := 40;

-- Instruction Set

    constant NOP: std_logic_vector(4 downto 0) := "00000";
    constant HLT: std_logic_vector(4 downto 0) := "00001";
    constant SETC: std_logic_vector(4 downto 0) := "00010";
    constant INPUT: std_logic_vector(4 downto 0) := "00011";
    constant OUTPUT: std_logic_vector(4 downto 0) := "00100";

    constant NOT_INST: std_logic_vector(4 downto 0) := "00101";
    constant INC: std_logic_vector(4 downto 0) := "00110";
    constant MOV: std_logic_vector(4 downto 0) := "00111";
    
    constant ADD: std_logic_vector(4 downto 0) := "01000";
    constant SUB: std_logic_vector(4 downto 0) := "01001";
    constant AND_INST: std_logic_vector(4 downto 0) := "01010";

    constant PUSH: std_logic_vector(4 downto 0) := "01011";
    constant POP: std_logic_vector(4 downto 0) := "01100";

    constant IADD: std_logic_vector(4 downto 0) := "10000";
    constant LDM: std_logic_vector(4 downto 0) := "10001";
    constant LDD: std_logic_vector(4 downto 0) := "10010";
    constant STD: std_logic_vector(4 downto 0) := "10011";

    constant JZ: std_logic_vector(4 downto 0) := "10100";
    constant JN: std_logic_vector(4 downto 0) := "10101";
    constant JC: std_logic_vector(4 downto 0) := "10110";
    constant JMP: std_logic_vector(4 downto 0) := "10111";
    constant CALL: std_logic_vector(4 downto 0) := "11011"; --//TODO: Change to 11011

    constant RET: std_logic_vector(4 downto 0) := "11001";
    constant RTI: std_logic_vector(4 downto 0) := "11010";
    constant INT: std_logic_vector(4 downto 0) := "11100";


    ------------------------------
    -- Decode Signals
    ------------------------------

    signal jump: std_logic;
    signal jump_type: std_logic_vector(1 downto 0);
    signal reg_write_enable: std_logic;

    ------------------------------
    -- Execution Signals
    ------------------------------

    signal op1_mux_select: std_logic;
    signal op2_mux_select: std_logic;
    signal flags_enable: std_logic;
    signal alu_op: std_logic_vector(2 downto 0);
    
    signal saveFlags: std_logic;
    signal loadFlags: std_logic;

    ------------------------------------------------
    -- Memory Signals
    ------------------------------------------------

    signal mem_read: std_logic;
    signal mem_write: std_logic;
    signal addr_sel: std_logic;
    signal data_sel: std_logic;

    -----------------------------------------------
    -- Fetch Signals (We might need to change this)
    -----------------------------------------------

    signal pc_enable: std_logic;

    signal old_pc: std_logic;
    signal inst_mid_reg: std_logic_vector(15 downto 0);
    
    -- For the pc register
    signal pass_old_pc: std_logic;
    signal pass_zero: std_logic_vector(1 downto 0);
    signal pass_R1: std_logic;
    signal int1: std_logic;
    signal int2: std_logic;

    -----------------------------------------------
    -- Signals For Flush
    -----------------------------------------------

    signal reset_if_id: std_logic;
    signal reset_id_ex: std_logic;
    signal reset_ex_mem: std_logic;
    signal reset_mem_wb: std_logic;

    -----------------------------------------------
    constant DEFAULT_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := (others => '0');


-- Control Signals

    constant NOP_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"0000000000";
    constant HLT_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := DEFAULT_CTRL;
    constant SETC_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"2100000000";
    constant INPUT_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"D000180000";
    constant OUTPUT_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"C000400000";

    constant NOT_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"4100100000";
    constant INC_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"0100100000";
    constant MOV_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"2000100000";

    constant ADD_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"6100100000";
    constant SUB_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"8100100000";
    constant AND_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"A100100000";

    constant PUSH_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"0054000000";
    constant POP_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"009D900000";

    constant IADD_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"6900100000";
    constant LDM_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"D000100000";
    constant LDD_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"6880900000";
    constant STD_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := x"7040000000";

    constant JZ_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := DEFAULT_CTRL;
    constant JN_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := DEFAULT_CTRL;
    constant JC_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := DEFAULT_CTRL;
    constant JMP_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := DEFAULT_CTRL;
    constant CALL_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := DEFAULT_CTRL;

    constant RET_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := DEFAULT_CTRL;
    constant RTI_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := DEFAULT_CTRL;
    constant INT_CTRL: std_logic_vector(CONTROL_WIDTH-1 downto 0) := DEFAULT_CTRL;

-- signals



begin
    
    with i_opCode select
        o_control_signals <=
            NOP_CTRL when NOP,
            HLT_CTRL when HLT,
            SETC_CTRL when SETC,
            INPUT_CTRL when INPUT,
            OUTPUT_CTRL when OUTPUT,
            NOT_CTRL when NOT_INST,
            INC_CTRL when INC,
            MOV_CTRL when MOV,
            ADD_CTRL when ADD,
            SUB_CTRL when SUB,
            AND_CTRL when AND_INST,
            PUSH_CTRL when PUSH,
            POP_CTRL when POP,
            IADD_CTRL when IADD,
            LDM_CTRL when LDM,
            LDD_CTRL when LDD,
            STD_CTRL when STD,
            JZ_CTRL when JZ,
            JN_CTRL when JN,
            JC_CTRL when JC,
            JMP_CTRL when JMP,
            CALL_CTRL when CALL,
            RET_CTRL when RET,
            RTI_CTRL when RTI,
            INT_CTRL when INT,
            NOP_CTRL when others;

end architecture RTL;