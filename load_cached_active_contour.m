% active_contour = load_cached_active_contour(cache_dir, img_name, alpha_mask)
%
% given the cache dir, an image name and an alpha mask, create or load the
% active contour for this image.
%
% inputs:
%  cache_dir = the cache directory
%  img_name = the image to process
%  alpha_mask = a alpha mask to use
% outputs:
%  active_contour = the active contour for the provided image
% side effects:
%  loads cached data. Also loads a multipie image.
%

% --------
% Sam Kwak
% Copyright 2012
function active_contour = load_cached_active_contour(cache_dir, img_name, alpha_mask)
    
    full_mat_name = fullfile(alpha_dir, mat_name);
          alpha_mask_thresholded = img.*repmat(alpha_thresh, [1,1,3]);
      
      % at this point create the active contours.
      h = threshold_speed();
      
      %- initialize
      [phi C] = mask2phi(alpha_thresh);
      h.init(rgb2gray(img), phi, C); % initialize statistics
      
      %- curve evolution
      [phi_ C_] = ls_sparse(phi, C, h, iterations);

      contour_img = img.*repmat(phi_, [1, 1, 3]);
    
    
         [phi_ C_] = ls_sparse(phi, C, h, iterations);
    
end % load_cached_active_contour(...)