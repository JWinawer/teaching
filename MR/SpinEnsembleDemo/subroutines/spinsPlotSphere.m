function spinsPlotSphere(spins, M, isRotatingFrame)
% Draw the individual spins and the bulk magnetization vector they sum to.
%
%   spinsPlotSphere(spins, M, isRotatingFrame)
%
% Draws in the current axes. spins is nSpins x 3 and M is the 1 x 3 bulk
% magnetization, in units of the equilibrium magnetization. If
% isRotatingFrame is true (default false), the transverse axes are labeled
% X' and Y', the usual names for the axes of the rotating reference frame,
% and the plot is titled "Rotating frame". Z needs no prime, because the
% frame rotates about it.
%
% The graphics objects are built once and then updated in place on later
% calls. Rebuilding a scatter of several thousand points every frame is by
% far the slowest part of the animation, so this is what keeps it smooth.
%
% See also spinsAnimate

arguments
    spins (:,3) double
    M (1,3) double
    isRotatingFrame (1,1) logical = false
end

ax = gca;
handles = ax.UserData;

if isstruct(handles) && isfield(handles, "spins") && all(isvalid([handles.spins handles.total]))

    set(handles.spins, XData=spins(:,1), YData=spins(:,2), ZData=spins(:,3));
    set(handles.total, XData=[0 M(1)], YData=[0 M(2)], ZData=[0 M(3)]);
    set(handles.transverse, XData=[0 M(1)], YData=[0 M(2)], ZData=[0 0]);
    set(handles.longitudinal, XData=[0 0], YData=[0 0], ZData=[0 M(3)]);

else

    spinGray   = 0.2*[1 1 1];
    spinAlpha  = 0.8;
    vectorWidth = 4;

    handles = struct();
    handles.spins = scatter3(ax, spins(:,1), spins(:,2), spins(:,3), 100, ".", ...
        MarkerFaceColor=spinGray, MarkerFaceAlpha=spinAlpha, ...
        MarkerEdgeColor=spinGray, MarkerEdgeAlpha=spinAlpha);

    hold(ax, "on");
    plotAxes(ax);

    % Bulk magnetization: total, transverse component, longitudinal component
    handles.total        = plot3(ax, [0 M(1)], [0 M(2)], [0 M(3)], "k-", LineWidth=vectorWidth);
    handles.transverse   = plot3(ax, [0 M(1)], [0 M(2)], [0 0], "r-", LineWidth=vectorWidth);
    handles.longitudinal = plot3(ax, [0 0], [0 0], [0 M(3)], "g-", LineWidth=vectorWidth);
    hold(ax, "off");

    axis(ax, [-1 1 -1 1 -1 1]);
    axis(ax, "square");
    if isRotatingFrame
        % Short labels, with the frame named once in the title: a label like
        % "Y' (rotating frame)" runs off the edge of the figure.
        xlabel(ax, "X'");
        ylabel(ax, "Y'");
        title(ax, "Rotating frame", FontWeight="normal");
    else
        xlabel(ax, "X");
        ylabel(ax, "Y");
    end
    zlabel(ax, "Z");
    set(ax, FontSize=16, View=[-10 15]);

    ax.UserData = handles;

end

end

function plotAxes(ax)
% Draw the three coordinate axes through the origin
plot3(ax, [-1 1], [0 0], [0 0], "k-");
plot3(ax, [0 0], [1 -1], [0 0], "k-");
plot3(ax, [0 0], [0 0], [-1 1], "k-");
end
