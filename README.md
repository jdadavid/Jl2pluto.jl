# Jl2pluto.jl

Jl2pluto.jl : Convert an ordinary Julia file to Pluto notebook.

Call by :

  julia Jl2pluto [-f] inputfile.jl [outputplutonb.jl]

  If unspecified, outputplutonb.jl  defaults to "inputfile-pluto.jl"
  
  If no "-f", do not overwrite existing output notebook
  
  If    "-f", force write output notebook, erasing it if already existing
  
  
