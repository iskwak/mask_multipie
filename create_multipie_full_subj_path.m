% path_to_imgs = create_multipie_full_subj_path(path_to_multipie, subj, session, expression, pose)
%
% given a path to a multipie database, a subject id, session,
% expression, and pose, this function will create the path to that
% subjects multipie images in the given session and pose. Just a
% helper function that deals with fullfiles and some of the other
% folders that multipie databases seem to have like 'multiview'.
%
% inputs:
%  path_to_multipie = path to the root of the multipie database
%  subj = the subject id to get images for (double)
%  session = the session id                (double)
%  expression = the expression             (double)
%  pose = the pose                         (string)
% outputs:
%  path_to_imgs = the path to the multipie images
% side effects:
%  none
%

% --------
% Sam Kwak
% Copyright 2012
function path_to_imgs = create_multipie_full_subj_path(path_to_multipie, subj, session, expression, pose)

  path_to_imgs = fullfile( ...
    path_to_multipie, ...
    'data', ...
    ['session' sprintf('%0.2d', session)], ...
    'multiview', ...
    sprintf('%0.3d', subj), ...
    sprintf('%0.2d', expression), ...
    pose);

end % create_multipie_full_subj_path(...)
