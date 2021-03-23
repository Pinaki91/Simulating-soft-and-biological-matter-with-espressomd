###################################################################
#                                                              ####
#  IDP simulation with coarse grained residue based model from ####
#  Dignon PLOS Comp Bio paper 2018                             ####
#                                                              ####
###################################################################
source /home/pinaki/Documents/post_doc/codes/espresso_tutorials/LLPS/FUS/functions.tcl
puts " "
puts "======================================================="
puts "=               ESPResSo Simulation                   ="
puts "=                                                     ="
puts "======================================================="
puts " "
puts "[code_info]"

#############################################################
# 2 Preparing the System                                    #
#                                                           #
#############################################################
set n_mono 163
set n_poly 10
set n_part [expr $n_mono*$n_poly]
set box_length 300.

#############################################################
# 3 Initializing ESPResSo                                   #
#############################################################
setmd box_l $box_length $box_length $box_length
set time_step_init 0.001
set time_step_equi 0.01
setmd time_step $time_step_init
setmd skin 0.4
set kBT 4.0
set gamma 0.1
thermostat langevin $kBT $gamma

puts [setmd box_l]
puts [setmd time_step]
puts [setmd skin]
puts [integrate]
puts [thermostat]

#############################################################
#Bonded interaction
#############################################################
set k_harmonic 42.0
set r0 3.8
inter 0 harmonic $k_harmonic $r0
set bond_length $r0

polymer $n_poly $n_mono $bond_length mode RW 

#bond length
for {set i 1} {$i < $n_mono} {incr i} {
part $i bond 0 [expr $i-1]
}

###########################################################################
#Read input file for type
set typeid [readfile /home/pinaki/Documents/post_doc/codes/espresso_tutorials/LLPS/FUS/data/wildtype/fuslcd_type_wt.dat]
for {set p 0} { $p < $n_poly } { incr p} {
 for {set i 0} { $i < $n_mono } { incr i} {
 set ip [expr $i+$p*$n_mono]
 part $ip type [lindex [lindex $typeid $i] 1]
 }
}

#Read input file for short-range interaction parameter
set parameter [readfile  /home/pinaki/Documents/post_doc/codes/espresso_tutorials/LLPS/FUS/input_espresso.dat]
set mass_mono [list]
set charge_mono [list]
set sigma_mono [list]
set lambda_mono [list]

set type_max 20
for {set i 0} { $i < $type_max } { incr i} {
lappend mass_mono [lindex [lindex $parameter $i] 1]
lappend charge_mono [lindex [lindex $parameter $i] 2]
lappend sigma_mono [lindex [lindex $parameter $i] 3]
lappend lambda_mono [lindex [lindex $parameter $i] 4]
}

#assigning input parameters to particles
for {set i 0} { $i < $n_part } { incr i} {
set type_mono [part $i print type]
 for {set j 0} { $j < $type_max } { incr j} {
 if {$type_mono==$j} {
 part $i mass [lindex $mass_mono $j]
 part $i q [lindex $charge_mono $j]
  } 
 }
}

set rcap 6.
inter forcecap individual
set epsilon 0.844
# pairwise lennard_jones for all particles (lambda dependent)
for {set i 0} { $i < $type_max} { incr i} {
 for {set j $i} { $j <$type_max } { incr j} {
 set sigma [expr 0.5*[lindex $sigma_mono $i] + 0.5*[lindex $sigma_mono $j] ]
 set rcut_wca [expr pow(2,(1./6.)) * $sigma]
 set rcut_lj [expr 2.5 * $sigma]
 set lambda [expr 0.5*[lindex $lambda_mono $i] + 0.5*[lindex $lambda_mono $j] ]
 set rcut [expr $lambda*$rcut_lj + (1-$lambda)*$rcut_wca]
 inter $i $j lennard-jones $epsilon $sigma $rcut 0.0 0.0 $rcap 0.0
 }
}

#warm up with force cap on
set warm_loop 300
set warm_step 200
set del_r [expr $rcap/$warm_loop]

for { set k 0 } { $k < $warm_loop} { incr k } {
 for {set i 0} { $i < $type_max} { incr i} {
  for {set j $i} { $j <$type_max } { incr j} {      
  set sigma [expr 0.5*[lindex $sigma_mono $i] + 0.5*[lindex $sigma_mono $j] ]
  set rcut_wca [expr pow(2,(1./6.)) * $sigma]
  set rcut_lj [expr 2.5 * $sigma]
  set lambda [expr 0.5*[lindex $lambda_mono $i] + 0.5*[lindex $lambda_mono $j] ]
  set rcut [expr $lambda*$rcut_lj + (1-$lambda)*$rcut_wca]
  inter $i $j lennard-jones $epsilon $sigma $rcut 0.0 0.0 $rcap 0.0  
  }
 }
set rcap [expr $rcap-$del_r] 
inter forcecap individual
integrate $warm_step
puts "Warm up integration $k, box length is $box_length" 
}
#############################################################
set rcap 0
inter forcecap 0
integrate 100
puts "done "
###########################################################################S

