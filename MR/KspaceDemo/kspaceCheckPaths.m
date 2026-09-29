function kspaceCheckPaths()
% Add the demo's subroutines folder to the MATLAB path, if it is not there yet.
%
%   kspaceCheckPaths()
%
% The top-level functions call this themselves, so you only need the demo
% folder itself on the path.

demoFolder = fileparts(mfilename("fullpath"));
if ~exist("kspaceStepFactor.m", "file")
    addpath(fullfile(demoFolder, "subroutines"));
end

end
