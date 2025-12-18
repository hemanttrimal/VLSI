/************************************************************************

 Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
 
 www.maven-silicon.com
 
 All Rights Reserved
   
 This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
 It is not to be shared with or used by any third parties who have not enrolled for our
 paid training courses or received any written authorization from Maven Silicon.

Filename:	ram_rd_monitor.sv   

Version:	1.0

************************************************************************/
//------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------

   // Extend ram_rd_monitor from uvm_monitor
	class rd_monitor extends uvm_monitor;

  // Factory Registration
	`uvm_component_utils(rd_monitor)

  // Declare virtual interface handle with RMON_MP as modport
   	virtual router_if.RMON_MP vif;

  // Declare the ram_wr_agent_config handle as "m_cfg"
        rd_agent_config m_cfg;

  // Analysis TLM port to connect the monitor to the scoreboard for lab09
  uvm_analysis_port #(read_xtn) monitor_port;

//------------------------------------------
// METHODS
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "rd_monitor", uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task collect_data();
//extern function void report_phase(uvm_phase phase);


endclass 

//-----------------  constructor new method  -------------------//
 
 function rd_monitor::new (string name = "rd_monitor", uvm_component parent);
    super.new(name, parent);
// create object for handle monitor_port using new
    monitor_port = new("monitor_port", this);
  endfunction : new

//-----------------  build() phase method  -------------------//
 	function void rd_monitor::build_phase(uvm_phase phase);
	// call super.build_phase(phase);
          super.build_phase(phase);        
	// get the config object using uvm_config_db                  
	  if(!uvm_config_db #(rd_agent_config)::get(this,"","rd_agent_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
        endfunction

//-----------------  connect() phase method  -------------------//
	// in connect phase assign the configuration object's virtual interface
	// to the monitor's virtual interface instance(handle --> "vif")
     	function void rd_monitor::connect_phase(uvm_phase phase);         
          vif = m_cfg.vif;
        endfunction

//-----------------  run_phase()method  -------------------//
      task rd_monitor::run_phase(uvm_phase phase);
       forever
		begin
        // Call collect data task
       collect_data(); 
	   end
       endtask

task rd_monitor::collect_data();
  read_xtn xtn1;
  xtn1 = read_xtn::type_id::create("xtn1");
  // Wait for read_enb to be asserted before sampling header
  while (!vif.read_monitor_cb.read_enb)
  @(vif.read_monitor_cb);
  xtn1.header = vif.read_monitor_cb.data_out;
  // Payload size from header[7:2]
  xtn1.payload = new[xtn1.header[7:2]];
  // Optional: Wait 1 cycle before reading payload (aligns with some protocols)
  @(vif.read_monitor_cb);
  // Loop to capture payload
  foreach (xtn1.payload[i]) 
  begin
    while (!vif.read_monitor_cb.read_enb)
      @(vif.read_monitor_cb);
    xtn1.payload[i] = vif.read_monitor_cb.data_out;
    //$display("Read Payload[%0d] = %0d", i, xtn1.payload[i]);
	@(vif.read_monitor_cb);
  end
  xtn1.parity = vif.read_monitor_cb.data_out;
  `uvm_info("FROM READ MON", $sformatf("printing from Read Monitor \n%s", xtn1.sprint()), UVM_LOW)
  monitor_port.write(xtn1);
endtask

     
  


