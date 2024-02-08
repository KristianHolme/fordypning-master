function [moveablepoints, totNudgedPoints, totUnNudgedPoints] = nudgePoints(targetpoints, moveablepoints, varargin)
    opt = struct('verbose', true, ...
        'targetOccupation', true, ...
        'round', true);
    opt = merge_options(opt, varargin{:});

    numMov = size(moveablepoints, 1);
    numTarg = size(targetpoints, 1);
    availabletargets = true(numTarg,1);

    closenesslimit = 1; %1: always nudge
    totNudgedPoints = 0;

    for im = 1:numMov
        mpoint = moveablepoints(im,:);
        availabletargetPoints = targetpoints(availabletargets,:);
        diffs = availabletargetPoints - repmat(mpoint, sum(availabletargets),1);
        norms = sum(diffs .^2,2);
        [sortnorm, sortorder] = sort(norms);
        closeEnough = sortnorm(1) < sortnorm(2)*closenesslimit;
        if closeEnough
            totNudgedPoints = totNudgedPoints +1;
            localTargetIx = sortorder(1);
            globalTargetIxs = find(availabletargets);
            globalTargetIx = globalTargetIxs(localTargetIx);
            if opt.targetOccupation
                availabletargets(globalTargetIx) = false;
            end
            
            moveablepoints(im,:) = targetpoints(globalTargetIx,:);
        end
    end
    totUnNudgedPoints = size(moveablepoints,1) - totNudgedPoints;
    dispif(opt.verbose, 'Total nudged points:%d\n', totNudgedPoints);
end