% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step01_download.m
%
% Downloads and extracts code and dataset for reproduction of paper:
% "Analyzing Chroma Feature Types for Automated Chord Recognition"
% by Nanzhu Jiang et al.
% 
% Programmer: Sebastian Rosenzweig
% Supervisor: Christof Weiss
% Audio Processing Seminar WS 2016/2017
% FAU Erlangen-Nuernberg/AudioLabs Erlangen
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc;

%% Delete old files
if exist('./dataset/audio/','dir')
    rmdir('./dataset/audio/','s');
end
if exist('./dataset/chords/','dir')
    rmdir('./dataset/chords/','s');
end
if exist('./code/MATLAB-Chroma-Toolbox_2.0/','dir')
    rmdir('./code/MATLAB-Chroma-Toolbox_2.0/','s');
end
if exist('./output/listOfFiles.mat','file')
    delete('./output/listOfFiles.mat');
end

%% Download dataset and Chroma Toolbox
options = weboptions('Timeout',Inf);
dataZip = websave('./dataset/data.zip','http://labrosa.ee.columbia.edu/projects/chords/beatles.zip',options);
chromaZip = websave('./code/chroma.zip','https://www.audiolabs-erlangen.de/content/resources/MIR/chromatoolbox/MATLAB-Chroma-Toolbox_2.0.zip',options);

%% Extract ZIP files
unzip(dataZip,'./dataset/');
unzip(chromaZip,'./code/');

% cleanup
delete(dataZip);
delete(chromaZip);

%% Prepare dataset
% get paths to all files
listMP3Path = getFileNames('./dataset/','*.mp3',1);
listChordsPath = getFileNames('./dataset/','*.lab',1);

% check if files have been found
if isempty(listMP3Path) || isempty(listChordsPath)
    error('Dataset not found! Please download it once more!');
end

% get filenames only
listMP3 = getFileNames('./dataset/','*.mp3',0);
listChords = getFileNames('./dataset/','*.lab',0);

% remove numbers from filenames
for i = 1:length(listMP3)
    listMP3{i,1} = listMP3{i,1}(4:end);
    listChords{i,1} = listChords{i,1}(4:end);
end

% create new directories
mkdir('./dataset/audio/');
mkdir('./dataset/chords/');

% copy files to new directories
for i = 1:length(listMP3)
    copyfile(listMP3Path{i,1},['./dataset/audio/' listMP3{i,1}]);
    copyfile(listChordsPath{i,1},['./dataset/chords/' listChords{i,1}]);
end

% delete old folder structure
rmdir('./dataset/beatles','s');

% save list of files
save('./output/listOfFiles.mat','listMP3');