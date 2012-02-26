% mask = load_cached_skin_info(multipie_image, cached_dir)
%
% Given a multipie image, this function will attempt to load a cached skin
% mask from disk. If it doesn't exist it will create it.
%
% inputs:
%  multipie_image = the image to get the changing pixel mask
%  cached_dir = the directory of cached data.
% outputs:
%  mask = the changing pixels
% side effects:
%  loads images or loads a matlab mat file.
%

% --------
% Sam Kwak
% Copyright 2012
function mask = load_cached_skin_info(multipie_image, cached_dir)
    
    % the mask will be based on the first image in the set, so strip the
    % last characters of the image name and replace with '00.mat'
    [multipie_dir, basename] = fileparts(multipie_image);
    base_mat_name = [basename(1:end-2), '00.mat'];
    
    mean_mask_dir = fullfile(cached_dir, 'mean_mask');
    
    full_mat_name = fullfile(mean_mask_dir, base_mat_name);
    
    if ~exist(full_mat_name, 'file')
        parts = regexp(basename, '_', 'split');
        pose = parts{4};
        mask =  skin_info(multipie_dir, pose);
        
        if ~exist(mean_mask_dir, 'dir')
            [path_to_dir, mask_dir] = fileparts(mean_mask_dir);
            mkdir(path_to_dir,  mask_dir);
        end
        
        save(full_mat_name, 'mask');
    else
        mask = load(full_mat_name);
        mask = mask.mask;
    end
    
end % load_cached_skin_info(...)