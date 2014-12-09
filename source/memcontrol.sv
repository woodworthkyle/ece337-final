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
  input wire [1:0] target_ba,         // Target Bank Address 
  input wire [11:0] target_addr,      // Memory address from AHB
  input wire enable,                  // Bus clear signal - check before any opperations (R/W)
  input wire w_en,                    // Enable from AHB for write command
  input wire r_en,                    // Endable from AHB for read command
  input wire [11:0] c_addr_o,         // Address output from cache to MC 
  input wire rollover_flag,           // Rollover flag from counter 
  output reg c_addr_en,               // Enables writing to address block 
  output reg [11:0] c_addr_i,         // Address of TOP item in cache
  output reg c_w_en,                  // Asserted when writing into cache
  output reg [2:0] c_w_addr,          // Address of cache block to write to (0-7)
  output reg c_r_en,                  // Asserted when reading from the cache
  output reg [2:0] c_r_addr,          // Address of cache block to read from 
  output reg BUSYn,                   // Busy signal to AHB when not in Active idle state
  output reg [1:0] mem_ba,             // Band address
  output reg [11:0] mem_addr,         // Memory address to SDRAM 
  output reg mem_cke,                 // Clock enable
  output reg mem_CSn,                 // Chip select
  output reg mem_RASn,                // Row address stobe
  output reg mem_CASn,                // Coloumn address strobe
  output reg mem_WEn,                 // Write enable
  output reg [3:0] mem_DQM,                 // Memory output/input enable
  output reg tim_clear,               // Time clear
  output reg tim_EN,                  // Timer enable
  output reg [11:0] tim_ro_value      // Timer rollover value      
);

  // STATE DELCARTIONS
  typedef enum logic [5:0] {
    // STATES
    INIT_WAIT0,         // After power on, wait 100 us
    INIT_WAIT1,         // After power on, wait 100 us
    INIT_PRE_C,         // Precharge all cells in SDRAM
    INIT_WAIT2,         // Wait for precharge cycle
    INIT_AUTO_R1,       // Auto refresh SDRAM
    INIT_WAIT3,         // Wait for refresh to complete
    INIT_AUTO_R2,       // Auto refresh SDRAM again
    INIT_WAIT4,         // Wait for refresh to complete
    INIT_SET_MODE,      // Load mode register of SDRAM
    INIT_WAIT5,         // Wait for mode register loading
    INIT_WAIT6,         // Wait cycle
    INIT_WAIT7,         // Wait cycle
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
    R_PRE_C,            // Send precharge command for terminate 
    W_SET_PREP,         // Set SDRAM WRITE Prep command
    W_SET_CMD,          // Set SDRAM WRITE command
    W_WAIT,             // Wiat for write to complete
    W_PRE_C             // Send precharge command for terminate 
  } state_type;
  
  
  // LOCAL DECLARATIONS
  state_type state;
  state_type nextState;
  reg [2:0] offset = 3'b000;
  reg next_BUSYn;
  
  /*---------------------------------------PROCESSES---------------------------------------*/
  /*-----------------------------------NEXT STATE LOGIC------------------------------------*/
  always_ff @ (posedge hclk, negedge nrst) begin
    if (nrst == 1'b0) begin
      state <= INIT_WAIT0;
      BUSYn <= 1'b0;
    end
    else begin
    state <= nextState;
    BUSYn <= next_BUSYn;
    end
  end

  // NEXT STATE
  always_comb begin
    // Default
    nextState <= state;
    
    // Case statements
    case (state)
      INIT_WAIT0:
      begin
        nextState <= ((rollover_flag == 1'b1)? INIT_WAIT1 : INIT_WAIT0);
      end
      
      INIT_WAIT1:
      begin
        nextState <= INIT_WAIT2;
      end
      
      INIT_WAIT2:
      begin
        nextState <= ((rollover_flag == 1'b1)? INIT_PRE_C: INIT_WAIT2);
      end
      
      INIT_PRE_C:
      begin
        nextState <= INIT_WAIT3;
      end
      
      INIT_WAIT3:
      begin
        nextState <= INIT_AUTO_R1;
      end
      
      INIT_AUTO_R1:
      begin
        nextState <= INIT_WAIT4;
      end
      
      INIT_WAIT4:
      begin
        nextState <= ((rollover_flag == 1'b1)? INIT_AUTO_R2: INIT_WAIT4); 
      end
      
      INIT_AUTO_R2:
      begin
        nextState <= INIT_WAIT5;
      end
      
      INIT_WAIT5:
      begin
        nextState <= ((rollover_flag == 1'b1)? INIT_SET_MODE: INIT_WAIT5);
      end
      
      INIT_SET_MODE:
      begin
        nextState <= INIT_WAIT6;
      end
      
      INIT_WAIT6:
      begin
        nextState <= INIT_WAIT7;
      end
      
      INIT_WAIT7:
      begin
        nextState <= ACTIVE_IDLE;
      end
      
      ACTIVE_IDLE:
      begin
        if (rollover_flag == 1'b1)
          nextState <= RF_PRE_C;
        else if ((w_en == 1'b1) & (r_en == 1'b0) & (enable == 1'b1))
          nextState <= W_SET_PREP;
        else if ((w_en == 1'b0) & (r_en == 1'b1) & (enable == 1'b1))
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
        if (target_addr == c_addr_o)
          nextState <= R_RELAY_DATA;
        else if (target_addr == (c_addr_o + 1))
          nextState <= R_RELAY_DATA;
        else if (target_addr == (c_addr_o + 2))
          nextState <= R_RELAY_DATA;
        else if (target_addr == (c_addr_o + 3))
          nextState <= R_RELAY_DATA;
        else if (target_addr == (c_addr_o + 4))
          nextState <= R_RELAY_DATA;
        else if (target_addr == (c_addr_o + 5))
          nextState <= R_RELAY_DATA;
        else if (target_addr == (c_addr_o + 6))
          nextState <= R_RELAY_DATA;
        else if (target_addr == (c_addr_o + 7))
          nextState <= R_RELAY_DATA;
        else
          nextState <= R_SET_PREP;
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
        nextState <= R_PRE_C;
      end
      
      R_PRE_C:
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
        nextState <= W_PRE_C;
      end
      
      W_PRE_C:
      begin
        nextState <= ACTIVE_IDLE;
      end
      default:
      begin
        nextState <= state;
      end
                
    endcase 
  end // Next state end
  
  /*-----------------------------------OUTPUT LOGIC------------------------------------*/
  always_comb begin
    // Defaults
    mem_ba = target_ba;           // Always relayed through - controlled by AHB
    mem_cke = 1'b1;               // Always high except during start of INIT
    //BUSYn = 1'b0;                 // Always busy except when in active idle
    next_BUSYn = 1'b0;
    c_addr_en = 1'b0;             // Reset all cache values to default values
    c_addr_i = 12'b000000000000;   
    c_w_en = 1'b0;                
    c_w_addr = 3'b000;
    c_r_en = 1'b0;
    c_r_addr = 3'b000;
    mem_addr = 12'b000000000000;
    mem_CSn = 1'b0;               // Default NOP settings for SDRAM
    mem_RASn = 1'b1;
    mem_CASn = 1'b1;
    mem_WEn = 1'b1;
    mem_DQM = 4'b1111;
    
    //
    offset = 0;
    tim_EN = 1'b0;
    tim_clear = 1'b1;
    tim_ro_value = '0;
        
    // Case statements
    case (state)
      INIT_WAIT0:
      begin
        mem_addr = 12'b000000000000;
        mem_cke = 1'b0;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
        tim_clear = 1'b0;
        tim_EN = 1'b1;
        tim_ro_value = 2500;
      end
      
      INIT_WAIT1:
      begin
        mem_addr = 12'b000000000000;
        mem_cke = 1'b1;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
        tim_clear = 1'b1;
        tim_EN = 1'b0;
        tim_ro_value = 2500;  
      end
      
      INIT_WAIT2:
      begin
        mem_addr = 12'b000000000000;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
        tim_EN = 1'b1;
        tim_clear = 1'b0;
        tim_ro_value = 2500;    
      end
      
      INIT_PRE_C:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b0;
        mem_CASn = 1'b1;
        mem_WEn = 1'b0;
        tim_EN = 1'b0;
        tim_clear = 1'b1;    
      end
      
      INIT_WAIT3:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
      end
      
      INIT_AUTO_R1:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b0;
        mem_CASn = 1'b0;
        mem_WEn = 1'b1;
        tim_clear = 1'b1;
        tim_EN = 1'b0;
      end
      
      INIT_WAIT4:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
        tim_clear = 1'b0;
        tim_EN = 1'b1;
        tim_ro_value = 3;
      end
      
      INIT_AUTO_R2:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b0;
        mem_CASn = 1'b0;
        mem_WEn = 1'b1;
        tim_clear = 1'b1;
        tim_EN = 1'b0;
      end
      
      INIT_WAIT5:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
        tim_clear = 1'b0;
        tim_EN = 1'b1;
        tim_ro_value = 3;
      end
      
      INIT_SET_MODE:
      begin
        mem_addr = 12'b001000010011; //x0x 00 1 00 001 0 011;
        mem_CSn = 1'b0;
        mem_RASn = 1'b0;
        mem_CASn = 1'b0;
        mem_WEn = 1'b0;
        tim_clear = 1'b1;
        tim_EN = 1'b0;
      end
      
      INIT_WAIT6:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
        tim_clear = 1'b1;
        tim_EN = 1'b0;
      end
      
      INIT_WAIT7:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
        tim_clear = 1'b1;
        tim_EN = 1'b0;
        tim_ro_value = 750;
      end
      
      ACTIVE_IDLE:
      begin
        next_BUSYn = 1'b1;
        tim_clear = 1'b0;
        tim_EN = 1'b1;
        tim_ro_value = 750;
        
        if (rollover_flag == 1'b1) begin
          next_BUSYn = 1'b0;
          mem_CSn = 1'b0;
          mem_RASn = 1'b0;
          mem_CASn = 1'b0;
          mem_WEn = 1'b1;
          end
        else if (((w_en == 1'b1) | (r_en == 1'b1)) & (enable == 1'b1)) begin
          next_BUSYn = 1'b0;
          mem_CSn = 1'b0;
          mem_RASn = 1'b1;
          mem_CASn = 1'b1;
          mem_WEn = 1'b1;
        end
        else begin
          next_BUSYn = 1'b1;
          mem_CSn = 1'b0;
          mem_RASn = 1'b1;
          mem_CASn = 1'b1;
          mem_WEn = 1'b1;
          end
      end
      
      RF_PRE_C:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b0;
        mem_CASn = 1'b1;
        mem_WEn = 1'b0;
        tim_clear = 1'b1;
        tim_EN = 1'b0;
      end
      
      RF_AUTO_R:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b0;
        mem_CASn = 1'b0;
        mem_WEn = 1'b1;
        tim_clear = 1'b1;
        tim_EN = 1'b0;
      end
      
      RF_WAIT1:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
        tim_clear = 1'b1;
        tim_EN = 1'b0;
      end
      
      RF_WAIT2:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
        tim_clear = 1'b1;
        tim_EN = 1'b0;
      end
      RF_WAIT3:
      begin
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
        tim_clear = 1'b1;
        tim_EN = 1'b0;
        tim_ro_value = 750;
      end
      
      R_CHECK_HIT:
      begin
        offset = 0;
        mem_addr = 12'b000000000000;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
        
        if (mem_addr == c_addr_o) begin
          offset = 0;
        end else if (target_addr == (c_addr_o + 1)) begin
          offset = 1;
        end else if (target_addr == (c_addr_o + 2)) begin
          offset = 2;
        end else if (target_addr == (c_addr_o + 3)) begin
          offset = 3;
        end else if (target_addr == (c_addr_o + 4)) begin
          offset = 4;
        end else if (target_addr == (c_addr_o + 5)) begin
          offset = 5;
        end else if (target_addr == (c_addr_o + 6)) begin
          offset = 6;
        end else if (target_addr == (c_addr_o + 7)) begin
          offset = 7;
        end
        
        if(nextState == R_RELAY_DATA) begin
          next_BUSYn = 1'b1;
        end
      end
      
      R_RELAY_DATA:
      begin
        // Added BUSYn to be asserted to let the bus know we have data on the line
        next_BUSYn = 1'b1;
        c_r_en = 1'b1;
        c_r_addr = offset;
      end
      
      R_SET_PREP:
      begin
        mem_addr = target_addr;
        mem_CSn = 1'b0;
        mem_RASn = 1'b0;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
      end
      
      R_SET_CMD:
      begin
        mem_addr = target_addr;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b0;
        mem_WEn = 1'b1;
      end
      
      R_WAIT1:
      begin
        mem_addr = target_addr;
        c_w_en = 1'b1;
        c_w_addr = 3'b000;
        c_addr_i = target_addr;
        c_addr_en = 1'b1;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
      end
      
      R_WAIT2:
      begin
        c_w_en = 1'b1;
        c_w_addr = 3'b001;
        c_addr_i = 12'b000000000000;
        c_addr_en = 1'b0;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
      end
      
      R_WAIT3:
      begin
        c_w_en = 1'b1;
        c_w_addr = 3'b010;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
      end
      
      R_WAIT4:
      begin
        c_w_en = 1'b1;
        c_w_addr = 3'b011;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
      end
      
      R_WAIT5:
      begin
        c_w_en = 1'b1;
        c_w_addr = 3'b100;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
      end
      
      R_WAIT6:
      begin
        c_w_en = 1'b1;
        c_w_addr = 3'b101;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
      end
      
      R_WAIT7:
      begin
        c_w_en = 1'b1;
        c_w_addr = 3'b110;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
      end
      
      R_WAIT8:
      begin
        c_w_en = 1'b1;
        c_w_addr = 3'b111;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b0;
      end
      
      R_PRE_C:
      begin
        next_BUSYn = 1'b1;
        mem_CSn = 1'b0;
        mem_RASn = 1'b0;
        mem_CASn = 1'b1;
        mem_WEn = 1'b0;
      end
      
      W_SET_PREP:
      begin
        mem_addr = target_addr;
        mem_CSn = 1'b0;
        mem_RASn = 1'b0;
        mem_CASn = 1'b1;
        mem_WEn = 1'b1;
      end
      
      W_SET_CMD:
      begin
        mem_addr = target_addr;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b0;
        mem_WEn = 1'b0;
      end
      
      W_WAIT:
      begin
        next_BUSYn = 1'b1;
        mem_CSn = 1'b0;
        mem_RASn = 1'b1;
        mem_CASn = 1'b1;
        mem_WEn = 1'b0;
      end
      
      W_PRE_C:
      begin
        next_BUSYn = 1'b1;
        mem_CSn = 1'b0;
        mem_RASn = 1'b0;
        mem_CASn = 1'b1;
        mem_WEn = 1'b0;
      end
                
    endcase
    
  end // Output Logic end
  
  
endmodule     