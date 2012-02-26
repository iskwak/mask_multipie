% detections = load_multipie_facecom_detections(cache_dir, multipie_image_name)
%
% given a cache directory and a multipie image, attempt to load the
% detections for that image.
%
% inputs:
%  cache_dir = a cache directory that has the face.com detections
%  multipie_image_name = the name of the multipie image to process.
% outputs:
%  detections = struct with the face.com detection information
% side effects:
%  loads a text file
%

% --------
% Sam Kwak
% Copyright 2012
function detections = load_multipie_facecom_detection(cache_dir, multipie_image_name)
    
    % first take the multipie_image_name and parse out the needed
    % information.
    % Need the session number (and maybe the pose number later)
    [img_path, basename] = fileparts(multipie_image_name);
    parts = regexp(basename, '_', 'split');
    %session = ['session', parts{2}];
    pose = parts{4};
    subj = str2double(parts{1});
    
    %pose = GetMultiPieImgInfo(imgName, 'pose');
    %subj = str2double(GetMultiPieImgInfo(imgName, 'subject'));
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
    
    hd5file = fullfile(cache_dir, 'face_com', detectionSubDir, sprintf('%03d.hd5',subj));
    if ~exist(hd5file, 'file')
        %fiducials = [];
        backup_name = fullfile(img_path, ['002', basename(4:end)], '.png');
        detections = load_multipie_facecom_detection(cache_dir, backup_name);
        return;
    end
    
    
    allFiducials = load_fiducials_face_com( ...
        subj, ...
        fullfile(cache_dir, 'face_com', detectionSubDir));
    
    % after getting all the fiducials, figure out which set belongs
    % to the current image.
    % the names of the images in the fiducials file might be in a cell
    % array or a regular array. Figure this out first
    if ~iscell(allFiducials.image)
        error('allFiducials.image is not a cell array');
        % convert the fiducials.name to a string
    end % if are these actually fiducials
    
    % get the detection information for this image
    [~,basename] = fileparts(multipie_image_name);
    idx = strcmp(allFiducials.image, basename);
    
    if sum(idx) == 0
        %error('no detections found');
        backup_name = fullfile(img_path, ['002', basename(4:end), '.png']);
        detections = load_multipie_facecom_detection(cache_dir, backup_name);
        return;
    else
        
        fields = fieldnames(allFiducials);
        for i_fields = 1:length(fields)
            % skip if the fieldname is image, which is the image name
            if strcmp(fields(i_fields), 'image')
                continue;
            end
            detections.(fields{i_fields}) = ...
                allFiducials.(fields{i_fields})(idx);
        end % loop over fields
    end
    
end % load_multipie_facecom_detections(...)




%    % first take the multipie_image_name and parse out the needed
%    % information.
%    % Need the session number (and maybe the pose number later)
%    [~, basename] = fileparts(multipie_image_name);
%    parts = regexp(basename, '_', 'split');
%    session = ['session', parts{2}];
%
%    detections_dir = fullfile(cache_dir, 'detections');
%
%    % usually the best face detection will be from the face on the
%    % first face (nuetral illumination), but not always. First case
%    % try to use a face detection from a different lighting
%    %lightings = cell(1,20);
%    %for i_lighting = 1:20
%    %  lightings{i_lighting} = sprintf('%02d', i_lighting-1);
%    %end % loop over possible lightings
%
%    i_lighting = 0;
%    jsondata = [];
%
%    while length(jsondata) < 3 && i_lighting < 20
%      lighting_name = [basename(1:end-2), sprintf('%02d', i_lighting)];
%
%      fid = fopen(fullfile(detections_dir, session, [lighting_name, '.txt']), 'r');
%      jsondata = fgetl(fid);
%      fclose(fid);
%      i_lighting = i_lighting + 1;
%    end % loop over the lighthing conditions
%
%    % was there any detections that were found?
%    if length(jsondata) < 3
%      % if not, then leverage that the faces are generally in the same
%      % place. also log that this happened.
%      fid = fopen(fullfile(cache_dir, 'errors', [basename, '.txt']), 'w');
%      fclose(fid);
%
%      % next load up the face box from the first face
%      subject = parts{1};
%      new_base = strrep(basename, subject, '002');
%      fid = fopen(fullfile(detections_dir, session, [new_base, '.txt']), 'r');
%      jsondata = fgetl(fid);
%      fclose(fid);
%    end %
%
%    parsed = parse_json(jsondata);
%    detections = parsed{1}{1};
