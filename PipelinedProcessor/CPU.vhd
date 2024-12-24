library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CPU is
port(
    clk: in std_logic;
    reset: in std_logic;
    i_input: in std_logic_vector(15 downto 0);
    o_output: out std_logic_vector(15 downto 0);
    o_error_pc: out std_logic_vector(15 downto 0)
);
end entity CPU;

architecture RTL of CPU is

    -- Internal Signals
    signal s_input: std_logic_vector(15 downto 0);
    signal s_output: std_logic_vector(15 downto 0);
    signal s_error_pc: std_logic_vector(15 downto 0);

    -- Fetch Stage Signals
    signal fetch_o_instruction: std_logic_vector(15 downto 0);
    signal fetch_o_next_pc: std_logic_vector(15 downto 0);
    signal fetch_o_immediate: std_logic_vector(15 downto 0);

    -- IF/ID Register Signals
    signal if_id_o_instruction: std_logic_vector(15 downto 0);
    signal if_id_o_next_pc: std_logic_vector(15 downto 0);
    signal if_id_o_immediate: std_logic_vector(15 downto 0);

    -- Decode Stage Signals
    signal decode_o_next_pc: std_logic_vector(15 downto 0);
    signal decode_o_R1: std_logic_vector(15 downto 0);
    signal decode_o_R2: std_logic_vector(15 downto 0);
    signal decode_o_immediate: std_logic_vector(15 downto 0);
    signal decode_o_Rsrc1: std_logic_vector(2 downto 0);
    signal decode_o_Rsrc2: std_logic_vector(2 downto 0);
    signal decode_o_Rdest: std_logic_vector(2 downto 0);
    signal decode_o_control_signals: std_logic_vector(39 downto 0);
    signal decode_o_flush

    -- ID/EX Register Signals
    signal id_ex_o_next_pc: std_logic_vector(15 downto 0);
    signal id_ex_o_R1: std_logic_vector(15 downto 0);
    signal id_ex_o_R2: std_logic_vector(15 downto 0);
    signal id_ex_o_immediate: std_logic_vector(15 downto 0);
    signal id_ex_o_Rsrc1: std_logic_vector(2 downto 0);
    signal id_ex_o_Rsrc2: std_logic_vector(2 downto 0);
    signal id_ex_o_Rdest: std_logic_vector(2 downto 0);
    signal id_ex_o_control_signals: std_logic_vector(39 downto 0);

    -- Execute Stage Signals
    signal execute_o_next_pc: std_logic_vector(15 downto 0);
    signal execute_o_flags: std_logic_vector(2 downto 0);
    signal execute_o_Rdest: std_logic_vector(2 downto 0);
    signal execute_o_R1: std_logic_vector(15 downto 0);
    signal execute_o_immediate: std_logic_vector(15 downto 0);
    signal execute_o_Result: std_logic_vector(15 downto 0);
    signal execute_o_control_signals: std_logic_vector(39 downto 0);

    -- EX/MEM Register Signals
    signal ex_mem_o_next_pc: std_logic_vector(15 downto 0);
    signal ex_mem_o_flags: std_logic_vector(2 downto 0);
    signal ex_mem_o_Rdest: std_logic_vector(2 downto 0);
    signal ex_mem_o_R1: std_logic_vector(15 downto 0);
    signal ex_mem_o_immediate: std_logic_vector(15 downto 0);
    signal ex_mem_o_Result: std_logic_vector(15 downto 0);
    signal ex_mem_o_control_signals: std_logic_vector(39 downto 0);

    -- Memory Stage Signals
    signal memory_o_mem_read_data: std_logic_vector(15 downto 0);
    signal memory_o_Result: std_logic_vector(15 downto 0);
    signal memory_o_Rdest: std_logic_vector(2 downto 0);
    signal memory_o_control_signals: std_logic_vector(39 downto 0);

    -- MEM/WB Register Signals
    signal mem_wb_o_mem_read_data: std_logic_vector(15 downto 0);
    signal mem_wb_o_Result: std_logic_vector(15 downto 0);
    signal mem_wb_o_Rdest: std_logic_vector(2 downto 0);
    signal mem_wb_o_control_signals: std_logic_vector(39 downto 0);

    -- WriteBack Stage Signals
    signal wb_o_write_enable: std_logic;
    signal wb_o_write_data: std_logic_vector(15 downto 0);
    signal wb_o_Rdest: std_logic_vector(2 downto 0);
    signal wb_o_output_io: std_logic_vector(15 downto 0);

