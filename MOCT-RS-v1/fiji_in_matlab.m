%% Automatic Coregistration Module (Order of program execution: 4 if automatic mode selected)
% 1. Tested with  FIJI/Image J 1.54d
% 2. Make sure to add PTBIOP website to get the SIFT with Multichannel feature in FIJI.
% 3. See comment by Nikolas Chiaruttini (April 2021) at:
% https://forum.image.sc/t/registration-of-multi-channel-timelapse-with-linear-stack-alignment-with-sift/50209/16
% 4. Make sure you have added FIJI/scripts to MATLAB path

function fiji_in_matlab(vars,Dir)

ImageJ; % Invoke ImageJ/FIJI
cd (Dir.MainPath);

% Load appropriate macro:
% For rectangular MAIA grid, fiducial_radius = 3 (less stringent filter) as
% test points are tightly clustered at center.
% For radial MAIA grid, fiducial_radius = 5 (stringent filter)

if contains(Dir.path,'Rectangular')
    automatic_macro_path = [dir(['*fiducial3*','.ijm']).folder, '\',dir(['*fiducial3*','.ijm']).name];
else
    automatic_macro_path = [dir(['*fiducial5*','.ijm']).folder, '\',dir(['*fiducial5*','.ijm']).name];
end

IJ=ij.IJ(); % Create an ImageJ instance
IJ.runMacroFile(java.lang.String(automatic_macro_path));

% Show registration preview as GIF
cd (Dir.path2);
cd ..
gif_file = [dir(['*','.gif']).folder, '\',dir(['*','.gif']).name]; % Use '/' for Mac
winopen(gif_file); % Current solution as reading gifs in MATLAB is problematic at the time of testing

% Check if registration is fine; if not, retry with CLAHE
dialog_box_fig = uifigure;
dialog_box_msg = 'Does the registration shown in the preview look okay to you?';
dialog_box_resp = uiconfirm(dialog_box_fig,dialog_box_msg,'Selection Menu','Icon','question','Options',{'Yes!','No'},'CloseFcn',@(h,e) close(dialog_box_fig));

try
    switch dialog_box_resp
        case 'Yes!'
            disp('Alright. Moving ahead with overlaying the registered MAIA points on the OCT en-face image \n');
        case 'No'
            !taskkill -f -im Microsoft.Photos.exe
            % System command to force close Microsoft Photos which is
            % showing the registration preview
            error('FIJI Macro: AutoRegFail. Registration O/P was unsatisfactory according to the user.');
    end
catch
    disp('Trying the "Manual-override" option of the FIJI Macro');
    cd (Dir.MainPath);
    manual_macro_path = [dir(['*override*','.ijm']).folder, '\',dir(['*override*','.ijm']).name];
    IJ.runMacroFile(java.lang.String(manual_macro_path));
    cd (Dir.path2);
    cd ..
    gif_file_override = [dir(['*','.gif']).folder, '\',dir(['*','.gif']).name]; %Use '/' for Mac
    winopen(gif_file_override);

    dialog_box_fig_override = uifigure;
    dialog_box_msg_override = 'Now, does the registration shown in the preview look okay to you?';
    dialog_box_resp_override = uiconfirm(dialog_box_fig_override,dialog_box_msg_override,'Selection Menu','Icon','question','Options',{'Yes!','No'},'CloseFcn',@(h,e) close(dialog_box_fig_override));

    try
        switch dialog_box_resp_override
            case 'Yes!'
                disp('Alright. Moving ahead with overlaying the registered MAIA points on the OCT A-scan.');
            case 'No'
                !taskkill -f -im Microsoft.Photos.exe
                error('FIJI Macro: AutoRegFail. Registration O/P was once again unsatisfactory according to the user.');
        end

    catch
        disp('Returning control to the calling function');
        return;
    end
end

ij.IJ.run("Quit",""); % Close the ImageJ instance
clear IJ MIJ ans
clear dialog_box_fig dialog_box_fig_override dialog_box_msg dialog_box_msg_override dialog_box_resp dialog_box_resp_override
clear IJM
%!taskkill -f -im Microsoft.Photos.exe
!taskkill -f -im PhotosService.exe

% Grab the ID's, threshold values, and the transformed X and Y positions of
% the MAIA test grid from the output csv file of the Macro

cd (Dir.path2);
cd ..
csv_file = [dir(['*','.csv']).folder, '\',dir(['*','.csv']).name]; % Use '/' for Mac
macro_transformed_maia_thresholds = readtable(csv_file);
macro_transformed_maia_thresholds_ordered = sortrows(macro_transformed_maia_thresholds,2); % Trackmate returns IDs in scrambled order
matrix_maia_pixels_cartesian_shifted =  macro_transformed_maia_thresholds_ordered{1:end,["X","Y"]};

% Get Pixel-to-degree ratio and load custom MAIA color table
cd (Dir.path2);
file3 = [dir(['*','_threshold.txt']).folder, '\',dir(['*','_threshold.txt']).name];
opts_maiaThresholdFile = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts_maiaThresholdFile.DataLines = [18, 18];
opts_maiaThresholdFile.Delimiter = "\t";

% Specify column names and types
opts_maiaThresholdFile.VariableNames = ["ID", "Var2", "Var3", "Var4"];
opts_maiaThresholdFile.SelectedVariableNames = "ID";
opts_maiaThresholdFile.VariableTypes = ["double", "string", "string", "string"];

% Specify file level properties
opts_maiaThresholdFile.ExtraColumnsRule = "ignore";
opts_maiaThresholdFile.EmptyLineRule = "read";

% Specify variable properties
opts_maiaThresholdFile = setvaropts(opts_maiaThresholdFile, ["Var2", "Var3", "Var4"], "WhitespaceRule", "preserve");
opts_maiaThresholdFile = setvaropts(opts_maiaThresholdFile, ["Var2", "Var3", "Var4"], "EmptyFieldRule", "auto");

% Import the pixel-to-deg ratio value from the file
Pix2deg_ratio_Maia = readmatrix(file3, opts_maiaThresholdFile);
clear opts_maiaThresholdFile

Deg2pix_ratio_Maia = 1/Pix2deg_ratio_Maia;
cd (Dir.MainPath);
load maiacolormap.mat MaiaColorMap;

maia_ThresholdValues = macro_transformed_maia_thresholds_ordered{1:end,"Threshold"};
colorVectors = zeros(length(maia_ThresholdValues),3);
temp_maia_ThresholdValues = maia_ThresholdValues;
temp_maia_ThresholdValues(temp_maia_ThresholdValues<1) = 1; % Some threshold files have a 0 for optic nerve or negative values incompatible with MATLAB

for kk = 1:length(maia_ThresholdValues)
    colorVectors(kk,:) = MaiaColorMap(temp_maia_ThresholdValues(kk),:);
end

global OCT_w_Bscan % Loads from auto_bscan_OCT_alignment.m
global colrow % Loads from auto_bscan_OCT_alignment.m

assignin('base','OCT_w_Bscan',OCT_w_Bscan);
assignin('base','matrix_maia_pixels_cartesian_shifted',matrix_maia_pixels_cartesian_shifted);

bscan_aligned_oct_image = uint8(OCT_w_Bscan);
markerSize = 0.43*Deg2pix_ratio_Maia;

final_overlayed_image = insertShape(bscan_aligned_oct_image,'FilledCircle',[matrix_maia_pixels_cartesian_shifted,repmat(round(markerSize)./2,length(matrix_maia_pixels_cartesian_shifted),1)],...
    'Color',uint8(round(255.*colorVectors)));

maia_IDs = macro_transformed_maia_thresholds_ordered{1:end,"ID"};

final_overlayed_image = insertText(final_overlayed_image,matrix_maia_pixels_cartesian_shifted,maia_IDs,'BoxOpacity',0,'AnchorPoint','LeftBottom','TextColor',uint8(round(255.*colorVectors)));

figure;
imshow(final_overlayed_image);
title('MAIA sensitivity map overlayed on the B-scans')
colormap(MaiaColorMap);
colorbarprops = colorbar('southoutside');
colorbarprops.Label.String = 'MAIA Sensitivity Scale (in dB)';
colorbarprops.Label.FontSize = 12;
colorbarprops.Ticks = 0:36;
clim([0 36])
set(gcf, 'Color', 'w');

% Add the B-scan numbers as well
for r = 1:size(colrow,1)
    bscan_text = text(colrow(r,2)-40,colrow(r,1),strcat('#',num2str(r))); % 40 pixels away from the starting location of the b-scan for better legibility
    if r==1
        continue
    end
    if colrow(r,1)==colrow(r-1,1)
        bscan_text.Color =[0.6350 0.0780 0.1840];
    else
        bscan_text.Color = 'black';
    end
end

%% Query Retinal Thickness

maia_ID_without_ON = maia_IDs; % Will be saved and used later by ThicknessQuery_new_RS
maia_Thresh_without_ON = maia_ThresholdValues; % Will be saved and used later by ThicknessQuery_new_RS
nMaiaPoints = vars.nMaiaPoints;

% Check whether the no. of MAIA points recovered from the registered image is equal
% to the no. of MAIA points specified in the input file.

try
    if size(macro_transformed_maia_thresholds,1)~=nMaiaPoints
        error('The algorithm was not able to recover all the MAIA points from the registered image. This will lead to erroneous results in computing the retinal thickness.');
    end
catch
    disp('Aborting automatic alignment operation and returning control to the calling function. Choose "No" in the next dialog box and try Manual alignment');
    return
end

clos_bscan_n_maialoc_bscan_wo_ON = zeros(nMaiaPoints,2);

% Find the:
% 1) Closest B-scan to a particular MAIA point
% 2) The distance b/w location of the MAIA point to the start of B-scan
% found in Step 1.

for i=2:nMaiaPoints+1
    clos_bscan_n_maialoc_bscan_wo_ON(i-1,1) = find(abs(colrow(:,1)-matrix_maia_pixels_cartesian_shifted(i-1,2))==min(abs(colrow(:,1)-matrix_maia_pixels_cartesian_shifted(i-1,2))),1);
    clos_bscan_n_maialoc_bscan_wo_ON(i-1,2) = (matrix_maia_pixels_cartesian_shifted(i-1,1)-colrow(clos_bscan_n_maialoc_bscan_wo_ON(i-1,1),2))*(((colrow(clos_bscan_n_maialoc_bscan_wo_ON(i-1,1),3)-11)*vars.WarpStep+512)/512);
end

fileName = 'CorregisterResult';
save([Dir.ResultPath,'/',fileName,'.mat']); % Save Coregistration variables

ThicknessQuery_new_RS(Dir); % Invoke the Retinal Thickness Query module
end