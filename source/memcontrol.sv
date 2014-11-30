// $Id: $
// File name:   memcontrol.sv
// Created:     11/30/2014
// Author:      Cody Allen
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Memory Controller for SDRAM Memory Controller


module memcontrol
(
  input wire hclk,
  input wire nrst,
  input wire [11:0] mem_addr,
  input wire enable,
  input wire w_en,
  input wire r_en,
  input wire [11:0] c_addr_o,
  input wire refresh,
  output reg [4:0] c_addr_en,
  output reg [11:0] c_addr_i,
  output reg c_w_en,
  output reg [11:0] c_w_addr,
  output reg c_r_en,
  output reg [11:0] c_r_addr,
  output reg BUSYn,
  output reg [11:0] mem_addr,
  output reg mem_cke,
  output reg mem_CSn,
  output reg mem_RASn,
  output reg mem_CASn,
  output reg mem_WEn,
  output wire hclk,
  output reg tim_RSTn
);

  // STATE DELCARTIONS
  typedef enum logic [4:0] {
    // STATES
    INIT_RAM,           // After power on, initialize RAM
    ACTIVE_IDLE,            // HQ Idle state
    CHANGE_PARAMS,      // Change RAM parameters bsaed on request
    REFRESH,            // State for refreshing address
    REC_ADDR_AHB,       // Recieve address from AHB Master
    CHOOSE_RoW,         // Set Read or Write based on request
    CHECK_HIT,          // Check for hit in cache when READING
    RETURN_DATA,        // Return data via AHB from cache
    SET_READ_PREP,      // Set SDRAM READ Prep command
    SET_READ_CMD,       // Set SDRAM READ command
    READ_IDLE,          // Wait on SDRAM for READ request
    WRITE_TO_CACHE,     // Write the data to the cache
    SET_WRITE_PREP,     // Set SDRAM WRITE Prep command
    SET_WRITE_CMD,      // Set SDRAM WRITE command
    RAM_OUT_DIS         // SDRAM output disabled
  } state_type;
  
  
  // LOCAL DECLARATIONS
  state_type state;
  state_type nextState;
  
  // PROCESSES
  // STATE REGISTER
  always_ff @ (posedge hclk, negedge nrst) begin
    if (nrst == 1'b0) begin
      state <= INIT_RAM;
    end
    else begin
    state <= nextState;
    end
  end

  // NEXT STATE
  always_comb begin
    // Default
    nextState <= state;
    
    // Case statements
    case (state)
      INIT_RAM:
      begin
        nextState <= ;
      end
      
      ACTIVE_IDLE:
      begin
        nextState <= ;
      end
      
      CHANGE_PARAMS:
      begin
        nextState <= ;
      end
      
      REFRESH:
      begin
        nextState <= ;
      end
      
      REC_ADDR_AHB:
      begin
        nextState <= ;
      end
      
      CHOOSE_RoW:
      begin
        nextState <= ;
      end
      
      CHECK_HIT:
      begin
        nextState <= ;
      end
      
      RETURN_DATA:
      begin
        nextState <= ;
      end
      
      SET_READ_PREP:
      begin
        nextState <= ;
      end
      
      SET_READ_CMD:
      begin
        nextState <= ;
      end
      
      READ_IDLE:
      begin
        nextState <= ;
      end
      
      RAM_OUT_E:
      begin
        nextState <= ;
      end
      
      WRITE_TO_CACHE:
      begin
        nextState <= ;
      end
      
      SET_WRITE_PREP:
      begin
        nextState <= ;
      end
      
      SET_WRITE_CMD:
      begin
        nextState <= ;
      end
      
      RAM_OUT_DIS:
      begin
        nextState <= ;
      end
    endcase
  end
  
  // OUTPUT LOGIC
  always_comb begin
    // Default 
    
    // Case statements
    
    
  end
  
  
endmodule     