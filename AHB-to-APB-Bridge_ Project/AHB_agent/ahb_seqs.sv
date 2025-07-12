
class ahb_seq extends uvm_sequence #(ahb_xtn);
	`uvm_object_utils(ahb_seq)
	
	bit [31:0] haddr;
	bit hwrite;
	bit [2:0] hsize;
	bit [2:0] hburst;

	extern function new(string name = "ahb_seq");

endclass

//constructor
function ahb_seq::new(string name = "ahb_seq");
	super.new(name);
endfunction

//single transfer
class single_seq extends ahb_seq;

	`uvm_object_utils(single_seq)

	extern function new(string name = "single_seq");
	extern task body(); 

endclass

//constructor
function single_seq::new(string name = "single_seq");
	super.new(name);
endfunction

//body
task single_seq::body();
 repeat(10)
  req = ahb_xtn::type_id::create("req");
  start_item(req);
  assert(req.randomize() with { Htrans == 2'b10;Hburst == 3'b000;Hwrite == 1;});
  finish_item(req);
endtask

class burst_seq extends ahb_seq;

  `uvm_object_utils(burst_seq)
 
  extern function new(string name = "burst_seq");
  extern task body();

endclass

function burst_seq::new(string name = "burst_seq");
  super.new(name);
endfunction

task burst_seq::body();
  
  int beat_size;
  int total_beats;
  int wrap_mask;
  bit is_wrap;
  bit [31:0] next_addr;
	repeat(10)
  req = ahb_xtn::type_id::create("req");
	
  // Initial transaction
  start_item(req);
  assert(req.randomize() with { Htrans == 2'b10; Hburst inside {[3'b001:3'b111]};}); // Exclude SINGLE (000)
  finish_item(req);

  haddr  = req.Haddr;
  hsize  = req.Hsize;
  hburst = req.Hburst;
  hwrite = req.Hwrite;

  beat_size = 1 << hsize; // bytes per beat, 2^hsize
  is_wrap   = hburst inside {3'b010, 3'b100, 3'b110}; // WRAP4/8/16 bursts

  // Determine burst length based on hburst
  case (hburst)
    3'b001: total_beats = (req.length > 1) ? req.length : 2; // INCR
    3'b011: total_beats = 4;
    3'b101: total_beats = 8;
    3'b111: total_beats = 16;
    3'b010: total_beats = 4;  // WRAP4
    3'b100: total_beats = 8;  // WRAP8
    3'b110: total_beats = 16; // WRAP16
    default: total_beats = 1;
  endcase

  // Calculate wrap boundary mask if needed
  if (is_wrap)
    wrap_mask = (beat_size * total_beats) - 1;

  // Remaining transfers in burst (after first)
  for (int i = 1; i < total_beats; i++) begin
    start_item(req);

    if (is_wrap)
      next_addr = (haddr & ~wrap_mask) | ((haddr + beat_size) & wrap_mask);
    else
      next_addr = haddr + beat_size;

    assert(req.randomize() with {
      Hsize  == hsize;
      Hburst == hburst;
      Hwrite == hwrite;
      Htrans == 2'b11;
      Haddr  == next_addr;
    });

    finish_item(req);
    haddr = req.Haddr;
  end

  // Final IDLE transaction
  start_item(req);
  assert(req.randomize() with {Htrans == 2'b00;});
  finish_item(req);

endtask
