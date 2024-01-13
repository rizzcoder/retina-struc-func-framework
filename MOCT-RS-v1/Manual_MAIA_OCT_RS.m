%% Manual Coregistation Module (Order of program execution: 4 - if manual mode selected)

% The user has to atleast 6 "good and interesting" corresponding points between
% the MAIA nad the OCT image for it to work properly.
% Fixed Image: OCT cSLO; Moving Image: MAIA SLO

function Manual_MAIA_OCT_RS(vars,Dir)

validnMatchPts = false;

% Select atleast 6 corresponding points b/w OCT and MAIA image
while ~validnMatchPts
    prompt = "How many pairs of corresponding points do you want to manually select? Select a number between 6 & 10: ";
    nMatchPts = input(prompt);
    if (nMatchPts>5) && (nMatchPts<=10)
        validnMatchPts = true;
    else
        fprintf("Invalid input. Try again by choosing a number between 6 and 10.\n")
    end
end

% warning('off');
close all
oct_file = Dir.file;
oct_path = Dir.path;
nMaiaPoints = vars.nMaiaPoints;

imageoct = [oct_path oct_file];
oct_image = imread(imageoct); % Read OCT cSLO

maia_file = Dir.file2;
maia_path = Dir.path2;

imagemaia = [maia_path maia_file];
imageIndex = regexp(maia_file,'\d*','Match');
imageIndexStr = [imageIndex{1} '_' imageIndex{2}];

if size(strsplit(maia_file),2)>4
    warning('on'); %#ok<WNON>
    warning('A MAIA image has been loaded that contains overlayed contents and may affect the results check carefully');
    warning('off');
end

% Get MAIA threshold file
currentDIR = pwd;
cd(maia_path)
ThresholdFileName = dir(['*',imageIndexStr,'_threshold.txt']);

if isempty(ThresholdFileName)
    a = dir;
    for i = 3:length(a)
        if a(i).isdir
            cd(a(i).name)
            ThresholdFileName = dir(['*',imageIndexStr,'_threshold.txt']);
            if ~isempty(ThresholdFileName)
                file3 = [maia_path,a(i).name,'/',ThresholdFileName.name];
                break
            end
            cd ..
        end
        if i==length(a)
            error('Unable to locate threshold file \nMake sure file is in the same directory as MAIA image',[]);
        end
    end
else
    file3 = [maia_path,ThresholdFileName.name];
end

cd(currentDIR)

maia_image = imread(imagemaia); % Read MAIA SLO

fprintf('Manual alignment in progress.. \n');
fprintf(['Select %d "good & interesting" corresponding points in the two images. \n' ...
    'Refer to the ReadMe file for tips on selecting such points. \n'...
    'You can close the dialog box after %d corresponding points are chosen \n'],nMatchPts,nMatchPts);

%% Start Registration

oct_image_gray = im2gray(oct_image);
maia_image_gray = im2gray(maia_image);
[movingPoints,fixedPoints] = cpselect(maia_image_gray,oct_image_gray,Wait=true);

transformation_function = fitgeotform2d(movingPoints,fixedPoints,"projective");
Rfixed = imref2d(size(oct_image_gray));
registered_image = imwarp(maia_image_gray,transformation_function,OutputView=Rfixed);

ssimval = ssim(registered_image,oct_image_gray);
fprintf('Structural Similarity Index: %f\n', ssimval);

figure;
imshowpair(oct_image_gray,registered_image,"blend")
title({'Registered MAIA & OCT Image'});
set(gcf, 'Color', 'w');

%% Overlay MAIA sensitivity points on the registered image
% Read the threshold text file and grab all its properties automatically

% First get the value of Pixels-to-Degree ratio found in the threshold file
opts_maiaThresholdFile = delimitedTextImportOptions("NumVariables", 4);
opts_maiaThresholdFile.DataLines = [18, 18; 27, 28]; %Because the pixel2deg ratio
% is in the 18th line and PRL initial values are in Line 27 and 28 of the
% maia threshold text file
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

% Import the pix2deg_ratio and the PRL_Initial X and Y values in degree
% from the threshold text file.
ratio_and_prl_values = readmatrix(file3, opts_maiaThresholdFile);

Pix2deg_ratio_Maia = ratio_and_prl_values(1,1);
prl_initial_x_deg = ratio_and_prl_values(2,1);
prl_initial_y_deg = ratio_and_prl_values(3,1);

clear opts_maiaThresholdFile

Deg2pix_ratio_Maia = 1/Pix2deg_ratio_Maia; % This is equivalent to 1024/36 = approx. 28.44

% Next, get the values of the ID, x_deg, y_deg and the threshold value
% table from the threshold.txt file

opts_maiaThresholdFile = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts_maiaThresholdFile.DataLines = [50, 50+nMaiaPoints]; %Because the first MAIA ID point starts at Line 50 in MAIA Threshold file
opts_maiaThresholdFile.Delimiter = "\t";

