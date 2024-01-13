%% OCT B-scan fixer

% This module tries to fix faulty B-scans by doing a weighted interpolation
% of the nearby non-faulty B-scans.

function bscan_fixer(faulty_indices,all_the_bscans)

folder_path = all_the_bscans(1).folder;
warning('on');
warning('Make sure you have a backup of the original OCT B-scans. This step will overwrite it!')
warning('off');

% Specify the range of images for interpolation (5 previous and 5 next)
interpolation_range = -2:2;

% Loop through the faulty indices
for faulty_idx = 1:length(faulty_indices)
    % Construct the filename of the faulty image
    faulty_filename = sprintf('%d.tif', faulty_indices(faulty_idx));

    % Load the faulty image
    faulty_image = imread(fullfile(folder_path, faulty_filename));

    faulty_image_collapsed = mean(faulty_image,3);

    % Initialize the interpolated image for each channel
    interpolated_image = zeros(size(faulty_image_collapsed));

    % Loop through the interpolation range
    for offset = 1:length(interpolation_range)
        % Calculate the index of the neighboring image
        neighbor_idx = faulty_indices(faulty_idx) + interpolation_range(offset);

        % Skip faulty and out-of-bounds indices
        if neighbor_idx < 1 || neighbor_idx > 97 || ismember(neighbor_idx, faulty_indices)
            continue;
        end

        % Construct the filename of the neighboring image
        neighbor_filename = sprintf('%d.tif', neighbor_idx);

        % Load the neighboring image
        neighbor_image = imread(fullfile(folder_path, neighbor_filename));
        neighbor_image_collapsed = mean(neighbor_image,3);

        % Accumulate for interpolation with weights based on distance
        weight = abs(interpolation_range(offset));
        interpolated_image = interpolated_image + weight *double(neighbor_image_collapsed);

    end

    % Normalize the interpolated image
    interpolated_image_normalized = interpolated_image / sum(abs(interpolation_range));

    final_interpolated_image = uint8(zeros(size(faulty_image)));

    for channel=1:3
        final_interpolated_image(:,:,channel) = interpolated_image_normalized;
    end



    % Construct the new filename for the interpolated image
    interpolated_filename = sprintf('%d.tif', faulty_indices(faulty_idx));

    % Save the interpolated image: % Warning: Overwrites!
    imwrite(uint8(interpolated_image_normalized), fullfile(folder_path, interpolated_filename), 'tif');

    fprintf('Interpolated image for #%d\n', faulty_indices(faulty_idx));
end

fprintf('Interpolation complete.\n');
end
