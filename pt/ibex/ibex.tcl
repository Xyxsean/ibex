#################################################
# PrimeTime script for static timing analysis   #
# MS 7/2015                                     #
#################################################

# Display long reports one page at a time
set sh_enable_page_mode true

# Enable or Disable PrimePower, which provides power analysis
set power_enable_analysis true


##################################################
# Set files and paths
##################################################

# Set the top_level name
set top_level ibex_top

# Set library paths
set search_path ". /courses/ee6321/share/ibm13rflpvt/synopsys/"

# Specify a list of libraries, design files, and library files used during linking
set link_path "* scx3_cmos8rf_lpvt_tt_1p2v_25c.db" 

# Read design or library files
read_db "scx3_cmos8rf_lpvt_tt_1p2v_25c.db"

# Read verilog files
set verilog_files {../../dc_syn/dc/ibex/ibex_top.nl.v}
read_verilog $verilog_files

# Resolve references in a design
# Note: It resolves all references between different modules in the hierarchy
#       and builds an internal representation of the design for timing analysis
link_design -keep_sub_designs $top_level


##################################################
# Define timing constraints
##################################################

# Timing Constraints
source ./timing.tcl


##################################################
# Run PrimeTime 
##################################################

# Generate a report file
set rpt_file "${top_level}.pt.rpt"
check_timing

report_design >> ${rpt_file}
report_reference >> ${rpt_file}
report_constraint >> ${rpt_file}
report_constraint -all_violators -significant_digits 4 >> ${rpt_file}
report_timing -significant_digits 4 -delay_type min_max >> ${rpt_file}

# Do power analysis
set power_analysis_mode "time_based"
read_vcd "../VCD_files/lfsr1.vcd" #-strip_path "testbench/lfsr_0"
report_switching_activity >> ${rpt_file}
report_switching_activity -list_not_annotated >> ${rpt_file}
update_power
report_power >> ${rpt_file}
report_power -hierarchy >> ${rpt_file}

write_sdf -context verilog "./ibex.pt.sdf"

# Finish PrimeTime
quit
