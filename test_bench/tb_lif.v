`timescale 1ns / 1ps

module tb_lif;

reg clk;
reg reset_n;
reg spike_in;

wire spike_out;
wire [2:0] membrane;

reg[8:0] i;

//--------------------------------------------------
// DUT
//--------------------------------------------------

lif_neuron uut (

    .clk(clk),
    .reset_n(reset_n),
    .spike_in(spike_in),
    .spike_out(spike_out),
    .membrane(membrane)

);

//--------------------------------------------------
// Clock Generation
//--------------------------------------------------

always #5 clk = ~clk;

//--------------------------------------------------
// Stimulus
//--------------------------------------------------

initial
begin

    clk = 0;
    reset_n = 0;
    spike_in = 0;

    #20;
    reset_n = 1;

    // Random spike stream
    for(i = 0; i < 300; i = i + 1)
    begin

        @(posedge clk);

        spike_in = $urandom_range(0,1);

    end

    spike_in = 0;

    #100;

    $finish;

end

//--------------------------------------------------
// Console Monitor
//--------------------------------------------------

initial
begin

    $monitor(
    "Time=%0t | Spike_In=%b | Mem=%0d | Ref=%0d | State=%b | Spike_Out=%b",
    $time,
    spike_in,
    membrane,
    uut.ref_counter,
    uut.state,
    spike_out
    );

end

endmodule