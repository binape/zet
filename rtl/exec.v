`timescale 1ns/10ps

`include "defines.v"

module exec(ir, off, imm, cs, a, clk, rst,
            memout, wr_data, addr, we, m_io, byteop);
  // IO Ports
  input [`IR_SIZE-1:0] ir;
  input [15:0] off, imm;
  input        clk;
  input        rst;
  input [15:0] memout;

  output [15:0] wr_data, a;
  output        we, m_io, byteop;
  output [19:0] addr;
  output [15:0] cs;

  // Net declarations
  wire [15:0] b, c, flags, s, oflags, omemalu, bus_b;
  wire [31:0] aluout;
  wire [3:0]  addr_a, addr_b, addr_c, addr_d;
  wire [2:0]  t, func;
  wire [1:0]  addr_s;
  wire        wrfl, high, wr_mem, memalu, a_byte, c_byte;
  wire        wr, wr_reg;
  wire        wr_cnd;
  wire        jmp;

  // Module instances
  alu     alu0( {c, a}, bus_b, aluout, t, func, flags, oflags, ~byteop, s, off);
  regfile reg0( a, b, c, cs, {aluout[31:16], omemalu}, s, flags, wr_reg, wrfl,
                high, clk, rst, addr_a, addr_b, addr_c, addr_d, addr_s, oflags,
                ~byteop, a_byte, c_byte);
  jmp_cond jc0( flags, addr_b, addr_c[0], c, jmp);  

  // Assignments
  assign addr_s = ir[1:0];
  assign addr_a = ir[5:2];
  assign addr_b = ir[9:6];
  assign addr_c = ir[13:10];
  assign addr_d = ir[17:14];
  assign wrfl   = ir[18];
  assign wr_mem = ir[19];
  assign wr     = ir[20];
  assign wr_cnd = ir[21]; 
  assign high   = ir[22];
  assign t      = ir[25:23];
  assign func   = ir[28:26];
  assign byteop = ir[29];
  assign memalu = ir[30];
  assign m_io   = ir[31];
  assign b_imm  = ir[32];
  assign a_byte = ir[33];
  assign c_byte = ir[34];

  assign omemalu = memalu ? aluout[15:0] : memout;
  assign bus_b   = b_imm ? imm : b;

  assign we = ~wr_mem;
  assign addr = aluout[19:0];
  assign wr_data = c;
  assign wr_reg = wr | (jmp & wr_cnd);
endmodule
