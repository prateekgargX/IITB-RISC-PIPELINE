-- what will staller do?
-- controlls all the pipeline registers
-- inserts NOPs as well
-- to create a stall at nth stage, all previous registers are suspended from being updated 
-- and data to next register is NOP instruction
-- to insert a NOP, simply turn off the write_enable lines.
-- in the fetch state this can be achieved by using a "0000" opcode. Controller handles the rest.

-- checks if currently_fetched_instrucion_is_branch_instruction from fetch state itself
-- staticly predicts the branch being taken. In other words, absolute chad.
-- Unconditional branches will always require NOPs since there target  

-- takes BEQ_COM output and if 0 immediately attons for the sins committed. can be informed by hazard unit as well.
-- gets inputs from hazard mititgation unit to decide NOPs where and how many 

-- OK, smarty pants but what will HazardsUnit do? and what about forwarding?
-- HazardsUnit detects whether there is data dependency or anyway other event which might require stalling the pipeline
-- since distinction might not be clear we can integrate Hazards logic into staller.
-- Forward unit detects very specific kind of hazards, 
-- kind of ones which can be mitigated without requiring stalling since you already have the write-back data required and give it alu. 
-- when the need of forwarding arises alu_operands are switched requires a mux.

-- This design can also use branch predictor buffer if we need it later on.
