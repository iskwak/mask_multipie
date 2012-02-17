% subjects = get_session_subjects(path_to_multipie, session_number)
%
% Each session in multipie seems to have a different subject makeup.
% This function will just figure out what subjects are available in
% the desired session.
%
% inputs:
%  path_to_multipie = the path to multipie
%  session_number = the session to evaluate (double)
% outputs:
%  subjects = an array of the available subject ids (double)
% side effects:
%  will query directory paths
%

% --------
% Sam Kwak
% Copyright 2012
function subjects = get_session_subjects(path_to_multipie, session_number)

  path_to_subjects = fullfile( ...
    path_to_multipie, ...
    'data', ...
    ['session', sprintf('%02d', session_number)], ...
    'multiview');

  dir_entries = dir(path_to_subjects);

  subjects = cellfun(@(x) str2double(x), {dir_entries(3:end).name});

end % get_session_subjects(...)
