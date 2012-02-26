numDictionaryTrainPatches = 10000;
patchWidth = 32;
numBasisVectors = 256;
betaPenalty = 0.1;
maxPatchesPerTrainImageLMNN = 1000;
maxPatchesPerTrainImageRefine = 50000;
maxPatchesFromQuery = 10000;

% mpieProcessedDataRoot = '/home/eric/machome/big/MPIEProcessedData/';
mpieProcessedDataRoot = '/Users/eric/big/MPIEProcessedData/';
dictionaryTrainPatchesDirectory = '../data/dictionary_patches';

sparsity_func = 'L1';
epsilon = [];

% params for flann
% flann_params = struct('algorithm','autotuned');
% below are default param values for flann (taken from flann_build_index)
flann_params = struct('algorithm', 'kdtree' ,'checks', 32,  'cb_index', 0.4, 'trees', 4, 'branching', 32, 'iterations', 5, 'centers_init', 'random', 'target_precision', 0.9,'build_weight', 0.01, 'memory_weight', 0, 'sample_fraction', 0.1, 'log_level', 'warning', 'random_seed', 0);


% params for spams
spams_param.K=numBasisVectors;
spams_param.lambda=betaPenalty;
spams_param.numThreads=8; % number of threads
spams_param.batchsize=400;
spams_param.iter=1000;
spams_param.approx=0;

% Between 0 and 1, smaller means finer segmentation.
segmentationCoarseness = .01;
segmentationResizeFactor = 1;

%dictionaryMat = sprintf('../data/dictionary_%s_b%d_p%d_beta%g.mat', sparsity_func, numBasisVectors, patchWidth, betaPenalty);
dictionaryMat = sprintf('../data/dictionary_spams_%s_b%d_p%d_beta%g.mat', sparsity_func, numBasisVectors, patchWidth, betaPenalty);
lmnnMat = '../data/spams_LMNN.mat';
flann_index_file = '../data/flann_index.idx';


% LBPRecognition parameters
lbpCache = '/data/cached_data/lbp';
lbpOverwriteCache = false;


% face.com detection location
faceComDetectionDir = '/data/experiments/face_com/';
