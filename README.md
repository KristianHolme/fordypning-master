# Fordypningsoppgave/masteroppgave
![animation](Media/BsimPEBI.gif)

This repository contains files for creating different kind of grids, and running SPE11 simulations in Matlab/MRST to compare the effects of different grids and discretization choices.

## To run files (hopefully):
- Rename 'config-template.JSON' to 'config.JSON' and modify it to suit your setup
    - output_folder: folder where output from simulations are stored
    - spe11utils_folder: (for SPE11A simulations) folder of the spe11-utils repo (cloned from SINTEF-MRST-BitBucket)
    - decksave_folder: folder to save deck files to (as .mat-files). for example spe11utils_folder\deck, leave as empty string if you don't mind converting from the .DATA file each time (usually doesn't take a lot of time)
    - repo_folder: the folder where this repo is cloned.
    - geo_folder: the folder containing the spe11a.geo file. Can be found in the SPE11 CSP repo (https://github.com/Simulation-Benchmarks/11thSPE-CSP/)
    - spe11decks_folder: the folder containing the spe11-decks repo (https://github.com/sintefmath/spe11-decks)
        - The schedule timesteps are modified so that both injection periods and the settling period are all 100 steps each.

        
- Run setup.m
    - Adds the project files to the matlab path
    - Turns the MRST option 'useMEX' on, to utilize accelerated computations where possible.
    - makes sure the ./data/grid-files directory exists
## MRST functions
A combination of the development version of MRST hosted on bitbucket, and the 2023-b release was used. Some functions are modified.
The modified MRST functions are in the folder ```src/MRST_functions```. Eventually, some of these modifications may find their way into an official release of MRST.
## Dependencies/Related software
The scripts and functions in this repository depend on a number of packages. The main dependency is [MRST](https://www.sintef.no/projectweb/mrst/), the Matlab Reservoir Simulation Toolbox, developed at [SINTEF Digital](https://www.sintef.no/en/digital/departments-new/department-of-mathematics-and-cybernetics/research-group-applied-computational-science/). Some modifications to MRST functionality has been made, and some other packages and files have been used:
1. For generating PEBI-grids, a [fork](https://github.com/KristianHolme/UPR) of the MRST module UPR has been made. 
    - The main modifications are bugfixes and performance improvements, in addition to some modifications to ease the prototyping process.
2. The [spe11-decks repo](https://github.com/sintefmath/spe11-decks) for input deck(s).
3. [Jutul.jl](https://github.com/sintefmath/Jutul.jl)/[JutulDarcy.jl](https://github.com/sintefmath/JutulDarcy.jl) for accelerated computations in julia.
4. [CSP11_JutulDarcy.jl](https://github.com/sintefmath/CSP11_JutulDarcy.jl/tree/SPE11C_input) for running compositional models. (branch SPE11C_input for SPE11C support.)
5. [The official SPE11 CSP repo](https://github.com/Simulation-Benchmarks/11thSPE-CSP/) for ```.geo```-files describing the geometry of the reservoirs, and for grid generation scripts.
6. [multilevelOT](https://github.com/liujl11git/multilevelOT) was used for efficiently calculating the [Earth Movers Distance](https://en.wikipedia.org/wiki/Earth_mover%27s_distance) between different mass distributions from different simulations. (Not included in repo)
7. [tightfig(hfig)](https://se.mathworks.com/matlabcentral/fileexchange/34055-tightfig-hfig) for making nicer plots. (Not included in repo)
8. A modified version of [table2latex.m](https://se.mathworks.com/matlabcentral/fileexchange/69063-matlab-table-to-latex-conversor) is used for some tables (included in repo).



## Generating grids
- ```generateCutCellGrid``` and ```generatePEBIGrid``` for cut-cell and PEBI-grids
- ```generateStructuredGrid``` for generating structured grids for SPE11C
- Powershell scripts in ```./scripts/gridgeneration/``` to generate structured/unstructured grids for SPE11A and B, using Gmsh and python.

## Example
The function 'basic_example.m contains example of grid generation and simulation.

pdisc (pressure discretization) can be changed to the following:
- pressure discretization-methods:
    - '' for TPFA
    - 'cc' for ECLIPSE/INTERSECT TPFA (face interp. point is int.sct. between face and line between cell centers).
    - 'hybrid-avgmpfa' for TPFA around wells and avgMPFA elsewhere.
    - 'hybrid-mpfa' for MPFA around wells and avgMPFA elsewhere.
    - 'hybrid-ntpfa' for TPFA around well cells and along top pressure boundary.
    - 'p' (experimental) for "PEBI-style" transmissibility for PEBI-grids (from generatePEBIGrid). Similar to 'cc' but cell centers are exchanged for Voronoi sites.

For more options, see 'runSims.m'. The main options to change are ```gridcase(s)``` for different grids and ```pdisc(s)``` for different pressure discretizations.
