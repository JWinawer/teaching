function [params, ok] = kspaceParamsDialog(params)
% Show a dialog for editing the k-space demo parameters.
%
%   [params, ok] = kspaceParamsDialog(params)
%
% params is in everyday units (see kspaceDefaultParams), and so is the
% output. ok is false if the user cancelled. Fields that the dialog cannot
% show (an image or T2* given as a matrix) are left unchanged.
%
% See also kspaceDemo, kspaceDefaultParams

arguments
    params (1,1) struct = kspaceDefaultParams()
end

imageList = ["checkerboard.jpg", "face.jpg", "sagittalBrain.jpg", "axialBrain.jpg", "axialLucas.jpg", "other"];
fieldErrorList = ["local offset", "random offset", "random lowpass", "x gradient", "y gradient", ...
    "dc offset", "map", "none"];

% Each row: field name, style, label, list of options (popups only)
items = {
    "imageFile",       "popup",    "Image",                                     imageList
    "showProgress",    "checkbox", "Show recon as k-space fills (slower)",      []
    "keepDialogOpen",  "checkbox", "Keep dialog open after each run",           []
    "sequenceType",    "popup",    "k-space trajectory",                        ["epi", "spiral"]
    "fieldErrorType",  "popup",    "B0 field error",                            fieldErrorList
    "fieldErrorPpm",   "number",   "Field error size (ppm of B0)",              []
    "FOV",             "number",   "Field of view (mm)",                        []
    "pixelSize",       "number",   "Pixel size, reconstructed image (mm)",      []
    "objectSize",      "number",   "Object size (mm)",                          []
    "objectPixelSize", "number",   "Pixel size, object (mm)",                   []
    "bandwidth",       "number",   "Receiver bandwidth, total (kHz)",           []
    "echoTime",        "number",   "Echo time, TE (ms): time to k-space center", []
    "t2star",          "number",   "T2* of tissue (ms, Inf = no decay)",        []
    };

% Fill in any missing fields, then keep only the items the dialog can show:
% text and scalar values
defaults = kspaceDefaultParams();
isShowable = true(size(items, 1), 1);
for ii = 1:size(items, 1)
    name = items{ii, 1};
    if ~isfield(params, name)
        params.(name) = defaults.(name);
    end
    value = params.(name);
    isShowable(ii) = isscalar(value) || ischar(value);
end
items = items(isShowable, :);

% generalDialog expects character vectors and cell arrays
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

dialogPosition = [1 1 0.25 0.5];
[response, ok] = generalDialog(dlg, mfilename, dialogPosition);
if ~ok
    return
end

% Copy the answers back, as strings rather than character vectors
for ii = 1:numel(dlg)
    value = response.(dlg(ii).fieldName);
    if ischar(value)
        value = string(value);
    end
    params.(dlg(ii).fieldName) = value;
end

end
