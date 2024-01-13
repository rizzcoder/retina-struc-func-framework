function no_maia_pts = find_no_maia_pts(filename, dataLines)
%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [50, Inf]; % MAIA IDs start from Line 50
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["ID", "Var2", "Var3", "Var4"];
opts.SelectedVariableNames = "ID";
opts.VariableTypes = ["double", "string", "string", "string"];

% Specify file level properties: Ignore empty rows in MAIA text file
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var2", "Var3", "Var4"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var2", "Var3", "Var4"], "EmptyFieldRule", "auto");

% Import the data
maia_ids_table = readtable(filename, opts);
no_maia_pts = size(maia_ids_table,1)-1;
end