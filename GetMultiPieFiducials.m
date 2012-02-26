% fiducials = GetMultiPieFiducials(imgName)
%
% given an image name, get the face.com fiducials for that image
% (if it exists)
%
% inputs:
%  multipie_image = the image to get the fiducials for
% outputs:
%  fiducials = the fiducials for the image
% side effects:
%  loads a mat file
%

% --------
% Sam Kwak
% Copyright 2012
function fiducials = GetMultiPieFiducials(imgName)
    ImportGlobals

    pose = GetMultiPieImgInfo(imgName, 'pose');
    subj = str2double(GetMultiPieImgInfo(imgName, 'subject'));
    %session = GetMultiPieImgInfo(imgName, 'session');
    %expression = GetMultiPieImgInfo(imgName, 'expression');

    % the multipie fiducials can be stored in one of two places. The
    % location they are stored in depends on if the image is frontal
    % or not.
    if strcmp(pose, '041') || ...
            strcmp(pose, '050') || ...
            strcmp(pose, '051') || ...
            strcmp(pose, '130') || ...
            strcmp(pose, '140')
        detectionSubDir = 'multiPIE_5frontal_new';
    else
        detectionSubDir = 'multiPIE_nonfrontal';
    end % if pose type is frontal

    hd5file = fullfile(faceComDetectionDir, detectionSubDir, sprintf('%03d.hd5',subj));
    if ~exist(hd5file, 'file')
        fiducials = [];
        return;
    end
    
    allFiducials = load_fiducials_face_com( ...
        subj, ...
        fullfile(faceComDetectionDir, detectionSubDir));

    % after getting all the fiducials, figure out which set belongs
    % to the current image.
    % the names of the images in the fiducials file might be in a cell
    % array or a regular array. Figure this out first
    if ~iscell(allFiducials.image)
        error('allFiducials.image is not a cell array');
        % convert the fiducials.name to a string
    end % if are these actually fiducials

    % get the detection information for this image
    [~,basename] = fileparts(imgName);
    idx = strcmp(allFiducials.image, basename);
    if sum(idx) == 0
        %error('no detections found');
        fiducials = [];
        return;
    end

    fields = fieldnames(allFiducials);
    for i_fields = 1:length(fields)
        % skip if the fieldname is image, which is the image name
        if strcmp(fields(i_fields), 'image')
            continue;
        end
        fiducials.(fields{i_fields}) = ...
            allFiducials.(fields{i_fields})(idx);
    end % loop over fields

end % GetMultiPieFiducials


% a function to get the multipie image information. like pose, session
% and so on.
function info = GetMultiPieImgInfo(imgName, partInfo)
[~,basename] = fileparts(imgName);
parts = regexp(basename, '_', 'split');

switch partInfo
    case 'subject'
        info = parts{1};
    case 'pose'
        info = parts{4};
    case 'session'
        info = parts{2};
    case 'expression'
        info = parts{3};
    case 'lighting'
        info = parts{5};

    case 'all'
        info = parts;
end % switch over desired info

end % GetMultiPieImgInfo(...)
