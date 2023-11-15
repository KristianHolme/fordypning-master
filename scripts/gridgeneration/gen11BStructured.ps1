param(
    [int[]]$nxValues,
    [int[]]$nyValues
)

# Loop through all combinations of nx and ny values
foreach ($nx in $nxValues) {
    foreach ($ny in $nyValues) {
        # Run Python script for the current combination of nx and ny
        $dir = Get-Location
        Write-Host current dir $dir
        $savedir = Join-Path (Split-Path -Parent $dir) -ChildPath "..\grid-files"
        Write-Host savedir: $savedir
        Set-Location .\..\..\11thSPE-CSP\geometries\
        Write-Host using CSP scripts...
        python make_structured_mesh.py --variant B -nx $nx -ny $ny
        
        # Define filenames
        $mshFileName = "spe11b_structured.msh"
        $newFileName = "spe11b_struct$nx" + "x" + "$ny.m"
        
        # Convert using gmsh (assuming gmsh can convert to .m, replace 'm' with correct format otherwise)
        Write-Host Converting with Gmsh
        gmsh $mshFileName -save -o $newFileName
        
        # Move file to grid-files folder
        Move-Item -Path $newFileName -Destination $savedir
        Set-Location $dir
    }
}

