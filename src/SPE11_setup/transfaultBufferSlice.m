function G = transfaultBufferSlice(G, varargin)
opt = struct('sliceOffset', 34);
opt = merge_options(opt,varargin{:});
dispif(true, "Slicing to add buffervolume...\n");

sliceOffset = opt.sliceOffset;
G.buffereps = sliceOffset;

xmin = min(G.nodes.coords(:,1));
xmax = max(G.nodes.coords(:,1));
ymin = min(G.nodes.coords(:,2));
ymax = max(G.nodes.coords(:,2));
xavg = (xmin+xmax)/2;
yavg = (ymin+ymax)/2;
[G, gix] = sliceGrid(G, {[xmin+sliceOffset, yavg, 0], [xmax-sliceOffset, yavg, 0]}, ...
    'normal', [1 0 0]);
G.cells.tag = G.cells.tag(gix.parent.cells);
[G, gix] = sliceGrid(G, {[xavg, ymin+sliceOffset, 0], [xavg, ymax-sliceOffset, 0]}, ...
    'normal', [0 1 0]);
dispif(true, "Done slicing.\n");
G.cells.tag = G.cells.tag(gix.parent.cells);
end