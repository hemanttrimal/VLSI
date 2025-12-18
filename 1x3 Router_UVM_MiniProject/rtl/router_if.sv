interface router_if(input bit clk);

logic [7:0 ]data_in;
logic [7:0] data_out;
logic resetn;
logic err;
logic busy;
bit read_enb;
logic vld_out;
logic pkt_valid;

clocking write_driver_cb@(posedge clk);
	default input#1 output  #1;
	output pkt_valid;
	output  data_in;
	output resetn;
	input busy;
	input err;
endclocking

clocking write_monitor_cb@(posedge clk);
	default input#1 output  #1;
	input pkt_valid;
	input  data_in;
	input resetn;
	input busy;
	input err;
endclocking

clocking read_monitor_cb@(posedge clk);
	default input#1 output  #1;
	input  data_out;
	input vld_out;
	input read_enb;
endclocking

clocking read_driver_cb@(posedge clk);
	default input#1 output  #1;
	output read_enb;
	input vld_out;
endclocking

modport WDR_MP(clocking write_driver_cb);
modport WMON_MP(clocking write_monitor_cb);
modport RDR_MP(clocking read_driver_cb);
modport RMON_MP(clocking read_monitor_cb);

endinterface :router_if

	 
