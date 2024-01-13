%% Retinal Thickness Query Module (Order of program execution: 5)

% This module queries the retinal thickness of all layers for each MAIA sensitivity point.
% It first extracts the pixel values of all the surfaces in the XML file generated
% by OCT-Explorer for the corresponding b-scan and the "y" value within that b-scan. Then
% it subtracts the values between these surfaces and multiplies it by 3.9
% (axial resolution: 3.9µm/pixel) to get the retinal thickness.

function ThicknessQuery_new_RS(Dir)

cd(Dir.ResultPath);

if ~isempty(dir('CorregisterResult.mat')) && ~isempty(dir('*bscans_Sequence'))
    b = dir('CorregisterResult.mat');
    load(b.name);
    disp(pwd);

    final_values = [clos_bscan_n_maialoc_bscan_wo_ON(:,1:2),zeros(size(clos_bscan_n_maialoc_bscan_wo_ON,1),11)]; %#ok<*NODEF>

    cd(Dir.MainPath);

    XML_new = readstruct([Dir.ResultPath '/bscans_Sequence/bscans_Sequence_Surfaces_Iowa.xml']);

    for Xiii=1:size(final_values,1) % i.e. no. of MAIA points
        if round(final_values(Xiii,2))>XML_new.surface_size.x||round(final_values(Xiii,2))<1 % If the y-location in a particular b-scan
            % is less than 1 or greater than 512, then there is no thickness available

            disp(['No thickness available for MAIA point #' num2str(maia_ID_without_ON(Xiii)) ' because it is ' num2str(final_values(Xiii,2)) ' pixels away from the starting location of the b-scan #' num2str(final_values(Xiii,1))]); %More clearer way of reporting no thickness
            final_values(Xiii,3:13)=nan;
        else
            final_values(Xiii,3:13) = [XML_new.surface(1).bscan(final_values(Xiii,1)).y(round(final_values(Xiii,2))),XML_new.surface(2).bscan(final_values(Xiii,1)).y(round(final_values(Xiii,2))),XML_new.surface(3).bscan(final_values(Xiii,1)).y(round(final_values(Xiii,2))),...
                XML_new.surface(4).bscan(final_values(Xiii,1)).y(round(final_values(Xiii,2))),XML_new.surface(5).bscan(final_values(Xiii,1)).y(round(final_values(Xiii,2))),XML_new.surface(6).bscan(final_values(Xiii,1)).y(round(final_values(Xiii,2))),...
                XML_new.surface(7).bscan(final_values(Xiii,1)).y(round(final_values(Xiii,2))),XML_new.surface(8).bscan(final_values(Xiii,1)).y(round(final_values(Xiii,2))),XML_new.surface(9).bscan(final_values(Xiii,1)).y(round(final_values(Xiii,2))),...
                XML_new.surface(10).bscan(final_values(Xiii,1)).y(round(final_values(Xiii,2))),XML_new.surface(11).bscan(final_values(Xiii,1)).y(round(final_values(Xiii,2)))];

            final_values_converted(:,1:2) = final_values(:,1:2);
            final_values_converted(:,3:12) = (final_values(:,4:13)-final_values(:,3:12))*3.9;
            % Axial resolution of Heidelberg Spectralis OCT/SLO is 3.9 micrometer

            final_values_converted(:,3:14) = final_values_converted(:,1:12);
            final_values_converted(:,1) = maia_ID_without_ON;
            final_values_converted(:,2) = maia_Thresh_without_ON;
        end
    end

    MAIA_values_converted_table = array2table(final_values_converted);

    MAIA_values_converted_table.Properties.VariableNames = {'MAIA_ID','MAIA_Threshold (dB)','Closest b-scan','Adj. dist b/w MAIA pt & start of b-scan (pixels)','B/w ILM & RNFL-GCL (µm)',...
        'B/w RNFL-GCL & GCL-IPL (µm)','B/w GCL-IPL & IPL-INL (µm)','B/w IPL-INL & INL-OPL (µm)','B/w INL-OPL & OPL-Henles Fiber Layer (µm)',...
        'B/w OPL-HFL & BMEIS (µm)','B/w BMEIS & IS/OS junction (IS/OSJ) (µm)','B/w IS/OSJ & Inner boundary of OPR (IB_OPR) (µm)',...
        'B/w IB_OPR & Inner boundary of RPE (IB_RPE) (µm)','B/w IB_RPE & Outer boundary of RPE (OB_RPE) (µm)'};

    if vars.Mauto == 1
        writetable(MAIA_values_converted_table, [Dir.ResultPath '\Retinal Thickness_Automatic.xlsx']);
    else
        writetable(MAIA_values_converted_table, [Dir.ResultPath '\Retinal Thickness_Manual.xlsx']);
    end

    fprintf('Procedure complete. Check out the Retinal Thickness excel sheet in the Results folder! \n');

elseif isempty(dir('*.mat'))
    error('Can''t find the CorregisterResult.mat file that contains the MAIA positions!');
elseif isempty(dir('*bscans_Sequence'))
    error('The ''bscans_Sequence'' output by OCT-Explorer should be placed in the ''Result'' folder!!');
end

end