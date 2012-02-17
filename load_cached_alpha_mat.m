% alpha_mask = load_cached_alpha_mat(cache_dir, img_name, foreground_mask, changing_mask)
%
% loads the alpha mat for the given image.
%
% inputs:
%  cache_dir = the cache directory
%  img_name = the image to process
%  foreground_mask = a foreground mask to use
%  changing_mask = the mask that provides information of what is changing.
%   this will be negated and OR'ed with the background scribbles to
%   help make a better background mask.
% outputs:
%  alpha_mask = the alpha mask for the provided image
% side effects:
%  loads cached data. Also loads a multipie image.
%

% --------
% Sam Kwak
% Copyright 2012
function alpha_mask = load_cached_alpha_mat(cache_dir, img_name, foreground_mask, changing_mask)
    
    [multipie_dir, basename] = fileparts(img_name);
    % convert the basename to have 00.mat as the trailing chars
    mat_name = [basename(1:end-2), '00.mat'];
    
    alpha_dir = fullfile(cache_dir, 'alpha_masks');
    full_mat_name = fullfile(alpha_dir, mat_name);
    
    if ~exist(full_mat_name, 'file')
        % the alpha mask doesn't exist, create it and cache it.
        img_name = [basename(1:end-2), '00.png'];
        img = im2double(imread(fullfile(multipie_dir, img_name)));
        
        % apply the scribbles to the original image.
        scribbled = apply_scribbles(img, foreground_mask, foreground_mask);
        
        scribbles = zeros(size(img));
        alphamask = create_background_mask(img, img_name, cache_dir, changing_mask);
        
        scribbled = apply_scribbles(scribbled, scribbles, alphamask);
        
        alpha_mask = do_alpha_mat(img, scribbled);
        
        
        
        save(full_mat_name, 'alpha_mask', 'scribbled', 'foreground_mask', 'changing_mask');
    else
        alpha_mask = load(full_mat_name);
        alpha_mask = alpha_mask.alpha_mask;
    end
    
    
end % load_cached_alpha_mat(...)


function background_mask = create_background_mask(img, img_name, cache_dir, changing_mask)
    
    [~, basename] = fileparts(img_name);
    parts = regexp(basename, '_', 'split');
    pose = parts{4};
    
    background_mask = ~logical(changing_mask);
    [rows, cols] = size(changing_mask);
    
    % cluster the background pixels to figure out the cloth color.
    %imshow(background_mask);
    
    linear_bg = background_mask(:);
    linear_img = reshape(img, [rows*cols, 3]);
    
    linear_img(~repmat(linear_bg, [1,3])) = 10;
    
    bg_idx = find(linear_bg);
    
    background = linear_img(bg_idx, :);
    
    % cluster and get the background pixel colors
    try
        [IDX,C] = kmeans(background, 2);
    catch %#ok<CTCH>
        % some times kmeans just doesn't work? but when i rerun it later it
        % works... so a hack to just try again
        [IDX,C] = kmeans(background, 2);
    end
    
    [~,max_id] = max([sum(IDX==1), sum(IDX==2)]);
    
    %max_cluster_idx = IDX == max_id;%find(IDX == max_id);    
    
%     background_mask = zeros(rows*cols,1);
%     %for i_IDX = 1:length(max_cluster_idx)
%     %    background_mask(bg_idx(max_cluster_idx(i_IDX)), IDX(max_cluster_idx(i_IDX))) = 1;
%     %end
%     background_mask(bg_idx(max_cluster_idx)) = 1;%, IDX(max_cluster_idx)) = 1;
%     background_mask = reshape(background_mask, [rows,cols]);

    changing_img = reshape(img, [rows*cols,3]);

    changing_img(logical(changing_mask(:)),:) = 2;
    changing_img = reshape(changing_img, [rows, cols, 3]);

    background_mask = classify_pixels(changing_img, C(max_id, :), .05);

    background_mask = imfill(background_mask, 'holes');
    strelem = strel('disk', 5);
    background_mask = imerode(background_mask, strelem);
    background_mask = imfill(background_mask, 'holes');
    
    switch pose
        case '010'
            [~, ~, alphamask] = imread(fullfile(cache_dir, 'scribbles', 'alpha_background_010.png'));

            % apply the changing mask
            %strelem = strel('disk', 7);
            %back_mask = imerode(~changing_mask, strelem);
            background_mask = background_mask | logical(im2double(alphamask));
        case '041'
            [~, ~, alphamask] = imread(fullfile(cache_dir, 'scribbles', 'alpha_background_041.png'));
            background_mask = background_mask | logical(im2double(alphamask));
    end
    
end
