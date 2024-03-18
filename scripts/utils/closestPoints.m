function I = closestPoints(P1, P2)
%For each point in P2, find the closest point in P1, and return the indices
if ispc
  usermem = memory;
  availableMemGB = usermem.MemAvailableAllArrays/1073741824;
else
  [~,w] = unix('free | grep Mem');
  stats = str2double(regexp(w, '[0-9]*', 'match'));
  availableMemGB = stats(end)/1e6;
end
batchLimit = 0.04e9*availableMemGB; %seems to work on 32GB of memory, dont know how it scales
nx = size(P1, 1);
ny = size(P2, 1);
if ny*nx > batchLimit
  midpoint = round(ny/2);

  I1 = closestPoints(P1,P2(1:midpoint,:));
  I2 = closestPoints(P1,P2(midpoint+1:end,:));
  I = [I1;I2];
  return
end

d = sqrt(abs(bsxfun(@plus, sum(P1.^2,2),sum(P2.^2,2)') - 2*(P1*P2')));
dim = 1;
[~, I] = min(d, [], dim);
I = I';

end