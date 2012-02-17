% scribbled = apply_scribbles(img, scribbles, alpha)
%
% A helper function to take scribbles and apply them to an img. The
% Levin matting wants the original image + an image with scribbles
% on top of them. This function will help do that. This function
% is expecting the output of an imread call on a png with an alpha
% channel. For example
%  img = imread('imagetomask.jpg');
%  [scribbles, ~, alpha] = imread('somepng.png');
%  scribbled = apply_scribbles(img, scribbles, alpha);
%
% inputs:
%  img = the image to apply the scribbles to
%  scribbles = the scribbles to apply
%  alpha = the alpha channel provided by imread
% outputs:
%  scribbled = the original image with the scribbles applied to it
% side effects:
%  none
%

% --------
% Sam Kwak
% Copyright 2011
function scribbled = apply_scribbles(img, scribbles, alpha)

  idx = find(alpha);
  scribbled = img;
  [rows,cols,chans] = size(img);

  for i_chans = 1:chans
    % use linear indicies to do the application of the scribbles.
    scribbled(idx+ (rows*cols*(i_chans-1) )) = scribbles(idx);
    %scribbled(idx+rows*cols) = scribbles(idx);
    %scribbled(idx+2*rows*cols) = scribbles(idx);
  end % loop over the channels in the image

end % apply_scribbles(...)
