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
    [~, basename] = fileparts(multipie_image_name);
    parts = regexp(basename, '_', 'split');
    session = ['session', parts{2}];
    
    detections_dir = fullfile(cache_dir, 'detections');

    % usually the best face detection will be from the face on the
    % first face (nuetral illumination), but not always. First case
    % try to use a face detection from a different lighting
    %lightings = cell(1,20);
    %for i_lighting = 1:20
    %  lightings{i_lighting} = sprintf('%02d', i_lighting-1);
    %end % loop over possible lightings

    i_lighting = 0;
    jsondata = [];
    
    while length(jsondata) < 3 && i_lighting < 20
      lighting_name = [basename(1:end-2), sprintf('%02d', i_lighting)];

      fid = fopen(fullfile(detections_dir, session, [lighting_name, '.txt']), 'r');
      jsondata = fgetl(fid);
      fclose(fid);
      i_lighting = i_lighting + 1;
    end % loop over the lighthing conditions

    % was there any detections that were found?
    if length(jsondata) < 3
      % if not, then leverage that the faces are generally in the same
      % place. also log that this happened.
      fid = fopen(fullfile(cache_dir, 'errors', [basename, '.txt']), 'w');
      fclose(fid);

      % next load up the face box from the first face
      subject = parts{1};
      new_base = strrep(basename, subject, '002');
      fid = fopen(fullfile(detections_dir, session, [new_base, '.txt']), 'r');
      jsondata = fgetl(fid);
      fclose(fid);
    end % 

    parsed = parse_json(jsondata);
    detections = parsed{1}{1};

end % load_multipie_facecom_detections(...)
