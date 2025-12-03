/*

An arbiter example.  Three requests, can grant two at the same time.
A request should be served within two cycles.

*/

module arbiter (
    input logic clk,
    input logic requestA,
    input logic requestB,
    input logic requestC
);

logic grantA;
logic grantB;
logic grantC;

// Implication.
function automatic logic imply(logic a, logic b);
    return !a || b;
endfunction

// Only grant if requested.
assert property (@(posedge clk) imply(grantA, requestA));
assert property (@(posedge clk) imply(grantB, requestB));
assert property (@(posedge clk) imply(grantC, requestC));

// Count requests and grants.
logic [1:0] requestCount;
logic [1:0] grantCount;
assign requestCount = requestA + requestB + requestC;
assign grantCount   = grantA + grantB + grantC;

// Grant at most two requests at a time.
assert property (@(posedge clk) grantCount <= 2);

// Grant one if one is requested.
assert property (@(posedge clk) imply(requestCount == 1, grantCount == 1));

// Must grant two if two or more are requested.
assert property (@(posedge clk) imply(requestCount >= 2, grantCount == 2));

// A request must be granted within two cycles.
assert property (@(posedge clk) (requestA && !grantA) ##1 requestA |-> grantA);
assert property (@(posedge clk) (requestB && !grantB) ##1 requestB |-> grantB);
assert property (@(posedge clk) (requestC && !grantC) ##1 requestC |-> grantC);

// Arbiter implementation.

// My ugly solution that took a couple hours to get right.

/*

logic deniedC;
initial
    deniedC = 1'b0;
always_ff @(posedge clk)
    deniedC <= requestC && !grantC;

assign grantA = requestA;
assign grantB = requestB && !(requestA && deniedC && requestC);
assign grantC = requestC && !(grantA && grantB);

*/


// Solution found with Grok after two iterations.  Pretty amazing!

logic was_blocked_A;
logic was_blocked_B;
logic was_blocked_C;

// Explicit reset initialization (required for some formal tools and clean simulation)
initial begin
    was_blocked_A = 1'b0;
    was_blocked_B = 1'b0;
    was_blocked_C = 1'b0;
end

always_ff @(posedge clk) begin
    was_blocked_A <= requestA && !grantA;
    was_blocked_B <= requestB && !grantB;
    was_blocked_C <= requestC && !grantC;
end

always_comb begin
    // Default: grant every active request
    grantA = requestA;
    grantB = requestB;
    grantC = requestC;

    // Three concurrent requests → grant only two
    if (requestA && requestB && requestC) begin
        if (was_blocked_A) begin
            // A was blocked last cycle → grant A+B, block C
            grantA = 1'b1;
            grantB = 1'b1;
            grantC = 1'b0;
        end
        else if (was_blocked_B) begin
            // B was blocked last cycle → grant A+B, block C
            grantA = 1'b1;
            grantB = 1'b1;
            grantC = 1'b0;
        end
        else if (was_blocked_C) begin
            // C was blocked last cycle → grant A+C, block B
            grantA = 1'b1;
            grantB = 1'b0;
            grantC = 1'b1;
        end
        else begin
            // First time all three are active → fixed priority A > B > C
            grantA = 1'b1;
            grantB = 1'b1;
            grantC = 1'b0;
        end
    end
end

endmodule