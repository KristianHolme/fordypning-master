import gmsh
import sys
import os
import numpy as np

def generate_grid(refinement_factor=1.0, grid_type='QT', spe_case='A'):
    """
    Generate grid for SPE11 case using Gmsh

    Parameters:
        refinement_factor (float): Factor to control mesh refinement (default=1.0)
        grid_type (str): Either 'QT' for quad/triangle or 'T' for triangle-only
        spe_case (str): Either 'A' or 'B' for SPE11A or SPE11B
    """
    import gmsh
    import os

    # Initialize Gmsh
    gmsh.initialize()
    
    try:
        # Get the directory of the current script and construct paths
        script_dir = os.path.dirname(os.path.abspath(__file__))
        geo_file = os.path.join(script_dir, '..', '..', 'data', 'geo-files', 'spe11a.geo')
        
        # Format refinement factor for filename (e.g., 0.3 -> "0_3")
        ref_str = f"{refinement_factor}".replace(".", "_")
        
        # Load and execute the .geo script
        gmsh.open(geo_file)
        
        
        gmsh.option.setNumber("Mesh.MeshSizeFactor", refinement_factor/5.0)
        
        
        # Set mesh options based on grid type
        if grid_type == 'QT':
            alg_str = 'pb'  # Parallel packing + blossom
            gmsh.option.setNumber("Mesh.Algorithm", 8)  # Parallel packing
            gmsh.option.setNumber("Mesh.RecombinationAlgorithm", 2)  # Blossom
            gmsh.option.setNumber("Mesh.RecombineAll", 1)
        else:  # Triangle grid
            alg_str = '5'  # Delaunay
            gmsh.option.setNumber("Mesh.Algorithm", 5)  # Delaunay
            gmsh.option.setNumber("Mesh.RecombineAll", 0)
        
        # Set output filename based on SPE case
        output_file = os.path.join(
            script_dir, '..', '..', 'data', 'grid-files',
            f'spe11{spe_case.lower()}_ref{ref_str}_alg{alg_str}.m'
        )
        
        # Generate the mesh
        gmsh.option.setNumber("Mesh.SaveAll", 1)
        gmsh.model.mesh.generate(2)  # 2D mesh
        
        # Scale mesh if SPE11B
        if spe_case.upper() == 'B':
            # Create transformation matrix for scaling
            # Format: [3000x, 0, 0, 0, 0, 1000y, 0, 0, 0, 0, 1z, 0]
            transform = [
                3000, 0, 0, 0,  # First row: scale x by 3000
                0, 1000, 0, 0,  # Second row: scale y by 1000
                0, 0, 1, 0      # Third row: no change to z
            ]
            gmsh.model.mesh.affineTransform(transform)
        
        # Save as .m file
        gmsh.write(output_file)
        
    finally:
        gmsh.finalize()



if __name__ == "__main__":
    # Parse command line arguments if called directly
    refinement = float(sys.argv[1]) if len(sys.argv) > 1 else 1.0
    grid_type = sys.argv[2] if len(sys.argv) > 2 else 'QT'
    spe_case = sys.argv[3] if len(sys.argv) > 3 else 'B'
    
    if grid_type not in ['QT', 'T']:
        raise ValueError("grid_type must be either 'QT' or 'T'")
    if spe_case.upper() not in ['A', 'B']:
        raise ValueError("spe_case must be either 'A' or 'B'")
    
    generate_grid(refinement, grid_type, spe_case) 
    # generate_grid(0.19, 'T', 'B') 
