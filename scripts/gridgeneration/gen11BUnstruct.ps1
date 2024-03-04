param (
    [float[]]$refs,
    [int]$alg = 6  # Set the default alg to 6 (Frontal). Change this number as needed.
)

$dir = Get-Location
$savedir = Join-Path (Split-Path -Parent $dir) -ChildPath "..\grid-files"
Set-Location .\..\..\..\11thSPE-CSP\geometries\
foreach ($refinement_factor in $refs) {
    $str_refinement_factor = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, "{0}", $refinement_factor)
    $safe_refinement_factor = $str_refinement_factor -replace '\.', '_'
    $filename = "spe11b_ref" + $safe_refinement_factor + "_alg" + $alg + ".m"
    $savepath = Join-Path -Path $savedir -ChildPath $filename
    Write-Host Savepath: $savepath
   
    Write-Host Converting with Gmsh
    # Add the -setnumber Mesh.Algorithm $alg to specify the mesh alg
    & gmsh -2 spe11b.geo -setnumber refinement_factor $refinement_factor -setnumber Mesh.Algorithm $alg -format 'm' -o $savepath
}
Set-Location $dir
