import gmsh
import sys
import os
import numpy as np
import time
import shutil
import fileinput

def generate_grid(refinement_factor=1.0, grid_type='QT', spe_case='A', save_mesh=True):
    """
    Generate grid for SPE11 case using Gmsh

    Parameters:
        refinement_factor (float): Factor to control mesh refinement (default=1.0)
        grid_type (str): Either 'QT' for quad/triangle or 'T' for triangle-only
        spe_case (str): Either 'A' or 'B' for SPE11A or SPE11B
        save_mesh (bool): Whether to save the mesh to file (default=True)
    """
    import gmsh
    import os

    # Start timer
    start_time = time.time()

    # Initialize Gmsh
    gmsh.initialize()
    
    try:
        # Get the directory of the current script and construct paths
        script_dir = os.path.dirname(os.path.abspath(__file__))
        geo_file = os.path.join(script_dir, '..', '..', 'data', 'geo-files', 'spe11a.geo')
        
        # Format refinement factor for filename (e.g., 0.3 -> "0_3")
        ref_str = f"{refinement_factor}".replace(".", "_")
        
        if grid_type == 'QT':
            # Create a temporary copy of the .geo file
            temp_geo = os.path.join(script_dir, '..', '..', 'data', 'temp', 'temp_spe11a.geo')
            os.makedirs(os.path.dirname(temp_geo), exist_ok=True)
            shutil.copy2(geo_file, temp_geo)
            
            # Modify the refinement factor in the temporary file
            with fileinput.FileInput(temp_geo, inplace=True) as file:
                for line in file:
                    if 'DefineConstant[ refinement_factor =' in line:
                        print(f'DefineConstant[ refinement_factor = {refinement_factor} ];')
                    else:
                        print(line, end='')
            
            # Load the modified .geo file
            gmsh.open(temp_geo)
        else:
            # For triangle meshes, load original file and use mesh size factor
            gmsh.open(geo_file)
            gmsh.option.setNumber("Mesh.MeshSizeFactor", refinement_factor/5.0)
        
        # Enable parallel meshing with multiple threads
        gmsh.option.setNumber("General.NumThreads", 20)  # Adjust based on your CPU
        
        # Set mesh options based on grid type
        if grid_type == 'QT':
            alg_str = 'pb'  # Parallel packing + blossom
            gmsh.option.setNumber("Mesh.Algorithm", 9)  # Parallel packing
            gmsh.option.setNumber("Mesh.RecombinationAlgorithm", 1)  # Blossom
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
        if grid_type == 'QT':
            gmsh.model.mesh.recombine()
        
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
        
        # Save mesh if requested
        if save_mesh:
            gmsh.write(output_file)
        else:
            # Save temporary file in Gmsh format for visualization with consistent name
            temp_file = os.path.join(script_dir, '..', '..', 'data', 'temp', 'temp_mesh.msh')
            # Create temp directory if it doesn't exist
            temp_dir = os.path.dirname(temp_file)
            if not os.path.exists(temp_dir):
                os.makedirs(temp_dir)
            gmsh.write(temp_file)
            print(f"\nTemporary mesh saved to: {temp_file}")
            print("You can open this file in Gmsh GUI to visualize the mesh")
        
        # Get elements
        elementTypes, elementTags, elementNodes = gmsh.model.mesh.getElements()

        # Dictionary of element types
        elemType_to_name = {
            1: "2-node line",
            2: "3-node triangle",
            3: "4-node quadrangle",
            4: "4-node tetrahedron",
            5: "8-node hexahedron",
            8: "3-node second order line",
            9: "6-node second order triangle",
            10: "9-node second order quadrangle",
            15: "1-node point"
        }

        # Print all element types and counts
        print("\nElement types found:", elementTypes)
        for i, elementType in enumerate(elementTypes):
            numElements = len(elementTags[i])
            name = elemType_to_name.get(elementType, f"Unknown type {elementType}")
            print(f"Number of {name}: {numElements}")

        # Print total number of elements
        total_elements = sum(len(tags) for tags in elementTags)
        print(f"\nTotal number of elements: {total_elements}")
        
        # Count triangles and quads
        num_triangles = sum(len(elementTags[i]) for i, elemType in enumerate(elementTypes) if elemType == 2)
        num_quads = sum(len(elementTags[i]) for i, elemType in enumerate(elementTypes) if elemType == 3)
        print(f"Number of cells (triangles + quads): {num_triangles + num_quads}")
        
        # Print elapsed time
        elapsed_time = time.time() - start_time
        print(f"\nGrid generation completed in {elapsed_time:.2f} seconds")
        
    finally:
        gmsh.finalize()
        # Clean up temporary file if it exists
        if grid_type == 'QT' and os.path.exists(temp_geo):
            os.remove(temp_geo)

if __name__ == "__main__":
    # Parse command line arguments if called directly
    refinement = float(sys.argv[1]) if len(sys.argv) > 1 else 1.0
    grid_type = sys.argv[2] if len(sys.argv) > 2 else 'QT'
    spe_case = sys.argv[3] if len(sys.argv) > 3 else 'B'
    save_mesh = True if len(sys.argv) <= 4 else sys.argv[4].lower() == 'true'
    
    if grid_type not in ['QT', 'T']:
        raise ValueError("grid_type must be either 'QT' or 'T'")
    if spe_case.upper() not in ['A', 'B']:
        raise ValueError("spe_case must be either 'A' or 'B'")
    
    generate_grid(refinement, grid_type, spe_case, save_mesh)
