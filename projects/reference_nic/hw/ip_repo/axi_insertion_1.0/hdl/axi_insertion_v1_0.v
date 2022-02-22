
`timescale 1 ns / 1 ps

	module axi_write_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 6,

		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 256,
        parameter integer C_S00_AXIS_TUSER_WIDTH    = 128,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 256,
		parameter integer C_M00_AXIS_START_COUNT	= 32,
        parameter integer C_M00_AXIS_TUSER_WIDTH    = 128
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tkeep,
		input wire [C_S00_AXIS_TUSER_WIDTH-1 : 0] s00_axis_tuser,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tkeep,
		output wire [C_M00_AXIS_TUSER_WIDTH-1 : 0] m00_axis_tuser,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);

	// Add user logic here
    axi_write u0(
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
         //XI Lite
        .s_axi_clk(s00_axi_aclk),
        .s_axi_resetn(s00_axi_aresetn), 
        
		.s_axi_awaddr(s00_axi_awaddr),
		.s_axi_awvalid(s00_axi_awvalid),
		.s_axi_awready(s00_axi_awready),
		.s_axi_wdata(s00_axi_wdata),
		.s_axi_wvalid(s00_axi_wvalid),
		.s_axi_wready(s00_axi_wready),
		.s_axi_bresp(s00_axi_bresp),
		.s_axi_bvalid(s00_axi_bvalid),
		.s_axi_bready(s00_axi_bready),
		
        .s_axi_rdata(s00_axi_rdata),
        .s_axi_rvalid(s00_axi_rvalid),
        .s_axi_rready(s00_axi_rready), 
        .s_axi_rresp(s00_axi_rresp),
        .s_axi_araddr(s00_axi_araddr),
        .s_axi_arvalid(s00_axi_arvalid),
        .s_axi_arready(s00_axi_arready)
    );
	// User logic ends

	endmodule
