function kspaceCheckPaths()
% Add the demo's subfolders to the MATLAB path, if they are not there yet.
%
%   kspaceCheckPaths()
%
% The top-level functions call this themselves, so you only need the demo
% folder itself on the path.

demoFolder = fileparts(mfilename("fullpath"));
if ~exist("kspaceStepFactor.m", "file")
    addpath(fullfile(demoFolder, "subroutines"));
end
if ~exist("generalDialog.m", "file")
    addpath(fullfile(demoFolder, "mrVistaUtilities"));
end

end
