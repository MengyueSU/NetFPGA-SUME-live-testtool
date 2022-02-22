
`timescale 1 ns / 1 ps

	module axi_assertion_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 256,
		parameter integer C_S00_AXIS_TUSER_WIDTH    = 128,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 256,
		parameter integer C_M00_AXIS_TUSER_WIDTH    = 128,
		parameter integer C_M00_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here
        output wire  out_assertion,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tkeep,
		output wire [C_M00_AXIS_TUSER_WIDTH-1 : 0] m00_axis_tuser,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready,

		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tkeep,
		input wire [C_S00_AXIS_TUSER_WIDTH-1 : 0] s00_axis_tuser,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid
	);
	
	axi_assertion_test u0(
        //AXI Stream Slave
        .s_axis_clk(s00_axis_aclk),
        .s_axis_resetn(s00_axis_aresetn),
        .s_axis_tdata(s00_axis_tdata),
        .s_axis_tkeep(s00_axis_tkeep),
        .s_axis_tlast(s00_axis_tlast),
        .s_axis_tuser(s00_axis_tuser),
        .s_axis_tvalid(s00_axis_tvalid),
        .s_axis_tready(s00_axis_tready),
        //AXI Stream Master
        .m_axis_clk(m00_axis_aclk),
        .m_axis_resetn(m00_axis_aresetn),
        .m_axis_tdata(m00_axis_tdata),
        .m_axis_tkeep(m00_axis_tkeep),
        .m_axis_tlast(m00_axis_tlast),
        .m_axis_tuser(m00_axis_tuser),
        .m_axis_tvalid(m00_axis_tvalid),
        .m_axis_tready(m00_axis_tready),
        
        //assertion
        .out_assertion(out_assertion)
     );
	// Add user logic here

	// User logic ends

	endmodule