begin
    Fetch_Stage_Instance: entity work.FetchStage
    port map(
        clk => clk,
        reset => reset,

        i_R1 => decode_o_R1,
        i_WB_data => wb_o_write_data,

        o_instruction => fetch_o_instruction,
        o_next_pc => fetch_o_next_pc,
        o_immediate => fetch_o_immediate
    );

    IF_ID_Register: entity work.IF_ID_Register
    port map(
        clk => clk,
        flush => decode_o_control_signals(0),
        
        i_instruction => fetch_o_instruction,
        i_next_pc => fetch_o_next_pc,
        i_immediate => fetch_o_immediate,
        
        o_instruction => if_id_o_instruction,
        o_immediate => if_id_o_immediate,
        o_next_pc => if_id_o_next_pc
    );

    Decode_Stage_Instance: entity work.DecodeStage
    port map(
        clk => clk,
        reset => reset,

        i_next_pc => if_id_o_next_pc,
        i_instruction => if_id_o_instruction,
        i_immediate => if_id_o_immediate,

        i_ID_EX_Rdest => id_ex_o_Rdest,
        i_ID_EX_mem_read_enable => id_ex_o_control_signals(31),

        i_flags => execute_o_flags,

        i_input_io => s_input,
        
        i_write_enable => wb_o_write_enable,
        i_write_data => wb_o_write_data,
        i_Rdest => wb_o_Rdest,
        
        o_next_pc => decode_o_next_pc,
        o_R1 => decode_o_R1,
        o_R2 => decode_o_R2,
        o_immediate => decode_o_immediate,
        o_Rsrc1 => decode_o_Rsrc1,
        o_Rsrc2 => decode_o_Rsrc2,
        o_Rdest => decode_o_Rdest,

        o_control_signals => decode_o_control_signals
    );

    ID_EX_Register: entity work.ID_EX_Register
    port map(
        clk => clk,
        flush => decode_o_control_signals(1),

        i_next_pc => decode_o_next_pc,
        i_R1 => decode_o_R1,
        i_R2 => decode_o_R2,
        i_immediate => decode_o_immediate,
        i_Rsrc1 => decode_o_Rsrc1,
        i_Rsrc2 => decode_o_Rsrc2,
        i_Rdest => decode_o_Rdest,
        i_control_signals => decode_o_control_signals,

        o_next_pc => id_ex_o_next_pc,
        o_R1 => id_ex_o_R1,
        o_R2 => id_ex_o_R2,
        o_immediate => id_ex_o_immediate,
        o_Rsrc1 => id_ex_o_Rsrc1,
        o_Rsrc2 => id_ex_o_Rsrc2,
        o_Rdest => id_ex_o_Rdest,
        o_control_signals => id_ex_o_control_signals
    );

    Execute_Stage_Instance: entity work.ExecuteStage
    port map(
        clk => clk,
        reset => reset,

        i_next_pc => id_ex_o_next_pc,
        i_R1 => id_ex_o_R1,
        i_R2 => id_ex_o_R2,
        i_immediate => id_ex_o_immediate,

        i_Rdest => id_ex_o_Rdest,
        i_Rsrc1 => id_ex_o_Rsrc1,
        i_Rsrc2 => id_ex_o_Rsrc2,

        i_MEM_WB_Rdest => mem_wb_o_Rdest,
        i_MEM_WB_RegWrite => wb_o_write_enable,
        i_WB_Data => wb_o_write_data,

        i_EX_MEM_Rdest => ex_mem_o_Rdest,
        i_EX_MEM_RegWrite => ex_mem_o_control_signals(20),
        i_EX_MEM_Result => ex_mem_o_Result,

        i_control_signals => id_ex_o_control_signals,

        o_next_pc => execute_o_next_pc,
        o_flags => execute_o_flags,
        o_Rdest => execute_o_Rdest,
        o_R1 => execute_o_R1,
        o_immediate => execute_o_immediate,
        o_Result => execute_o_Result,
        o_control_signals => execute_o_control_signals
    );

    EX_MEM_Register: entity work.EX_MEM_Register
    port map(
        clk => clk,
        flush => decode_o_control_signals(2),
        
        i_next_pc => execute_o_next_pc,
        i_flags => execute_o_flags,
        i_Rdest => execute_o_Rdest,
        i_R1 => execute_o_R1,
        i_immediate => execute_o_immediate,
        i_Result => execute_o_Result,
        i_control_signals => execute_o_control_signals,
        o_next_pc => ex_mem_o_next_pc,
        o_flags => ex_mem_o_flags,
        o_Rdest => ex_mem_o_Rdest,
        o_R1 => ex_mem_o_R1,
        o_immediate => ex_mem_o_immediate,
        o_Result => ex_mem_o_Result,
        o_control_signals => ex_mem_o_control_signals
    );

    Memory_Stage_Instance: entity work.MemoryStage
    port map(
        clk => clk,
        reset => reset,

        i_next_pc => ex_mem_o_next_pc,
        i_flags => ex_mem_o_flags,
        i_Rdest => ex_mem_o_Rdest,
        i_R1 => ex_mem_o_R1,
        i_immediate => ex_mem_o_immediate,
        i_Result => ex_mem_o_Result,
        i_control_signals => ex_mem_o_control_signals,

        o_mem_read_data => memory_o_mem_read_data,
        o_Result => memory_o_Result,
        o_Rdest => memory_o_Rdest,
        o_control_signals => memory_o_control_signals
    );

    MEM_WB_Register: entity work.MEM_WB_Register
    port map(
        clk => clk,
        flush => decode_o_control_signals(3),

        i_mem_read_data => memory_o_mem_read_data,
        i_Result => memory_o_Result,
        i_Rdest => memory_o_Rdest,
        i_control_signals => memory_o_control_signals,

        o_mem_read_data => mem_wb_o_mem_read_data,
        o_Result => mem_wb_o_Result,
        o_Rdest => mem_wb_o_Rdest,
        o_control_signals => mem_wb_o_control_signals
    );

    WriteBack_Stage_Instance: entity work.WriteBackStage
    port map(
        clk => clk,
        reset => reset,

        i_mem_read_data => mem_wb_o_mem_read_data,
        i_Result => mem_wb_o_Result,
        i_Rdest => mem_wb_o_Rdest,
        i_control_signals => mem_wb_o_control_signals,

        o_write_enable => wb_o_write_enable,
        o_write_data => wb_o_write_data,
        o_Rdest => wb_o_Rdest,
        o_output_io => wb_o_output_io
    );


    o_output <= wb_o_output_io;
    o_error_pc <= s_error_pc;

end architecture RTL;