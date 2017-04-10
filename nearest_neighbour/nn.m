function output = nn(points, intersectionObj)
%Linear nearest neighbour method
%
%   Parameters
%   ----------
%   - points: double matrix
%     [p1, p2, ...]
%   - intersectionObj: Intersection
%     Has `haveIntersection` method
%
%   Returns
%   -------
%   - output: cell array of logical vectors
%     Each item is a logical vector that shwos neighbourhoods

numberOfPoints = size(points, 2);
output = cell(1, numberOfPoints);

% first point has no previous neighbours
output{1} = [];
for indexOfPoint = 2:numberOfPoints
    output{indexOfPoint} = zeros(1, indexOfPoint - 1, 'logical');
    currentPoint = points(:, indexOfPoint);

    for indexOfNeighbour = 1:(indexOfPoint - 1)
        output{indexOfPoint}(indexOfNeighbour) = ...
            intersectionObj.haveIntersection(currentPoint, points(:, indexOfNeighbour));
    end
end


end

