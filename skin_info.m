% mask = skin_info(multipie_dir, pose)
%
% Given a directory to multipie images, this function will figure out a
% mask of all the "moving" things in the image. It does this by figuring
% out which pixels have lots of variance
%
% inputs:
%   multipie_dir = path to a set of multipie images. should be the pose
%    directory of multipie subject/expression/session combination
%   pose = the pose of this multipie directory
% outputs:
%  mask = the mask of the pixels that have lots of change.
% side effects:
%  loads a lot of images.
%

% --------
% Sam Kwak
% Copyright 2012
function mask =  skin_info(multipie_dir, pose)
    
    
    files=dir(fullfile(multipie_dir, '*png'));
    
    im_stack1=zeros(480,640,length(files)-2);
    im_stack2=zeros(480,640,length(files)-2);
    im_stack3=zeros(480,640,length(files)-2);
    im_stack=zeros(480,640,length(files)-2);
    
    for k=2:(length(files)-1)
        file_name=files(k).name;
        im=double(imread(fullfile(multipie_dir, file_name)));
        im_stack1(:,:,k-1)=im(:,:,1);
        im_stack2(:,:,k-1)=im(:,:,2);
        im_stack3(:,:,k-1)=im(:,:,3);
        im_stack(:,:,k-1)=rgb2gray(im/max(im(:)));
    end
    
    th=3;
    
    switch(pose)
        case {'19_1','11_0','24_0','08_1'}
            th=3;
        otherwise
            th=3;%8
    end
    var_ims1=var(im_stack1,1,3)./(mean(im_stack1,3)+eps);
    var_ims2=var(im_stack2,1,3)./(mean(im_stack2,3)+eps);
    var_ims3=var(im_stack3,1,3)./(mean(im_stack3,3)+eps);
    var_ims=var(im_stack,1,3)./mean(im_stack,3);
    mask1=ones(size(var_ims1,1),size(var_ims1,2));
    mask2=ones(size(var_ims1,1),size(var_ims1,2));
    mask3=ones(size(var_ims1,1),size(var_ims1,2));
    mask1(var_ims1<th)=0;
    mask2(var_ims2<th)=0;
    mask3(var_ims3<th*4)=0;
    
    mask=mask1+mask2+mask3;
    mask(mask>=1)=1;

end % skin_info