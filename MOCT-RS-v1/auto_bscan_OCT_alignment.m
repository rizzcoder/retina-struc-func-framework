%% Automatic OCT B-scan alignment module (Order of program execution: 3)

% This module extracts and aligns OCT B-scans while accounting for eye movements.

function auto_bscan_OCT_alignment(vars,Dir)

warning('off');
hm = pwd;
octSLO = imread([Dir.path,Dir.file]); % Read OCT cSLO image

if size(octSLO,3)~=1
    octSLO = mean(octSLO,3);
end

if mean(octSLO)>1
    octSLO1 = 255-octSLO;
else
    octSLO1 = octSLO;
end

cd(Dir.path)

%% Set parameters based on values entered in the GUI
%%%%%%%%%%\/ Parameters \/%%%%%%%%%%%
nBscans = vars.nBscans;       % The no. of OCT bscans: ## default 97
warp_step = vars.WarpStep;    % how much it will warp the b-scan  ## default 1
vM = vars.VertM;              % how much the b-scan can move up and down  ## default 10;
vH = vars.HorzM;              % how much the b-scan can move left and right  ## default 50; 0 means can have any horizontal value
%%%%%%%%%%/\ Parameters /\%%%%%%%%%%%

if vars.folder == 0
    path = uigetdir('Select B scan folder');
else
    if ismac
        path = [Dir.path,'/bscans'];   % for OS
    else
        path = [Dir.path,'\bscans'];   % for windows
    end
end

%% Grab the OCT XML file. This has information exported from the OCT machine.
octxmlfilename = dir([Dir.path,'*.xml']);

if size(octxmlfilename,1) == 0
    error('OCT XML file not found \nPlace the corresponding xml file in the OCT image folder',[]); %#ok<*CTPCT>
elseif size(octxmlfilename,1)>1
    error('Multiple XMLs file found \nYou will need to remove the non-corresponding xmls from the folder',[]);
end

cd(hm)
octST_new = readstruct(([Dir.path,octxmlfilename.name]));

fprintf('Extracting B-scans... \n')
cd(path)

all_the_bscans = dir('*.tif');

%% Perform basic OCT B-scan quality check
flagged_bscan_indices = find(bscan_quality_check(all_the_bscans,path));
feature_quality_check_on = 0;

if feature_quality_check_on
disp('Check the following B-scans in your data if they are okay:');
disp(flagged_bscan_indices);

% Ask user if they want to try to fix it
answer = questdlg('Any OCT B-scan faulty from your data?', ...
	'Selection Menu', ...
	'Yes','No','No');
% Handle response
switch answer
    case 'Yes'
        commandwindow 
        disp([answer ': okay, trying to fix the faulty B-scan.'])
        faulty_indices = str2double(strsplit(input('Enter the faulty B-scan numbers separated by commas: ', 's'), ','));
        bscan_fixer(faulty_indices,all_the_bscans)
    case 'No'
end
end

%% Extract B-scans from each TIFF file in the folder. Perform several image processing steps

