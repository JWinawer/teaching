function [response, ok] = generalDialog(dlg, ~, ~)
% Test stand-in for generalDialog: returns the default values, as the real
% dialog does when the user presses OK without changing anything.
ok = true;
for ii = 1:numel(dlg)
    value = dlg(ii).value;
    if strcmp(dlg(ii).style, "popup")
        assert(ischar(value) && any(strcmp(dlg(ii).list, value)), ...
            "Popup default is not in its list: " + dlg(ii).fieldName);
    end
    response.(dlg(ii).fieldName) = value;
end
end
