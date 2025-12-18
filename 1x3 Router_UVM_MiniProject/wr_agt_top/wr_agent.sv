//------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------
// Extend ram_wr_agent from uvm_agent
class wr_agent extends uvm_agent;

  // Factory Registration
  `uvm_component_utils(wr_agent)

  // Declare handle for configuration object
  wr_agent_config m_cfg;
  wr_agent_config w_cfg;

  // Declare handles for ram_wr_monitor, ram_wr_sequencer, and ram_wr_driver
  wr_monitor   monh;
  wr_sequencer m_sequencer;
  wr_driver    drvh;

  //------------------------------------------
  // METHODS
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "wr_agent", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass : wr_agent

//-----------------  Constructor new method  -------------------//
function wr_agent::new(string name = "wr_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

//-----------------  build_phase method  -------------------//
// Call parent build_phase
// Create ram_wr_monitor instance
// If is_active == UVM_ACTIVE, create ram_wr_driver and ram_wr_sequencer instances
function void wr_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if (!uvm_config_db #(wr_agent_config)::get(this, "", "wr_agent_config", w_cfg)) begin
    `uvm_fatal("CONFIG", "cannot get() w_cfg from uvm_config_db. Have you set() it?")
  end

  monh = wr_monitor::type_id::create("monh", this);

  if (w_cfg.is_active == UVM_ACTIVE) begin
    drvh       = wr_driver::type_id::create("drvh", this);
    m_sequencer = wr_sequencer::type_id::create("m_sequencer", this);
  end
endfunction

//-----------------  connect_phase method  -------------------//
// If is_active == UVM_ACTIVE, connect driver (seq_item_port) to sequencer (seq_item_export)
function void wr_agent::connect_phase(uvm_phase phase);
  if (w_cfg.is_active == UVM_ACTIVE) begin
    drvh.seq_item_port.connect(m_sequencer.seq_item_export);
  end
endfunction

   

   


