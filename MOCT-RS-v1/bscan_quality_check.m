%% OCT B-scan Quality Check

% This module tries to check if any OCT B-scans have been cut off abruptly due to imaging issues

function [flagged_bscan_indices] = bscan_quality_check(all_the_bscans,path)

flagged_bscan_indices(length(all_the_bscans),1) = 0;

parfor ii=1:length(all_the_bscans)
    try
        bscan=imread([path,'/',num2str(ii),'.tif']);
    catch
        warning('on'); %#ok<WNON>
        warning([strcat(num2str(ii),'.tif'),' does not exist'])
        warning('off');
        continue
    end

    if size(bscan,3)>1
        bscan=mean(bscan,3); %496X512; %This is the same as rgb2gray in this case as all the channels of b-scan image have the same values; so taking mean will also result in same values
    end

    [~,p]=max(bscan); % Look for the brightest patches in the B-scan. "p" reports the row in which the
    % maximum pixel value occurs in each column i.e u get a 1x 512 vector.

    top_edge = min(p); % Find the top retinal layer boundary
    bottom_edge = max(p); % Find the bottom retinal layer boundary

    cropped_image = imcrop(bscan,[0 top_edge-20 512 bottom_edge-top_edge+40]);
    % figure; imshow(cropped_image,[]);

    edge_image = edge(cropped_image,'Canny');
    skeletonized_image = bwmorph(edge_image,"skel",Inf);

    filtered_layers_image = bwpropfilt(skeletonized_image,'Area',[450, Inf],8);
    % figure; imshow(filtered_layers_image);

    [labelled_layer_matrix,no_of_layers] = bwlabel(filtered_layers_image);

    try
        % Find starting locations of the two layers.
        [start_row_layer1, start_col_layer1] = find(labelled_layer_matrix == 1, 1, 'first');
        [start_row_layer2, start_col_layer2] = find(labelled_layer_matrix == 2, 1, 'first');

        boundary_layer1 = bwtraceboundary(labelled_layer_matrix == 1,[start_row_layer1, start_col_layer1],"E",8);
        boundary_layer2 = bwtraceboundary(labelled_layer_matrix == 2,[start_row_layer2, start_col_layer2],"E",8);

        % Extract coordinates of the first 512 pixels along the boundary
        numPixelsToKeep_layer1 = min(512, size(boundary_layer1, 1));
        numPixelsToKeep_layer2 = min(512, size(boundary_layer2, 1));

        if size(boundary_layer1, 1) > numPixelsToKeep_layer1
            boundary_layer1 = boundary_layer1(1:numPixelsToKeep_layer1, :);
        end

        if size(boundary_layer2, 1) > numPixelsToKeep_layer2
            boundary_layer2 = boundary_layer2(1:numPixelsToKeep_layer2, :);
        end

        % Create a binary mask to keep only the desired pixels for Layer 1
        mask_layer1 = false(size(labelled_layer_matrix));
        linearIndices_layer1 = sub2ind(size(mask_layer1), boundary_layer1(:, 1), boundary_layer1(:, 2));
        mask_layer1(linearIndices_layer1) = true;

        % Apply the mask to keep only the first 512 pixels
        cropped_layer1 = (labelled_layer_matrix == 1) & mask_layer1;
        % figure; imshow(cropped_layer1);

        % Create a binary mask to keep only the desired pixels for Layer 2
        mask_layer2 = false(size(labelled_layer_matrix));
        linearIndices_layer2 = sub2ind(size(mask_layer2), boundary_layer2(:, 1), boundary_layer2(:, 2));
        mask_layer2(linearIndices_layer2) = true;

        % Apply the mask to keep only the first 512 pixels
        cropped_layer2 = (labelled_layer_matrix == 2) & mask_layer2;
        % figure; imshow(cropped_layer2);

        eccentricity_layer1_struct = regionprops(cropped_layer1,"Eccentricity");
        eccentricities_layer1 = eccentricity_layer1_struct.Eccentricity;

        eccentricity_layer2_struct = regionprops(cropped_layer2,"Eccentricity");
        eccentricities_layer2 = eccentricity_layer2_struct.Eccentricity;

        % Specify tolerance since the values returned are floating point
        % numbers.
        if (ismembertol(eccentricities_layer1, 1, 10e-06)|| ismembertol(eccentricities_layer2, 1, 10e-06))
            flagged_bscan_indices(ii,1) = 1;
        end

    catch
        flagged_bscan_indices(ii,1) = 1;
        warning('on'); %#ok<WNON>
        %warning([strcat(num2str(ii),'.tif'),' may have an issue'])
        warning('off');
    end
end
