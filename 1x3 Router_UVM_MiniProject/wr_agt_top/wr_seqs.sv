/************************************************************************

 Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
 
 www.maven-silicon.com
 
 All Rights Reserved
   
 This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
 It is not to be shared with or used by any third parties who have not enrolled for our
 paid training courses or received any written authorization from Maven Silicon.

Filename:	ram_wr_seqs.sv   

Version:	1.0

************************************************************************/

//------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------

 
  // Extend ram_wbase_seq from uvm_sequence parameterized by write_xtn 
	class wbase_seq extends uvm_sequence #(write_xtn);  
	
  // Factory registration using `uvm_object_utils

	`uvm_object_utils(wbase_seq)  
//------------------------------------------
// METHODS
//------------------------------------------

// Standard UVM Methods:
        extern function new(string name ="wbase_seq");
	endclass
//-----------------  constructor new method  -------------------//
	function wbase_seq::new(string name ="wbase_seq");
		super.new(name);
	endfunction

class router_wxtns_small_pkt extends wbase_seq;
  `uvm_object_utils(router_wxtns_small_pkt)
  
  bit[1:0]addr;
  function new(string name = "router_wxtns_small_pkt");
    super.new(name);
  endfunction
  
  task body();
    
    if (!uvm_config_db#(bit[1:0])::get(null,get_full_name(),"bit[1:0]",addr))
      `uvm_fatal(get_type_name(),"getting the configuration faile,check if it set properly")
      
    req = write_xtn::type_id::create("req");
    start_item(req);
    
    assert(req.randomize() with {header[7:2] inside {[1:15]} && header[1:0]==addr;});
    
  //  `uvm_info("router_WR_SEQUENCE",$sformatf("printing from sequence \n %s",req.sprint()),UVM_HIGH)
    finish_item(req);
 
endtask
  
endclass : router_wxtns_small_pkt

//medium pkt

class router_wxtns_medium_pkt extends wbase_seq;
  `uvm_object_utils(router_wxtns_medium_pkt)
  
  bit[1:0]addr;
  function new(string name ="router_wxtns_medium_pkt");
    super.new(name);
  endfunction
  
  task body();
    
    if (!uvm_config_db#(bit[1:0])::get(null,get_full_name(),"bit[1:0]",addr))
      `uvm_fatal(get_type_name(),"getting the configuration faile,check if it set properly")
      
    req = write_xtn::type_id::create("req");
    start_item(req);
    
    assert(req.randomize() with {header[7:2] inside {[16:30]} && header[1:0]==addr;});
    
    `uvm_info("router_WR_SEQUENCE",$sformatf("printing from sequence \n %s",req.sprint()),UVM_HIGH)
    finish_item(req);
 
endtask
  
endclass : router_wxtns_medium_pkt

//big pkt

class router_wxtns_big_pkt extends wbase_seq;
  `uvm_object_utils(router_wxtns_big_pkt)
  
  bit[1:0]addr;
  function new(string name="router_wxtns_big_pkt");
    super.new(name);
  endfunction
  
  task body();
    
    if (!uvm_config_db#(bit[1:0])::get(null,get_full_name(),"bit[1:0]",addr))
      `uvm_fatal(get_type_name(),"getting the configuration faile,check if it set properly")
      
    req = write_xtn::type_id::create("req");
    start_item(req);
    
    assert(req.randomize() with {header[7:2] inside {[1:15]} && header[1:0]==addr;});
    
    `uvm_info("router_WR_SEQUENCE",$sformatf("printing from sequence \n %s",req.sprint()),UVM_HIGH)
    finish_item(req);
 
endtask
  
endclass : router_wxtns_big_pkt

//random pkt

class router_wxtns_rndm_pkt extends wbase_seq;
  `uvm_object_utils(router_wxtns_rndm_pkt)
  
  bit[1:0]addr;
  function new(string name="router_wxtns_rndm_pkt");
    super.new(name);
  endfunction
  
  task body();
    
    if (!uvm_config_db#(bit[1:0])::get(null,get_full_name(),"bit[1:0]",addr))
      `uvm_fatal(get_type_name(),"getting the configuration file,check if it set properly")
      
    req = write_xtn::type_id::create("req");
    start_item(req);  
    assert(req.randomize() with {header[1:0]==addr;});
    
    `uvm_info("router_WR_SEQUENCE",$sformatf("printing from sequence \n %s",req.sprint()),UVM_HIGH)
    finish_item(req);
 endtask
  
endclass : router_wxtns_rndm_pkt

/* //------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------


  // Extend ram_single_addr_wr_xtns from ram_wbase_seq;
	class sequence1 extends wbase_seq;

  	
  // Factory registration using `uvm_object_utils
  	`uvm_object_utils(sequence1)

//------------------------------------------
// METHODS
//------------------------------i------------

// Standard UVM Methods:
        extern function new(string name ="sequence1");
        extern task body();
	endclass
//-----------------  constructor new method  -------------------//
	function sequence1::new(string name = "sequence1");
		super.new(name);
	endfunction

	  
//-----------------  task body method  -------------------//
      // Generate 10 sequence items with address always equal to 55
      // Hint use create req, start item, assert for randomization with in line
      //  constraint (with) finish item inside repeat's begin end block 
	
	task sequence1::body();
     

           $display("-------------------------------------------------------SEQUENCE-------");
   	   req= write_xtn :: type_id :: create("req");
	// repeat(1)
	//begin	
	   start_item(req);
   	   assert(req.randomize() with {header[7:2] < 4'd15;} );
	   	   finish_item(req);
	          $display("-------------------------------------------------------SEQUENCE-------");

	 //end 
    	endtask
 */

/* //------------------------------------------
// SEQUENCE: Small Address Range (1 to 15)
//------------------------------------------
class smallseq extends wbase_seq;
  `uvm_object_utils(smallseq)

  extern function new(string name = "smallseq");
  extern task body();
endclass

function smallseq::new(string name = "smallseq");
  super.new(name);
endfunction

task smallseq::body();
  $display("------------- smallseq BODY START -------------");

  req = write_xtn::type_id::create("req");
  
  begin
    start_item(req);
    assert(req.randomize() with { header[7:2] inside {[1:15]}; });
    finish_item(req);
  end

  $display("------------- smallseq BODY END -------------");
endtask


//------------------------------------------
// SEQUENCE: Medium Address Range (16 to 30)
//------------------------------------------
class mediumseq extends wbase_seq;
  `uvm_object_utils(mediumseq)

  extern function new(string name = "mediumseq");
  extern task body();
endclass

function mediumseq::new(string name = "mediumseq");
  super.new(name);
endfunction

task mediumseq::body();
  $display("------------- mediumseq BODY START -------------");

   begin
    req = write_xtn::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { header[7:2] inside {[16:30]}; });
    finish_item(req);
  end

  $display("------------- mediumseq BODY END -------------");
endtask


//------------------------------------------
// SEQUENCE: Large Address Range (31 to 63)
//------------------------------------------
class largeseq extends wbase_seq;
  `uvm_object_utils(largeseq)

  extern function new(string name = "largeseq");
  extern task body();
endclass

function largeseq::new(string name = "largeseq");
  super.new(name);
endfunction

task largeseq::body();
  $display("------------- largeseq BODY START -------------");

	begin
    req = write_xtn::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { header[7:2] inside {[31:63]}; });
    finish_item(req);
  end

  $display("------------- largeseq BODY END -------------");
endtask
 */
