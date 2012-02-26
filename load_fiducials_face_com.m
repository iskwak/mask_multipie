function fiducials = load_fiducials_face_com(id,basedir)
  if nargin==1
    %basedir = '/experiments/face_com/multiPIE_5frontal_new/';
    basedir = '/data/iskwak/experiments/face_com/multiPIE_5frontal_new/';
  end
  hd5file = fullfile(basedir, sprintf('%03d.hd5',id)); 
  fileID = H5F.open(hd5file,'H5F_ACC_RDONLY', 'H5P_DEFAULT');
  datasetID = H5D.open(fileID,'/fiducials');
  fiducials = H5D.read(datasetID,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT');
  H5D.close(datasetID)
  H5F.close(fileID);
  
  fiducials.image=cellstr(fiducials.image');
end
