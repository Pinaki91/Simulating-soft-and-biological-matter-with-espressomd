#########################################################################
#  Analysis for monomer density histogram                               #
#  Pinakinarayan A P Swain, 2016                                        #
#########################################################################
set out [open "/home/pinaki/scratch/pinaki/FUS/data/wildtype/temp1_dispersed/longtime1/rho_z_temp1_dispersed_longtime1_frame4000to5000.dat" "w"]

set frame_no 1;
set n [expr 100.*163]
set boxl_z 600.

set z [list]
set z_min -300.
set z_max 300.
set n_bin 600.
set h [expr ($z_max-$z_min)/$n_bin]

set avg_density [list]
for {set i 0} {$i < $n_bin} {incr i} {
lappend avg_density 0.0
}

for {set k 4000} {$k<= 5000} {set k [expr $k+10]} {
#read kth configuration
set in [open "/home/pinaki/scratch/pinaki/FUS/data/wildtype/temp1_dispersed/longtime1/config/config_$k" "r"]
while {  [set btitle [ blockfile $in read auto] ] != "eof" } {

if { $btitle == "particles"} {

#Here we have all the information

puts "frame $k"

set count [list]
for {set i 0} {$i < $n_bin} {incr i} {
lappend count 0.0
}

#analyze get_folded_positions
set pos_z_folded [list]
for {set p 0} {$p < $n} {incr p} {
 set t [part $p print pos] 
 set pos_z [lindex $t 2]
 #puts "$pos_z"
 set im_no [expr floor($pos_z/$boxl_z)]
 #bringing it back to center box
 lappend pos_z_folded [expr $z_min+$pos_z-$im_no*$boxl_z]
 }

for {set p 0} {$p < $n} {incr p} {
 set pos_z_centered [expr [lindex $pos_z_folded $p]-0.0]
 set i [expr int(($pos_z_centered-$z_min)/$h)]
 set count [lreplace $count $i $i [expr [lindex $count $i]+1]]
 #puts "particle p, pos_z $pos_z_centered, bin $i"
 }
set avg_density [vecadd $avg_density $count]
} 
}
#blockfile loops
close $in
}
#config loop

set avg_density [vecscale [expr 1.0/(101.*$n*$h)] $avg_density]
for {set i 0} {$i < $n_bin} {incr i} {
  set z [expr $z_min+($i+0.5)*$h]
  puts $out "$z [lindex $avg_density $i]"
  }


close $out
exit
