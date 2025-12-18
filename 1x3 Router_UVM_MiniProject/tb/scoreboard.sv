/************************************************************************

 Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
 
 www.maven-silicon.com
 
 All Rights Reserved
   
 This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
 It is not to be shared with or used by any third parties who have not enrolled for our
 paid training courses or received any written authorization from Maven Silicon.

Filename:	ram_sb.sv   

Version:	1.0

************************************************************************/
//------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------


	// Extend ram_scoreboard from uvm_scoreboard

	class scoreboard extends uvm_scoreboard;
 `uvm_component_utils(scoreboard)

    uvm_tlm_analysis_fifo #(write_xtn) fifo_wrh;   	
	uvm_tlm_analysis_fifo #(read_xtn) fifo_rdh[];
       
	int data_verified_count;
    env_config m_cfg;

    write_xtn wr_data;
    read_xtn  rd_data;
	read_xtn read_cov_data;
	write_xtn write_cov_data;
  
  covergroup router_fcov1;
    option.per_instance=1;
    
    CHANNEL:coverpoint write_cov_data.header[1:0]
    {
      bins low = {2'b00};
      bins mid1= {2'b01};
      bins mid2= {2'b10};
    }
    PAYLOAD_SIZE : coverpoint write_cov_data.header[7:2]
    {
      bins small_packet = {[1:15]};
      bins medium_packet = {[16:30]};
      bins large_packet = {[31:63]};
    }
    
    BAD_PKT : coverpoint write_cov_data.err
    {
      bins bad_pkt = {1};
    }
    
    CHANNEL_X_PAYLOAD_SIZE : cross CHANNEL,PAYLOAD_SIZE;
    CHANNEL_X_PAYLOAD_SIZE_X_BAD_PKT : cross CHANNEL, PAYLOAD_SIZE,BAD_PKT;
    
  endgroup :router_fcov1
  
 covergroup router_fcov2;
    option.per_instance=1;
    
    CHANNEL:coverpoint read_cov_data.header[1:0]
    {
      bins low = {2'b00};
      bins mid1= {2'b01};
      bins mid2= {2'b10};
    }
    PAYLOAD_SIZE : coverpoint read_cov_data.header[7:2]
    {
      bins small_packet = {[1:15]};
      bins medium_packet = {[16:30]};
      bins large_packet = {[31:63]};
    }
   
    CHANNEL_X_PAYLOAD_SIZE : cross CHANNEL,PAYLOAD_SIZE;
   
  endgroup :router_fcov2 


//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name="scoreboard",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void check_data(read_xtn rd_data);
extern function void report_phase(uvm_phase phase);

endclass


function scoreboard::new(string name ="scoreboard" ,uvm_component parent);
	super.new(name,parent);
    router_fcov1=new();
    router_fcov2=new();
endfunction
		


function void scoreboard::build_phase(uvm_phase phase);   
	super.build_phase(phase);
	if(!uvm_config_db #(env_config)::get(this,"","env_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
	wr_data=write_xtn::type_id::create("wr_data");
	rd_data=read_xtn::type_id::create("rd_data");
 
	fifo_wrh= new("fifo_wrh",this);
	fifo_rdh= new[m_cfg.no_of_read_agents];       
    foreach(fifo_rdh[i])
	begin
		fifo_rdh[i]= new($sformatf("fifo_rdh[%0d]",i),this);
	end
	 
endfunction: build_phase   

			
task scoreboard :: run_phase(uvm_phase phase);
	fork
		begin
			forever
			begin
				fifo_wrh.get(wr_data);
				`uvm_info("WRITE_SB","write data",UVM_LOW)
				wr_data.print;
				write_cov_data=wr_data;
				router_fcov1.sample();
			end
		end
	
		begin
			forever
			begin	
				fork:A
					begin
						fifo_rdh[0].get(rd_data);
							`uvm_info("READ_SB[0]","read_data",UVM_LOW)
						rd_data.print;
						check_data(rd_data);
						read_cov_data=rd_data;
						router_fcov2.sample();
					end
					
					begin
						fifo_rdh[1].get(rd_data);
							`uvm_info("READ_SB[1]","read_data",UVM_LOW)
						rd_data.print;
						check_data(rd_data);
						read_cov_data=rd_data;
						router_fcov2.sample();
					end
					
					begin
						fifo_rdh[2].get(rd_data);
							`uvm_info("READ_SB[2]","read_data",UVM_LOW)
						rd_data.print;
						check_data(rd_data);
						read_cov_data=rd_data;
						router_fcov2.sample();
					end
				join_any
				disable A;
			end
		end
	join
endtask

function void  scoreboard :: check_data(read_xtn rd_data);
	if(wr_data.header == rd_data.header)
		`uvm_info("SB","HEADER IS MATCHED",UVM_LOW)
	else
		`uvm_error("SB","HEADER COMPARISION FAILED")
	if(wr_data.payload == rd_data.payload)
		`uvm_info("SB","PAYLOAD IS MATCHED",UVM_LOW)
	else
		`uvm_error("SB","PAYLOAD COMPARISION FAILED")	
	if(wr_data.parity == rd_data.parity)
		`uvm_info("SB","PARITY IS MATCHED",UVM_LOW)
	else
		`uvm_error("SB","PARITY COMPARISION FAILED")	
		data_verified_count++;
endfunction
	
	


 function void scoreboard::report_phase(uvm_phase phase);
   // Displays the final report of test using scoreboard stistics
   `uvm_info(get_type_name(),$sformatf("Report:Number of data verified in SB %0d",data_verified_count), UVM_LOW)
 endfunction 







      

   
