if {![catch { set clk_ports [get_ports CLK_50MHZ] }]} {
    create_clock -name CLK_50MHZ -period 20.000 $clk_ports
}
