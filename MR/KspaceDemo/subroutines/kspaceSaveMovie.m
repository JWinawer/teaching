function movieFile = kspaceSaveMovie(frames, name, frameRate)
% Write captured frames to an mp4 file in the demo's movies/ folder.
%
%   movieFile = kspaceSaveMovie(frames, name, frameRate)
%
% Inputs
%   frames    - struct array of frames, from getframe
%   name      - file name, without extension. Characters that are not safe
%               in file names on every platform are removed.
%   frameRate - playback speed, frames per second
%
% Output
%   movieFile - full path of the saved movie
%
% movies/ is ignored by git, so saved movies are not committed.
%
% See also kspaceSimulate

arguments
    frames struct
    name (1,1) string
    frameRate (1,1) double {mustBePositive}
end

demoFolder = fileparts(fileparts(mfilename("fullpath")));
movieDir   = fullfile(demoFolder, "movies");
if ~isfolder(movieDir)
    mkdir(movieDir);
end

name = regexprep(name, "[^\w \-]", "");
if strlength(strtrim(name)) == 0
    name = "kspace";
end

writer = VideoWriter(fullfile(movieDir, name), "MPEG-4");
writer.FrameRate = frameRate;
open(writer);
writeVideo(writer, frames);
close(writer);

movieFile = fullfile(movieDir, name + ".mp4");
fprintf("Wrote %s\n", movieFile);

end
