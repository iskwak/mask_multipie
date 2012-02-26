% [segments, segmented] = segment_multipie(multipie_image, cache_dir)
%
% Given a multipie image, and assuming that other multipie images are in
% that directory, this function will return the multipie image masked.
%
% inputs:
%  multipie_image = the image to be segmented/masked
%  cache_dir = the directory to the cached data
% outputs:
%  segments = the foreground/background mask
%  segmented = the image segmented.
% side effects:
%  loads cached data. Also loads a multipie image.
%

% --------
% Sam Kwak
% Copyright 2012
function [segments, segmented] = segment_multipie(multipie_image, cache_dir)
    
    % the order of options:
    % get the mask of what is changing
    % get the face.com detection
    % create the foreground_mask
    % load/create the alpha_mask based on the foreground mask
    % apply active contours on the desired image with the alpha mask
    % return the head mask
    changed_mask = load_cached_skin_info(multipie_image, cache_dir);
    %detection = load_multipie_facecom_detection(cache_dir, multipie_image);
    detection = GetMultiPieFiducials(multipie_image);
    foreground_mask = create_foreground_mask(changed_mask, detection, multipie_image);
    alpha_mask = load_cached_alpha_mat(cache_dir, multipie_image, foreground_mask, changed_mask);

    % time to do the active contour creation
    img = im2double(imread(multipie_image));
    active_contour = apply_active_contours(img, alpha_mask);
    
    segments = active_contour;
    segmented = img.*repmat(active_contour, [1, 1, 3]);
    
end % segment_multipie(...)
