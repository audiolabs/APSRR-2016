% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% download.m
%
% Downloads and extracts code and dataset for reproduction of paper:
% "Analyzing Chroma Feature Types for Automated Chord Recognition"
% by Nanzhu Jiang et al.
% 
% Programmer: Sebastian Rosenzweig
% Supervisor: Christof Weiß
% Audio Processing Seminar WS 2016/2017
% FAU Erlangen-Nürnberg/AudioLabs Erlangen
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc;

%% Download dataset and Chroma Toolbox
options = weboptions('Timeout',Inf);
dataZip = websave('./dataset/data.zip','http://labrosa.ee.columbia.edu/projects/chords/beatles.zip',options);
chromaZip = websave('./code/chroma.zip','https://www.audiolabs-erlangen.de/content/resources/MIR/chromatoolbox/MATLAB-Chroma-Toolbox_2.0.zip',options);
%dataZip = urlwrite('http://labrosa.ee.columbia.edu/projects/chords/beatles.zip','./dataset/data.zip','Timeout',Inf);
%chromaZip = urlwrite('https://www.audiolabs-erlangen.de/content/resources/MIR/chromatoolbox/MATLAB-Chroma-Toolbox_2.0.zip','./code/chroma.zip','Timeout',Inf);

%% Extract ZIP files
unzip(dataZip);
unzip(chromaZip);

% cleanup
delete(dataZip);
delete(chromaZip);

%% Prepare dataset
% get paths to all files
% TODO: add function to repository
listMP3Path = getAllFiles('.\dataset\','*.mp3',1);
listChordsPath = getAllFiles('.\dataset\','*.lab',1);

% check if files have been found
if isempty(listMP3Path) || ispempty(listChordsPath)
    error('Dataset not found! Please download it once more!');
end

% get filenames only
listMP3 = getFileNames('.\dataset\','*.mp3',0);
listChords = getFileNames('.\dataset\','*.lab',0);

% remove numbers from filenames
for i = 1:length(listMP3)
    listMP3{i,1} = listMP3{i,1}(4:end);
    listChords{i,1} = listChords{i,1}(4:end);
end

% create new directories
mkdir('.\dataset\audio\');
mkdir('.\dataset\chords\');

% copy files to new directories
for i = 1:length(listMP3)
    copyfile(listMP3Path{i,1},['.\dataset\audio\' listMP3{i,1}]);
    copyfile(listChordsPath{i,1},['.\dataset\chords\' listChords{i,1}]);
end

% delete old folder structure
rmdir('.\dataset\beatles','s');

% save list of files
save('listOfFiles.mat','listMP3');