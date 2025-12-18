/************************************************************************

 Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
 
 www.maven-silicon.com
 
 All Rights Reserved
   
 This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
 It is not to be shared with or used by any third parties who have not enrolled for our
 paid training courses or received any written authorization from Maven Silicon.

Filename:	ram_env.sv   

Version:	1.0

************************************************************************/
//------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------
// Extend ram_env from uvm_env
class env extends uvm_env;

  // Factory Registration
  `uvm_component_utils(env)

  // LAB : Declare dynamic array of handles for ram_wr_agt_top, ram_rd_agt_top as wagt_top, ragt_top respectively
  wr_agt_top wagt_top;
  rd_agt_top ragt_top;

  // Declare handle for ram_virtual_sequencer as v_sequencer
  virtual_sequencer v_sequencer;

  // LAB : Declare dynamic array of handles for ram scoreboard as sb
  scoreboard sb;

  // Declare handle for env configuration object as m_cfg
  env_config m_cfg;

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "env", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass : env

//-----------------  constructor new method  -------------------//
function env::new(string name = "env", uvm_component parent);
  super.new(name, parent);
endfunction

//-----------------  build phase method  -------------------//
function void env::build_phase(uvm_phase phase);

  if (!uvm_config_db #(env_config)::get(this, "", "env_config", m_cfg)) begin
    `uvm_fatal("CONFIG", "cannot get() m_cfg from uvm_config_db. Have you set() it?")
  end

  if (m_cfg.has_wagent) begin
    wagt_top = wr_agt_top::type_id::create("wagt_top", this);
  end

  if (m_cfg.has_ragent) begin
    ragt_top = rd_agt_top::type_id::create("ragt_top", this);
  end

  super.build_phase(phase);

  if (m_cfg.has_virtual_sequencer) begin
    v_sequencer = virtual_sequencer::type_id::create("v_sequencer", this);
  end

  if (m_cfg.has_scoreboard) begin
    sb = scoreboard::type_id::create("sb", this);
  end

endfunction

//-----------------  connect phase method  -------------------//
function void env::connect_phase(uvm_phase phase);

  if (m_cfg.has_virtual_sequencer) begin

    if (m_cfg.has_wagent) begin
      v_sequencer.wr_seqrh = wagt_top.agnth.m_sequencer;
    end

    if (m_cfg.has_ragent) begin
      v_sequencer.rd_seqrh = new[3];
      for (int i = 0; i < m_cfg.no_of_read_agents; i++) begin
        v_sequencer.rd_seqrh[i] = ragt_top.agnth[i].m_sequencer;
      end
    end

  end

  if (m_cfg.has_scoreboard) begin
    wagt_top.agnth.monh.monitor_port.connect(sb.fifo_wrh.analysis_export);
    foreach (ragt_top.agnth[i]) begin
      ragt_top.agnth[i].monh.monitor_port.connect(sb.fifo_rdh[i].analysis_export);
    end
  end

endfunction


					      
			
