`timescale 1ns/10ps
`define CYCLE 10.0 // Cycle time
`define MAX 600000000000 // Max cycle number
`ifdef SYN
`include "top_syn.v"
`include "data_array/data_array.v"
`include "tag_array/tag_array.v"
`include "sram_1024/sram_1024.v"
`include "SRAM/SRAM.v"
`timescale 1ns/10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib"
`elsif PR
`include "top_pr.v"
`include "SRAM/SRAM.v"
`include "sram_1024/sram_1024.v"
`include "data_array/data_array.v"
`include "tag_array/tag_array.v"
`timescale 1ns/10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib"
`else
`include "top.sv"
`include "SRAM/SRAM_rtl.sv"
`include "sram_1024/sram_1024_rtl.sv"
`include "data_array/data_array_rtl.sv"
`include "tag_array/tag_array_rtl.sv"
`endif
`timescale 1ns/10ps
`include "ROM/ROM.v"
`include "DRAM/DRAM.sv"
`define mem_word(addr) \
  {TOP.DM1.i_SRAM.Memory_byte3[addr], \
   TOP.DM1.i_SRAM.Memory_byte2[addr], \
   TOP.DM1.i_SRAM.Memory_byte1[addr], \
   TOP.DM1.i_SRAM.Memory_byte0[addr]}
  
`define imem_word(addr) \
  {TOP.IM1.i_SRAM.Memory_byte3[addr], \
   TOP.IM1.i_SRAM.Memory_byte2[addr], \
   TOP.IM1.i_SRAM.Memory_byte1[addr], \
   TOP.IM1.i_SRAM.Memory_byte0[addr]}
`define rom_word(addr) \
  {i_ROM.Memory_byte3[addr], \
   i_ROM.Memory_byte2[addr], \
   i_ROM.Memory_byte1[addr], \
   i_ROM.Memory_byte0[addr]}


  
`define dram_word(addr) \
  {i_DRAM.Memory_byte3[addr], \
   i_DRAM.Memory_byte2[addr], \
   i_DRAM.Memory_byte1[addr], \
   i_DRAM.Memory_byte0[addr]}
`define SIM_END 'h3fff
`define SIM_END_CODE -32'd1
`define TEST_START 'h4_8400
module top_tb_final;

  logic clk;
  logic rst;
  logic [31:0] GOLDEN[6];
  logic [7:0] Memory_byte0[32768];
  logic [7:0] Memory_byte1[32768];
  logic [7:0] Memory_byte2[32768];
  logic [7:0] Memory_byte3[32768];
  //HW4
  logic [31:0] ROM_out;
  logic sensor_ready;
  logic [31:0] sensor_out;
  logic [31:0] DRAM_Q;
  logic ROM_enable;
  logic ROM_read;
  logic [31:0] ROM_address;
  logic sensor_en;
  logic DRAM_CSn;
  logic [3:0]DRAM_WEn;
  logic DRAM_RASn;
  logic DRAM_CASn;
  logic [10:0] DRAM_A;
  logic [31:0] DRAM_D;
  logic DRAM_valid;  
 
  logic [31:0] sensor_mem [0:511];  
  logic [8:0] sensor_counter;
  logic [9:0] data_counter;  
  //HW4
  integer gf, i, num, counter, feature_temp, gt;
  logic [31:0] temp;
  integer err;
  string prog_path;
  string pattern_path;
  always #(`CYCLE/2) clk = ~clk;
 

  top TOP(
    .clk(clk),
    .rst(rst),
    .ROM_out(ROM_out),
    .sensor_ready(sensor_ready),
    .sensor_out(sensor_out),
    .DRAM_Q(DRAM_Q),
	.DRAM_valid(DRAM_valid),
    .ROM_read(ROM_read),
    .ROM_enable(ROM_enable),
    .ROM_address(ROM_address),
    .sensor_en(sensor_en),
    .DRAM_CSn(DRAM_CSn),
    .DRAM_WEn(DRAM_WEn),
    .DRAM_RASn(DRAM_RASn),
    .DRAM_CASn(DRAM_CASn),
    .DRAM_A(DRAM_A),
    .DRAM_D(DRAM_D)	
  );

  
  ROM i_ROM(
    .CK(clk),
    .CS(ROM_enable),
    .OE(ROM_read),
    .A(ROM_address[11:0]),
    .DO(ROM_out)
  );  
  
   DRAM i_DRAM(
    .CK(clk), 
    .Q(DRAM_Q),
    .RST(rst),
    .CSn(DRAM_CSn),
    .WEn(DRAM_WEn),
    .RASn(DRAM_RASn),
    .CASn(DRAM_CASn),
    .A(DRAM_A),
    .D(DRAM_D),
	.VALID(DRAM_valid)
  ); 
  
  
  
  initial
  begin
    $value$plusargs("prog_path=%s", prog_path);
