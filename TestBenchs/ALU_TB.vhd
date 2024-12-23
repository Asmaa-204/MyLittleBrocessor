library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ALU_tb is
end ALU_tb;

architecture sim of ALU_tb is
    -- Component declaration
    component ALU is
        port (
            i_op1 : in std_logic_vector(15 downto 0);
            i_op2 : in std_logic_vector(15 downto 0);
            i_alu_control : in std_logic_vector(2 downto 0);
            o_result : out std_logic_vector(15 downto 0);
            o_flags : out std_logic_vector(2 downto 0)  -- Zero, Negative, Carry
        );
    end component;

    -- Test signals
    signal op1 : std_logic_vector(15 downto 0) := (others => '0');
    signal op2 : std_logic_vector(15 downto 0) := (others => '0');
    signal alu_control : std_logic_vector(2 downto 0) := (others => '0');
    signal result : std_logic_vector(15 downto 0);
    signal flags : std_logic_vector(2 downto 0);  -- Zero, Negative, Carry

    -- Constants for operations
    constant INC_S: std_logic_vector(2 downto 0) := "000";
    constant SETC_S : std_logic_vector(2 downto 0) := "001";
    constant NOT_S: std_logic_vector(2 downto 0) := "010";
    constant ADD_S : std_logic_vector(2 downto 0) := "011";
    constant SUB_S : std_logic_vector(2 downto 0) := "100";
    constant AND_S : std_logic_vector(2 downto 0) := "101";
    constant PASS_OP1_S : std_logic_vector(2 downto 0) := "110";
    constant PASS_OP2_S : std_logic_vector(2 downto 0) := "111";

    -- Function to convert std_logic_vector to string
    function vec2str(vec : std_logic_vector) return string is
        variable result : string(1 to vec'length);
    begin
        for i in vec'range loop
            case vec(i) is
                when '0' => result(i + 1) := '0';
                when '1' => result(i + 1) := '1';
                when others => result(i + 1) := 'X';
            end case;
        end loop;
        return result;
    end function;

    -- Test procedure
    procedure check_result(
        constant test_name : in string;
        constant expected_result : in std_logic_vector(15 downto 0);
        constant expected_zero : in std_logic;
        constant expected_negative : in std_logic;
        constant expected_carry : in std_logic;
        signal actual_result : in std_logic_vector(15 downto 0);
        signal actual_flags : in std_logic_vector(2 downto 0)
    ) is
    begin
        assert actual_result = expected_result
            report test_name & " - Result mismatch. Expected: " & 
                  vec2str(expected_result) & " Got: " & vec2str(actual_result)
            severity error;
            
        assert actual_flags(2) = expected_zero
            report test_name & " - Zero flag mismatch. Expected: " & 
                  std_logic'image(expected_zero) & " Got: " & std_logic'image(actual_flags(2))
            severity error;
            
        assert actual_flags(1) = expected_negative
            report test_name & " - Negative flag mismatch. Expected: " & 
                  std_logic'image(expected_negative) & " Got: " & std_logic'image(actual_flags(1))
            severity error;
            
        assert actual_flags(0) = expected_carry
            report test_name & " - Carry flag mismatch. Expected: " & 
                  std_logic'image(expected_carry) & " Got: " & std_logic'image(actual_flags(0))
            severity error;
    end procedure;

begin
    -- DUT instantiation
    DUT: ALU port map (
        i_op1 => op1,
        i_op2 => op2,
        i_alu_control => alu_control,
        o_result => result,
        o_flags => flags
    );

    -- Test process
    process
        variable temp_sum : unsigned(16 downto 0);
    begin
        -- Test 1: Increment
        op1 <= x"0001";
        op2 <= x"0000";
        alu_control <= INC_S;
        wait for 10 ns;
        check_result("INC_S Test 1", x"0002", '0', '0', '0', result, flags);

        -- Test 2: Increment with overflow
        op1 <= x"FFFF";
        wait for 10 ns;
        check_result("INC_S Test 2", x"0000", '1', '0', '1', result, flags);

        -- Test 3: Set Carry
        op1 <= x"8000";  -- Should set carry and clear result
        alu_control <= SETC_S;
        wait for 10 ns;
        check_result("SETC_S Test", x"0000", '1', '0', '1', result, flags);

        -- Test 4: NOT operation
        op1 <= x"AAAA";
        alu_control <= NOT_S;
        wait for 10 ns;
        check_result("NOT_S Test", x"5555", '0', '0', '0', result, flags);

        -- Test 5: Addition
        op1 <= x"1234";
        op2 <= x"4321";
        alu_control <= ADD_S;
        wait for 10 ns;
        check_result("ADD_S Test 1", x"5555", '0', '0', '0', result, flags);

        -- Test 6: Addition with carry
        op1 <= x"FFFF";
        op2 <= x"0001";
        wait for 10 ns;
        check_result("ADD_S Test 2", x"0000", '1', '0', '1', result, flags);

        -- Test 7: Subtraction
        op1 <= x"5555";
        op2 <= x"1111";
        alu_control <= SUB_S;
        wait for 10 ns;
        check_result("SUB_S Test 1", x"4444", '0', '0', '0', result, flags);

        -- Test 8: Subtraction with negative result
        op1 <= x"1111";
        op2 <= x"2222";
        wait for 10 ns;
        check_result("SUB_S Test 2", x"EEEF", '0', '1', '1', result, flags);

        -- Test 9: AND operation
        op1 <= x"FFFF";
        op2 <= x"F0F0";
        alu_control <= AND_S;
        wait for 10 ns;
        check_result("AND_S Test", x"F0F0", '0', '1', '0', result, flags);

        -- Test 10: Pass OP1
        op1 <= x"ABCD";
        op2 <= x"1234";
        alu_control <= PASS_OP1_S;
        wait for 10 ns;
        check_result("PASS_OP1_S Test", x"ABCD", '0', '1', '0', result, flags);

        -- Test 11: Pass OP2
        alu_control <= PASS_OP2_S;
        wait for 10 ns;
        check_result("PASS_OP2_S Test", x"1234", '0', '0', '0', result, flags);

        -- Test 12: Zero result test
        op1 <= x"0000";
        op2 <= x"0000";
        alu_control <= ADD_S;
        wait for 10 ns;
        check_result("Zero Result Test", x"0000", '1', '0', '0', result, flags);

        -- Report completion
        report "Simulation completed. Check the log for any errors.";
        wait;
    end process;

end architecture;