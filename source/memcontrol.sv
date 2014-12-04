// $Id: $
// File name:   memcontrol.sv
// Created:     11/30/2014
// Author:      Cody Allen
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Memory Controller for SDRAM Memory Controller


module memcontrol
(
  input wire hclk,                    // Clock input
  input wire nrst,                    // nrst input
  input wire [11:0] mem_addr,         // Memory address from AHB
  input wire enable,                  // Bus clear signal - check before any opperations (R/W)
  input wire w_en,                    // Enable from AHB for write command
  input wire r_en,                    // Endable from AHB for read command
  input wire [11:0] c_addr_o,         // Address output from cache to MC 
  input wire rollover_flag,           // Rollover flag from counter 
  output reg [4:0] c_addr_en,         // 
  output reg [11:0] c_addr_i,         // 
  output reg c_w_en,                  //
  output reg [11:0] c_w_addr,         //
  output reg c_r_en,                  //
  output reg [11:0] c_r_addr,         //
  output reg BUSYn,                   // Busy signal to AHB when not in Active idle state
  output reg [11:0] mem_addr,         // Memory address to SDRAM 
  output reg mem_cke,                 // Clock enable
  output reg mem_CSn,                 // Chip select
  output reg mem_RASn,                // Row address stobe
  output reg mem_CASn,                // Coloumn address strobe
  output reg mem_WEn,                 // Write enable
  output reg tim_EN,                  // Timer enable
  output reg [11:0] tim_ro_value      // Timer rollover value      
);

  // STATE DELCARTIONS
  typedef enum logic [5:0] {
    // STATES
    INIT_WAIT1,         // After power on, wait 100 us
    INIT_PRE_C,         // Precharge all cells in SDRAM
    INIT_WAIT2,         // Wait for precharge cycle
    INIT_AUTO_R1,       // Auto refresh SDRAM
    INIT_WAIT3,         // Wait for refresh to complete
    INIT_AUTO_R2,       // Auto refresh SDRAM again
    INIT_WAIT4,         // Wait for refresh to complete
    INIT_SET_MODE,      // Load mode register of SDRAM
    INIT_WAIT5,         // Wait for mode register loading
    ACTIVE_IDLE,        // HQ Idle state
    RF_PRE_C,           // Precharge cells command
    RF_AUTO_R,          // Send auto refresh command
    RF_WAIT1,           // Wait for auto refresh to complete
    RF_WAIT2,           // Wait for auto refresh to complete
    RF_WAIT3,           // Wait for auto refresh to complete
    R_CHECK_HIT,        // Check for hit in cache when READING
    R_RELAY_DATA,       // Return data via AHB from cache
    R_SET_PREP,         // Set SDRAM READ Prep command
    R_SET_CMD,          // Set SDRAM READ command
    R_WAIT1,            // Wait on SDRAM for read complete
    R_WAIT2,            // Wait on SDRAM for read complete
    R_WAIT3,            // Wait on SDRAM for read complete
    R_WAIT4,            // Wait on SDRAM for read complete
    R_WAIT5,            // Wait on SDRAM for read complete
    R_WAIT6,            // Wait on SDRAM for read complete
    R_WAIT7,            // Wait on SDRAM for read complete
    R_WAIT8,            // Wait on SDRAM for read complete
    W_SET_PREP,         // Set SDRAM WRITE Prep command
    W_SET_CMD,          // Set SDRAM WRITE command
    W_WAIT              // Wiat for write to complete
  } state_type;
  
  
  // LOCAL DECLARATIONS
  state_type state;
  state_type nextState;
  
  /*---------------------------------------PROCESSES---------------------------------------*/
  /*-----------------------------------NEXT STATE LOGIC------------------------------------*/
  always_ff @ (posedge hclk, negedge nrst) begin
    if (nrst == 1'b0) begin
      state <= INIT_WAIT1;
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
      INIT_WAIT1:
      begin
        nextState <= rollover_flag == 1'b1? INIT_PRE_C: INIT_WAIT1;
      end
      
      INIT_PRE_C:
      begin
        nextState <= INIT_WAIT2;
      end
      
      INIT_WAIT2:
      begin
        nextState <= rollover_flag == 1'b1? INIT_AUTO_R1: INIT_WAIT2;
      end
      
      INIT_AUTO_R1:
      begin
        nextState <= INIT_WAIT3;
      end
      
      INIT_WAIT3:
      begin
        nextState <= rollover_falg == 1'b1? INIT_AUTO_R2: INIT_WAIT3; 
      end
      
      INIT_AUTO_R2:
      begin
        nextState <= INIT_WAIT4;
      end
      
      INIT_WAIT4:
      begin
        nextState <= rollover_flag == 1'b1? INIT_SET_MODE: INIT_WAIT4;
      end
      
      INIT_SET_MODE:
      begin
        nextState <= INIT_WAIT5;
      end
      
      INIT_WAIT5:
      begin
        nextState <= rollover_flag == 1'b1? ACTIVE_IDLE: INIT_WAIT5;
      end
      
      ACTIVE_IDLE:
      begin
        if rollover_flag == 1'b1
          nextState <= RF_PRE_C;
        else if ((w_en == 1'b1) & (r_en == 1'b0))
          nextState <= W_SET_PREP;
        else if ((w_en == 1'b0) & (r_en == 1'b1))
          nextState <= R_CHECK_HIT;
        else
          nextState <= ACTIVE_IDLE;
      end
      
      RF_PRE_C:
      begin
        nextState <= RF_AUTO_R;
      end
      
      RF_AUTO_R:
      begin
        nextState <= RF_WAIT1;
      end
      
      RF_WAIT1:
      begin
        nextState <= RF_WAIT2;
      end
      
      RF_WAIT2:
      begin
        nextState <= RF_WAIT3;
      end
      RF_WAIT3:
      begin
        nextState <= ACTIVE_IDLE;
      end
      
      R_CHECK_HIT:
      begin
        nextState <= /*HIT CONDITION*/? R_RELAY_DATA: R_SET_PREP;
      end
      
      R_RELAY_DATA:
      begin
        nextState <= ACTIVE_IDLE;
      end
      
      R_SET_PREP:
      begin
        nextState <= R_SET_CMD;
      end
      
      R_SET_CMD:
      begin
        nextState <= R_WAIT1;
      end
      
      R_WAIT1:
      begin
        nextState <= R_WAIT2;
      end
      
      R_WAIT2:
      begin
        nextState <= R_WAIT3;
      end
      
      R_WAIT3:
      begin
        nextState <= R_WAIT4;
      end
      
      R_WAIT4:
      begin
        nextState <= R_WAIT5;
      end
      
      R_WAIT5:
      begin
        nextState <= R_WAIT6;
      end
      
      R_WAIT6:
      begin
        nextState <= R_WAIT7;
      end
      
      R_WAIT7:
      begin
        nextState <= R_WAIT8;
      end
      
      R_WAIT8:
      begin
        nextState <= R_RELAY_DATA;
      end
      
      W_SET_PREP:
      begin
        nextState <= W_SET_CMD;
      end
      
      W_SET_CMD:
      begin
        nextState <= W_WAIT;
      end
      
      W_WAIT:
      begin
        nextState <= ACTIVE_IDLE;
      end
                
    endcase 
  end // Next state end
  
  /*-----------------------------------OUTPUT LOGIC------------------------------------*/
  always_comb begin
    // Default 
    c_addr_en,
    c_addr_i,
    c_w_en,
    c_w_addr,
    c_r_en,
    c_r_addr,
    BUSYn,
    mem_addr,
    mem_cke,
    mem_CSn,
    mem_RASn,
    mem_CASn,
    mem_WEn,
    hclk,
    tim_RSTn
    
    // Case statements
    case (state)
      INIT_WAIT1:
      begin
        
      end
      
      INIT_PRE_C:
      begin
        
      end
      
      INIT_WAIT2:
      begin
        
      end
      
      INIT_AUTO_R1:
      begin
        
      end
      
      INIT_WAIT3:
      begin
        
      end
      
      INIT_AUTO_R2:
      begin
        
      end
      
      INIT_WAIT4:
      begin
        
      end
      
      INIT_SET_MODE:
      begin
        
      end
      
      INIT_WAIT5:
      begin
        
      end
      
      ACTIVE_IDLE:
      begin
        if rollover_flag == 1'b1
          
        else if ((w_en == 1'b1) & (r_en == 1'b0))
          
        else if ((w_en == 1'b0) & (r_en == 1'b1))
          
        else
          
      end
      
      RF_PRE_C:
      begin
        
      end
      
      RF_AUTO_R:
      begin
        
      end
      
      RF_WAIT1:
      begin
        
      end
      
      RF_WAIT2:
      begin
        
      end
      RF_WAIT3:
      begin
        
      end
      
      R_CHECK_HIT:
      begin
        
      end
      
      R_RELAY_DATA:
      begin
        
      end
      
      R_SET_PREP:
      begin
        
      end
      
      R_SET_CMD:
      begin
        
      end
      
      R_WAIT1:
      begin
        
      end
      
      R_WAIT2:
      begin
        
      end
      
      R_WAIT3:
      begin
        
      end
      
      R_WAIT4:
      begin
        
      end
      
      R_WAIT5:
      begin
        
      end
      
      R_WAIT6:
      begin
        
      end
      
      R_WAIT7:
      begin
        
      end
      
      R_WAIT8:
      begin
        
      end
      
      W_SET_PREP:
      begin
        
      end
      
      W_SET_CMD:
      begin
        
      end
      
      W_WAIT:
      begin
        
      end
                
    endcase
    
  end // Output Logic end
  
  
endmodule     