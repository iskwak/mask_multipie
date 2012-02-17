%% a script to try to create background color clusters

% first add the path to the ls_sparse code. assuming that it is within
% this directory
addpath('ls_sparse');
addpath('ls_sparse/speeds');
addpath('ls_sparse/util');

% add the path to the image matting code, also assumed to be in this
% directory
addpath('matting');


debug = false;

multipie_path = '/media/FreeAgent GoFlex Drive/datasets/multiPIE';
cache_dir = '/home/iskwak/Research/multiPIE_segmentation/cached_data';

%% choose some multipie settings
sessions = [1, 4];
poses = {'01_0'};

expression = 1;

subj_ids = get_session_subjects(multipie_path, sessions(1));
% pick some subjects to test on, but there are 3 subjects that I want
% to make sure is in my test group
%idx = find(subj_ids == 1 | subj_ids == 24 | subj_ids == 225);
%to_sample = 1:length(subj_ids);
%to_sample(idx) = [];
%to_use_idx = randperm(to_sample);
%to_use_idx = [


%% load a single subjects
% idea, using tali's masks, use this information to figure out which
% pixels represent the background of the image.
subj = subj_ids(6);
img_path = create_multipie_full_subj_path(multipie_path, subj, sessions(1), expression, poses{1});

changing_mask = logical(skin_info(img_path, poses{1}));

img = im2double(imread(get_multipie_image(multipie_path, subj, sessions(1), expression, poses{1}, 0)));


background_mask = ~logical(changing_mask);
%background_mask = false(size(changing_mask));
%background_mask(:, 1:185) = changing_mask(:,1:185) & true;
background_mask(:, 1:19) = false;
background_mask(477:end, :) = false;

imshow(background_mask);

linear_bg = background_mask(:);
linear_img = reshape(img, [480*640, 3]);

linear_img(~repmat(linear_bg, [1,3])) = 10;

bg_idx = find(linear_bg);

background = linear_img(bg_idx, :);

% cluster and get the background pixel colors
[IDX,C] = kmeans(background, 2);

% display the clusters
for i_clusters = 1:size(C,1)
  pixel = reshape(C(i_clusters,:), [1,1,3]);
  figure(i_clusters);
  imshow(repmat(pixel, [30,30,1]));
  title(['cluster ', num2str(i_clusters)]);
  disp(['cluster ', num2str(i_clusters), ' has ', num2str(sum(IDX==i_clusters))]);
end

for i_IDX = 1:length(IDX)
  linear_img(bg_idx(i_IDX),:) = 0;
  linear_img(bg_idx(i_IDX), IDX(i_IDX)) = 1;
end

figure(4)
imshow(reshape(linear_img, [480, 640, 3]));


% after getting the centers for the chair, try to remove it from the
% changing mask
changing_img = reshape(img, [480*640,3]);

% anything thats not in the changing mask, set to an impossibly high
% value. so it doesn't get clustered by the classify function
changing_img(changing_mask(:),:) = 2;
changing_img = reshape(changing_img, [480, 640, 3]);

labels = classify_pixels(changing_img, C, .05);
figure;
imagesc(labels)
%% dumb...
%%background = img;
%
%background_mask = ~logical(changing_mask);
%background_mask(:, 1:19) = false;
%background_mask(477:end, :) = false;
%
%linear_bg = background_mask(:);
%linear_img = reshape(img, [480*640, 3]);
%
%linear_img(~repmat(linear_bg, [1,3])) = 1;
%
%bg_idx = find(linear_bg);
%
%background = linear_img(bg_idx, :);
%
%% cluster and get the background pixel colors
%[IDX,C] = kmeans(background, 2);
%
%% display the clusters
%for i_clusters = 1:size(C,1)
%  pixel = reshape(C(i_clusters,:), [1,1,3]);
%  figure(i_clusters);
%  imshow(repmat(pixel, [30,30,1]));
%  title(['cluster ', num2str(i_clusters)]);
%  disp(['cluster ', num2str(i_clusters), ' has ', num2str(sum(IDX==i_clusters))]);
%end
%
%for i_IDX = 1:length(IDX)
%  linear_img(bg_idx(i_IDX),:) = 0;
%  linear_img(bg_idx(i_IDX), IDX(i_IDX)) = 1;
%end
%
%figure(4)
%imshow(reshape(linear_img, [480, 640, 3]));
%
%%background(repmat(background_mask, [1,1,3])) = [];
%%background = reshape(background, [length(background)/3, 3]);
%%
%
%%r = background(:,:,1);
%%r(~changing_mask) = [];
%%
%%g = background(:,:,2);
%%g(~changing_mask) = [];
%%
%%b = background(:,:,3);
%%b(~changing_mask) = [];
%%
%%background = [r', g', b'];
%%
%%background2 = img;
%%background2(repmat(~logical(changing_mask), [1,1,3])) = [];
