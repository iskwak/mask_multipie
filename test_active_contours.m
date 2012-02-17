%% helper script to run the multipie active contours segmentation
% it mostly has directory/file parsing kind of things going on.

% first add the path to the ls_sparse code. assuming that it is within
% this directory
addpath('ls_sparse');
addpath('ls_sparse/speeds');
addpath('ls_sparse/util');

% add the path to the image matting code, also assumed to be in this
% directory
addpath('matting');

% setup code to traverse the multipie database structure
base_to_multipie = '/media/FreeAgent GoFlex Drive/datasets/multiPIE/data/';

%% setup the desired multipie settings
% expressions to process
%expression = {'01'};
expression = '01';

% we want to test over multiple sessions (days).
sessions = {'session01', 'session04'};
%sessions = {'session04'};

pose_dir = '01_0';

% subjects to process
%path_to_multipie = fullfile(base_to_multipie, sessions{1}, 'multiview');
%subjects = dir(path_to_multipie);
% subjects = {subjects(3:end).name};
% subjects = subjects(2:4);
% in this test, only want 10 subjects-ish. Randomly sample them.
%idx = randi(length(subjects), 10, 1);
%subjects = subjects(idx);
%subjects = {'031', '048', '057', '094', '096', '107', '121', '146', '147','161'};
%subjects = {'031', '048', '057', '096', '107', '147'};
%subjects = {'003', '200', '070', '123'};
%subjects = {'002', '003', '004', '005', '147', '209', '225', '236', '181', '129'};
%subjects = {'024'};

[scribbles, ~, alphamask] = imread('alpha_scribbles_010.png');
scribbles = im2double(scribbles);

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

  for i_subj=1:length(subjects)
    %% for the current subject setup the path and output dir stuff
    current_path = fullfile( ...
      path_to_multipie, subjects{i_subj}, expression, pose_dir);

    folders = dir(current_path);
    folders = {folders(3:end).name};
    imgs = cellfun(@(x) fullfile(current_path, x), folders, 'uniformoutput', false);

    out_dir = fullfile(base_out_dir, sessions{i_session}, subjects{i_subj});
    if ~exist(out_dir, 'dir')
      mkdir(out_dir);
    end
    %out_folders = cellfun(@(x) fullfile(out_dir, x), folders, 'uniformoutput', false);

    %% create the alpha mask for only the first image 
    [~, basename] = fileparts(imgs{1});
    img = im2double(imread(imgs{1}));
    scribbled = apply_scribbles(img, scribbles, alphamask);

    tic
    [alpha, masked] = do_alpha_mat(img, scribbled);
    alpha_tics(end+1) = toc;

    alpha_thresh = alpha > .2;
    

    %% now process each image for the subject
    for i_imgs = 1:length(imgs)
    %for i_imgs = 1:4%length(imgs)
      disp(['subj: ', subjects{i_subj}, ', processing image: ', num2str(i_imgs), ' of ', num2str(length(imgs))]);
      [~, basename] = fileparts(imgs{i_imgs});
      %img = imread(imgs{i_imgs});
      %double_img = im2double(img);
      img = im2double(imread(imgs{i_imgs}));
      
      % create the alpha masked image
      %alpha_mask_thresholded = double_img.*repmat(alpha_thresh, [1,1,3]);
      alpha_mask_thresholded = img.*repmat(alpha_thresh, [1,1,3]);
      
      % at this point create the active contours.
      h = threshold_speed();
      
      %- initialize
      [phi C] = mask2phi(alpha_thresh);
      h.init(rgb2gray(img), phi, C); % initialize statistics
      
      %- curve evolution
      [phi_ C_] = ls_sparse(phi, C, h, iterations);

      contour_img = img.*repmat(phi_, [1, 1, 3]);
      
      % save out the data
      imwrite(alpha_mask_thresholded, fullfile(out_dir, [basename, '_alpha_thresholded.png']), 'png');
      imwrite(phi_, fullfile(out_dir, [basename, '_contour.png']), 'png');
      imwrite(contour_img, fullfile(out_dir, [basename, '_contour_masked.png']), 'png');
      %imwrite(alpha, fullfile(out_dir, [basename, '_alpha.png']), 'png');
      %imwrite(scribbled, fullfile(out_dir, [basename, '_scribbles.png']), 'png');
      %save(fullfile(out_dir, [basename, '_alpha.mat']), 'alpha');
    end

  end % loop over subjects

end % loop over sessions
