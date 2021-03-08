#############################################################
# Simulating Lennard-Jones particles
#Pinaki Swain, March 2020
#############################################################
source /home/pinaki/Documents/post_doc/codes/tutorials/lj/functions.tcl
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
set n_part 108
setmd time_step 0.01
set skin 0.4 
setmd skin $skin
set kBT 1.0
set gamma 1.0
thermostat langevin $kBT $gamma
set density 0.4
set box_length [expr pow($n_part/$density,1.0/3.0)+2*$skin]
puts "density = $density box_length = $box_length"
setmd box_l $box_length $box_length $box_length

#############################################################
# 3 Initializing ESPResSo                                   #
#                                                           #
#############################################################
puts [setmd box_l]
puts [setmd time_step]
puts [setmd skin]
puts [integrate]
puts [thermostat]

############################################################################
# 4 Interactions                                            
#Type for specific interaction between different particles and constraints
#0 : for all monomers belonging to polymer
############################################################################
set rcap 1.12246
set rcut 2.5
inter forcecap individual
inter 0 0 lennard-jones 1.0 1.0 $rcut 0.0 0.0 $rcap 0.0

puts "BEFORE WARM UP: [constraint]"
#############################################################
# Creating Particles                                        #
#############################################################
for {set i 0} {$i < $n_part} {incr i} {
   set pos_x [expr rand()*$box_length]
   set pos_y [expr rand()*$box_length]
   set pos_z [expr rand()*$box_length]
   part $i pos $pos_x $pos_y $pos_z q 0.0 type 0 
}
#############################################################
# Warmup                                                    #
#                                                           #
#############################################################
set warm_loop 300
set warm_step 200
set del_r [expr $rcap/$warm_loop]
for { set j 0 } { $j < $warm_loop} { incr j } {
    inter forcecap individual
    integrate $warm_step   
    set rcap [expr $rcap-$del_r]
    inter 0 0 lennard-jones 1.0 1.0 $rcut 0.0 0.0 $rcap 0.0
    puts "Warm up integration $j"    
}
puts "AFTER WARM UP: [constraint]"
set rcap 0
inter forcecap 0

###########################################################################################################
set obs_en [open "/home/pinaki/Documents/post_doc/codes/tutorials/lj/data/energy.dat" "w"]
set vsf [open "/home/pinaki/Documents/post_doc/codes/tutorials/lj/data/config.vsf" "w"]
set vtf [open "/home/pinaki/Documents/post_doc/codes/tutorials/lj/data/config.vtf" "w"]
#####################################################################################################################
set n_steps 1000
set n_cycle_equi 10
set n_cycle_prod 20
#equilibriation
for {set i 0} { $i < $n_cycle_equi } { incr i} {
    puts $i
    integrate $n_steps
}

#saving configurations for offline analysis
set f [open "/home/pinaki/Documents/post_doc/codes/tutorials/lj/data/config/config_0" "w"]
blockfile $f write particles {id pos}
close $f
set tstart [setmd time]
puts $obs_en "[expr [setmd time]-$tstart] [analyze energy total] [analyze energy kinetic]"
writevsf $vsf
writevcf $vtf

for {set i 0} { $i < $n_cycle_prod } { incr i} {
    puts $i
    integrate $n_steps
    puts $obs_en "[expr [setmd time]-$tstart] [analyze energy total] [analyze energy kinetic]"
set j [expr $i+1]
set f [open "/home/pinaki/Documents/post_doc/codes/tutorials/lj/data/config/config_$j" "w"]
blockfile $f write particles {id pos}
close $f
writevcf $vtf
}

close $obs_en
close $vsf
close $vtf


