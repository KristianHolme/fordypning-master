param (
    [float[]]$refinement_factors,
    [int]$algorithm = 6  # Set the default algorithm to 6 (Frontal). Change this number as needed.
)

foreach ($refinement_factor in $refinement_factors) {
    $str_refinement_factor = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, "{0}", $refinement_factor)
    $safe_refinement_factor = $str_refinement_factor -replace '\.', '_'
    $filename = ".\..\..\grid-files\spe11b_ref" + $safe_refinement_factor + "_alg" + $algorithm + ".m"

    # Add the -setnumber Mesh.Algorithm $algorithm to specify the mesh algorithm
    & gmsh -2 spe11b.geo -setnumber refinement_factor $refinement_factor -setnumber Mesh.Algorithm $algorithm -format 'm' -o $filename
}
