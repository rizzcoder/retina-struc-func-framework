%% Rename OCT B-scans module
% Renames OCT b-scan files which are originally in hexadecimal format to
% decimal

clear
close all;

% Select folder
folderPath = uigetdir;

% Move to folder to rename files
old = cd(folderPath);

% List tif files
list = dir( fullfile(folderPath,'*.tif') );

name = {list.name};

for i = 1:length(name)
    
    fprintf('%s\n',name{i});
    newName = [num2str(i) '.tif'];
    fprintf('%s renamed to %s \n',name{i},newName);
    movefile(name{i},newName,'f');
end

% Move back to original path
cd(old);