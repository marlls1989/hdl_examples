module mult #(WIDTH=32)
  (input logic clk, reset,
   input logic [WIDTH/2-1:0]  a, b,
   output logic [WIDTH-1:0] result);
   typedef enum        {INITIAL, LOAD, OPERATE} state_t;
   logic [WIDTH/2-1:0] a_r, b_r;
   logic [WIDTH-1:0]   acc;
   logic [$clog2(WIDTH):0] counter;
   state_t             ps, ns;

   // Control FSM
   always_ff @(posedge clk or negedge reset)
     if (!reset)
       ps <= INITIAL;
     else
       ps <= ns;

   always_comb
     case (ps)
       INITIAL : ns <= LOAD;
       LOAD    : ns <= OPERATE;
       OPERATE :
         if (!counter)
           ns <= INITIAL;
         else
           ns <= OPERATE;
       default : ns <= ps;
     endcase // case (ps)

   // Input Conditional Handshake
   always_ff @(posedge clk or negedge reset)
     if (!reset) begin
        a_r <= '0;
        b_r <= '0;
     end else if(ps == INITIAL) begin
        a_r <= a;
        b_r <= b;
     end

   always_ff @(posedge clk or negedge reset)
     if (!reset) begin
        acc = '0;
        counter = WIDTH/2;
     end else
       if (ps == OPERATE) begin
          logic c = 0;
          if (acc[0]) {c, acc[WIDTH-1:WIDTH/2]} = acc[WIDTH-1:WIDTH/2] + a_r;
          acc = {c, acc[WIDTH-1:1]};
          counter = counter-1;
       end else begin
          acc = {{(WIDTH/2){1'b0}}, b_r};
          counter = WIDTH/2;
       end

   // Output Conditional Handshake
   always_comb
     if (!counter)
       result <= acc;
     else
       result <= 'z;

endmodule // mult
