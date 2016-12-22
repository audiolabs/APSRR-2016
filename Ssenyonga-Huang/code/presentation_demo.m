clear; close all; clc;
work_folder = pwd;
cd ../../../
third_party = pwd;
cd(work_folder)
mkdir('demo_files')
set(0,'DefaultFigureWindowStyle','docked','DefaultAxesFontSize',14)
addpath(genpath([third_party,'/singingvoiceseparationrpca']));
addpath([third_party,'/MIR-1K/Wavfile']);
parm.nFFT = 1024;
parm.windowsize = 1024;
parm.masktype = 1; %1: binary mask, 2: no mask
parm.lambda = 1;
parm.gain = 1;
parm.power = 1;

%% Extract files and choose example
files = dir([third_party,'/MIR-1K/Wavfile/*.wav']);
k = randi(1000,1); % random song to use
[wavinmix, fs] = audioread(files(k).name);
parm.fs = fs;
Music = wavinmix(:,1);
Vocals = wavinmix(:,2);

% Mixing at different SNR

g_5 = rms(Vocals) / (10^0.5 * rms(Music));
g_min5 = rms(Music) / (10^0.5 * rms(Vocals));

wavinmix5 = g_5*Music + Vocals; % 5dB
wavinmix0 = Music + Vocals; % 0dB
wavinmix_min5 = Music + g_min5*Vocals; % -5dB
parm.outname = [work_folder, filesep, 'demo_files', filesep, files(k).name(1:end-4)];
audiowrite([parm.outname, '_SNR5.wav'],wavinmix5,fs); % 5dB
audiowrite([parm.outname, '_SNR0.wav'],wavinmix0,fs); % 0dB
audiowrite([parm.outname, '_SNRmin5.wav'],wavinmix_min5,fs); % -5dB
audiowrite([parm.outname, '_music.wav'],Music,fs);
audiowrite([parm.outname, '_vocal.wav'],Vocals,fs);
%% Run RPCA
outputs5 = rpca_mask_execute(wavinmix5, parm);
outputs0 = rpca_mask_execute(wavinmix0, parm);
outputs_min5 = rpca_mask_execute(wavinmix_min5, parm);

audiowrite([parm.outname, '_sparse.wav'],outputs5.wavoutE,fs);
audiowrite([parm.outname, '_lowrank.wav'],outputs5.wavoutA,fs);

%% plotting
figure('name','Mixture matrix, M')
stft(wavinmix5); % change this to show different spectograms, for different dB
figure('name','Sparse matrix, S')
stft(outputs5.wavoutE);
figure('name','Low rank matrix, L')
stft(outputs5.wavoutA);




