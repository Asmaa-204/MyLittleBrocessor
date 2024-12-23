library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity MemoryStage is
    port(
        clk: in std_logic;
        reset: in std_logic;

        -- Inputs From Execute Stage
        i_next_pc: in std_logic_vector(15 downto 0);
        i_flags: in std_logic_vector(2 downto 0);
        i_Rdest: in std_logic_vector(2 downto 0);
        i_R1: in std_logic_vector(15 downto 0);
        i_immediate: in std_logic_vector(15 downto 0);
        i_Result: in std_logic_vector(15 downto 0);
        i_control_signals: in std_logic_vector(39 downto 0);
    

        -- Outputs to Write Back Stage
        o_mem_read_data: out std_logic_vector(15 downto 0);
        o_Result: out std_logic_vector(15 downto 0);
        o_Rdest: out std_logic_vector(2 downto 0);
        o_control_signals: out std_logic_vector(39 downto 0)
    );
end entity MemoryStage;

-- mem_read_enable : 1
-- mem_write_enable : 1
-- mem_write_data_sel : 1
-- mem_addr_sel : 1
-- SP_update : 1
-- SP_enable : 1
-- SP_sel    : 2

-- length needed: 8
-- (Range Needed : 31 downto 24)

architecture MemoryStage_RTL of MemoryStage is

    -- Memory Signals
    signal mem_write_data: std_logic_vector(15 downto 0);
    signal mem_write_addr: std_logic_vector(15 downto 0);
    signal SP_selected: std_logic_vector(15 downto 0);

    signal SP_Register : std_logic_vector(15 downto 0) := std_logic_vector(unsigned(to_unsigned(4095, 16)));
    signal SP_next_Register : std_logic_vector(15 downto 0);
    signal SP_prev_Register : std_logic_vector(15 downto 0);

    

    -----------------------------------------
    -- CONTROL SIGNALS
    -----------------------------------------

    signal mem_signals: std_logic_vector(7 downto 0);

    -- disect the control signals

    signal mem_read_enable: std_logic;
    signal mem_write_enable: std_logic;
    signal mem_write_data_sel: std_logic;
    signal mem_addr_sel: std_logic;
    signal SP_update: std_logic;
    signal SP_enable: std_logic;
    signal SP_sel: std_logic_vector(1 downto 0);

begin

    mem_signals <= i_control_signals(31 downto 24);

    mem_read_enable <= mem_signals(7);
    mem_write_enable <= mem_signals(6);
    mem_write_data_sel <= mem_signals(5);
    mem_addr_sel <= mem_signals(4);
    SP_update <= mem_signals(3);
    SP_enable <= mem_signals(2);
    SP_sel <= mem_signals(1 downto 0);

    -----------------------------------------
    -- INSTANTIATE COMPONENTS
    -----------------------------------------

    SP_next_Register <= std_logic_vector(unsigned(SP_Register) + 1);
    SP_prev_Register <= std_logic_vector(unsigned(SP_Register) - 1);


    -- RAM

    RAM_Instance: entity work.RAM
        port map(
            clk => clk,
            reset => reset,
            write_enable => mem_write_enable,
            read_enable => mem_read_enable,
            addr => mem_write_addr,
            data_in => mem_write_data,
            data_out => o_mem_read_data
        );

    with mem_write_data_sel select
        mem_write_data <= i_R1 when '0',
                          i_immediate when others;

    with SP_sel select
        SP_selected <= SP_Register when "00",
                       SP_next_Register when "01",
                       SP_prev_Register when "10",
                       SP_Register when others;

    with mem_addr_sel select
        mem_write_addr <= i_Result when '0',
                          SP_selected when others;    

    process(clk, reset)
    begin
        if reset = '1' then
            SP_Register <= x"0FFF";
        elsif rising_edge(clk) then
            if SP_enable = '1' then
                case SP_update is
                    when '1' =>
                        SP_Register <= SP_next_Register;
                    when others =>
                        SP_Register <= SP_prev_Register;
                end case;
            end if;
        end if;
    end process;


end architecture MemoryStage_RTL;