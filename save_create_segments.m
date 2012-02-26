% save_create_segments(multipie_image, cache_dir, output_dir)
%
% given the name of an multipie image, it will try to segment it and save.
%
% inputs:
%  multipie_image = the image to be segmented/masked
%  cache_dir = where data is cached (this should be changed to an optional
%   arg at some point.
%  output_dir = where results should be saved to.
% outputs:
%
% side effects:
%  loads and creates cached data and saves a segmented image to disk.
%

% --------
% Sam Kwak
% Copyright 2012
function save_create_segments(multipie_image, cache_dir, output_dir)

    [segments, segmented] = segment_multipie(multipie_image, cache_dir);
 
    [~, basename] = fileparts(multipie_image);
    
    parts = regexp(basename, '_', 'split');
    pose = parts{4};
    pose = [pose(1:2), '_', pose(3)];
    
    base_output_name1 = fullfile(output_dir, 'masks', ['session', parts{2}], parts{1}, parts{3}, pose, basename);
    base_output_name2 = fullfile(output_dir, 'segments', ['session', parts{2}], parts{1}, parts{3}, pose, basename);
    
    base_output_dir = fileparts(base_output_name1);
    if ~exist(base_output_dir, 'dir')
        [parent_dir, sub_dir] = fileparts(base_output_dir);
        mkdir(parent_dir, sub_dir);
    end
    base_output_dir = fileparts(base_output_name2);
    if ~exist(base_output_dir, 'dir')
        [parent_dir, sub_dir] = fileparts(base_output_dir);
        mkdir(parent_dir, sub_dir);
    end
    
    
    %imwrite(segments, [base_output_name, '_contour.png']);
    imwrite(segments, [base_output_name1, '_mask.png']);
    imwrite(segmented, [base_output_name2, '_contour_masked.png']);
    
end % save_create_segments(...)