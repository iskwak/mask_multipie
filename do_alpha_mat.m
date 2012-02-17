% [alpha, masked] = do_alpha_mat(img, scribbled)
%
% given an image and scribbles, this function will apply the alpha
% matting algorithm described in "A Closed Form Solution to Natural
% Image Matting". The output will be the masked image and the alpha
% mask.
%
% inputs:
%  img = the input image. This should be a double image (im2double)
%  scribbled = the input image with the scribbles added to it. White
%   strokes represents foreground and black strokes represent
%   background.
% outputs:
%  alpha = the alpha mask
%  masked = the masked image.
% side effects:
%  none
%

% --------
% Sam Kwak
% Copyright 2011
function [alpha, masked] = do_alpha_mat(img, scribbled)

  % default values for the alpha matting. Later these might be added
  % as options to this function
  if (~exist('thr_alpha','var'))
    thr_alpha=[];
  end
  if (~exist('epsilon','var'))
    epsilon=[];
  end
  if (~exist('win_size','var'))
    win_size=[];
  end

  if (~exist('levels_num','var'))
    levels_num=1;
  end  
  if (~exist('active_levels_num','var'))
    active_levels_num=1;
  end  

  I = img;
  mI = scribbled;
  consts_map=sum(abs(I-mI),3)>0.001;
  if (size(I,3)==3)
    consts_vals=rgb2gray(mI).*consts_map;
  end
  if (size(I,3)==1)
    consts_vals=mI.*consts_map;
  end

  % actually do the alpha matting
  alpha=solveAlphaC2F(I,consts_map,consts_vals,levels_num, ...
                      active_levels_num,thr_alpha,epsilon,win_size);

  [F,B]=solveFB(I,alpha); %#ok

  masked = F.*repmat(alpha,[1,1,3]);

end % do_alpha_mat(...)
