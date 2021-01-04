# Jl2pluto.jl : Convert an ordinary Julia file to Pluto notebook.

Call by :

  julia Jl2pluto [-f] inputfile.jl [outputplutonb.jl]

  If unspecified, outputplutonb.jl  defaults to "inputfile-pluto.jl"
  
  If no "-f", do not overwrite existing output notebook
  
  If    "-f", force write output notebook, erasing it if already existing
  
  
# Plutojl2jl.jl : Convert a Pluto notebook file to ordinary Julia file.

 Call by :

  julia Plutojl2jl.jl [-h] [-i] [-f] [-k] inputplutonb.jl [output.jl]

  If "output.jl" unspecified and no "-i", aborts.
  If "-i", do the conversion inplace (so, also assume "-f")
  If [no "-i and ] no "-f", do not overwrite existing "output.jl"
  If                  "-f", force write "output.jl", erasing it if already existing
  
  If "-k" keep one blank line between cells (else delete both two blank lines between cells)
