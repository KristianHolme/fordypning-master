using DelaunayTriangulation
using CairoMakie
using MAT

file = matopen("pointData/points_898x120.mat")
Pts = read(file, "Pts")
close(file)

tri = triangulate(Pts')

fig = Figure(fontsize=24)
ax = Axis(fig[1, 1], title="SPE11 grid", titlealign=:left, width=400, height=400)
triplot!(ax, tri, show_convex_hull=true, show_ghost_edges=true)
fig
fig = Figure()
vorn = voronoi(tri, true)
ax = Axis(fig[1, 1], title="(f): Voronoi tessellation", titlealign=:left, width=400, height=400)
voronoiplot!(ax, vorn, show_generators=false)
current_figure()

fig = Figure(fontsize=24)

## Unconstrained example: Just some random points 
pts = randn(2, 500)
tri = triangulate(pts)
ax = Axis(fig[1, 1], title="(a): Unconstrained", titlealign=:left, width=400, height=400)
triplot!(ax, tri, show_convex_hull=true, show_ghost_edges=true)