function [params, ok] = kspaceParamsGUI(params)
% Show a dialog for editing the k-space demo parameters.
%
%   [params, ok] = kspaceParamsGUI(params)
%
% params is in everyday units (see kspaceDefaultParams), and so is the
% output. ok is false if the user cancelled. Fields that the dialog cannot
% show (an image or T2* given as a matrix) are left unchanged.

arguments
    params (1,1) struct = kspaceDefaultParams()
end

imageList = ["checkerboard.jpg", "face.jpg", "sagittalBrain.jpg", "axialBrain.jpg", "axialLucas.jpg", "other"];
noiseList = ["local offset", "random offset", "random lowpass", "x gradient", "y gradient", "dc offset", "map", "none"];

% Each row: field name, style, label, list of options (popups only)
items = {
    "imfile",       "popup",    "Image",                                     imageList
    "showProgress", "checkbox", "Show recon as k-space fills (slower)",      []
    "loop",         "checkbox", "Keep dialog open after each run",           []
    "sequenceType", "popup",    "k-space trajectory",                        ["epi", "spiral"]
    "noiseType",    "popup",    "B0 field error",                            noiseList
    "noiseScale",   "number",   "Field error size (ppm of B0)",              []
    "FOV",          "number",   "Field of view (mm)",                        []
    "res",          "number",   "Pixel size, reconstructed image (mm)",      []
    "imSize",       "number",   "Object size (mm)",                          []
    "imRes",        "number",   "Pixel size, object (mm)",                   []
    "bandwidth",    "number",   "Receiver bandwidth, total (kHz)",           []
    "echoTime",     "number",   "Echo time, TE (ms): time to k-space centre", []
    "t2star",       "number",   "T2* of tissue (ms, Inf = no decay)",        []
    "oversample",   "number",   "Spiral shots",                              []
    };

% The dialog can only show text and scalar values
isShowable = @(value) isscalar(value) || ischar(value);
keep = true(size(items, 1), 1);
for ii = 1:size(items, 1)
    keep(ii) = isShowable(params.(items{ii, 1}));
end
items = items(keep, :);

dlg = struct("fieldName", {}, "style", {}, "string", {}, "value", {}, "list", {});
for ii = 1:size(items, 1)
    value = params.(items{ii, 1});
    if isstring(value)
        value = char(value);
    end
    dlg(ii).fieldName = char(items{ii, 1});
    dlg(ii).style     = char(items{ii, 2});
    dlg(ii).string    = char(items{ii, 3});
    dlg(ii).value     = value;
    if isempty(items{ii, 4})
        dlg(ii).list = {};
    else
        dlg(ii).list = cellstr(items{ii, 4});
    end
end

pos = [1 1 .25 .5];
[resp, ok] = generalDialog(dlg, mfilename, pos);
if ~ok
    return
end

% Copy the answers back, as strings rather than character vectors
for ii = 1:numel(dlg)
    value = resp.(dlg(ii).fieldName);
    if ischar(value)
        value = string(value);
    end
    params.(dlg(ii).fieldName) = value;
end

end
