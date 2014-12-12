# This file specifies how the pads are placed
# The name of each pad here has to match the
# name in the verilog code
# The Mosis padframe has 4 corners and 40 pads

Version: 2

# West (1 to 51)
HADDR(0-31)
HRDATA(0-19)

# South (52 to 101)
HRDATA(20-31)
HWDATA(0-31)
HCLK
HRESETn
HBURST(2-0)
HPROT(2-0)

# East (102 to 152)
HPROT(3)
HSIZE(2-0)
HTRANS(1-0)
HWRITE
HREADYIN
HSEL
HRESP
HREADYOUT
MEM_RDATA(31-0)
MEM_CLK
MEM_CKE
MEM_CSn
MEM_RASn
MEM_CASn
MEM_WEn
MEM_BA(1-0)
MEM_DQM(0)

# North (153 to 203)
MEM_DQM(3-1)
MEM_WDATA(31-0)
MEM_ADDR(11-0)
VDD
GND


# East

Pad: U3 E
Pad: U4 E
Pad: U5 E
Pad: U6 E
Pad: U7 E
Pad: U8 E
Pad: U9 E
Pad: U10 E
Pad: U11 E
Pad: U12 E

# North
Pad: U100 N PADNC
Pad: U101 N PADNC
Pad: U1 N
Pad: U102 N PADNC
Pad: U103 N PADNC
Pad: U104 N PADNC
Pad: U105 N PADNC
Pad: U2 N
Pad: U106 N PADNC
Pad: U107 N PADNC

# West
Pad: U108 W PADNC
Pad: U109 W PADNC
Pad: U13 W
Pad: U14 W
Pad: U15 W
Pad: U16 W
Pad: U17 W
Pad: U18 W
Pad: U110 W PADNC
Pad: U111 W PADNC

# South
Pad: U112 S PADNC
Pad: U113 S PADNC
Pad: U114 S PADNC
Pad: U115 S PADNC
Pad: U116 S PADNC
Pad: U117 S PADNC
Pad: U118 S PADNC
Pad: U119 S PADNC
Pad: U120 S PADNC
Pad: U121 S PADNC


Orient: R0
Pad: c00 NW PADFC
Orient: R90
Pad: c01 SW PADFC
Orient: R180
Pad: c02 SE PADFC
Orient: R270
Pad: c03 NE PADFC