#Debye-Huckel potential
set debye_warm_up 100
set lB 7.
set lB_current 0.0
set lB_step [expr $lB/$debye_warm_up]
set kappa 0.1
set rcut_coulomb 50.

for {set i 0} { $i < $debye_warm_up} { incr i} {
inter coulomb $lB_current dh $kappa $rcut_coulomb
integrate 100
set lB_current [expr $lB_current+ $lB_step]
puts "debye warm up going on"
}
inter coulomb $lB dh $kappa $rcut_coulomb

############################################################
set n_steps 200
set n_squeeze 68

#To reach desired volume fraction
for {set i 0} { $i < $n_squeeze } { incr i} {
    puts $i
    integrate $n_steps
#reduce box length gradually
set box_length [expr $box_length*0.99]
change_volume $box_length xyz
puts "[setmd box_l] [analyze centermass 0]"
}
set box_length 150.
change_volume $box_length xyz

puts "Here we go"
#Store all particle positions, type
 set r [list]
 set part_type [list]
 for {set p 0} {$p < $n_part} {incr p} {
 lappend r [lindex [analyze get_folded_positions] $p]
 lappend part_type [part $p print type]
 }

#delete all of them
part deleteall
puts "no of particles is [setmd n_part]"

#Expand to bigger length in Z direction
set n_expand 69
set box_length_z $box_length
for {set i 0} { $i < $n_expand } { incr i} {
    integrate $n_steps
set box_length_z [expr $box_length_z*1.01]
change_volume $box_length_z z
puts "exapnsion: [setmd box_l]"
}
set box_length_z 600.
change_volume $box_length_z z
puts "expanded: [setmd box_l]"

#add particles in the center of the larger box with stored type
set z_shift [expr 0.5*($box_length_z-$box_length)]
for {set p 0} { $p < $n_part } { incr p} {
set temp [lindex $r $p]
set pos_x [lindex $temp 1]
set pos_y [lindex $temp 2]
set pos_z [expr [lindex $temp 3]+$z_shift]
part $p pos $pos_x $pos_y $pos_z type [lindex $part_type $p]
}

#Reassign charges and masses
for {set i 0} { $i < $n_part } { incr i} {
set type_mono [part $i print type]
 for {set j 0} { $j < $type_max } { incr j} {
 if {$type_mono==$j} {
 part $i mass [lindex $mass_mono $j]
 part $i q [lindex $charge_mono $j]
  } 
 }
}

#Rebond them
for {set p 0} {$p < $n_poly} {incr p} {
set n_start [expr $p*$n_mono]
set n_end [expr $n_start+$n_mono]
 for {set i [expr $n_start+1]} {$i < $n_end} {incr i} {
 part $i bond 0 [expr $i-1]
 }
}

#Change to desired temperature gradually
set target_temp 1.
set temp_decr [expr (4.0-$target_temp)/100.]
for {set i 0} { $i < 100 } { incr i} {
set kBT [expr $kBT-$temp_decr]
thermostat langevin $kBT $gamma
integrate 100
puts "[thermostat]"
}
set kBT $target_temp
thermostat langevin $kBT $gamma
setmd time_step $time_step_equi
puts "All set to go..."
###########################################################################################################
set obs_en [open "/home/pinaki/Documents/post_doc/codes/espresso_tutorials/LLPS/FUS/data/wildtype/temp1/energy.dat" "w"]
set vsf [open "/home/pinaki/Documents/post_doc/codes/espresso_tutorials/LLPS/FUS/data/wildtype/temp1/config.vsf" "w"]
set vtf [open "/home/pinaki/Documents/post_doc/codes/espresso_tutorials/LLPS/FUS/data/wildtype/temp1/config.vtf" "w"]
###########################################################################################################

set f [open "/home/pinaki/Documents/post_doc/codes/espresso_tutorials/LLPS/FUS/data/wildtype/temp1/config/config_0" "w"]
blockfile $f write particles {id pos type}
close $f
set tstart [setmd time]
puts $obs_en "[expr [setmd time]-$tstart] [analyze energy total] [analyze energy kinetic]"
writevsf $vsf
writevcf $vtf
############################################################
# 8 Integration                                            #
#                                                          #
############################################################
set n_steps 100
set n_equi 50

for {set i 0} { $i < $n_equi } { incr i} {
    puts $i
    integrate $n_steps
    puts $obs_en "[expr [setmd time]-$tstart] [analyze energy total] [analyze energy kinetic]"
set j [expr $i+1]
set f [open "/home/pinaki/Documents/post_doc/codes/espresso_tutorials/LLPS/FUS/data/wildtype/temp1/config/config_$j" "w"]
blockfile $f write particles {id pos type}
close $f

writevcf $vtf
}

close $obs_en
close $vsf
close $vtf
############################################################
