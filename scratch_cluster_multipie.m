% scratch code to help test an idea for segmenting multipie

% first add the path to the ls_sparse code. assuming that it is within
% this directory
addpath('ls_sparse');
addpath('ls_sparse/speeds');
addpath('ls_sparse/util');

% add the path to the image matting code, also assumed to be in this
% directory
addpath('matting');

% given a face box for a multipie image, is it possible to detect the
% skin and hair color? Using prior knowledge of the chair and background
% colors?

% in some sense, only needs to be good enough to allow the active
% contours to fix everything? Tho! I do remember seeing the active
% contours only doing minor fixes. There maybe some settings to modify
% to get the active contours to work better.

% first part of the idea, get a couple of multipie images that I think
% are interesting.
debug = false;

multipie_path = '/media/FreeAgent GoFlex Drive/datasets/multiPIE';
cache_dir = '/home/iskwak/Research/multiPIE_segmentation/cached_data';

%% setup the multipie information
subjects = [1, 24, 225];

session = 1;
expression = 1;
pose = '01_0';
lighting = 0;

%% next get the images and run some tests
img_path = get_multipie_image(multipie_path, subjects(1), session, expression, pose, lighting);
img = im2double(imread(img_path));

% get the face dectecion box
detection = load_multipie_facecom_detection(cache_dir, img_path);

% get the face box setup
[rows,cols, ~] = size(img);
width = detection.width*cols/100;
height = detection.height*rows/100;
minx = floor(detection.center.x*cols/100 - width/2);
miny = floor(detection.center.y*rows/100 - height/2);

if debug
  imshow(img) %#ok
  hold on
  rectangle('position', [minx, miny, width, height], 'linewidth', 2);
end

% try to find the skin pixels.
crop = imcrop(img, [minx, miny, width, height]);
[crop_rows, crop_cols, ~] = size(crop);
pixel_vals = reshape( ...
  crop, ...
  [crop_rows*crop_cols, 3, 1]);

[idx, c] = kmeans(pixel_vals, 3);

% find the largest center
cluster_ids = unique(idx);
max_id = 0;
num_pixels = 0;
for i_cluster = 1:length(cluster_ids)
  cluster_pixels = sum(idx == i_cluster);
  if num_pixels < cluster_pixels
    num_pixels = cluster_pixels;
    max_id = i_cluster;
  end % num_pixels > previous max
end % loop over cluster ids

% assume that the largest cluster is the cluster of skin (this is
% hopefully a good facebox)
pixel_vals(idx==max_id,1) = 1;

imshow(reshape(pixel_vals, [crop_rows, crop_cols, 3]));
