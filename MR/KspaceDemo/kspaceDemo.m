function [params, result] = kspaceDemo(params)
% A demonstration of MRI imaging principles and artifacts, with a dialog.
%
%   kspaceDemo()
%   [params, result] = kspaceDemo(params)
%
% Opens a dialog of scan settings, simulates the scan, and plots the result.
% If "Keep dialog open" is ticked, the dialog reopens with the last settings
% after each run. For scripts, use kspaceSimulate, which runs the same
% simulation without the dialog.
%
% Inputs
%   params - (optional) starting settings, in everyday units. Default:
%            kspaceDefaultParams().
%
% Outputs
%   params - the settings from the last run
%   result - the output of kspaceSimulate for the last run. It is also stored
%            in the figure's UserData.
%
% Sample images ('face.jpg' and 'brain.jpg') downloaded from Google Image
% search.
%
% Please feel free to improve this demo if you know how to do so. -JW
%
% Winawer, Vistasoft, 2009
%
% See also kspaceSimulate, kspaceDefaultParams

arguments
    params (1,1) struct = kspaceDefaultParams()
end

kspaceCheckPaths();

f = figure(Name="k-space demo", NumberTitle="off");
screenSize = get(groot, "ScreenSize");
f.Position = [screenSize(1:2) + 40, 0.6*screenSize(3:4)];

result = [];
keepGoing = true;
while keepGoing
    [params, ok] = kspaceParamsGUI(params);
    if ~ok || ~isvalid(f)
        return
    end
    result = kspaceSimulate(params, Figure=f);
    f.UserData = result;
    keepGoing = params.loop;
end

end
