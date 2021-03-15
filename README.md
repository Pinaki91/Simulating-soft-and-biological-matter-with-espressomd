# Simulating-soft-and-biological-matter-with-espressomd
The tutoroals use espresso-3.3.1 version to perform coarse-grained molecular dynamics.
Espresso can be downloaded from here, http://espressomd.org/wordpress/
Please cite the original article if you use the programs for researchs, Limbach, H.J., Arnold, A., Mann, B.A. and Holm, C., 2006.
ESPResSo—an extensible simulation package for research on soft matter systems. Computer Physics Communications, 174(9), pp.704-727.

Steps to run the programs
1. espresso-3.3.1 user guide http://espressomd.org/wordpress/wp-content/uploads/2017/06/ESPResSo_3.3.1_UsersGuide.pdf
2. simple installation steps that worked for me on Ubuntu 16.04 and 18.04
  (a) Install tcl latest version from ubuntu software centre
  (b) Install fftw3
      sudo apt-get install libfftw3-dev libfftw3-doc
  (c) Install  espresso (tcl and fftw3 are required)
      download the compressed file from the link, http://download.savannah.gnu.org/releases/espressomd/
      uncompress it.
      open terminal.
      cd to espresso unpacked folder
     ./configure 
      make   
3. Download the lj folder to begin with. Save the functions.tcl and program file (e.g. lj_tutorial.tcl) in the same folder (e.g. test).
6. Execute the program from the terminal by
   /path-to-espresso-directory/./Espresso /path-to-your-home-folder/test/lj_tutorial.tcl
 
However, running the programs successfully does not guarentee that the results are physically meaningful. I recommend reading first four chapters from the book "Understanding molecularsimulation : from algorithms to applications." by Daan Frenkel and Berend Smit to understand the basics. Using the code provided in the lj folder to reproduce the plot of different energies for NVE simulation of Lennard Jones particles(figure 4.3 in the second edition of the mentioned book) is a good start learning molecular dynamics.
