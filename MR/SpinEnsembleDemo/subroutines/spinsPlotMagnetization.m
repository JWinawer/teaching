function spinsPlotMagnetization(t, M)
% Plot the longitudinal and transverse magnetization against time.
%
%   spinsPlotMagnetization(t, M)
%
% Draws in the current axes. t is the full time vector, in ms, and M is the
% history so far, nStepsSoFar x 3. Two line objects are created once and
% then updated, rather than adding a new segment per frame.
%
% See also spinsAnimate

ax = gca;
nSoFar = size(M, 1);

Mz  = M(:,3);
Mxy = vecnorm(M(:,1:2), 2, 2);

handles = ax.UserData;

if isstruct(handles) && isfield(handles, "mz") && all(isvalid([handles.mz handles.mxy]))

    set(handles.mz, XData=t(1:nSoFar), YData=Mz);
    set(handles.mxy, XData=t(1:nSoFar), YData=Mxy);

else

    handles = struct();
    handles.mz = plot(ax, t(1:nSoFar), Mz, "g.-");
    hold(ax, "on");
    handles.mxy = plot(ax, t(1:nSoFar), Mxy, "r.-");
    hold(ax, "off");

    axis(ax, [0 max(t) -1 1.1]);
    axis(ax, "square");
    xlabel(ax, "Time (ms)");
    ylabel(ax, "Magnetization");
    legend(ax, ["Mz", "Mxy"], AutoUpdate="off", Location="southwest");

    ax.UserData = handles;

end

end
