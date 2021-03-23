##########################################################################
#  Offline Analysis for getting the configuration from block files  ######
#  Pinakinarayan A P Swain, 2015                                    ######
##########################################################################
set in [open "/home/pinaki/scratch/pinaki/FUS/data/wildtype/temp1_dispersed/longtime1/config/config_5000" "r"]

set n [expr 163*100]

while {  [set btitle [ blockfile $in read auto] ] != "eof" } {
if {$btitle == "particles"} {
    
set out [open "/home/pinaki/scratch/pinaki/FUS/data/wildtype/temp1_dispersed/longtime1/config/config_5000.dat" "w"]

for {set i 0} {$i < $n} {incr i} {
puts $out "[part $i print pos]"
}
close $out
}
}

close $in