tic
parfor ii = 1:length(all_the_bscans)
    close all
    try
        bscan = imread([path,'/',num2str(ii),'.tif']);
    catch
        warning('on');
        warning([strcat(num2str(ii),'.tif'),' does not exist'])
        warning('off');
        continue
    end

    if size(bscan,3)>1
        bscan = mean(bscan,3);
    end

    [~,p] = max(bscan); % Look for the brightest patches in the B-scan. "p" reports the row in which the
    % maximum pixel value occurs in each column i.e u get a 1x 512 vector.

    % If you want to visualize which are the brightest patches of the
    % image, uncomment the following code.
    % kk = zeros(496,512);
    % for i = 1:length(p)
    % kk(p(i),i) = bscan(p(i),i);
    % end

    % This piece of code fits a cubic polynomial curve to the maximum pixel
    % values. The polynomial function is used to estimate the position of
    % the outer retinal layers.

    x = 1:512;
    f = fit(x',p','poly3');
    f2 = fit(x((p-(f(1:512))')>0)',p((p-(f(1:512))')>0)','poly3');
    f3 = fit(x(abs(p-f2(1:512)')<=15)',p(abs(p-f2(1:512)')<=15)','poly3');
    f4 = fit(x(abs(p-f3(1:512)')<=15)',p(abs(p-f3(1:512)')<=15)','poly3');
    f5 = fit(x(abs(p-f4(1:512)')<=15)',p(abs(p-f4(1:512)')<=15)','poly3');

    [~,yM] = meshgrid(1:512,1:496); % Each b-scan is 512x496
    fitY = repmat((f5(1:512))',496,1);

    %Creates a mask based on the deviation of each pixel from the fitted curve.
    mask = abs(yM-fitY)<15;
    mask2 = nan(size(bscan,1),size(bscan,2));
    mask2(mask==1) = 1;

    d = double(bscan)+mask2; %Applies the mask to the original b-scan. You can use imshow(d,[]) to see this.
    e = mean(d,"omitnan");
    e(mean(bscan)==0) = mean(e); % Replace black borders with mean values.

    % Accentuate local features and suppress gradual illumination changes.

    f = zeros(1,512);
    for i = 1:512
        if i-20<1
            e_start = 1; e_end = 41;
        elseif i+20>512
            e_start = 512-24; e_end = 512;
        else
            e_start = i-20; e_end = i+20;
        end
        x2 = mean(e(e_start:e_end));
        f(i) = e(i)/x2;
    end

    g(ii,:) = f; %En-face image obtained from outer retinal layers
end

cd(hm)
fprintf('B-scan extraction done \n')

%% Accentuate retinal layers at different orientations using Gabor Filtering

octEX = flipud(g);
octEX = max(octEX(:))-octEX;
ii = 0;

% The output of the function is stored in a 3D matrix "mag", where each slice in the third dimension
% corresponds to a filter response for a specific orientation.
% [mag,phase] = imgaborfilt(A,wavelength,orientation,Name,Value)
% "wavelength" describes the wavelength in pixels/cycle of the sinusoidal carrier.
% "orientation" is the orientation of the filter in degrees.
% Spatial-frequency bandwidth, specified as a numeric scalar in units of octaves. The spatial-frequency bandwidth
% determines the cutoff of the filter response as frequency content in the input image varies from the preferred
% frequency, 1/lambda.
% Combo of 2 pixels/cycle & 4 octaves: capture fine details in en-face
% image while being sensitive to broader ranges of frequencies around the
% preferred frequency.

for i = 0:5:175
    ii = ii+1;
    [mag(:,:,ii),~] = imgaborfilt(octEX,2,i,'SpatialFrequencyBandwidth',4);
end
octEX1 = max(mag,[],3); % Maximum image response across all orientations.

if sum(isnan(octEX1(:)))>0
    octEX1(isnan(octEX1)) = nanmean(octEX1(:));
end

clear octEX
%% Create multiple candidate warped versions of en-face image
% Use scaling factor in affine transformation to stretch/compress candidate
% patches because en-face image appears to be horizontally stretched when
% system assumes less movement than actual. Conversely, compressed - when
% system assumes more movement than actual.
% N: Negative  scale, P: Positive scale

octEX.N10 = imwarp(octEX1,affinetform2d([(512-warp_step*10)/512,0,0;0,1,0;0,0,1]'));
octEX.N9 = imwarp(octEX1,affinetform2d([(512-warp_step*9)/512,0,0;0,1,0;0,0,1]'));
octEX.N8 = imwarp(octEX1,affinetform2d([(512-warp_step*8)/512,0,0;0,1,0;0,0,1]'));
octEX.N7 = imwarp(octEX1,affinetform2d([(512-warp_step*7)/512,0,0;0,1,0;0,0,1]'));
octEX.N6 = imwarp(octEX1,affinetform2d([(512-warp_step*6)/512,0,0;0,1,0;0,0,1]'));
octEX.N5 = imwarp(octEX1,affinetform2d([(512-warp_step*5)/512,0,0;0,1,0;0,0,1]'));
octEX.N4 = imwarp(octEX1,affinetform2d([(512-warp_step*4)/512,0,0;0,1,0;0,0,1]'));
octEX.N3 = imwarp(octEX1,affinetform2d([(512-warp_step*3)/512,0,0;0,1,0;0,0,1]'));
octEX.N2 = imwarp(octEX1,affinetform2d([(512-warp_step*2)/512,0,0;0,1,0;0,0,1]'));
octEX.N1 = imwarp(octEX1,affinetform2d([(512-warp_step*1)/512,0,0;0,1,0;0,0,1]'));

octEX.norm = octEX1;

octEX.P1 = imwarp(octEX1,affinetform2d([(512+warp_step*1)/512,0,0;0,1,0;0,0,1]'));octEX.P1=octEX.P1(:,2:end-1);
octEX.P2 = imwarp(octEX1,affinetform2d([(512+warp_step*2)/512,0,0;0,1,0;0,0,1]'));octEX.P2=octEX.P2(:,2:end-1);
octEX.P3 = imwarp(octEX1,affinetform2d([(512+warp_step*3)/512,0,0;0,1,0;0,0,1]'));octEX.P3=octEX.P3(:,2:end-1);
octEX.P4 = imwarp(octEX1,affinetform2d([(512+warp_step*4)/512,0,0;0,1,0;0,0,1]'));octEX.P4=octEX.P4(:,2:end-1);
octEX.P5 = imwarp(octEX1,affinetform2d([(512+warp_step*5)/512,0,0;0,1,0;0,0,1]'));octEX.P5=octEX.P5(:,2:end-1);
octEX.P6 = imwarp(octEX1,affinetform2d([(512+warp_step*6)/512,0,0;0,1,0;0,0,1]'));octEX.P6=octEX.P6(:,2:end-1);
octEX.P7 = imwarp(octEX1,affinetform2d([(512+warp_step*7)/512,0,0;0,1,0;0,0,1]'));octEX.P7=octEX.P7(:,2:end-1);
octEX.P8 = imwarp(octEX1,affinetform2d([(512+warp_step*8)/512,0,0;0,1,0;0,0,1]'));octEX.P8=octEX.P8(:,2:end-1);
octEX.P9 = imwarp(octEX1,affinetform2d([(512+warp_step*9)/512,0,0;0,1,0;0,0,1]'));octEX.P9=octEX.P9(:,2:end-1);
octEX.P10 = imwarp(octEX1,affinetform2d([(512+warp_step*10)/512,0,0;0,1,0;0,0,1]'));octEX.P10=octEX.P10(:,2:end-1);%97x522 at first then toned down to 97x520

cd(hm)
b = zeros(1,nBscans);

% Grab the starting Y-coordinates of the B-scans from the OCT XML file;
% i+1 is used as "i" inside the octST Opthalmic Acquisition context structure contains info
% about the cSLO image. All the following files from i+1 contains info about the B-scans
parfor i = 1:nBscans
    b(i) = octST_new.BODY.Patient.Study.Series.Image(i+1).OphthalmicAcquisitionContext.Start.Coord.Y;
end

% Divide each of the Y-coordinates of B-scans with the horizontal scale
Vpos = fliplr(round(b/octST_new.BODY.Patient.Study.Series.Image(2).OphthalmicAcquisitionContext.ScaleX));

% OCT cSLO resolution: 768X768
cN10 = zeros(vM*2+1,size(octEX.N10,2)-11+768,nBscans);
cN9 = zeros(vM*2+1,size(octEX.N9,2)-11+768,nBscans);
cN8 = zeros(vM*2+1,size(octEX.N8,2)-11+768,nBscans);
cN7 = zeros(vM*2+1,size(octEX.N7,2)-11+768,nBscans);
cN6 = zeros(vM*2+1,size(octEX.N6,2)-11+768,nBscans);
cN5 = zeros(vM*2+1,size(octEX.N5,2)-11+768,nBscans);
cN4 = zeros(vM*2+1,size(octEX.N4,2)-11+768,nBscans);
cN3 = zeros(vM*2+1,size(octEX.N3,2)-11+768,nBscans);
cN2 = zeros(vM*2+1,size(octEX.N2,2)-11+768,nBscans);
cN1 = zeros(vM*2+1,size(octEX.N1,2)-11+768,nBscans);
c = zeros(vM*2+1,size(octEX.norm,2)-11+768,nBscans);
cP1 = zeros(vM*2+1,size(octEX.P1,2)-11+768,nBscans);
cP2 = zeros(vM*2+1,size(octEX.P2,2)-11+768,nBscans);
cP3 = zeros(vM*2+1,size(octEX.P3,2)-11+768,nBscans);
cP4 = zeros(vM*2+1,size(octEX.P4,2)-11+768,nBscans);
cP5 = zeros(vM*2+1,size(octEX.P5,2)-11+768,nBscans);
cP6 = zeros(vM*2+1,size(octEX.P6,2)-11+768,nBscans);
cP7 = zeros(vM*2+1,size(octEX.P7,2)-11+768,nBscans);
cP8 = zeros(vM*2+1,size(octEX.P8,2)-11+768,nBscans);
cP9 = zeros(vM*2+1,size(octEX.P9,2)-11+768,nBscans);
cP10 = zeros(vM*2+1,size(octEX.P10,2)-11+768,nBscans);

cmax = zeros(11,nBscans);
fprintf('Aligning B-scans...')
%% Normalized cross-correlation b/w candidate en-face images and OCT cSLO
% Rationale: OCT cSLO can be considered as an "artifact-free" image

parfor i = 1:nBscans
    cN10(:,:,i) = normxcorr2(octEX.N10(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:)); %#ok<*PFOUS,*PFBNS>
    cN9(:,:,i) = normxcorr2(octEX.N9(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cN8(:,:,i) = normxcorr2(octEX.N8(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cN7(:,:,i) = normxcorr2(octEX.N7(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cN6(:,:,i) = normxcorr2(octEX.N6(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cN5(:,:,i) = normxcorr2(octEX.N5(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cN4(:,:,i) = normxcorr2(octEX.N4(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cN3(:,:,i) = normxcorr2(octEX.N3(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cN2(:,:,i) = normxcorr2(octEX.N2(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cN1(:,:,i) = normxcorr2(octEX.N1(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    c(:,:,i) = normxcorr2(octEX.norm(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cP1(:,:,i) = normxcorr2(octEX.P1(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cP2(:,:,i) = normxcorr2(octEX.P2(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cP3(:,:,i) = normxcorr2(octEX.P3(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cP4(:,:,i) = normxcorr2(octEX.P4(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cP5(:,:,i) = normxcorr2(octEX.P5(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cP6(:,:,i) = normxcorr2(octEX.P6(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cP7(:,:,i) = normxcorr2(octEX.P7(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cP8(:,:,i) = normxcorr2(octEX.P8(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cP9(:,:,i) = normxcorr2(octEX.P9(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
    cP10(:,:,i) = normxcorr2(octEX.P10(i,6:end-5),octSLO(Vpos(i)-vM:Vpos(i)+vM,:));
end

if vH==0 %If the B-scan is unconstrained horizontally (see parameters above)

    % Remove edge effects resulting from computing cross-correlation.

    cN10(:,[1:length(octEX.N10(1,6:end-5))-1,769:end],:) = 0;
    cN9(:,[1:length(octEX.N9(1,6:end-5))-1,769:end],:) = 0;
    cN8(:,[1:length(octEX.N8(1,6:end-5))-1,769:end],:) = 0;
    cN7(:,[1:length(octEX.N7(1,6:end-5))-1,769:end],:) = 0;
    cN6(:,[1:length(octEX.N6(1,6:end-5))-1,769:end],:) = 0;
    cN5(:,[1:length(octEX.N5(1,6:end-5))-1,769:end],:) = 0;
    cN4(:,[1:length(octEX.N4(1,6:end-5))-1,769:end],:) = 0;
    cN3(:,[1:length(octEX.N3(1,6:end-5))-1,769:end],:) = 0;
    cN2(:,[1:length(octEX.N2(1,6:end-5))-1,769:end],:) = 0;
    cN1(:,[1:length(octEX.N1(1,6:end-5))-1,769:end],:) = 0;
    c(:,[1:length(octEX.norm(1,6:end-5))-1,769:end],:) = 0;
    cP1(:,[1:length(octEX.P1(1,6:end-5))-1,769:end],:) = 0;
    cP2(:,[1:length(octEX.P2(1,6:end-5))-1,769:end],:) = 0;
    cP3(:,[1:length(octEX.P3(1,6:end-5))-1,769:end],:) = 0;
    cP4(:,[1:length(octEX.P4(1,6:end-5))-1,769:end],:) = 0;
    cP5(:,[1:length(octEX.P5(1,6:end-5))-1,769:end],:) = 0;
    cP6(:,[1:length(octEX.P6(1,6:end-5))-1,769:end],:) = 0;
    cP7(:,[1:length(octEX.P7(1,6:end-5))-1,769:end],:) = 0;
    cP8(:,[1:length(octEX.P8(1,6:end-5))-1,769:end],:) = 0;
    cP9(:,[1:length(octEX.P9(1,6:end-5))-1,769:end],:) = 0;
    cP10(:,[1:length(octEX.P10(1,6:end-5))-1,769:end],:) = 0;
else
    % Grab the starting X-coordinates of the B-scans from the OCT XML file.
    % Only one coordinate (here the x-coord from 9th b-scan (i.e. 10) is
    % used) since the X-coordinate is always the same for the B-scans by
    % manufacturer design.

    b = octST_new.BODY.Patient.Study.Series.Image(10).OphthalmicAcquisitionContext.Start.Coord.X;
    Hpos = fliplr(round(b/octST_new.BODY.Patient.Study.Series.Image(2).OphthalmicAcquisitionContext.ScaleX));

    % Set NCC maps to zero if they exceed edges
    cN10(:,[1:length(octEX.N10(1,6:end-5))+Hpos-vH,length(octEX.N10(1,6:end-5))+Hpos+vH:end],:) = 0;
    cN9(:,[1:length(octEX.N9(1,6:end-5))+Hpos-vH,length(octEX.N9(1,6:end-5))+Hpos+vH:end],:) = 0;
    cN8(:,[1:length(octEX.N8(1,6:end-5))+Hpos-vH,length(octEX.N8(1,6:end-5))+Hpos+vH:end],:) = 0;
    cN7(:,[1:length(octEX.N7(1,6:end-5))+Hpos-vH,length(octEX.N7(1,6:end-5))+Hpos+vH:end],:) = 0;
    cN6(:,[1:length(octEX.N6(1,6:end-5))+Hpos-vH,length(octEX.N6(1,6:end-5))+Hpos+vH:end],:) = 0;
    cN5(:,[1:length(octEX.N5(1,6:end-5))+Hpos-vH,length(octEX.N5(1,6:end-5))+Hpos+vH:end],:) = 0;
    cN4(:,[1:length(octEX.N4(1,6:end-5))+Hpos-vH,length(octEX.N4(1,6:end-5))+Hpos+vH:end],:) = 0;
    cN3(:,[1:length(octEX.N3(1,6:end-5))+Hpos-vH,length(octEX.N3(1,6:end-5))+Hpos+vH:end],:) = 0;
    cN2(:,[1:length(octEX.N2(1,6:end-5))+Hpos-vH,length(octEX.N2(1,6:end-5))+Hpos+vH:end],:) = 0;
    cN1(:,[1:length(octEX.N1(1,6:end-5))+Hpos-vH,length(octEX.N1(1,6:end-5))+Hpos+vH:end],:) = 0;
    c(:,[1:length(octEX.norm(1,6:end-5))+Hpos-vH,length(octEX.norm(1,6:end-5))+Hpos+vH:end],:) = 0;
    cP1(:,[1:length(octEX.P1(1,6:end-5))+Hpos-vH,length(octEX.P1(1,6:end-5))+Hpos+vH:end],:) = 0;
    cP2(:,[1:length(octEX.P2(1,6:end-5))+Hpos-vH,length(octEX.P2(1,6:end-5))+Hpos+vH:end],:) = 0;
    cP3(:,[1:length(octEX.P3(1,6:end-5))+Hpos-vH,length(octEX.P3(1,6:end-5))+Hpos+vH:end],:) = 0;
    cP4(:,[1:length(octEX.P4(1,6:end-5))+Hpos-vH,length(octEX.P4(1,6:end-5))+Hpos+vH:end],:) = 0;
    cP5(:,[1:length(octEX.P5(1,6:end-5))+Hpos-vH,length(octEX.P5(1,6:end-5))+Hpos+vH:end],:) = 0;
    cP6(:,[1:length(octEX.P6(1,6:end-5))+Hpos-vH,length(octEX.P6(1,6:end-5))+Hpos+vH:end],:) = 0;
    cP7(:,[1:length(octEX.P7(1,6:end-5))+Hpos-vH,length(octEX.P7(1,6:end-5))+Hpos+vH:end],:) = 0;
    cP8(:,[1:length(octEX.P8(1,6:end-5))+Hpos-vH,length(octEX.P8(1,6:end-5))+Hpos+vH:end],:) = 0;
    cP9(:,[1:length(octEX.P9(1,6:end-5))+Hpos-vH,length(octEX.P9(1,6:end-5))+Hpos+vH:end],:) = 0;
    cP10(:,[1:length(octEX.P10(1,6:end-5))+Hpos-vH,length(octEX.P10(1,6:end-5))+Hpos+vH:end],:) = 0;
end

% Find the position at which the maximum correlation occurs in the
% corresponding NCC map for each B-scan.
for i = 1:nBscans
    cmax(1,i) = max(reshape(cN10(:,:,i),1,[]));
    cmax(2,i) = max(reshape(cN9(:,:,i),1,[]));
    cmax(3,i) = max(reshape(cN8(:,:,i),1,[]));
    cmax(4,i) = max(reshape(cN7(:,:,i),1,[]));
    cmax(5,i) = max(reshape(cN6(:,:,i),1,[]));
    cmax(6,i) = max(reshape(cN5(:,:,i),1,[]));
    cmax(7,i) = max(reshape(cN4(:,:,i),1,[]));
    cmax(8,i) = max(reshape(cN3(:,:,i),1,[]));
    cmax(9,i) = max(reshape(cN2(:,:,i),1,[]));
    cmax(10,i) = max(reshape(cN1(:,:,i),1,[]));
    cmax(11,i) = max(reshape(c(:,:,i),1,[]));
    cmax(12,i) = max(reshape(cP1(:,:,i),1,[]));
    cmax(13,i) = max(reshape(cP2(:,:,i),1,[]));
    cmax(14,i) = max(reshape(cP3(:,:,i),1,[]));
    cmax(15,i) = max(reshape(cP4(:,:,i),1,[]));
    cmax(16,i) = max(reshape(cP5(:,:,i),1,[]));
    cmax(17,i) = max(reshape(cP6(:,:,i),1,[]));
    cmax(18,i) = max(reshape(cP7(:,:,i),1,[]));
    cmax(19,i) = max(reshape(cP8(:,:,i),1,[]));
    cmax(20,i) = max(reshape(cP9(:,:,i),1,[]));
    cmax(21,i) = max(reshape(cP10(:,:,i),1,[]));
end

global colrow
colrow = zeros(nBscans,3);

% Determine the row and column indices of maximum correlation in
% corresponding NCC map

for i = 1:nBscans
    [~,t] = max(cmax(:,i));
    switch t
        case 1
            [NPcol,NProw] = find(cN10(:,:,i)==max(reshape(cN10(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.N10(:,6:end-5),2);
        case 2
            [NPcol,NProw] = find(cN9(:,:,i)==max(reshape(cN9(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.N9(:,6:end-5),2);
        case 3
            [NPcol,NProw] = find(cN8(:,:,i)==max(reshape(cN8(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw=round(mean(NProw));
            NProw = NProw+1-size(octEX.N8(:,6:end-5),2);
        case 4
            [NPcol,NProw] = find(cN7(:,:,i)==max(reshape(cN7(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.N7(:,6:end-5),2);
        case 5
            [NPcol,NProw] = find(cN6(:,:,i)==max(reshape(cN6(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.N6(:,6:end-5),2);
        case 6
            [NPcol,NProw] = find(cN5(:,:,i)==max(reshape(cN5(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.N5(:,6:end-5),2);
        case 7
            [NPcol,NProw] = find(cN4(:,:,i)==max(reshape(cN4(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.N4(:,6:end-5),2);
        case 8
            [NPcol,NProw] = find(cN3(:,:,i)==max(reshape(cN3(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.N3(:,6:end-5),2);
        case 9
            [NPcol,NProw] = find(cN2(:,:,i)==max(reshape(cN2(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.N2(:,6:end-5),2);
        case 10
            [NPcol,NProw] = find(cN1(:,:,i)==max(reshape(cN1(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.N1(:,6:end-5),2);
        case 11
            [NPcol,NProw] = find(c(:,:,i)==max(reshape(c(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.norm(:,6:end-5),2);
        case 12
            [NPcol,NProw] = find(cP1(:,:,i)==max(reshape(cP1(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.P1(:,6:end-5),2);
        case 13
            [NPcol,NProw] = find(cP2(:,:,i)==max(reshape(cP2(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.P2(:,6:end-5),2);
        case 14
            [NPcol,NProw] = find(cP3(:,:,i)==max(reshape(cP3(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.P3(:,6:end-5),2);
        case 15
            [NPcol,NProw] = find(cP4(:,:,i)==max(reshape(cP4(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.P4(:,6:end-5),2);
        case 16
            [NPcol,NProw] = find(cP5(:,:,i)==max(reshape(cP5(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.P5(:,6:end-5),2);
        case 17
            [NPcol,NProw] = find(cP6(:,:,i)==max(reshape(cP6(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.P6(:,6:end-5),2);
        case 18
            [NPcol,NProw] = find(cP7(:,:,i)==max(reshape(cP7(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.P7(:,6:end-5),2);
        case 19
            [NPcol,NProw] = find(cP8(:,:,i)==max(reshape(cP8(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.P8(:,6:end-5),2);
        case 20
            [NPcol,NProw] = find(cP9(:,:,i)==max(reshape(cP9(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.P9(:,6:end-5),2);
        case 21
            [NPcol,NProw] = find(cP10(:,:,i)==max(reshape(cP10(:,:,i),1,[])));
            NPcol = round(mean(NPcol))-(vM+1)+Vpos(i); NProw = round(mean(NProw));
            NProw = NProw+1-size(octEX.P10(:,6:end-5),2);
    end
    colrow(i,:) = [NPcol,NProw,t];
end

fprintf('Done \n')

recovered = octSLO1; colrow2 = colrow;
%% Hampel Filtering & Interpolation for outliers from NCC

if vars.Bsmooth==1
    Ra = hampel(colrow(:,2),5); Rb = (Ra-colrow(:,2))==0; x = 1:nBscans;
    Ca = hampel(colrow(:,1),5); Cb = (Ca-colrow(:,1))==0; b = logical(Rb.*Cb);
    colrow(:,1) = round(interp1(x(b),Ca(b),x,'Spline'));
    colrow(:,2) = round(interp1(x(b),Ra(b),x,'Spline'));
    colrow(:,3) = round(interp1(x(b),colrow(b,3),x,'Spline'));
end

% If the difference between the interpolated and original column and row
% coordinates is less than a certain threshold, retain original coordinates;
% otherwise, replace with interpolated values.

for i = 1:nBscans
    if abs(colrow(i,1)-colrow2(i,1))<=3 && abs(colrow(i,2)-colrow2(i,2))<=5
        colrow(i,:) = colrow2(i,:);
    end

    % Correct for out-of-bounds coordinates

    if colrow(i,1)<1
        if colrow2(i,1)<1
            colrow(i,1) = 1;
        else
            colrow(i,1) = colrow2(i,1);
        end
    elseif colrow(i,1)>768
        if colrow2(i,1)>768
            colrow(i,1) = 768;
        else
            colrow(i,1) = colrow2(i,1);
        end
    end

    if colrow(i,3)<1
        if colrow2(i,3)<1
            colrow(i,3) = 1;
        else
            colrow(i,3) = colrow2(i,3);
        end
    elseif colrow(i,3)>21
        if colrow2(i,3)>21
            colrow(i,3) = 21;
        else
            colrow(i,3) = colrow2(i,3);
        end
    end

    if colrow(i,2)<1
        if colrow2(i,2)<1
            colrow(i,2) = 1;
        else
            colrow(i,2) = colrow2(i,2);
        end
    elseif colrow(i,2)>257+(11-colrow(i,3))
        if colrow2(i,2)>257+(11-colrow(i,3))
            colrow(i,2)=257+(11-colrow(i,3));
        else
            colrow(i,2) = colrow2(i,2);
        end
    end

    %% Map the B-scans to appropriate positions in OCT cSLO and display the result

    switch colrow(i,3)
        case 1
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.N10(:,6:end-5),2)-1) = octEX.N10(i,6:end-5);
        case 2
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.N9(:,6:end-5),2)-1) = octEX.N9(i,6:end-5);
        case 3
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.N8(:,6:end-5),2)-1) = octEX.N8(i,6:end-5);
        case 4
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.N7(:,6:end-5),2)-1) = octEX.N7(i,6:end-5);
        case 5
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.N6(:,6:end-5),2)-1) = octEX.N6(i,6:end-5);
        case 6
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.N5(:,6:end-5),2)-1) = octEX.N5(i,6:end-5);
        case 7
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.N4(:,6:end-5),2)-1) = octEX.N4(i,6:end-5);
        case 8
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.N3(:,6:end-5),2)-1) = octEX.N3(i,6:end-5);
        case 9
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.N2(:,6:end-5),2)-1) = octEX.N2(i,6:end-5);
        case 10
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.N1(:,6:end-5),2)-1) = octEX.N1(i,6:end-5);
        case 11
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.norm(:,6:end-5),2)-1) = octEX.norm(i,6:end-5);
        case 12
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.P1(:,6:end-5),2)-1) = octEX.P1(i,6:end-5);
        case 13
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.P2(:,6:end-5),2)-1) = octEX.P2(i,6:end-5);
        case 14
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.P3(:,6:end-5),2)-1) = octEX.P3(i,6:end-5);
        case 15
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.P4(:,6:end-5),2)-1) = octEX.P4(i,6:end-5);
        case 16
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.P5(:,6:end-5),2)-1) = octEX.P5(i,6:end-5);
        case 17
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.P6(:,6:end-5),2)-1) = octEX.P6(i,6:end-5);
        case 18
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.P7(:,6:end-5),2)-1) = octEX.P7(i,6:end-5);
        case 19
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.P8(:,6:end-5),2)-1) = octEX.P8(i,6:end-5);
        case 20
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.P9(:,6:end-5),2)-1) = octEX.P9(i,6:end-5);
        case 21
            recovered(colrow(i,1),colrow(i,2):colrow(i,2)+size(octEX.P10(:,6:end-5),2)-1) = octEX.P10(i,6:end-5);
    end
end

% Display and save the B-scans on OCT CSLO image
figure(1), set(gcf,'units','normalized','position',[0 0 .5 1]), imagesc(recovered), colormap gray, xlabel('X -->'), ylabel('Y (downwards)'), title('B Scans Alignment')
savefig([Dir.ResultPath '/B Scans Alignment']);

figure(2), set(gcf,'units','normalized','position',[.5 0 .5 1]), imagesc(octEX.norm), colormap gray, ylabel('No. of b-scans'), title('B Scans without Warping')
savefig([Dir.ResultPath '/B Scans without Warping']);

% Number the B-scans
figure; imshow(recovered,[]); xlabel('X'); ylabel('Y'); title('B-scan alignment with scan numbers')

for r = 1:size(colrow,1)
    bscan_text = text(colrow(r,2)-40,colrow(r,1),strcat('#',num2str(r))); % 40 pixels away from the starting location of the B-scan for better legibility
    if r==1
        continue
    end
    if colrow(r,1)==colrow(r-1,1)
        bscan_text.Color = [0.6350 0.0780 0.1840]; % Highlight overlapping B-scans
    else
        bscan_text.Color = 'black';
    end
end

hold on
dummy_data_legend = plot(nan, nan, '*','color', [0.6350 0.0780 0.1840]);
legend_bscan_numbers = legend(dummy_data_legend);
legend_bscan_numbers.String = 'Partially overlapping B-scan';
legend_bscan_numbers.FontSize = 12;
axis on;
set(gcf, 'Color', 'w');

global OCT_w_Bscan

if mean(recovered(:))>1
    OCT_w_Bscan = recovered;
else
    OCT_w_Bscan = recovered*255;
end
toc
end