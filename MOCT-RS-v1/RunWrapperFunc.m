%% Wrapper Function (Order of program execution: 2)

% This is a wrapper function which performs several tasks:
% 1) Allows user to select a particular subject's OCT and MAIA image
% 2) Automatically aligns the OCT B-scans accounting for eye movements
% 3) Performs registration of MAIA to the OCT image either automatically or
%    manually based on user choice. If the automatic method fails, the
%    framework switches to the manual mode

function RunWrapperFunc(vars,main_menu)

try
    close all

    currentDIR = pwd;
    mainPath = currentDIR;

    cd(vars.folderB)
    [file,path] = uigetfile({'*.tif'},'Select OCT fundus Image of a particular subject','OCT.tif');
    cd(vars.folderM)
    [file2,path2] = uigetfile({'*.png'},'Select MAIA fundus Image of the same subject','MAIA.png');
    resultPath = uigetdir(pwd,'Choose Result Directory of the same subject');
    Dir.file = file;
    Dir.path = path;
    Dir.file2 = file2;
    Dir.path2 = path2;
    Dir.ResultPath = resultPath;
    Dir.MainPath = mainPath;

    assignin('base','Dir',Dir);

    if ~ischar(file) || ~ischar(file2)
        error('You did not select a fundus image!')
    end

    vars.nBscans = size(dir([Dir.path '**/*.tif']),1)-1; %OCT folder has Bscans + 1 CSLO
    maia_threshold_file = dir([Dir.path2 '*','_threshold.txt']);
    maia_threshold_path = [maia_threshold_file.folder, '\', maia_threshold_file.name];

    vars.nMaiaPoints = find_no_maia_pts(maia_threshold_path);

    cd(currentDIR)
    path
    path2
    commandwindow

    fprintf('Starting b-scans auto alignment.. \n');
    auto_bscan_OCT_alignment(vars,Dir) % Automatic OCT B-scan alignment module

    % Future Feature
    feature_align_check_on = 0;
    pause(3);
    if feature_align_check_on
        % Dialog box
        an = questdlg('Do the B-scan lines look okay?');
        if strcmp(an,'No')
            GUIhome(main_menu)
            error('B-scans okay?: No\nTry again using some different parameters')
        elseif strcmp(an,'Cancel')
            GUIhome(main_menu)
            error('Program closed - cancel pressed')
        elseif isempty(an)
            GUIhome(main_menu)
            error('Program closed')
        end
    end

    %% Choice of Automatic or Manual Mode
    if vars.Mauto == 1
        fprintf('Starting the Automatic MAIA-OCT Coregistration procedure.. \n');
        fprintf('Calling FIJI. Do not press any button until the procedure is complete or an error is thrown.. \n');
        fiji_in_matlab(vars,Dir) % Automatic Coregistration Module
    else
        fprintf('Starting the Manual MAIA-OCT Coregistration procedure.. \n');
        Manual_MAIA_OCT_RS(vars,Dir) % Manual Coregistration Module
    end

    % Dialog box
    an = questdlg('Is the co-registration acceptable to you?');
    if strcmp(an,'No')
        if vars.Mauto == 1
            disp('Starting the Manual MAIA-OCT Coregistration procedure.')
            Manual_MAIA_OCT_RS(vars,Dir)
        else
            GUIhome(main_menu)
            error('Retry manual alignment with more number of points OR retry with the Automatic Coregistration method if you have not tried so far');
        end
    elseif strcmp(an,'Yes')
        close all
        GUIhome(main_menu)
    elseif strcmp(an,'Cancel')
        GUIhome(main_menu)
        error('Program closed - cancel pressed')
    elseif isempty(an)
        GUIhome(main_menu)
        error('Program closed')
    end
    GUIhome(main_menu)

catch runERROR
    cd(currentDIR)
    GUIhome(main_menu)
    rE='## ERROR IN ##\n';
    for i=1:length(runERROR.stack)
        rE=strcat(rE,runERROR.stack(i).name,' \nLine: ',num2str(runERROR.stack(i).line),' \n');
    end
    error([rE,runERROR.message],[])
end
end

function GUIhome(main_menu)
commandwindow
main_menu.Visible = 'Off';
main_menu.Visible = 'On';
end