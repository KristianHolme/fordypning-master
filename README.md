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
        - Recommened to refine schedule by changing the last three schedule steps in ```spe11-decks/csp11b/isothermal/130_62/CSP11B_DISGAS.DATA``` ($100$ times is more than enough, and what is assumed in some plotting scripts):
        ```
        #change this
        TSTEP
        1*9125.0 #or 1*346750
        #to this
        TSTEP
        100*91.250 #or 100*3467.50
        ```

        
- Run setup.m
    - Adds the scripts-folder as an mrst module called masterthesis and adds it to the path
    Turns the MRST option 'useMEX' on, to utilize accelerated computations where possible.

## Generating grids
- ```GenerateCutCellGrid``` and ```GeneratePEBIGrid``` for cut-cell and PEBI-grids
- ```GenerateStructuredGrid``` for generation of structured grid for SPE11C
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
    - 'p' (experimental) for "PEBI-style" transmissibility for PEBI-grids (from GeneratePEBIGrid). Similar to 'cc' but cell centers are exchanged for Voronoi sites.

For more options, see 'runSims.m'. The main options to change are ```gridcase(s)``` for different grids and ```pdisc(s)``` for different pressure discretizations.
