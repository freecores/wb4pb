////////////////////////////////////////////////////////////////////////////////
// This sourcecode is released under BSD license.
// Please see http://www.opensource.org/licenses/bsd-license.php for details!
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2011, Stefan Fischer <Ste.Fis@OpenCores.org>
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution. 
//  * Neither the name of the author nor the names of his contributors may be 
//    used to endorse or promote products derived from this software without 
//    specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
//
////////////////////////////////////////////////////////////////////////////////
// filename: avnet_sp3a_eval_gpio_vlog.v
// description: synthesizable PicoBlaze (TM) general purpose i/o example using 
//              wishbone / AVNET (R) Sp3A-Eval-Kit version
// todo4user: add other modules as needed
// version: 0.0.0
// changelog: - 0.0.0, initial release
//            - ...
////////////////////////////////////////////////////////////////////////////////


module avnet_sp3a_eval_gpio_vlog (
  FPGA_RESET,
  CLK_16MHZ,
  
  FPGA_PUSH_A,
  FPGA_PUSH_B,
  FPGA_PUSH_C,
  
  LED1,
  LED2,
  LED3,
  LED4
);

  input FPGA_RESET;
  wire  FPGA_RESET;
  input CLK_16MHZ;
  wire  CLK_16MHZ;
  
  input FPGA_PUSH_A;
  wire  FPGA_PUSH_A;
  input FPGA_PUSH_B;
  wire  FPGA_PUSH_B;
  input FPGA_PUSH_C;
  wire  FPGA_PUSH_C;
  
  output LED1;
  wire   LED1;
  output LED2;
  wire   LED2;
  output LED3;
  wire   LED3;
  output LED4;
  wire   LED4;
  
  reg rst;
  wire clk;
  
  wire wb_cyc;
  wire wb_stb;
  wire wb_we;
  wire[7:0] wb_adr;
  wire[7:0] wb_dat_m2s;
  wire[7:0] wb_dat_s2m;
  wire wb_ack;
  
  wire pb_write_strobe;
  wire pb_read_strobe;
  wire[7:0] pb_port_id;
  wire[7:0] pb_in_port;
  wire[7:0] pb_out_port;
  
  wire[17:0] instruction;
  wire[9:0] address;
  
  wire interrupt;
  wire interrupt_ack;
  
  wire[7:0] gpio_in;
  wire[7:0] gpio_out;
  wire[7:0] gpio_oe;
  
  reg[23:0] timer;
  
  // reset synchronisation
  always@(posedge clk)
    rst <= FPGA_RESET;
  assign clk = CLK_16MHZ;
  
  // module instances
  ///////////////////
    
  kcpsm3 inst_kcpsm3 (
    .address(address),
    .instruction(instruction),
    .port_id(pb_port_id),
    .write_strobe(pb_write_strobe),
    .out_port(pb_out_port),
    .read_strobe(pb_read_strobe),
    .in_port(pb_in_port),
    .interrupt(interrupt),
    .interrupt_ack(interrupt_ack),
    .reset(rst),
    .clk(clk)
  );

  pbwbgpio inst_pbwbgpio (
    .address(address),
    .instruction(instruction),
    .clk(clk)
  );

  wbm_picoblaze inst_wbm_picoblaze (
    .rst(rst),
    .clk(clk),
    
    .wbm_cyc_o(wb_cyc),
    .wbm_stb_o(wb_stb),
    .wbm_we_o(wb_we),
    .wbm_adr_o(wb_adr),
    .wbm_dat_m2s_o(wb_dat_m2s),
    .wbm_dat_s2m_i(wb_dat_s2m),
    .wbm_ack_i(wb_ack),
    
    .pb_port_id_i(pb_port_id),
    .pb_write_strobe_i(pb_write_strobe),
    .pb_out_port_i(pb_out_port),
    .pb_read_strobe_i(pb_read_strobe),
    .pb_in_port_o(pb_in_port)
  );

  wbs_gpio inst_wbs_gpio (
    .rst(rst),
    .clk(clk),
    
    .wbs_cyc_i(wb_cyc),
    .wbs_stb_i(wb_stb),
    .wbs_we_i(wb_we),
    .wbs_adr_i(wb_adr),
    .wbs_dat_m2s_i(wb_dat_m2s),
    .wbs_dat_s2m_o(wb_dat_s2m),
    .wbs_ack_o(wb_ack),
    
    .gpio_in_i(gpio_in),
    .gpio_out_o(gpio_out),
    .gpio_oe_o(gpio_oe)
  );
  
  // i/o buffer generation
  
  assign gpio_in = {
    1'b0,
    FPGA_PUSH_C,
    FPGA_PUSH_B,
    FPGA_PUSH_A,
    {4{1'b0}}
  };
  
  assign LED1 = gpio_out[0];
  assign LED2 = gpio_out[1];
  assign LED3 = gpio_out[2];
  assign LED4 = timer[23];
  
  always@(posedge clk) begin : led_blinker
    timer <= timer + 1;
    if (rst)
      timer <= {24{1'b0}};
  end
  
endmodule
