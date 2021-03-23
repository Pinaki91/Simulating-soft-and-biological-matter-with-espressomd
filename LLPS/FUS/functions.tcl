# Copyright (C) 2010,2011,2012,2013 The ESPResSo project
#  
# This file is part of ESPResSo.
#  
# ESPResSo is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#  
# ESPResSo is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#  
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>. 
#
#############################################################
#                                                           #
#  Functions                                               #
#                                                           # 
#############################################################
proc save_sim {cfile parinfo range } {
# write all available sim information to channel cfile
# in block format
 blockfile $cfile write variable all
 blockfile $cfile write tclvariable all
 blockfile $cfile write particles $parinfo $range
 blockfile $cfile write interactions
 blockfile $cfile write bonds $range
 blockfile $cfile write random
 blockfile $cfile write seed
 blockfile $cfile write bitrandom
 blockfile $cfile write bitseed
}

proc save_sim1 {cfile parinfo range } {
# write all available sim information to channel cfile
# in block format
blockfile $cfile write variable all
blockfile $cfile write particles $parinfo $range
}

proc readData {filename} {
    set result {}
    set f [open $filename r]
    foreach line [split [read $f] \n] {
        lappend result $line
    }
    return $result
}

proc readfile {filename} {
    set f [open $filename]
    set data [read $f]
    close $f
    return $data
}
