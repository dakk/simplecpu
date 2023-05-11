from pymtl3 import *
from pymtl3.datatypes import bitstruct, Bits32, Bits5
from pymtl3.passes.backends.verilog.translation.VTranslator import VTranslator

BDataType 	= Bits32
BAddressType 	= Bits3
BInstructionType= Bits32


@bitstruct
class Instruction:
  opcode: Bits3
  op1: Bits3
  op2: Bits3
  op3: Bits3
  unused: Bits20

# Define the opcodes for our six instructions
OP_NOP   = 0
OP_LOAD  = 1
OP_STORE = 2
OP_ADD   = 3
OP_SUB   = 4
OP_JMPZ  = 5
OP_JMP   = 6

class Memory( Component ):
  def construct( s, mem_size ):
    # Memory is a list of 32-bit values
    s.mem = [ Wire(BDataType) for _ in range(mem_size) ]

    # The Memory component has an address input and a data output
    s.addr = InPort(BAddressType)
    s.data = OutPort(BDataType)

    # It also has a write enable signal and a data input for writing to memory
    s.write_enable = InPort(Bits1)
    s.write_data = InPort(Bits32)

    @update
    def read_data():
      s.data @= s.mem[s.addr]

    @update
    def write_data():
      if s.write_enable:
        s.mem[s.addr] @= s.write_data
        
class SimpleCPU( Component ):
  def construct(s):
    # The CPU has 8 registers and a program counter
    s.registers = [ Wire(BDataType) for _ in range(8) ]
    s.pc = Wire(Bits3)

    # The CPU takes an instruction as input
    s.instruction = Wire(Instruction)

    # We have an instruction memory
    s.imem = Memory( 2**3 )  # Assuming 1024 instructions can be stored

    # Connect PC to IMem
    connect( s.imem.addr, s.pc )

    # Fetch instruction from memory
    @update
    def fetch_instruction():
      s.instruction @= s.imem.data

    # Execute instruction
    @update
    def execute_instruction():
      #if s.instruction.opcode == OP_LOAD:
      #  s.registers[s.instruction.op1] @= mem[s.instruction.op2]

      #elif s.instruction.opcode == OP_STORE:
      #  mem[s.instruction.op1] = s.registers[s.instruction.op2]

      if s.instruction.opcode == OP_ADD:
        s.registers[s.instruction.op1] @= s.registers[s.instruction.op2] + s.registers[s.instruction.op3]

      elif s.instruction.opcode == OP_SUB:
        s.registers[s.instruction.op1] @= s.registers[s.instruction.op2] - s.registers[s.instruction.op3]

      elif s.instruction.opcode == OP_JMPZ:
        if s.registers[s.instruction.op1] == 0:
          s.pc @= s.instruction.op2

      elif s.instruction.opcode == OP_JMP:
        s.pc @= s.instruction.op1

      else:  # Increment the PC if it's not a jump
        s.pc @= s.pc + 1




def translate_to_verilog( model, outf='out.v' ):
  model.elaborate()
  v = VTranslator(model)
  v.translate(model)
  f = open(outf,'w')
  f.write(v.hierarchy.src)
  f.close()
  
  
cpu = SimpleCPU()
translate_to_verilog(cpu)



"""
module Instruction__opcode_3__op1_3__op2_3__op3_3__unused_20(
  input [28:0] instruction_in,
  output [2:0] opcode,
  output [2:0] op1,
  output [2:0] op2,
  output [2:0] op3,
  output [19:0] unused
);

assign opcode = instruction_in[28:26];
assign op1 = instruction_in[25:23];
assign op2 = instruction_in[22:20];
assign op3 = instruction_in[19:17];
assign unused = instruction_in[16:0];

endmodule
"""
