%% Assignment 4 Q2b
% for each image, run detectors for each
% bicycle, car, cyclist, pedestrian, person  (30 total: 15L , 15R)

%Update this for each detector
%detector-car
%detector-bicycle %needed to add this case to getData
%detector-cyclist
%detector-pedestrian
%detector-person

%probably faster to just run this sequentially changing things than
%throwing it all into loops

%004945
%no results for 
%left [cyclist, pedestrian]
%right [cyclist, pedestrian]

%004964
%no results for 
%left [cyclist, pedestrian]
%right [cyclist, pedestrian]

%005002
%no results for
%left [cyclist, pedestrian]
%right [cyclist, pedestrian]

% need to adjust thresholds for above, model.thresh too low it seems?

data = getData([], [], 'detector-person');
model = data.model;
col = 'r';

%Update this for each test image, need to do left and right?
%ids to check are ["004945";"004964";"005002"]
imdata = getData('005002', 'test', 'right');
im = imdata.im;
f = 1.5;
imr = imresize(im,f); % if we resize, it works better for small objects

% detect objects
fprintf('running the detector, may take a few seconds...\n');
tic;

[ds, bs] = imgdetect(imr, model, model.thresh); % you may need to reduce the threshold if you want more detections
e = toc;
fprintf('finished! (took: %0.4f seconds)\n', e);
nms_thresh = 0.5;
top = nms(ds, nms_thresh);
if model.type == model_types.Grammar
  bs = [ds(:,1:4) bs];
end
if ~isempty(ds)
    % resize back
    ds(:, 1:end-2) = ds(:, 1:end-2)/f;
    bs(:, 1:end-2) = bs(:, 1:end-2)/f;
end;
showboxesMy(im, reduceboxes(model, bs(top,:)), col);
fprintf('detections:\n');
ds = ds(top, :);

%save(filename,variables)
%save(DATA_DIR/results/id_type_{left|right},ds);
%e.g. 
%save(fullfile(DATA_DIR, 'test', 'results', '005002_person_left.mat'), 'ds');
%save(fullfile(DATA_DIR, 'test', 'results', '005002_person_right.mat'), 'ds');



