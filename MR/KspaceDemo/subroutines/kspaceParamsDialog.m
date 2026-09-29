function [params, ok] = kspaceParamsDialog(params, options)
% Show a dialog for editing the k-space demo parameters.
%
%   [params, ok] = kspaceParamsDialog(params)
%
% params is in everyday units (see kspaceDefaultParams), and so is the
% output. ok is false if the user cancelled or closed the dialog, in which
% case params is returned unchanged. Fields that the dialog cannot show (an
% image or T2* given as a matrix) are left unchanged.
%
% Inputs
%   params  - starting settings (default: kspaceDefaultParams())
%   TestFcn - (optional, for tests) a function called with the dialog
%             figure once it is built, before waiting for the user. It can
%             set the controls (each is tagged with its parameter name) and
%             press "OK" or "Cancel" (tagged with those names).
%
% See also kspaceDemo, kspaceDefaultParams

arguments
    params (1,1) struct = kspaceDefaultParams()
    options.TestFcn = []
end

imageList = ["checkerboard.jpg", "face.jpg", "sagittalBrain.jpg", "axialBrain.jpg", "axialLucas.jpg", "other"];
fieldErrorList = ["local offset", "random offset", "random lowpass", "x gradient", "y gradient", ...
    "dc offset", "map", "none"];

progressList   = ["final", "line", "point"];
progressLabels = ["Final image only", "One line at a time", "One point at a time (slow)"];

% Each row: field name, style, label, list of values (drop-downs only), and
% the text shown for each value (if different from the value)
items = {
    "imageFile",       "dropdown", "Image",                                     imageList, []
    "progressDisplay", "dropdown", "Show recon as k-space fills",               progressList, progressLabels
    "keepDialogOpen",  "checkbox", "Keep dialog open after each run",           [], []
    "sequenceType",    "dropdown", "k-space trajectory",                        ["epi", "spiral"], []
    "fieldErrorType",  "dropdown", "B0 field error",                            fieldErrorList, []
    "fieldErrorPpm",   "number",   "Field error size (ppm of B0)",              [], []
    "FOV",             "number",   "Field of view (mm)",                        [], []
    "pixelSize",       "number",   "Pixel size, reconstructed image (mm)",      [], []
    "objectSize",      "number",   "Object size (mm)",                          [], []
    "objectPixelSize", "number",   "Pixel size, object (mm)",                   [], []
    "bandwidth",       "number",   "Receiver bandwidth, total (kHz)",           [], []
    "echoTime",        "number",   "Echo time, TE (ms): time to k-space center", [], []
    "t2star",          "number",   "T2* of tissue (ms, Inf = no decay)",        [], []
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
nItems = size(items, 1);

% Build the dialog: one row per setting, then a row of buttons
rowHeight = 26;   % pixels
dialog = uifigure(Name="k-space demo settings", ...
    Position=[100 100 480 rowHeight*(nItems + 1) + 40], ...
    CloseRequestFcn=@(src, ~) finish(src, false));
dialog.UserData = struct("isDone", false, "ok", false);
grid = uigridlayout(dialog, [nItems + 1, 2], ColumnWidth={"fit", "1x"}, ...
    RowHeight=repmat({rowHeight - 4}, 1, nItems + 1));

controls = gobjects(nItems, 1);
for ii = 1:nItems
    [name, style, label, list, displayed] = items{ii, :};
    uilabel(grid, Text=label);
    value = params.(name);
    switch style
        case "dropdown"
            value = string(value);
            if isempty(displayed)
                displayed = list;
            end
            if ~ismember(value, list)
                % Keep a choice that is not in the list, e.g. brain.jpg
                list      = [list value]; %#ok<AGROW>
                displayed = [displayed value]; %#ok<AGROW>
            end
            controls(ii) = uidropdown(grid, Items=displayed, ItemsData=list, Value=value);
        case "checkbox"
            controls(ii) = uicheckbox(grid, Text="", Value=logical(value));
        case "number"
            controls(ii) = uieditfield(grid, "numeric", Value=value);
        otherwise
            % Cannot happen: every row of items uses one of the styles above
    end
    controls(ii).Tag = name;
end

buttons = uigridlayout(grid, [1 2], Padding=[0 0 0 0]);
buttons.Layout.Column = [1 2];
uibutton(buttons, Text="OK", Tag="OK", ButtonPushedFcn=@(~, ~) finish(dialog, true));
uibutton(buttons, Text="Cancel", Tag="Cancel", ButtonPushedFcn=@(~, ~) finish(dialog, false));

% Wait for the user. A test can press a button first, in which case there
% is nothing to wait for.
if ~isempty(options.TestFcn)
    options.TestFcn(dialog);
end
if ~dialog.UserData.isDone
    uiwait(dialog);
end

ok = isvalid(dialog) && dialog.UserData.ok;
if ok
    for ii = 1:nItems
        value = controls(ii).Value;
        if ischar(value)
            value = string(value);
        end
        params.(items{ii, 1}) = value;
    end
end
if isvalid(dialog)
    delete(dialog);
end

end

function finish(dialog, ok)
% Record which button was pressed and stop waiting
dialog.UserData = struct("isDone", true, "ok", ok);
uiresume(dialog);
end
