% active_contour = apply_active_contours(img_name, alpha_mask)
%
% Given an image and alpha mask, create the active contour for this image.
%
% inputs:
%  img_name = the image to process
%  alpha_mask = a alpha mask to use
% outputs:
%  active_contour = the active contour for the provided image
% side effects:
%  none
%

% --------
% Sam Kwak
% Copyright 2012
function active_contour = apply_active_contours(img, alpha_mask)
    alpha_threshold = .2;
    iterations = 150;
    
    alpha_thresh = alpha_mask > alpha_threshold;
    
    [labels, num_labels] = bwlabel(alpha_thresh,4);
    max_vals = -inf;
    max_label = 0;
    for i_labels = 1:num_labels
        num_vals = sum(labels(:) == i_labels);
        if num_vals > max_vals
            max_label = i_labels;
            max_vals = num_vals;
        end
    end % loop over the labels
    
    alpha_thresh = labels == max_label;
    
    alpha_thresh = bwfill(alpha_thresh, 'holes');
    
    % at this point create the active contours.
    %h = mean_speed();
    %h = mean_var_speed();
    %h = georgiou_speed();
    %h = bhattacharyya_speed();
    h = threshold_speed();
    
    %- initialize
    [phi C] = mask2phi(alpha_thresh);
    h.init(rgb2gray(img), phi, C); % initialize statistics
    
    %- curve evolution
    [phi_ ~] = ls_sparse(phi, C, h, iterations);
    
    active_contour = phi_;
    
    active_contour = imfill(active_contour, 'holes');
    
end % apply_active_contours(...)