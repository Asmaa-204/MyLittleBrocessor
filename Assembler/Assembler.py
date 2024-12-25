import re
import copy
from typing import List

INSTRUCTION_KEYS = ["opcode", "Rsrc1", "Rsrc2", "Rdst", "extra"]

INSTRUCTION_SET = {
    "nop":  {INSTRUCTION_KEYS[0]:"00000", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "hlt":  {INSTRUCTION_KEYS[0]:"00001", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "setc": {INSTRUCTION_KEYS[0]:"00010", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "in":   {INSTRUCTION_KEYS[0]:"00011", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "out":  {INSTRUCTION_KEYS[0]:"00100", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "not":  {INSTRUCTION_KEYS[0]:"00101", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "inc":  {INSTRUCTION_KEYS[0]:"00110", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "mov":  {INSTRUCTION_KEYS[0]:"00111", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "add":  {INSTRUCTION_KEYS[0]:"01000", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "sub":  {INSTRUCTION_KEYS[0]:"01001", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "and":  {INSTRUCTION_KEYS[0]:"01010", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "push": {INSTRUCTION_KEYS[0]:"01011", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "pop":  {INSTRUCTION_KEYS[0]:"01100", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "iadd": {INSTRUCTION_KEYS[0]:"10000", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"01"},
    "ldm":  {INSTRUCTION_KEYS[0]:"10001", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"01"},
    "ldd":  {INSTRUCTION_KEYS[0]:"10010", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"01"},
    "std":  {INSTRUCTION_KEYS[0]:"10011", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"01"},
    "jz":   {INSTRUCTION_KEYS[0]:"10100", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "jn":   {INSTRUCTION_KEYS[0]:"10101", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "jc":   {INSTRUCTION_KEYS[0]:"10110", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "jmp":  {INSTRUCTION_KEYS[0]:"10111", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "call": {INSTRUCTION_KEYS[0]:"11000", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"00"},
    "ret":  {INSTRUCTION_KEYS[0]:"11001", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"10"},
    "rti":  {INSTRUCTION_KEYS[0]:"11010", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"10"},
    "int":  {INSTRUCTION_KEYS[0]:"11100", INSTRUCTION_KEYS[1]:"000", INSTRUCTION_KEYS[2]:"000", INSTRUCTION_KEYS[3]:"000", INSTRUCTION_KEYS[4]:"11"},
}

REGISTER_MAP = {
    "r0": "000",
    "r1": "001",
    "r2": "010",
    "r3": "011",
    "r4": "100",
    "r5": "101",
    "r6": "110",
    "r7": "111",
}

def hex_to_binary(hex_value):
    try:
        binary_value = bin(int(hex_value, 16))[2:]
        return ''.join(['0' for i in range(16 - len(binary_value))]) + binary_value
    except ValueError as e:
        raise ValueError(f"Invalid hexadecimal value: {hex_value}") from e

def parse_instruction(line: str) -> List[str]:
    line = line.strip().lower()  # Convert the whole line to lowercase
    parts = re.split(r'[,\s\(\)]+', line)
    parts = [p for p in parts if p]  # Remove empty strings
    return parts

def construct_binary_instruction(instruction_obj):
    return ''.join(instruction_obj[key] for key in INSTRUCTION_KEYS)

def write_to_output_file(line):
    print(line)

def convert_instruction_to_binary(parts):
    if (parts[0] not in INSTRUCTION_SET):
        return None, parts[0]
    copied_obj = copy.copy(INSTRUCTION_SET[parts[0]])
    imm_val = None
    match parts[0]:
        case "nop" | "hlt" | "setc" | "ret" | "rti":
            pass
        case "in":
            copied_obj[INSTRUCTION_KEYS[3]] = REGISTER_MAP[parts[1]]
        case "out":
            copied_obj[INSTRUCTION_KEYS[1]] = REGISTER_MAP[parts[1]]
        case "not" | "inc" | "mov":
            copied_obj[INSTRUCTION_KEYS[1]] = REGISTER_MAP[parts[2]]
            copied_obj[INSTRUCTION_KEYS[3]] = REGISTER_MAP[parts[1]]
        case "add" | "sub" | "and":
            copied_obj[INSTRUCTION_KEYS[1]] = REGISTER_MAP[parts[2]]
            copied_obj[INSTRUCTION_KEYS[2]] = REGISTER_MAP[parts[3]]
            copied_obj[INSTRUCTION_KEYS[3]] = REGISTER_MAP[parts[1]]
        case "push":
            copied_obj[INSTRUCTION_KEYS[1]] = REGISTER_MAP[parts[1]]
        case "pop":
            copied_obj[INSTRUCTION_KEYS[3]] = REGISTER_MAP[parts[1]]
        case "iadd":
            copied_obj[INSTRUCTION_KEYS[1]] = REGISTER_MAP[parts[2]]
            copied_obj[INSTRUCTION_KEYS[3]] = REGISTER_MAP[parts[1]]
            imm_val = parts[3]
        case "ldm":
            copied_obj[INSTRUCTION_KEYS[3]] = REGISTER_MAP[parts[1]]
            imm_val = parts[2]
        case "ldd" | "std":
            copied_obj[INSTRUCTION_KEYS[1]] = REGISTER_MAP[parts[3]]
            copied_obj[INSTRUCTION_KEYS[3]] = REGISTER_MAP[parts[1]]
            imm_val = parts[2]
        case "jz" | "jn" | "jc" | "jmp" | "call":
            copied_obj[INSTRUCTION_KEYS[1]] = REGISTER_MAP[parts[1]]
        case "int":
            # indx can only be either 0 or 1
            copied_obj[INSTRUCTION_KEYS[1]] = '00' + parts[1]


    return construct_binary_instruction(copied_obj), imm_val

def process_instructions(input_file: str, output_file: str):
    try:
        with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
            i = 0
            for line in infile:
                line = line.strip()
                if not line or line[0] == '#':
                    continue
                parsed = parse_instruction(line)
                if (parsed[0] == '.org'):
                    while (i < int(parsed[1], 16) - 1):
                        # outfile.write(hex_to_binary(construct_binary_instruction(INSTRUCTION_SET["nop"])) + "\n")
                        i += 1
                    continue
                instruction, imm_val = convert_instruction_to_binary(parsed)
                if instruction:
                    outfile.write(instruction + "\n")
                if imm_val:
                    outfile.write(hex_to_binary(imm_val) + "\n")
                i += 1
    except FileNotFoundError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# Example usage
if __name__ == "__main__":
    input_file = "TestCase1.asm"
    output_file = "output.bin"

    process_instructions(input_file, output_file)
