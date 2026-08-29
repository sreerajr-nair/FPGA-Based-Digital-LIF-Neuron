`timescale 1ns / 1ps

module lif_neuron #

(
    parameter MEM_WIDTH          = 8,
    parameter THRESHOLD          = 8'd5,
    parameter WEIGHT             = 8'd1,
    parameter LEAK               = 8'd1,
    parameter REFRACTORY_CYCLES  = 4
)

(
    input  wire clk,
    input  wire reset_n,
    input  wire spike_in,

    output reg  spike_out,
    output reg [MEM_WIDTH-1:0] membrane
);

//--------------------------------------------------
// State Encoding
//--------------------------------------------------

localparam IDLE  = 2'b00;
localparam SPIKE = 2'b01;
localparam DOWN  = 2'b10;

reg [1:0] state;

reg [$clog2(REFRACTORY_CYCLES+1)-1:0] ref_counter;


//--------------------------------------------------
// LIF FSM
//--------------------------------------------------

always @(posedge clk or negedge reset_n)
begin

    if(!reset_n)
    begin
        membrane    <= 0;
        spike_out   <= 0;
        ref_counter <= 0;
        state       <= IDLE;
    end

    else
    begin

        case(state)

        //--------------------------------------------------
        // IDLE
        //--------------------------------------------------

        IDLE:
        begin

            spike_out <= 1'b0;

            //--------------------------
            // Integrate
            //--------------------------

            if(spike_in)
            begin

                if((membrane + WEIGHT) >= THRESHOLD)
                begin
                    membrane <= membrane + WEIGHT;
                    state    <= SPIKE;
                end

                else
                begin
                    membrane <= membrane + WEIGHT;
                end

            end

            //--------------------------
            // Leak
            //--------------------------

            else
            begin

                if(membrane > LEAK)
                    membrane <= membrane - LEAK;
                else
                    membrane <= 0;

            end

        end

        //--------------------------------------------------
        // Generate Output Spike
        //--------------------------------------------------

        SPIKE:
        begin

            spike_out   <= 1'b1;
            membrane    <= 0;
            ref_counter <= 0;
            state       <= DOWN;

        end

        //--------------------------------------------------
        // Refractory
        //--------------------------------------------------

        DOWN:
        begin

            spike_out <= 1'b0;

            if(ref_counter < REFRACTORY_CYCLES-1)
            begin
                ref_counter <= ref_counter + 1;
            end

            else
            begin
                ref_counter <= 0;
                state <= IDLE;
            end

        end

        //--------------------------------------------------

        default:
        begin
            state <= IDLE;
        end

        endcase

    end

end

endmodule