
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
  

  repeat (10) begin

    // Initial NONSEQ transfer
    req = ahb_xtn::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {
      Htrans == 2'b10;
	  Hwrite == 1;
      Hburst inside {[3'b001:3'b111]}; // INCR, WRAP4/8/16
    });
    finish_item(req);

    haddr  = req.Haddr;
    hsize  = req.Hsize;
    hburst = req.Hburst;
    hwrite = req.Hwrite;

    beat_size = 1 << hsize; // 2^Hsize bytes per beat
    is_wrap   = hburst inside {3'b010, 3'b100, 3'b110}; // WRAP types

    // Determine burst length
    case (hburst)
      3'b001: total_beats = $urandom_range(1, 16); // INCR: random length
      3'b010: total_beats = 4;  // WRAP4
      3'b011: total_beats = 4;  // INCR4
      3'b100: total_beats = 8;  // WRAP8
      3'b101: total_beats = 8;  // INCR8
      3'b110: total_beats = 16; // WRAP16
      3'b111: total_beats = 16; // INCR16
      default: total_beats = 1;
    endcase

    // Calculate wrap mask if wrap burst
    if (is_wrap)
      wrap_mask = (beat_size * total_beats) - 1;

    // SEQ transfers (remaining beats)
    for (int i = 1; i < total_beats; i++) begin
      req = ahb_xtn::type_id::create($sformatf("req_%0d", i));
      start_item(req);

      if (is_wrap)
        next_addr = (haddr & ~wrap_mask) | ((haddr + beat_size) & wrap_mask);
      else
        next_addr = haddr + beat_size;

      assert(req.randomize() with {
        Htrans == 2'b11;
        Hsize  == hsize;
        Hburst == hburst;
        Hwrite == hwrite;
        Haddr  == next_addr;
      });

      finish_item(req);
      haddr = next_addr;
    end

    // Final IDLE transfer
    req = ahb_xtn::type_id::create("idle_req");
    start_item(req);
    assert(req.randomize() with { Htrans == 2'b00; });
    finish_item(req);
  end

endtask

