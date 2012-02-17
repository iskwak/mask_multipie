% labels = classify_pixels(img, centers, threshold)
%
% a helper function to a kind of nearest neighbor classification for
% images. The threshold is so that pixels can be rejected as not near
% the given centers.
%
% inputs:
%  img = the image to label
%  centers = the centers to classify to
%  threshold = a threshold for saying something is too far. default
%   inf, so nothing is too far.
% outputs:
%  labels = a 2d array the same size as the image, where each index
%   has the label value.
% side effects:
%  none
%

% --------
% Sam Kwak
% Copyright 2012
function labels = classify_pixels(img, centers, threshold)

  if nargin < 3
    threshold = inf;
  end

  [rows, cols, ~] = size(img);

  lin_img = reshape(img, [rows*cols, 3]);

  num_centers = size(centers,1);

  dists = zeros([rows*cols, num_centers]);
  for i_centers = 1:num_centers
    curr_centers = repmat(centers(i_centers,:), [rows*cols, 1]);
    dists(:, i_centers) = sqrt(sum( ...
      (lin_img-curr_centers).*(lin_img-curr_centers), 2));
  end % loop over centers

  % next figure out which center the pixels are closer to
  [vals, ids] = min(dists, [], 2);

  % find which values are outside of the threshold
  idx = vals > threshold;
  ids(idx) = 0;

  labels = reshape(ids, [rows, cols]);

end % classify_pixels(...)
