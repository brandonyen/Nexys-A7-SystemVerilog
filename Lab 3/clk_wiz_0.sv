module clk_wiz_0 (
    input  logic clk_in1,   // Clock input port
    output logic clk_out1   // Clock output port
);

    // Core generation attribute (for Xilinx tools)
    (* CORE_GENERATION_INFO = "clk_wiz_0,clk_wiz_v5_1,{component_name=clk_wiz_0,use_phase_alignment=true,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=false,use_inclk_switchover=false,use_dyn_reconfig=false,enable_axi=0,feedback_source=FDBK_AUTO,PRIMITIVE=MMCM,num_out_clk=1,clkin1_period=10.0,clkin2_period=10.0,use_power_down=false,use_reset=false,use_locked=false,use_inclk_stopped=false,feedback_type=SINGLE,CLOCK_MGR_TYPE=NA,manual_override=false}" *)

    // Instantiate the clk_wiz_0_clk_wiz component
    clk_wiz_0_clk_wiz U0 (
        .clk_in1(clk_in1),     // Map clk_in1 to input port
        .clk_out1(clk_out1)    // Map clk_out1 to output port
    );

endmodule
