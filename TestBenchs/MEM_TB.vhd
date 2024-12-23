library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MemoryStage_TB is
end entity MemoryStage_TB;

architecture TB of MemoryStage_TB is
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
    -- Component signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    
    -- Input signals
    signal i_next_pc : std_logic_vector(15 downto 0) := (others => '0');
    signal i_flags : std_logic_vector(2 downto 0) := (others => '0');
    signal i_Rdest : std_logic_vector(2 downto 0) := (others => '0');
    signal i_R1 : std_logic_vector(15 downto 0) := (others => '0');
    signal i_immediate : std_logic_vector(15 downto 0) := (others => '0');
    signal i_Result : std_logic_vector(15 downto 0) := (others => '0');
    signal i_control_signals : std_logic_vector(39 downto 0) := (others => '0');
    
    -- Output signals
    signal o_mem_read_data : std_logic_vector(15 downto 0);
    signal o_Result : std_logic_vector(15 downto 0);
    signal o_Rdest : std_logic_vector(2 downto 0);
    signal o_control_signals : std_logic_vector(39 downto 0);
    
    -- Test status
    signal test_error_count : integer := 0;

    -- Control signals

    signal mem_signals: std_logic_vector(7 downto 0);

    signal mem_read_enable : std_logic := '0';
    signal mem_write_enable : std_logic := '0';
    signal mem_write_data_sel : std_logic := '0';
    signal mem_addr_sel : std_logic := '0';
    signal SP_update : std_logic := '0';
    signal SP_enable : std_logic := '0';
    signal SP_sel : std_logic_vector(1 downto 0) := (others => '0');

    
    -- Helper procedure for checking results
    procedure check_equal(
        signal actual : in std_logic_vector;
        expected : in std_logic_vector;
        test_name : in string;
        signal error_count : inout integer) is
    begin
        if actual /= expected then
            report "Test " & test_name & " failed!" &
                   " Expected: " & integer'image(to_integer(unsigned(expected))) &
                   " Got: " & integer'image(to_integer(unsigned(actual)))
                severity error;
            error_count <= error_count + 1;
        else
            report "Test " & test_name & " passed!" severity note;
        end if;
    end procedure;

begin


    mem_signals <= mem_read_enable & mem_write_enable & mem_write_data_sel & mem_addr_sel & SP_update & SP_enable & SP_sel;

    -- Instantiate the Memory Stage
    UUT: entity work.MemoryStage
    port map (
        clk => clk,
        reset => reset,
        i_next_pc => i_next_pc,
        i_flags => i_flags,
        i_Rdest => i_Rdest,
        i_R1 => i_R1,
        i_immediate => i_immediate,
        i_Result => i_Result,
        i_control_signals => i_control_signals,
        o_mem_read_data => o_mem_read_data,
        o_Result => o_Result,
        o_Rdest => o_Rdest,
        o_control_signals => o_control_signals
    );

    -- Clock process
    clk_process: process
    begin
        clk <= '1';
        wait for CLK_PERIOD/2;
        clk <= '0';
        wait for CLK_PERIOD/2;
    end process;

    -- Test process
    test_process: process
    begin
        
        wait for CLK_PERIOD;
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;

        report "Test Case 0: PUSH Operation" severity note;
        i_R1 <= x"ABCD";
        
        i_control_signals <= (others => '0');
        i_control_signals(31 downto 24) <= "01110110";  -- mem_write_enable='1', mem_addr_sel='1', SP_update='1', SP_enable='1'

        wait for CLK_PERIOD;

        report "Test Case 1: POP Operation" severity note;

        -- mem_write_enable='0', mem_addr_sel='1', SP_update='0', SP_enable='1', 
        i_control_signals(31 downto 24) <= "10010101";  -- mem_read_enable='1', mem_addr_sel='1', SP_update='0', SP_enable='1'

        i_control_signals <= (others => '0');



        





        

     -- Report final test status
        if test_error_count = 0 then
            report "All tests passed!" severity note;
        else
            report "Tests completed with " & integer'image(test_error_count) & " errors." severity error;
        end if;
        
        wait;
    end process;

end architecture TB;