% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ReproduceFigure4.m
%
% Reproduction of figure 4 of paper:
% "Analyzing Chroma Feature Types for Automated Chord Recognition"
% by Nanzhu Jiang et al.
% 
% Programmer: Sebastian Rosenzweig
% Supervisor: Christof Weiß
% Audio Processing Seminar WS 2016/2017
% FAU Erlangen-Nürnberg/AudioLabs Erlangen
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc

%% Set paths, load files
addpath(genpath('.\code\')); % add chroma toolbox

chordsFolder = '.\dataset\chords\';
audioFolder = '.\dataset\audio\';

load('listOfFiles.mat');

%% Compute pitch features
fileName = 'Blackbird.wav';
[f_audio,sideinfo] = wav_to_audio('', audioFolder, fileName);
shiftFB = estimateTuning(f_audio);

paramPitch.winLenSTMSP = 4410;
paramPitch.shiftFB = shiftFB;
paramPitch.visualize = 0;
[f_pitch,sideinfo] = ...
    audio_to_pitch_via_FB(f_audio,paramPitch,sideinfo);

paramCP.applyLogCompr = 0;
paramCP.visualize = 0;
paramCP.inputFeatureRate = sideinfo.pitch.featureRate;
[f_CP,sideinfo] = pitch_to_chroma(f_pitch,paramCP,sideinfo);

paramCLP.applyLogCompr = 1;
paramCLP.factorLogCompr = 1;
paramCLP.visualize = 0;
paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
[f_CLP1,sideinfo1] = pitch_to_chroma(f_pitch,paramCLP,sideinfo);

paramCLP.applyLogCompr = 1;
paramCLP.factorLogCompr = 10;
paramCLP.visualize = 0;
paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
[f_CLP10,sideinfo10] = pitch_to_chroma(f_pitch,paramCLP,sideinfo);

paramCLP.applyLogCompr = 1;
paramCLP.factorLogCompr = 100;
paramCLP.visualize = 0;
paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
[f_CLP100,sideinfo100] = pitch_to_chroma(f_pitch,paramCLP,sideinfo);

paramCLP.applyLogCompr = 1;
paramCLP.factorLogCompr = 1000;
paramCLP.visualize = 0;
paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
[f_CLP1000,sideinfo1000] = pitch_to_chroma(f_pitch,paramCLP,sideinfo);

paramCLP.applyLogCompr = 1;
paramCLP.factorLogCompr = 10000;
paramCLP.visualize = 0;
paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
[f_CLP10000,sideinfo10000] = pitch_to_chroma(f_pitch,paramCLP,sideinfo);


%% Create template vectors
templateVec = cell(24,1);
templateVec{1,1} = [1 0 0 0 1 0 0 1 0 0 0 0]; % C-major
for i = 2:12
    templateVec{i,1} = circshift(templateVec{1,1}',i-1)';
end
templateVec{13,1} = [1 0 0 1 0 0 0 1 0 0 0 0]; % C-minor
for i = 14:24
    templateVec{i,1} = circshift(templateVec{13,1}',i-1)';
end
% Major: 'C' 'Cis' 'D' 'Dis' 'E' 'F' 'Fis' 'G' 'Gis' 'A' 'Bb' 'B' 
% Minor: 'Cm' 'Cism' 'Dm' 'Dism' 'Em' 'Fm' 'Fism' 'Gm' 'Gism' 'Am' 'Bbm' 'Bm' 

%% Do template matching
chromaMatrixLog = f_CP;
chordIdxVec = zeros(1, size(chromaMatrixLog,2));

for i = 1:size(chromaMatrixLog,2)
    featureVec = chromaMatrixLog(:,i);
    distanceVec = NaN(1,24);

    for j = 1:24
        distanceVec(j) = 1 - dot(featureVec,templateVec{j,1})/(norm(featureVec,2)*norm(templateVec{j,1},2));
    end

    [~,chordIdxVec(i)] = min(distanceVec);
end

%% Evaluation
