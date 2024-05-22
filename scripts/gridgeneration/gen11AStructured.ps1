#generate multiple structured grids
#given a number of nx-values (resolution in x-direction) and ny-values, generates grids with all combination of resolutions
param(
    [int[]]$nxValues,
    [int[]]$nyValues
)
# should be called from the geometries folder?
# Loop through all combinations of nx and ny values
foreach ($nx in $nxValues) {
    foreach ($ny in $nyValues) {
        # Run Python script for the current combination of nx and ny
        python make_structured_mesh.py --variant A -nx $nx -ny $ny

        # Define filenames
        $mshFileName = "spe11a_structured.msh"
        $newFileName = "spe11a_struct$nx" + "x" + "$ny.m"

        # Convert using gmsh
        gmsh $mshFileName -save -o $newFileName

        # Move file to grid-files folder
        Move-Item -Path $newFileName -Destination ".\..\..\grid-files\"
    }
}

