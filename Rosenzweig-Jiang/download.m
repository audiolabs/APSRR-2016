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

%clear all; close all; clc

%% Download dataset and Chroma Toolbox
% dataZip = websave('./dataset/data.zip','http://labrosa.ee.columbia.edu/projects/chords/beatles.zip');
% chromaZip = websave('./code/chroma.zip','https://www.audiolabs-erlangen.de/content/resources/MIR/chromatoolbox/MATLAB-Chroma-Toolbox_2.0.zip');
% ffmpegZip = websave('./code/ffmpeg.zip','https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-20161127-801b5c1-win64-static.zip');
% dataZip = urlwrite('http://labrosa.ee.columbia.edu/projects/chords/beatles.zip','./dataset/data.zip');
% chromaZip = urlwrite('https://www.audiolabs-erlangen.de/content/resources/MIR/chromatoolbox/MATLAB-Chroma-Toolbox_2.0.zip','./code/chroma.zip');
% ffmpegZip = urlwrite('https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-20161127-801b5c1-win64-static.zip','./code/ffmpeg.zip');
% 
% %% Extract ZIP files
% unzip(dataZip);
% unzip(chromaZip);
% unzip(ffmpegZip);
% 
% % cleanup
% delete(dataZip);
% delete(chromaZip);
% delete(ffmpegZip);

%% Prepare dataset
% get paths to all files
listMP3Path = getAllFiles('.\dataset\','*.mp3',1);
listChordsPath = getAllFiles('.\dataset\','*.lab',1);

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

% convert mp3s to wav (fs = 22050)
ffmpeg = fullfile(pwd,'code\ffmpeg-20161127-801b5c1-win64-static\ffmpeg-20161127-801b5c1-win64-static\bin\ffmpeg.exe');
for i = 1:length(listMP3)
    pathMP3File = fullfile(pwd,['dataset\audio\' listMP3{i,1}]);
    pathWAVFile = [pathMP3File(1:end-3) 'wav'];
    command = [ffmpeg ' -i ' pathMP3File ' -ar 22050 ' pathWAVFile];
    system(command);
end

% delete all mp3 files
delete('.\dataset\audio\*.mp3');