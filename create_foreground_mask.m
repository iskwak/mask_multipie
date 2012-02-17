% mask = create_foreground_mask(changed_mask, detection, multipie_image)
%
% Given a mask that shows what has changed within the multpie images and
% the face.com detections, return a foreground mask, that can be used with
% Levin's image matting
%
% inputs:
%  changed_mask
%  detection = face.com detection struct
%  multipie_image = the multipie image name.
% outputs:
%  foreground_mask = the foreground mask
% side effects:
%  none
%

% --------
% Sam Kwak
% Copyright 2012
function mask = create_foreground_mask(changed_mask, detection, multipie_image)
    
    % first, clean up the mask of the things that changed within all the
    % images in the pose
    
    % get the largest connected component.
    [labels, num_labels] = bwlabel(changed_mask,4);
    max_vals = -inf;
    max_label = 0;
    for i_labels = 1:num_labels
        num_vals = sum(labels(:) == i_labels);
        if num_vals > max_vals
            max_label = i_labels;
            max_vals = num_vals;
        end
    end % loop over the labels
    
    mask = labels == max_label;

    % modify the detection face box based on the pose of the multipie
    % image.
    [rows,cols, ~] = size(mask);
    [~, basename] = fileparts(multipie_image);
    parts = regexp(basename, '_', 'split');
    pose = parts{4};
    detection = modify_detection(detection, pose, rows);
    
    % next, use the face box within the detection to get some information
    width = detection.width*cols/100;
    height = detection.height*rows/100;
    minx = floor(detection.center.x*cols/100 - width/2);
    miny = max(floor(detection.center.y*rows/100 - height/2), 1);
    mask2 = zeros(size(mask));
    for i_width = 1:width
        for i_height = 1:height
            mask2(i_height+miny, i_width+minx) = mask(i_height+miny, i_width+minx);
        end
    end
    
    % erode and dilate the image a bit
    strelem = strel('disk', 7);
    %mask2 = imdilate(mask2, strelem);
    %strelem = strel('disk', 11);
    mask2 = imerode(mask2, strelem);
    %figure;imshow(mask2);
    %strelem = strel('disk', 3);
    %mask2 = imdilate(mask2, strelem);
    %figure;imshow(mask2);
    
    
    mask = mask2;
end % create_foreground_mask(...)

%% helper function
function detection = modify_detection(detection, pose, rows)

  switch pose
    case '010'
      maxy = detection.center.y + detection.height/2;
      detection.height = maxy;
      detection.center.y = maxy/2;
    case '041'
      maxy = detection.center.y + detection.height/2;
      detection.height = maxy;
      detection.center.y = maxy/2;
  end

end % modify_detection(...)
