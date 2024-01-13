%% Retinal Structure-Function Assessment Framework

% MIT License
% Copyright 2023 © Rijul S. Soans, © Benjamin E. Smith, © Susana T. L. Chung

% Main Program (Order of program execution: 1)

% This program generates a UI where the user can input parameters.

%% Initialize
close all
clear;

currentDIR = pwd;
addpath(genpath(currentDIR));
cd ..
prevDIR = pwd;

%% Set all the parameters to be displayed on the GUI
main_menu = uifigure('Position',[500 300 657 464]); 
main_menu.Pointer = 'hand';

title_label = uilabel(main_menu);
title_label.Text = 'Retinal Structure-Function Assessment Framework';
title_label.Position = [32,410,600,65];
title_label.FontSize = 24;
title_label.FontWeight = 'bold';

subtitle_label_text = sprintf('%s\n%s\n%s','Sight Enhancement Lab','Herbert Wertheim School of Optometry & Vision Science','University of California, Berkeley, USA');
subtitle_label = uilabel(main_menu,"Text",subtitle_label_text,"Position",[50,360,600,65]);
subtitle_label.FontSize = 18;
subtitle_label.FontAngle = 'italic';
subtitle_label.HorizontalAlignment = 'center';

instruction_button = uibutton(main_menu);
instruction_button.Text = 'Start here: Instructions';
instruction_button.Position = [192,300,258,46];
instruction_button.FontSize = 18;
instruction_button.FontWeight = 'bold';
instruction_button.ButtonPushedFcn = 'open(''Read_me_first_Manual_v010.docx'')';

general_checklist_panel = uipanel(main_menu);
general_checklist_panel.Position = [34,143,174,138];
general_checklist_panel.Title = 'General Checklists:';
general_checklist_panel.FontSize = 14;
general_checklist_panel.FontWeight = 'bold';

xml_checkbox = uicheckbox(main_menu);
xml_checkbox.Position = [44,158,106,41];
xml_checkbox.Text = 'Is the XML file under OCT folder?';
xml_checkbox.WordWrap = "on";
xml_checkbox.Tooltip = 'Check this box if the XML file is placed under SubjectID-->OCT';

bscan_checkbox = uicheckbox(main_menu);
bscan_checkbox.Position = [44,208,106,41];
bscan_checkbox.Text = 'Are B-scans under "bscans" folder?';
bscan_checkbox.WordWrap = "on";
bscan_checkbox.Tooltip = 'Check this box if the bscans are placed under SubjectID-->OCT-->bscans';

registration_panel = uipanel(main_menu);
registration_panel.Position = [348,205,279,75];
registration_panel.Title = 'Registration Panel:';
registration_panel.FontSize = 14;
registration_panel.FontWeight = 'bold';

registration_type_label = uilabel(main_menu);
registration_type_label.Text = 'Coregistration Type:';
registration_type_label.Position = [358,200,600,65];
registration_type_dropdown = uidropdown(main_menu,"Items",["Automatic Mode","Manual Mode"]);
registration_type_dropdown.ItemsData = ["1","0"];
registration_type_dropdown.Position = [478,225,120,20];

lab_logo = uiimage(main_menu);
lab_logo.ImageSource = "selab_logo.png";
lab_logo.Position = [35,20,100,100];

sw_version_label = uilabel(main_menu);
sw_version_label.Text = 'Software Version: 0.1.0';
sw_version_label.FontSize = 16;
sw_version_label.Position = [238,-20,200,100];

authors_label_text = sprintf('%s\n%s\n%s\n%s','Authors:','Rijul S. Soans, PhD','Benjamin E. Smith, PhD','Susana T. L. Chung, OD, PhD'); 
authors_label = uilabel(main_menu,"Text",authors_label_text,"Position",[475,15,600,65]);
authors_label.FontSize = 12;
authors_label.HorizontalAlignment = 'left';

begin_analysis_button = uibutton(main_menu);
begin_analysis_button.Text = 'Begin Analysis';
begin_analysis_button.Position = [347,144,280,47];
begin_analysis_button.FontSize = 18;
begin_analysis_button.FontWeight = 'bold';
begin_analysis_button.ButtonPushedFcn = ['cd(currentDIR); vars.xml = xml_checkbox.Value;',...
'vars.folder = bscan_checkbox.Value; vars.Mauto = str2num(registration_type_dropdown.Value); vars.WarpStep = 1;',...
'vars.HorzM = 50; vars.Bsmooth = 1;',...
'vars.nBscans = []; vars.nMaiaPoints = []; vars.folderB = prevDIR; vars.folderM = prevDIR;',...
'vars.VertM = 10; RunWrapperFunc(vars,main_menu)'];
