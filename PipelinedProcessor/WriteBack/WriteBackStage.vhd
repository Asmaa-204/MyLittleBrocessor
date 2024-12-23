library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WriteBackStage is
    port(
        clk: in std_logic;
        reset: in std_logic;

        -- Inputs From Memory Stage
        i_mem_read_data: in std_logic_vector(15 downto 0);
        i_Result: in std_logic_vector(15 downto 0);
        i_Rdest: in std_logic_vector(2 downto 0);
        i_control_signals: in std_logic_vector(39 downto 0);

        -- Outputs to Fetch Stage
        -- //TODO: Add Outputs to Fetch Stage

        -- Outputs to Register File
        o_write_enable: out std_logic;
        o_write_data: out std_logic_vector(15 downto 0);
        o_Rdest: out std_logic_vector(2 downto 0);

        -- Outputs to IO
        o_output_io: out std_logic_vector(15 downto 0)
    );
end entity WriteBackStage;

-- wb_data_sel : 1
-- write_enable : 1
-- output_io   : 1
-- wb_return  : 1

-- length needed: 4
-- (Range Needed : 23 downto 20)

architecture WriteBackStage_RTL of WriteBackStage is

    signal write_data: std_logic_vector(15 downto 0);
    signal output_io: std_logic_vector(15 downto 0);

    -----------------------------------------
    -- Control Signals
    -----------------------------------------

    signal wb_signals: std_logic_vector(3 downto 0);

    signal wb_data_sel: std_logic;
    signal write_enable: std_logic;
    signal io_out: std_logic;
    signal wb_return: std_logic;
begin

    -- disect the control signals
    wb_signals <= i_control_signals(23 downto 20);

    wb_data_sel <= wb_signals(0);
    io_out <= wb_signals(1);
    wb_return <= wb_signals(2);
    write_enable <= wb_signals(3);
    

    with wb_data_sel select
        write_data <= i_Result when '0',
                      i_mem_read_data when others;

    with io_out select
        output_io <= write_data when '1',
                     output_io  when others;



    o_output_io <= output_io;
    o_write_data <= write_data;
    o_write_enable <= write_enable;
    o_Rdest <= i_Rdest;

end architecture WriteBackStage_RTL;
