%% helper script to test a masking idea

% first add the path to the ls_sparse code. assuming that it is within
% this directory
addpath('ls_sparse');
addpath('ls_sparse/speeds');
addpath('ls_sparse/util');

% add the path to the image matting code, also assumed to be in this
% directory
addpath('matting');

% setup code to traverse the multipie database structure
base_to_multipie = '/databases/multiPIE/data/';

%% setup the desired multipie settings
% expressions to process
%expression = {'01'};
expression = '01';

% we want to test over multiple sessions (days).
sessions = {'session01'};
%sessions = {'session04'};
%sessions = {'session01', 'session04'};

pose_dirs = '01_0';
%pose_dirs = '04_1';

% subjects to process
path_to_multipie = fullfile(base_to_multipie, sessions{1}, 'multiview');
%subjects = dir(path_to_multipie);
%subjects = {subjects(3:end).name};
%subjects = subjects(24:25);
% in this test, only want 10 subjects-ish. Randomly sample them.
%idx = randi(length(subjects), 10, 1);
%subjects = subjects(idx);
%subjects = {'031', '048', '057', '094', '096', '107', '121', '146', '147','161'};
%subjects = {'031', '048', '057', '096', '107', '147'};
%subjects = {'003', '200', '070', '123'};

%% setup cache dir
base_cache_dir = '~/Research/multiPIE_segmentation/cached_data';

cached_mask_dir = fullfile(base_cache_dir, 'masks');

if ~exist(cached_mask_dir, 'dir')
    mkdir(cached_mask_dir);
end

detections_dir = fullfile(base_cache_dir, 'detections');

%out_dir = '~/Research/multiPIE_segmentation/cached_data/segments';
%if ~exist(out_dir, 'dir')
%    mkdir(out_dir);
%end


%% setup the output dir
base_out_dir = 'sample_contours';

if ~exist(base_out_dir, 'dir')
    mkdir(base_out_dir);
end % make sure the base_out_dir exists


%% parameters for the active contours
iterations = 150;



%% process the files
alpha_tics = [];
for i_session=1:length(sessions)
    
    path_to_multipie = fullfile(base_to_multipie, sessions{i_session}, 'multiview');
    subjects = dir(path_to_multipie);
    subjects = {subjects(3:end).name};
    %subjects = subjects(132:end);
    %subjects = subjects(1:10);
    %subjects = {subjects{1:10}, '024', '225'};
    %subjects = {subjects{2:10}, '024', '225'};
    %subjects = {'031', '096', '107'};
    %subjects = {'107'};
    %subjects = {'002', '024', '225'};
    %subjects = {'225'};
    %subjects = {'024'};

    for i_subj=1:length(subjects)
        current_path = fullfile( ...
            path_to_multipie, subjects{i_subj}, expression, pose_dirs);
        
        folders = dir(current_path);
        folders = {folders(3:end).name};
        imgs = cellfun(@(x) fullfile(current_path, x), folders, 'uniformoutput', false);
        
        for i_img = 1:2%length(imgs)
            disp(['subj: ', subjects{i_subj}, ', processing image: ', num2str(i_img), ' of ', num2str(length(imgs))]);
            [~, basename] = fileparts(imgs{i_img});
            save_create_segments(imgs{i_img}, base_cache_dir, base_cache_dir);
        end
        
    end % loop over subjects
    
end % loop over sessions
