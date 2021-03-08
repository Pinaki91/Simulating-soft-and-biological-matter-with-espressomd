set in [open "|gzip -cd /home/pinaki/espresso-polymer/lj/data/case4/equi.block.gz" "r"]
set out [open "/home/pinaki/espresso-polymer/lj/data/case4/rdf.dat" "w"]

puts $out "#"
puts $out "#"
puts $out "# Radial Distribution Function "
puts $out "#"

set frame_no 1;
# rdf collect
for {set i 0} {$i < 100} {incr i}  { lappend avg_rdf 0; }
while {  [set btitle [ blockfile $in read auto] ] != "eof" } {
 if {$btitle == "variable"} {
     set times [setmd time]
     set boxl [lindex [setmd box_l] 0]
      puts "frame $frame_no"
    }
 if { $btitle == "particles"}   {
           # 
           # Here We have an access to all simulation information on given time 
	   # 
	      set group 0
	      set rmin 0.0
	      set rmax [expr 0.5*$boxl]
	      set rbin 100
	      set drdf [analyze rdf $group $group $rmin $rmax $rbin ]
	      set data_rdf [lindex $drdf 1]
	      set dsize [llength $data_rdf]
	          set rlist [list]
	          set rdflist [list]
              for {set i 0} {$i <$dsize} {incr i} {
	        lappend  rlist [lindex $data_rdf $i 0]
	        lappend  rdflist [lindex $data_rdf $i 1]
	      }
	       set avg_rdf [vecadd $avg_rdf  $rdflist]
       incr frame_no ;
    }
}
set avg_rdf [vecscale [expr 1.0/$frame_no]  $avg_rdf]
 foreach r $rlist value $avg_rdf { puts $out "$r  $value" }
close $in
close $out
exit