% Specify column names and types
opts_maiaThresholdFile.VariableNames = ["ID", "x_deg", "y_deg", "Threshold"];
opts_maiaThresholdFile.VariableTypes = ["double", "double", "double", "double"];

% Specify file level properties
opts_maiaThresholdFile.ExtraColumnsRule = "ignore";
opts_maiaThresholdFile.EmptyLineRule = "read";

matrix_maia = readmatrix(file3, opts_maiaThresholdFile);

matrix_maia_pixels = matrix_maia(:,2:3)*Deg2pix_ratio_Maia; %Convert X and Y which are in degrees to pixels

% Compute grid center using PRL_Initial value
maia_grid_center_x = prl_initial_x_deg*Deg2pix_ratio_Maia;
maia_grid_center_y = prl_initial_y_deg*Deg2pix_ratio_Maia;

% Offset test points with grid center
matrix_maia_pixels_cartesian = [matrix_maia_pixels(:,1)+maia_grid_center_x,matrix_maia_pixels(:,2)+maia_grid_center_y];
matrix_maia_pixels_cartesian_shifted = transformPointsForward(transformation_function,matrix_maia_pixels_cartesian);

%% Overlay MAIA test points on the OCT cSLO image
% Load MAIA Color Map based on the decibel color scale i.e. 0-36 dB
load maiacolormap.mat MaiaColorMap;

% Prepare color codes based on the threshold values of MAIA
maia_ThresholdValues = matrix_maia(:,4);
colorVectors = zeros(length(maia_ThresholdValues),3);

temp_maia_ThresholdValues = maia_ThresholdValues;
temp_maia_ThresholdValues(temp_maia_ThresholdValues==0) = 1; % Some threshold files have a 0 for optic nerve
temp_maia_ThresholdValues(temp_maia_ThresholdValues==-1) = 1; % Some threshold files have a -1 for optic nerve

for kk = 1:length(maia_ThresholdValues)
    colorVectors(kk,:) = MaiaColorMap(temp_maia_ThresholdValues(kk),:);
end

markerSize = 0.43*Deg2pix_ratio_Maia;

global OCT_w_Bscan % Loads from auto_bscan_OCT_alignment.m
global colrow % Loads from auto_bscan_OCT_alignment.m

assignin('base','OCT_w_Bscan',OCT_w_Bscan);
assignin('base','matrix_maia_pixels_cartesian_shifted',matrix_maia_pixels_cartesian_shifted);

bscan_aligned_oct_image = uint8(OCT_w_Bscan);

final_overlayed_image = insertShape(bscan_aligned_oct_image,'FilledCircle',[matrix_maia_pixels_cartesian_shifted,repmat(round(markerSize)./2,length(matrix_maia_pixels_cartesian_shifted),1)],...
    'Color',uint8(round(255.*colorVectors)));

final_overlayed_image = insertText(final_overlayed_image,matrix_maia_pixels_cartesian_shifted,matrix_maia(:,1),'BoxOpacity',0,'AnchorPoint','LeftBottom','TextColor',uint8(round(255.*colorVectors)));

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

% Add the b-scan numbers as well
for r = 1:size(colrow,1)
    bscan_text = text(colrow(r,2)-40,colrow(r,1),strcat('#',num2str(r))); % 40 pixels away from the starting location of the b-scan for better legibility
    if r==1
        continue
    end
    if colrow(r,1)==colrow(r-1,1)
        bscan_text.Color = [0.6350 0.0780 0.1840];
    else
        bscan_text.Color = 'black';
    end
end

%% Query Retinal Thickness

maia_ID_without_ON = matrix_maia(2:end,1); % Will be saved and used later by ThicknessQuery_new_RS
maia_Thresh_without_ON = matrix_maia(2:end,4); % Will be saved and used later by ThicknessQuery_new_RS

clos_bscan_n_maialoc_bscan_wo_ON = zeros(nMaiaPoints,2);

% Find the:
% 1) Closest B-scan to a particular MAIA point
% 2) The distance b/w location of the MAIA point to the start of B-scan
% found in Step 1.

for i=2:nMaiaPoints+1
    clos_bscan_n_maialoc_bscan_wo_ON(i-1,1) = find(abs(colrow(:,1)-matrix_maia_pixels_cartesian_shifted(i,2))==min(abs(colrow(:,1)-matrix_maia_pixels_cartesian_shifted(i,2))),1);
    clos_bscan_n_maialoc_bscan_wo_ON(i-1,2) = (matrix_maia_pixels_cartesian_shifted(i,1)-colrow(clos_bscan_n_maialoc_bscan_wo_ON(i-1,1),2))*(((colrow(clos_bscan_n_maialoc_bscan_wo_ON(i-1,1),3)-11)*vars.WarpStep+512)/512);
end

fileName = 'CorregisterResult';
save([Dir.ResultPath,'/',fileName,'.mat']); % Save Coregistration variables

ThicknessQuery_new_RS(Dir); % Invoke the Retinal Thickness Query module
end