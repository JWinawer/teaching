function kspaceCheckPaths()
% Add the demo's subfolders to the MATLAB path, if they are not there yet.
%
%   kspaceCheckPaths()

demoFolder = fileparts(mfilename("fullpath"));
if ~exist("kspaceParamsGUI.m", "file")
    addpath(fullfile(demoFolder, "kspaceFunctions"));
end
if ~exist("generalDialog.m", "file")
    addpath(fullfile(demoFolder, "mrVistaUtilities"));
end

end
