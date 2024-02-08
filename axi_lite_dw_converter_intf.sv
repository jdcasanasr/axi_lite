/// Interface wrapper for `axi_lite_dw_converter`.
`include "axi/typedef.svh"
`include "axi/assign.svh"

/* 
*   Daniel Casañas:
*
*   AXI_ADDR_WIDTH = $clog2(N_DEVICES)
*
*   For AXI4 to AXI4-Lite (Downsizer):
*     AXI_SLV_PORT_DATA_WIDTH = 32'd16 (Fails if 32'd8)
*     AXI_MST_PORT_DATA_WIDTH = 32'd32
*
*   For AXI4-Lite to AXI4 (Upsizer):
*     AXI_SLV_PORT_DATA_WIDTH = 32'd32
*     AXI_MST_PORT_DATA_WIDTH = 32'd8
*/

module axi_lite_dw_converter_intf #(
  /// AXI4-Lite address width of the ports.
  parameter int unsigned AXI_ADDR_WIDTH          = 32'd3,
  /// AXI4-Lite data width of the slave port.
  parameter int unsigned AXI_SLV_PORT_DATA_WIDTH = 32'd32,
  /// AXI4-Lite data width of the master port.
  parameter int unsigned AXI_MST_PORT_DATA_WIDTH = 32'd16
) (
  /// Clock, positive edge triggered.
  input  logic    clk_i,
  /// Asynchrounous reset, active low.
  input  logic    rst_ni,
  /// Slave port interface.
  AXI_LITE.Slave  slv,
  /// Master port interface.
  AXI_LITE.Master mst
);
  // AXI configuration
  localparam int unsigned AxiStrbWidthSlv =  AXI_SLV_PORT_DATA_WIDTH / 32'd8;
  localparam int unsigned AxiStrbWidthMst =  AXI_MST_PORT_DATA_WIDTH / 32'd8;
  // Type definitions
  typedef logic [AXI_ADDR_WIDTH-1:0]          lite_addr_t;
  typedef logic [AXI_SLV_PORT_DATA_WIDTH-1:0] lite_data_slv_t;
  typedef logic [AxiStrbWidthSlv-1:0]         lite_strb_slv_t;
  typedef logic [AXI_MST_PORT_DATA_WIDTH-1:0] lite_data_mst_t;
  typedef logic [AxiStrbWidthMst-1:0]         lite_strb_mst_t;


  `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_lite_t, lite_addr_t)
  `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_lite_slv_t, lite_data_slv_t, lite_strb_slv_t)
  `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_lite_mst_t, lite_data_mst_t, lite_strb_mst_t)
  `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_lite_t)

  `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_lite_t, lite_addr_t)
  `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_lite_slv_t, lite_data_slv_t)
  `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_lite_mst_t, lite_data_mst_t)


  `AXI_LITE_TYPEDEF_REQ_T(req_lite_slv_t, aw_chan_lite_t, w_chan_lite_slv_t, ar_chan_lite_t)
  `AXI_LITE_TYPEDEF_RESP_T(res_lite_slv_t, b_chan_lite_t, r_chan_lite_slv_t)

  `AXI_LITE_TYPEDEF_REQ_T(req_lite_mst_t, aw_chan_lite_t, w_chan_lite_mst_t, ar_chan_lite_t)
  `AXI_LITE_TYPEDEF_RESP_T(res_lite_mst_t, b_chan_lite_t, r_chan_lite_mst_t)

  req_lite_slv_t slv_req;
  res_lite_slv_t slv_res;
  req_lite_mst_t mst_req;
  res_lite_mst_t mst_res;

  `AXI_LITE_ASSIGN_TO_REQ(slv_req, slv)
  `AXI_LITE_ASSIGN_FROM_RESP(slv, slv_res)
  `AXI_LITE_ASSIGN_FROM_REQ(mst, mst_req)
  `AXI_LITE_ASSIGN_TO_RESP(mst_res, mst)

  axi_lite_dw_converter #(
    .AxiAddrWidth        ( AXI_ADDR_WIDTH          ),
    .AxiSlvPortDataWidth ( AXI_SLV_PORT_DATA_WIDTH ),
    .AxiMstPortDataWidth ( AXI_MST_PORT_DATA_WIDTH ),
    .axi_lite_aw_t       ( aw_chan_lite_t          ),
    .axi_lite_slv_w_t    ( w_chan_lite_slv_t       ),
    .axi_lite_mst_w_t    ( w_chan_lite_mst_t       ),
    .axi_lite_b_t        ( b_chan_lite_t           ),
    .axi_lite_ar_t       ( ar_chan_lite_t          ),
    .axi_lite_slv_r_t    ( r_chan_lite_slv_t       ),
    .axi_lite_mst_r_t    ( r_chan_lite_mst_t       ),
    .axi_lite_slv_req_t  ( req_lite_slv_t          ),
    .axi_lite_slv_res_t  ( res_lite_slv_t          ),
    .axi_lite_mst_req_t  ( req_lite_mst_t          ),
    .axi_lite_mst_res_t  ( res_lite_mst_t          )
  ) i_axi_lite_dw_converter (
    .clk_i,
    .rst_ni,
    .slv_req_i ( slv_req ),
    .slv_res_o ( slv_res ),
    .mst_req_o ( mst_req ),
    .mst_res_i ( mst_res )
  );
endmodule