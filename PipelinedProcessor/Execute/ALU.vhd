library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
port (
    i_op1 : in std_logic_vector(15 downto 0);
    i_op2 : in std_logic_vector(15 downto 0);
    i_alu_control : in std_logic_vector(2 downto 0);
    o_result : out std_logic_vector(15 downto 0);
    o_flags : out std_logic_vector(2 downto 0)  -- Zero, Negative, Carry
);
end ALU;

architecture Behavioral of ALU is
    -- Operation constants
    constant INC_S: std_logic_vector(2 downto 0) := "000";
    constant SETC_S : std_logic_vector(2 downto 0) := "001";
    constant NOT_S: std_logic_vector(2 downto 0) := "010";
    constant ADD_S : std_logic_vector(2 downto 0) := "011";
    constant SUB_S : std_logic_vector(2 downto 0) := "100";
    constant AND_S : std_logic_vector(2 downto 0) := "101";
    constant PASS_OP1_S : std_logic_vector(2 downto 0) := "110";
    constant PASS_OP2_S : std_logic_vector(2 downto 0) := "111";

    signal carry_out: std_logic;
    signal zero_out: std_logic;
    signal negative_out: std_logic;
    
    signal temp_result: std_logic_vector(16 downto 0);


begin
    -- Main ALU process
    process(i_op1, i_op2, i_alu_control)
    begin
        -- Default assignments
        temp_result <= (others => '0');
        
        case i_alu_control is
            when INC_S =>
                temp_result <= std_logic_vector('0' & unsigned(i_op1) + 1);
                
            when SETC_S =>
                temp_result <= '1' & x"0000";
                
            when NOT_S =>
                temp_result <= '0' & not i_op1;
                
            when ADD_S =>
                temp_result <= std_logic_vector('0' & unsigned(i_op1) + unsigned(i_op2));
                
            when SUB_S =>
                temp_result <= std_logic_vector('0' & unsigned(i_op1) - unsigned(i_op2));
                
            when AND_S =>
                temp_result <= '0' & (i_op1 and i_op2);
                
            when PASS_OP1_S =>
                temp_result <= '0' & i_op1;
                
            when PASS_OP2_S =>
                temp_result <= '0' & i_op2;
                
            when others =>
                temp_result <= (others => '0');
        end case;
    end process;

            -- Direct output assignments
    o_result <= temp_result(15 downto 0);
    carry_out <= temp_result(16);
    negative_out <= temp_result(15);
    zero_out <= '1' when temp_result(15 downto 0) = (15 downto 0 => '0') else '0';

    -- Flag assignments
    o_flags <= zero_out & negative_out & carry_out;

end Behavioral;