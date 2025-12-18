/************************************************************************

 Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
 
 www.maven-silicon.com
 
 All Rights Reserved
   
 This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
 It is not to be shared with or used by any third parties who have not enrolled for our
 paid training courses or received any written authorization from Maven Silicon.

Filename:	ram_virtual_seqs.sv   

Version:	1.0

************************************************************************/
//------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------



//------------------------------------------------------------------------------
//
// SEQUENCE: Base RAM virtual sequence - base virtual sequence with objections from which 
// all virtual sequences can be derived
//
//------------------------------------------------------------------------------

  // Extend ram_vbase_seq from uvm_sequence parameterized by uvm_sequence_item;

class vbase_seq extends uvm_sequence #(uvm_sequence_item);

	
  // Factory registration
	`uvm_object_utils(vbase_seq)  
       wr_sequencer wr_seqrh;
  // LAB : Declare dynamic array of handles for ram_wr_sequencer and ram_rd_sequencer as wr_seqrh[] & rd_seqrh[]
        rd_sequencer rd_seqrh[];
  // Declare handle for virtual sequencer
        virtual_sequencer vsqrh;
  // Declare dynamic array of Handles for all the sequences

  // LAB :  Declare handle for ram_env_config
	env_config m_cfg; 

/*    smallseq seqrh;
  rd_xtns_seq rd_seq[];  */
//------------------------------------------
// METHODS
//------------------------------------------

// Standard UVM Methods:
/*  	extern function new(string name = "vbase_seq");
	extern task body(); */
	
//-----------------  constructor new method  -------------------//

// Add constructor 
	function new(string name ="vbase_seq");
		super.new(name);
	endfunction
//-----------------  task body() method  -------------------//
 task body();
    if(!uvm_config_db#(env_config)::get(null,get_full_name(),"env_config",m_cfg)) 
      
       `uvm_fatal(get_type_name(),"cannot get() m_cfg from uvm_config_db. Have you set() it?")
       
       
       rd_seqrh=new[m_cfg.no_of_read_agents];
  
       
    assert($cast(vsqrh,m_sequencer))
      else
        begin
      	`uvm_error("Body","Error in $cast of virtual sequencer")
        end
	 wr_seqrh = vsqrh.wr_seqrh;
     foreach(rd_seqrh[i])
	 begin
        rd_seqrh[i]=vsqrh.rd_seqrh[i];
		end
  endtask
endclass:vbase_seq
  
 // small pkt vseq
class router_small_pkt_vseq extends vbase_seq;
  `uvm_object_utils(router_small_pkt_vseq)
  bit[1:0]addr;
  
  router_wxtns_small_pkt wrtns;
 rd_xtns_seq  rdtns;
  
  function new(string name="router_small_pkt_vseq");
    super.new(name);
  endfunction
  
  task body();
    super.body();
    if(!uvm_config_db#(bit[1:0])::get(null,get_full_name(),"bit[1:0]",addr))
    `uvm_fatal(get_type_name(),"getting the configuration fails,check if it set properly")
 
    if(m_cfg.has_wagent)
      begin
       // `uvm_info("ABCD",$sformatf("has_wagent=%d",m_cfg.has_wagent),UVM_LOW)
        wrtns=router_wxtns_small_pkt::type_id::create("wrtns");
      end
    
  if(m_cfg.has_ragent)
    begin
      rdtns=rd_xtns_seq::type_id::create("rdtns");
    end
  
  fork 
    begin
      wrtns.start(wr_seqrh);
    end
    
    begin
      if(addr==2'b00)
        rdtns.start(rd_seqrh[0]);
      if(addr==2'b01)
        rdtns.start(rd_seqrh[1]);
      if(addr==2'b10)
        rdtns.start(rd_seqrh[2]);
    end
  join
  endtask
endclass:router_small_pkt_vseq
       
       
 
 // medium pkt vseq
class router_medium_pkt_vseq extends vbase_seq;
  `uvm_object_utils(router_medium_pkt_vseq)
  bit[1:0]addr;
  
  router_wxtns_medium_pkt wrtns;
 rd_xtns_seq  rdtns;
  
  function new(string name="router_medium_pkt_vseq");
    super.new(name);
  endfunction
  
  task body();
    super.body();
    if(!uvm_config_db#(bit[1:0])::get(null,get_full_name(),"bit[1:0]",addr))
    `uvm_fatal(get_type_name(),"getting the configuration fails,check if it set properly")
    
    if(m_cfg.has_wagent)
      begin
        wrtns=router_wxtns_medium_pkt::type_id::create("wrtns");
      end
    
  if(m_cfg.has_ragent)
    begin
    rdtns=rd_xtns_seq::type_id::create("rdtns");
  end
  
  fork 
    begin
      wrtns.start(wr_seqrh);
    end
    
    begin
      if(addr==2'b00)
        rdtns.start(rd_seqrh[0]);
      if(addr==2'b01)
        rdtns.start(rd_seqrh[1]);
      if(addr==2'b10)
        rdtns.start(rd_seqrh[2]);
    end
  join
  endtask
endclass:router_medium_pkt_vseq
       
//big packet
       
class router_big_pkt_vseq extends vbase_seq;
  `uvm_object_utils(router_big_pkt_vseq)
  bit[1:0]addr;
  
  router_wxtns_big_pkt wrtns;
 rd_xtns_seq  rdtns;
  
  function new(string name="router_big_pkt_vseq");
    super.new(name);
  endfunction
  
  task body();
    super.body();
  if(!uvm_config_db#(bit[1:0])::get(null,get_full_name(),"bit[1:0]",addr))
    `uvm_fatal(get_type_name(),"getting the configuration fails,check if it set properly")
    
    if(m_cfg.has_wagent)
      begin
        wrtns=router_wxtns_big_pkt::type_id::create("wrtns");
      end
    
  if(m_cfg.has_ragent)
    begin
    rdtns=rd_xtns_seq::type_id::create("rdtns");
  end
  
  fork 
    begin
      wrtns.start(wr_seqrh);
    end
    
    begin
      if(addr==2'b00)
        rdtns.start(rd_seqrh[0]);
      if(addr==2'b01)
        rdtns.start(rd_seqrh[1]);
      if(addr==2'b10)
        rdtns.start(rd_seqrh[2]);
    end
  join
  endtask
endclass:router_big_pkt_vseq
       
//Random test
       
class router_rndm_pkt_vseq extends vbase_seq;
  `uvm_object_utils(router_rndm_pkt_vseq)
  bit[1:0]addr;
  
  router_wxtns_rndm_pkt wrtns;
 rd_xtns_seq  rdtns;
  
  function new(string name="router_rndm_pkt_vseq");
    super.new(name);
  endfunction
  
  task body();
    super.body();
    if(!uvm_config_db#(bit[1:0])::get(null,get_full_name(),"bit[1:0]",addr))
    `uvm_fatal(get_type_name(),"getting the configuration fails,check if it set properly")
    
/*     if(m_cfg.has_wagent)
      begin
        wrtns=router_wxtns_rndm_pkt::type_id::create("wrtns");
      end */
    
  if(m_cfg.has_ragent)
    begin
    rdtns=rd_xtns_seq::type_id::create("rdtns");
  end
  
  fork 
    begin
      wrtns.start(wr_seqrh);
    end
    
    begin
      if(addr==2'b00)
        rdtns.start(rd_seqrh[0]);
      if(addr==2'b01)
        rdtns.start(rd_seqrh[1]);
      if(addr==2'b10)
        rdtns.start(rd_seqrh[2]);
    end
  join
  endtask
endclass:router_rndm_pkt_vseq

/* task vbase_seq::body();
 
	  if(!uvm_config_db #(env_config)::get(null,get_full_name(),"env_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
		
		
		rd_seqrh= new[m_cfg.no_of_read_agents];
assert($cast(vsqrh,m_sequencer)) else
	begin
		`uvm_error("BODY", "Error in $cast of virtual sequencer")
	end

		wr_seqrh = vsqrh.wr_seqrh;
	foreach(rd_seqrh[i])
		rd_seqrh[i] = vsqrh.rd_seqrh[i];
		
endtask: body

   
class seq_1 extends vbase_seq;
	`uvm_object_utils(seq_1)  



	extern function new(string name = "seq_1");
	extern task body();
endclass :seq_1
 
function seq_1::new(string name ="seq_1");
		super.new(name);
endfunction

task seq_1::body();
super.body();

seqrh= smallseq :: type_id :: create("seqrh");
rd_seq= new[m_cfg.no_of_read_agents];
foreach(rd_seq[i])
rd_seq[i]= rd_xtns_seq :: type_id :: create($sformatf("rd_seq[%0d]",i));
fork
seqrh.start(wr_seqrh);
fork
rd_seq[0].start(rd_seqrh[0]);
rd_seq[1].start(rd_seqrh[1]);
rd_seq[2].start(rd_seqrh[2]);
join
join
endtask */
