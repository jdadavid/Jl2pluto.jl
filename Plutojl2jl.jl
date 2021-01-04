# Plutojl2jl.jl : Convert a Pluto notebook file to ordinary Julia file.
#
#  Call by :
#
#   julia Plutojl2jl.jl [-h] [-i] [-f] inputplutonb.jl [output.jl]
#
#   If "output.jl" unspecified and no "-i", aborts.
#   If "-i", do the conversion inplace (so, also assume "-f")
#   If [no "-i and ] no "-f", do not overwrite existing "output.jl"
#   If                  "-f", force write "output.jl", erasing it if already existing
#
#	If "-k" keep one blank line between cells (else delete both two blank lines between cells)

# J.D.A.DAVID 04/01/2021
# Conception following asking of Rafael Guerra

# Note (04/01/2021) infrastructing for reading from stdin/ writing to stdout partielly in place / not yet working ...


# From  https://github.com/fonsp/Pluto.jl/blob/master/src/notebook/Notebook.jl
const _notebook_header = "### A Pluto.jl notebook ###"
# We use a creative delimiter to avoid accidental use in code
# so don't get inspired to suddenly use these in your code!
const _cell_id_delimiter = "# ╔═╡ "
const _order_delimiter = "# ╠═"
const _order_delimiter_folded = "# ╟─"
const _cell_suffix = "\n\n"

# defined by JDAD
const _cell_order_delimiter = "# ╔═╡ Cell order:"


msghelp="""
Plutojl2jl.jl : Convert a Pluto notebook file to ordinary Julia file.

 Call by :

  julia Plutojl2jl.jl [-h] [-i] [-f] [-k] inputplutonb.jl [output.jl]

  If "output.jl" unspecified and no "-i", aborts.
  If "-i", do the conversion inplace (so, also assume "-f")
  If [no "-i and ] no "-f", do not overwrite existing "output.jl"
  If                  "-f", force write "output.jl", erasing it if already existing
  
  If "-k" keep one blank line between cells (else delete both two blank lines between cells)

"""

mhelp() = (@info msghelp)

if length(ARGS) < 1; @info("plutojl2jl : No option nor inputfile, aborting\n"); mhelp(); exit(3); end

if ARGS[1] == "-h"; mhelp(); exit(0); end

inplace=false
enableoverwrite=false

if ARGS[1] == "-i"; inplace=true; popfirst!(ARGS) end

if length(ARGS) < 1; @info "plutojl2jl : No option nor inputfile, aborting"; mhelp(); exit(4); end
if ARGS[1] == "-f"; enableoverwrite=true; popfirst!(ARGS) end

if length(ARGS) < 1; @info "plutojl2jl : No inputfile, aborting"; mhelp(); exit(5); end
inputfile=ARGS[1]

if inputfile == "-"    ; inputfile=stdin; end
if inputfile == "stdin"; inputfile=stdin; end

if inplace
	if length(ARGS) > 1; @info "plutojl2jl : Inplace, so only input should be specified, aborting\n"; mhelp(); exit(6); end
	if enableoverwrite; @info "plutojl2jl : -f (forced overwrite) redundant with Inplace\n";  end
	outputfile=inputfile
else
	if length(ARGS) > 2; @info "plutojl2jl : Only input and output should be specified, aborting\n"; mhelp(); exit(7); end
	if length(ARGS) <2 ; @info "plutojl2jl : No output specified, aborting\n"; mhelp(); exit(8); end
	outputfile=ARGS[2]
	if outputfile == "-"    ; inputfile=stdout; end
	if outputfile == "stdin"; inputfile=stdout; end
	if outputfile == inputfile && !enableoverwrite; @info "plutojl2jl : input and output are same -- no overwrite -- aborting\n"; exit(9); end
	if outputfile == inputfile &&  enableoverwrite; @info "plutojl2jl : input and output are same -- overwrite ok -- doing inplace\n"; inplace=true; end
end



if !isfile(inputfile)
	@info "plutojl2jl : inputfile $inputfile does not exists, aborting"
	exit(10)
end
if filesize(inputfile) < 2
	@info "plutojl2jl : inputfile $inputfile is empty, aborting"
	exit(11)
end

lines=readlines(inputfile)

if lines[1] == _notebook_header
	if lines[2][1:3] == "# v" && lines[3] ==""
		# notebook OK
		deleteat!(lines,[1,2,3])
	else
		@info "plutojl2jl : Malformed Pluto notebook (2nd/3rd lines notok), aborting."
		exit(12)
	end
else
	@info "plutojl2jl : Not a Pluto noteboook, doing nothing.";
	exit(0)
end

# Deletion of Cell Order lines (should be last lines in file)
numcods=findall(x -> x == _cell_order_delimiter, lines)
i=numcods[1]
deleteat!(lines,i:size(lines,1))
if  lines[i-1] == "" && lines[i-2] == ""
		deleteat!(lines,[i-2, i-1])
end

# Deletion of each cell marker begin, and possibly cell ends (empty) lines
numcids=reverse(findall(x -> startswith(x,_cell_id_delimiter), lines))
@show numcids
for i in numcids
    deleteat!(lines,[i])
	if  lines[i-1] == "" && lines[i-2] == ""
		if keepblank
		# we keep one empty line
			deleteat!(lines,i-1)
		else
			deleteat!(lines,[i-2, i-1])
		end
	end
end


if inplace
	nothing
else
	if isfile(outputfile)
		if !enableoverwrite
			@info "plutojl2jl : outputfile $outputfile already exists, no forced override,  aborting"
			exit(1)
		else
			@info "plutojl2jl : overwriting $(outputfile) as authorised"
		end
	end
end

iomode= outputfile == stdout ? "w+" : "w"
open(outputfile, iomode) do io
	foreach(line -> println(io, line),lines)
end

@info "plutojl2jl : Julia ordinary file $outputfile written (from notebook $inputfile)."


