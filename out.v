//-------------------------------------------------------------------------
// SimpleCPU_noparam.v
//-------------------------------------------------------------------------
// This file is generated by PyMTL SystemVerilog translation pass.

// PyMTL BitStruct Instruction__opcode_3__op1_3__op2_3__op3_3__unused_20 Definition
typedef struct packed {
  logic [2:0] opcode;
  logic [2:0] op1;
  logic [2:0] op2;
  logic [2:0] op3;
  logic [19:0] unused;
} Instruction__opcode_3__op1_3__op2_3__op3_3__unused_20;

// PyMTL Component Memory Definition
// At /home/dakk/simplecpu_mtl.py

module Memory__mem_size_8
(
  input  logic [2:0] addr ,
  input  logic [0:0] clk ,
  output logic [31:0] data ,
  input  logic [0:0] reset ,
  input  logic [31:0] write_data ,
  input  logic [0:0] write_enable 
);
  logic [31:0] mem [0:7];

  // PyMTL Update Block Source
  // At /home/dakk/simplecpu_mtl.py:40
  // @update
  // def read_data():
  //   s.data @= s.mem[s.addr]
  
  always_comb begin : read_data
    data = mem[addr];
  end

  // PyMTL Update Block Source
  // At /home/dakk/simplecpu_mtl.py:44
  // @update
  // def write_data():
  //   if s.write_enable:
  //     s.mem[s.addr] @= s.write_data
  
  always_comb begin : write_data
    if ( write_enable ) begin
      mem[addr] = write_data;
    end
  end

endmodule


// PyMTL Component SimpleCPU Definition
// At /home/dakk/simplecpu_mtl.py

module SimpleCPU_noparam
(
  input  logic [0:0] clk ,
  input  logic [0:0] reset 
);
  localparam logic [1:0] __const__OP_ADD  = 2'd3;
  localparam logic [2:0] __const__OP_SUB  = 3'd4;
  localparam logic [2:0] __const__OP_JMPZ  = 3'd5;
  localparam logic [2:0] __const__OP_JMP  = 3'd6;
  Instruction__opcode_3__op1_3__op2_3__op3_3__unused_20 instruction;
  logic [2:0] pc;
  logic [31:0] registers [0:7];
  //-------------------------------------------------------------
  // Component imem
  //-------------------------------------------------------------

  logic [2:0] imem__addr;
  logic [0:0] imem__clk;
  logic [31:0] imem__data;
  logic [0:0] imem__reset;
  logic [31:0] imem__write_data;
  logic [0:0] imem__write_enable;

  Memory__mem_size_8 imem
  (
    .addr( imem__addr ),
    .clk( imem__clk ),
    .data( imem__data ),
    .reset( imem__reset ),
    .write_data( imem__write_data ),
    .write_enable( imem__write_enable )
  );

  //-------------------------------------------------------------
  // End of component imem
  //-------------------------------------------------------------

  // PyMTL Update Block Source
  // At /home/dakk/simplecpu_mtl.py:70
  // @update
  // def execute_instruction():
  //   #if s.instruction.opcode == OP_LOAD:
  //   #  s.registers[s.instruction.op1] @= mem[s.instruction.op2]
  // 
  //   #elif s.instruction.opcode == OP_STORE:
  //   #  mem[s.instruction.op1] = s.registers[s.instruction.op2]
  // 
  //   if s.instruction.opcode == OP_ADD:
  //     s.registers[s.instruction.op1] @= s.registers[s.instruction.op2] + s.registers[s.instruction.op3]
  // 
  //   elif s.instruction.opcode == OP_SUB:
  //     s.registers[s.instruction.op1] @= s.registers[s.instruction.op2] - s.registers[s.instruction.op3]
  // 
  //   elif s.instruction.opcode == OP_JMPZ:
  //     if s.registers[s.instruction.op1] == 0:
  //       s.pc @= s.instruction.op2
  // 
  //   elif s.instruction.opcode == OP_JMP:
  //     s.pc @= s.instruction.op1
  // 
  //   else:  # Increment the PC if it's not a jump
  //     s.pc @= s.pc + 1
  
  always_comb begin : execute_instruction
    if ( instruction.opcode == 3'( __const__OP_ADD ) ) begin
      registers[instruction.op1] = registers[instruction.op2] + registers[instruction.op3];
    end
    else if ( instruction.opcode == 3'( __const__OP_SUB ) ) begin
      registers[instruction.op1] = registers[instruction.op2] - registers[instruction.op3];
    end
    else if ( instruction.opcode == 3'( __const__OP_JMPZ ) ) begin
      if ( registers[instruction.op1] == 32'd0 ) begin
        pc = instruction.op2;
      end
    end
    else if ( instruction.opcode == 3'( __const__OP_JMP ) ) begin
      pc = instruction.op1;
    end
    else
      pc = pc + 3'd1;
  end

  // PyMTL Update Block Source
  // At /home/dakk/simplecpu_mtl.py:65
  // @update
  // def fetch_instruction():
  //   s.instruction @= s.imem.data
  
  always_comb begin : fetch_instruction
    instruction = imem__data;
  end

  assign imem__clk = clk;
  assign imem__reset = reset;
  assign imem__addr = pc;

endmodule
