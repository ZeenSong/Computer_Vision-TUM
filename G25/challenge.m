%% Computer Vision Challenge 2019

% Group number:
group_number = 25;

% Group members:
members = {'Zeen Song','Shengzhi Wang','Lei Wang','Yikai Xu','Xiajun Zhou'};

% Email-Address (from Moodle!):
% mail = {'ga99abc@tum.de', 'daten.hannes@tum.de'};
mail = {'ge25ram@tum.de','ge73coz@tum.de','ge25xem@tum.de','ge25wun@tum.de','ge73zes@cdtum.de'};

%% Start timer here
tic

%% Disparity Map
% Specify path to scene folder containing img0 img1 and calib
addpath('lib');
scene_path = uigetdir('','Select directory of a files');

% Calculate disparity map and Euclidean motion
[D,distancemap,R,T] = disparitymap_census(scene_path); % Census Method(Recommended)

%[D,distancemap,R,T]  = disparitymap_SAD(scene_path); % SAD Method
%[D,distancemap,R,T] = disparitymap_GM(scene_path); % GM Method
%% Validation
% Specify path to ground truth disparity map
gt_path = scene_path;
gt_fn = fullfile(gt_path,'disp0.pfm');
% Load the ground truth
G = pfmread(gt_fn);

% Estimate the quality of the calculated disparity map
p = validate_dmap(D{1}, G);

%% Stop timer here
elapsed_time = toc;


%% Print Results
% R, T, p, elapsed_time
fprintf('R = \n');
disp(R);
fprintf('T = \n');
disp(T);
fprintf('p = \n');disp(p);fprintf('dB');
fprintf('elapsed_time = \n');
disp(elapsed_time)

%% Display Disparity
plotdisp(D);

%% 3Dplot (Need Computer Vision Toolbox)
% fn = fullfile(gt_path,'im0.png');
% Image = double(imread(fn));
% DreiD_Recons(distancemap,Image);