import gmsh
import sys

# Initialize Gmsh
gmsh.initialize()

# Check if the input file and output file are provided
if len(sys.argv) != 3:
    print("Usage: python transform_mesh.py <input_mesh_file> <output_mesh_file>")
    gmsh.finalize()
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

# Open the existing mesh file
gmsh.open(input_file)

# Get all the nodes and their coordinates
node_tags, node_coords, _ = gmsh.model.mesh.getNodes()

# Apply the transformation function
transformed_coords = []
for i in range(len(node_coords) // 3):
    u = node_coords[3 * i]
    v = node_coords[3 * i + 1]
    w = node_coords[3 * i + 2]
    new_w = w + 150 * (1 - (v / 2500 - 1) ** 2) + v / 500
    transformed_coords.extend([u, v, new_w])

# Remove the existing nodes
gmsh.model.mesh.clear()

# Add the transformed nodes back
gmsh.model.mesh.addNodes(3, 1, node_tags, transformed_coords)

# Save the transformed mesh to a new file
gmsh.write(output_file)

# Finalize Gmsh
gmsh.finalize()

