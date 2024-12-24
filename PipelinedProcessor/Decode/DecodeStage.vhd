library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DecodeStage is 
    port(
        clk: in std_logic;  
        reset: in std_logic;

        -- Inputs From Fetch Stage
        i_next_pc: in std_logic_vector(15 downto 0);
        i_instruction: in std_logic_vector(15 downto 0);
        i_immediate: in std_logic_vector(15 downto 0);

        -- Inptuts From ID/EX Buffer
        i_ID_EX_Rdest: in std_logic_vector(2 downto 0);
        i_ID_EX_mem_read_enable: in std_logic;

        -- Inputs From Execute Stage
        i_flags: in std_logic_vector(2 downto 0);

        -- Inputs From IO
        i_input_io: in std_logic_vector(15 downto 0);

        -- Inputs From WriteBack Stage
        i_write_enable: in std_logic;
        i_write_data: in std_logic_vector(15 downto 0);
        i_Rdest: in std_logic_vector(2 downto 0);

        -- Outputs to Execute Stage
        o_next_pc: out std_logic_vector(15 downto 0);
        o_R1: out std_logic_vector(15 downto 0);
        o_R2: out std_logic_vector(15 downto 0);
        o_immediate: out std_logic_vector(15 downto 0);
        o_Rsrc1: out std_logic_vector(2 downto 0);
        o_Rsrc2: out std_logic_vector(2 downto 0);
        o_Rdest: out std_logic_vector(2 downto 0);

        -- Control Signals
        o_control_signals: out std_logic_vector(39 downto 0)

        -- Hazards
        stall: out std_logic;
    );
end entity DecodeStage;

-- io_in : 1

-- length needed: 1
-- (Range Needed : 19)



architecture DecodeStage_RTL of DecodeStage is

    constant CONTROL_WIDTH: integer := 40;

    signal OpCode: std_logic_vector(4 downto 0);
    signal Rsrc1: std_logic_vector(2 downto 0);
    signal Rsrc2: std_logic_vector(2 downto 0);
    signal Rdest: std_logic_vector(2 downto 0);
    signal Extra_two_bits: std_logic_vector(1 downto 0);
    

    signal mem_read_data1: std_logic_vector(15 downto 0);
    signal mem_read_data2: std_logic_vector(15 downto 0);

    signal control_signals: std_logic_vector(39 downto 0);

    -- Control signals
    signal decode_signals: std_logic_vector(0 downto 0);
    signal io_in: std_logic := '0';

begin



    ------------------------------
    -- Disect the instruction
    ------------------------------

    OpCode <= i_instruction(15 downto 11);
    Rsrc1 <= i_instruction(10 downto 8);
    Rsrc2 <= i_instruction(7 downto 5);
    Rdest <= i_instruction(4 downto 2);
    Extra_two_bits <= i_instruction(1 downto 0);

    ------------------------------
    -- Dissect the control signals
    ------------------------------

    decode_signals <= control_signals(19 downto 19);
    io_in <= decode_signals(0);

    ------------------------------
    -- Instantiate the components
    ------------------------------

    RegisterFile_Instance: entity work.RegisterFile
        port map(
            clk => clk,
            reset => reset,
            i_write_enable => i_write_enable,
            i_Rsrc1 => Rsrc1,
            i_Rsrc2 => Rsrc2,
            i_Rdest => i_Rdest,
            i_write_data => i_write_data,
            o_read_data_1 => mem_read_data1, 
            o_read_data_2 => mem_read_data2
        );

    ControlUnit_Instance: entity work.ControlUnit
        port map(
            clk => clk,
            i_opCode => OpCode,
            i_extra_two_bits => Extra_two_bits,
            o_control_signals => control_signals
        );


    HazardUnit_Instance: entity work.HazardUnit
        port map(
            i_IF_ID_Rsrc1 => Rsrc1,
            i_IF_ID_Rsrc2 => Rsrc2,
            i_ID_EX_Rdest => i_ID_EX_Rdest,
            i_ID_EX_mem_read_enable => i_ID_EX_mem_read_enable,
            i_flags => i_flags,
            i_jump_enable => control_signals(18),
            i_jump_type => OpCode(1 downto 0)
        );


    ------------------------------
    -- Outputs
    ------------------------------

    o_Rsrc1 <= Rsrc1;
    o_Rsrc2 <= Rsrc2;
    o_Rdest <= Rdest;
    o_next_pc <= i_next_pc;
    o_R1 <= mem_read_data1;
    o_R2 <= mem_read_data2;
    o_control_signals <= control_signals;

    -- o_immediate is either the immediate or the input from IO

    with io_in select
        o_immediate <= i_input_io when '1',
                       i_immediate when others;


end architecture DecodeStage_RTL;