//////////////////////////////////////////////////////////////////////
    pattern_path = "/test_pattern/seq6";
//////////////////////////////////////////////////////////////////////
    clk = 0; rst = 1; sensor_counter = 0; data_counter = 0;
    #(`CYCLE) rst = 0;
    $readmemh({prog_path, "/rom0.hex"}, i_ROM.Memory_byte0);
    $readmemh({prog_path, "/rom1.hex"}, i_ROM.Memory_byte1);
    $readmemh({prog_path, "/rom2.hex"}, i_ROM.Memory_byte2);
    $readmemh({prog_path, "/rom3.hex"}, i_ROM.Memory_byte3);
    $readmemh({prog_path, "/dram0.hex"}, i_DRAM.Memory_byte0);
    $readmemh({prog_path, "/dram1.hex"}, i_DRAM.Memory_byte1);
    $readmemh({prog_path, "/dram2.hex"}, i_DRAM.Memory_byte2);
    $readmemh({prog_path, "/dram3.hex"}, i_DRAM.Memory_byte3);
    $readmemh({prog_path, pattern_path, "/frame_byte0.hex"}, i_DRAM.Memory_byte0,'h0004_0400);
    $readmemh({prog_path, pattern_path, "/frame_byte1.hex"}, i_DRAM.Memory_byte1,'h0004_0400);
    $readmemh({prog_path, pattern_path, "/frame_byte2.hex"}, i_DRAM.Memory_byte2,'h0004_0400);
    $readmemh({prog_path, pattern_path, "/frame_byte3.hex"}, i_DRAM.Memory_byte3,'h0004_0400);

    num = 0;
    gf = $fopen({prog_path, pattern_path, "/answer.txt"}, "r");
    while (!$feof(gf))
    begin
      $fscanf(gf, "%d\n", GOLDEN[num]);
      num++;
    end
    $fclose(gf);

    while (1)
    begin
      #(`CYCLE)
      if (`mem_word(`SIM_END) == `SIM_END_CODE)
      begin
        break; 
      end
    end	
    $display("\nDone\n");
	for(i = 0; i < 3; i++)begin
		$display("X[%4d] = %d, GOLDEN = %d", i, `dram_word('h7ffc0 + 2*i), GOLDEN[2*i]);
		$display("Y[%4d] = %d, GOLDEN = %d", i, `dram_word('h7ffc0 + 2*i + 1), GOLDEN[2*i + 1]);
	end
    err = 0;
	$display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  Congratulations !!    **      / O.O  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("\n");
    $finish;
  end

  `ifdef SYN
  initial $sdf_annotate("top_syn.sdf", TOP);
  `elsif PR
  initial $sdf_annotate("top_pr.sdf", TOP);
  `endif

  initial
  begin
    `ifdef FSDB
    $fsdbDumpfile("top.fsdb");
    //$fsdbDumpvars(0, TOP);
    $fsdbDumpvars;
    `elsif FSDB_ALL
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars("+struct", "+mda", TOP);
    `endif
    #(`CYCLE*`MAX)
    //for (i = 0; i < 2048; i++)
    //begin
    //    $display("DRAM[%4h] = %h", `TEST_START + i, `dram_word(`TEST_START + i));
	//$fwrite(img_debug,"%b\n",`dram_word(`TEST_START + i));
    //end
	/*
	for (i = 0; i < 18; i++)
    begin
		$display("x[%4d] = %h, y[%4d] = %h", i, `dram_word(i + 'hf0000), i, `dram_word(i + 'hf0000 + 1));
    end
	*/
	
	
	
	$display("IM[%4d] = %h", 'h4b4, `imem_word('h4b4));
	$display("DRAM[%4d] = %h", 'h4b4, `dram_word('h4b4));
	
    $finish;
  end
  
  task result;
    input integer err;
    input integer num;
    integer rf;
    begin
      `ifdef SYN
			rf = $fopen({prog_path, "/result_syn.txt"}, "w");
      `elsif PR
			rf = $fopen({prog_path, "/result_pr.txt"}, "w");
      `else
			rf = $fopen({prog_path, "/result_rtl.txt"}, "w");
      `endif
      $fdisplay(rf, "%d,%d", num - err, num);
      if (err === 0)
      begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  Congratulations !!    **      / O.O  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("\n");
      end
      else
      begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  OOPS!!                **      / X,X  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation Failed!!   **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("         Totally has %d errors                     ", err); 
        $display("\n");
      end


      $display("counter : %h \n data_1 %h \n", `dram_word('h0005_0000), `dram_word('h0005_4000)); 
	

    end
  endtask

endmodule


