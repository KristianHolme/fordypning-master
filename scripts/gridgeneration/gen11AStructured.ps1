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

        # Convert using gmsh (assuming gmsh can convert to .m, replace 'm' with correct format otherwise)
        gmsh $mshFileName -save -o $newFileName

        # Move file to grid-files folder
        Move-Item -Path $newFileName -Destination ".\..\..\grid-files\"
    }
}

