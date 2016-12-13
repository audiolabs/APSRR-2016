% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ReproduceFigure4.m
%
% Reproduction of Tb-graph of figure 4 of paper:
% "Analyzing Chroma Feature Types for Automated Chord Recognition"
% by Nanzhu Jiang et al.
% 
% Programmer: Sebastian Rosenzweig
% Supervisor: Christof Weiss
% Audio Processing Seminar WS 2016/2017
% FAU Erlangen-Nuernberg/AudioLabs Erlangen
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc
tic

%% Set paths, load files, init variables
addpath(genpath('./code/')); % add chroma toolbox

chordsFolder = './dataset/chords/';
audioFolder = './dataset/audio/';
outputFolder = './output/';

load('listOfFiles.mat'); % load list of MP3-files

fMeasure = zeros(size(listMP3,1),6);

for fileIdx = 1:size(listMP3,1)
    if fileIdx == 87
        % Ask_me_why.lab is buggy
        continue;
    end
    fprintf('Processing file %d of %d...\n',fileIdx,size(listMP3,1));
    fileName = listMP3{fileIdx};

    %% Compute pitch features
    [f_audio,fs] = audioread([audioFolder fileName]);
    f_audio = resample (f_audio,22050,fs,100);
    shiftFB = estimateTuning(f_audio);

    paramPitch.winLenSTMSP = 4410;
    paramPitch.shiftFB = shiftFB;
    paramPitch.visualize = 0;
    [f_pitch,sideinfo] = ...
        audio_to_pitch_via_FB(f_audio,paramPitch);

    chromaMatrices = cell(6,1);

    paramCP.applyLogCompr = 0;
    paramCP.visualize = 0;
    paramCP.inputFeatureRate = sideinfo.pitch.featureRate;
    [chromaMatrices{1},~] = pitch_to_chroma(f_pitch,paramCP,sideinfo);

    paramCLP.applyLogCompr = 1;
    paramCLP.factorLogCompr = 1;
    paramCLP.visualize = 0;
    paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
    [chromaMatrices{2},~] = pitch_to_chroma(f_pitch,paramCLP,sideinfo);

    paramCLP.applyLogCompr = 1;
    paramCLP.factorLogCompr = 10;
    paramCLP.visualize = 0;
    paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
    [chromaMatrices{3},~] = pitch_to_chroma(f_pitch,paramCLP,sideinfo);

    paramCLP.applyLogCompr = 1;
    paramCLP.factorLogCompr = 100;
    paramCLP.visualize = 0;
    paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
    [chromaMatrices{4},~] = pitch_to_chroma(f_pitch,paramCLP,sideinfo);

    paramCLP.applyLogCompr = 1;
    paramCLP.factorLogCompr = 1000;
    paramCLP.visualize = 0;
    paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
    [chromaMatrices{5},~] = pitch_to_chroma(f_pitch,paramCLP,sideinfo);

    paramCLP.applyLogCompr = 1;
    paramCLP.factorLogCompr = 10000;
    paramCLP.visualize = 0;
    paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
    [chromaMatrices{6},~] = pitch_to_chroma(f_pitch,paramCLP,sideinfo);

    %save([outputFolder fileName(1:end-3) 'mat'],'chromaMatrices');
    %load([outputFolder fileName(1:end-3) 'mat']);

    %% Create binary template vectors
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

    for compressionIdx = 1:size(chromaMatrices,1)
        chromaMatrixLog = chromaMatrices{compressionIdx};
        
        %% Do template matching

        chordIdxVec = zeros(1, size(chromaMatrixLog,2));

        for i = 1:size(chromaMatrixLog,2)
            featureVec = chromaMatrixLog(:,i);
            distanceVec = NaN(1,24);

            for j = 1:24
                distanceVec(j) = 1 - dot(featureVec,templateVec{j,1})/(norm(featureVec,2)*norm(templateVec{j,1},2));
            end

            [~,chordIdxVec(i)] = min(distanceVec);
        end

        %% Prepare chord labels
        % read file
        fid = fopen([chordsFolder fileName(1:end-3) 'lab']);
        content = textscan(fid, '%f64 %f64 %s');
        fclose(fid);

        % map all occuring chords to major/minor/none chords
        contentMM = content;
        for i = 1:size(content{3},1)
            if i == 55
                a = 1;
            end
            curLabel = contentMM{3}{i};
            k = strfind(curLabel,':');
            if isempty(k) % major chord
                slash = strfind(curLabel,'/');
                if ~isempty(slash)
                    contentMM{3}{i} = curLabel(1:slash-1);
                end
                
                switch contentMM{3}{i}
                    case 'Eb'
                        contentMM{3}{i} = 'D#';
                    case 'Ab'
                        contentMM{3}{i} = 'G#';
                    case 'Gb'
                        contentMM{3}{i} = 'F#';
                    case 'A#'
                        contentMM{3}{i} = 'B';
                    case 'Db'
                        contentMM{3}{i} = 'C#';    
                end
            else
                newLabel = curLabel(1:k-1);
                switch newLabel
                    case 'Eb'
                        newLabel = 'D#';
                    case 'Ab'
                        newLabel = 'G#';
                    case 'Gb'
                        newLabel = 'F#';
                    case 'A#'
                        newLabel = 'B';
                    case 'Db'
                        newLabel = 'C#';
                end

                app = curLabel(k+1:end);
                switch app
                    case 'min'
                        newLabel = strcat(newLabel, ':min');
                    case 'dim'
                        newLabel = strcat(newLabel, ':min');
                    case 'aug'
                        newLabel = strcat(newLabel, '');
                    case 'maj7'
                        newLabel = strcat(newLabel, '');   
                    case '7'
                        newLabel = strcat(newLabel, '');
                    case 'maj(9)'
                        newLabel = strcat(newLabel, '');    
                    case 'aug(7)'
                        newLabel = strcat(newLabel, '');    
                    case 'min7'
                        newLabel = strcat(newLabel, ':min');    
                    case 'min(9)'
                        newLabel = strcat(newLabel, ':min');    
                    case 'dim(7)'
                        newLabel = strcat(newLabel, ':min');    
                    case 'hdim7'
                        newLabel = strcat(newLabel, ':min');    
                    case 'dim7'
                        newLabel = strcat(newLabel, ':min');    
                    otherwise
                        newLabel = 'N';
                end

                contentMM{3}{i} = newLabel;
            end
        end

        % assign chords to each window
        labelIdxVec = NaN(size(chordIdxVec));

        for i = 1:length(labelIdxVec)
            % calculate center of current window
            featureRate = 10;%sideinfo.pitch.featureRate;
            
            fLen = fs/featureRate;
            centerSample = (2*i-1)*fLen/2;
            centerT = centerSample/fs;

            % find label index
            if centerT > contentMM{2}(end)
                labelIdx = size(contentMM,1);
            else
                labelIdx = find(contentMM{1} <= centerT & contentMM{2} > centerT);
            end

            if isempty(labelIdx)
                error('Could not find entry to given time!');
            end

            % translate chord label to chord index
            curChordName = contentMM{3}{labelIdx};
            switch curChordName
                case 'C'
                    labelIdxVec(i) = 1;
                case 'C#'
                    labelIdxVec(i) = 2;
                case 'D'
                    labelIdxVec(i) = 3;
                case 'D#'
                    labelIdxVec(i) = 4;
                case 'E'
                    labelIdxVec(i) = 5;
                case 'F'
                    labelIdxVec(i) = 6;
                case 'F#'
                    labelIdxVec(i) = 7;
                case 'G'
                    labelIdxVec(i) = 8;
                case 'G#'
                    labelIdxVec(i) = 9;
                case 'A'
                    labelIdxVec(i) = 10;
                case 'Bb'
                    labelIdxVec(i) = 11;
                case 'B'
                    labelIdxVec(i) = 12;
                case 'C:min'
                    labelIdxVec(i) = 13;
                case 'C#:min'
                    labelIdxVec(i) = 14;
                case 'D:min'
                    labelIdxVec(i) = 15;
                case 'D#:min'
                    labelIdxVec(i) = 16;
                case 'E:min'
                    labelIdxVec(i) = 17;
                case 'F:min'
                    labelIdxVec(i) = 18;
                case 'F#:min'
                    labelIdxVec(i) = 19;
                case 'G:min'
                    labelIdxVec(i) = 20;
                case 'G#:min'
                    labelIdxVec(i) = 21;
                case 'A:min'
                    labelIdxVec(i) = 22;
                case 'Bb:min'
                    labelIdxVec(i) = 23;
                case 'B:min'
                    labelIdxVec(i) = 24;
                case 'N'
                    labelIdxVec(i) = 25;
                otherwise
                    error('Unknown chord!');
            end
        end

        %% Evaluation
        C = 0; %correct
        FP = 0; %false positive
        FN = 0; %false negative

        for i = 1:length(labelIdxVec)
            curChordC = chordIdxVec(i); %computed chord
            curChordR = labelIdxVec(i); %reference chord

            if curChordR == 25
                continue
            end

            if curChordC == curChordR
                C = C+1;
            else
                FN = FN+1;
                FP = FP+1;
            end    
        end

        P = C/(C+FP);
        R = C/(C+FN);
        F = 2*P*R/(P+R);
        
        if isnan(F)
            F = 0;
        end
        
        fMeasure(fileIdx,compressionIdx) = F;
    end    
end

%% Plot results
F0 = sum(fMeasure(:,1))/size(fMeasure,1);
F1 = sum(fMeasure(:,2))/size(fMeasure,1);
F10 = sum(fMeasure(:,3))/size(fMeasure,1);
F100 = sum(fMeasure(:,4))/size(fMeasure,1);
F1000 = sum(fMeasure(:,5))/size(fMeasure,1);
F10000 = sum(fMeasure(:,6))/size(fMeasure,1);

FVec = [F0 F1 F10 F100 F1000 F10000];

h = figure;
p = plot(1:6,FVec,'-o','MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor',[.7 .7 .7],'LineWidth',3);
set(p,'Color',[.7 .7 .7]);
ylim([0.35 0.8]);
xlim([0.5 6.5]);
set(gca,'XTick',1:6);
set(gca,'XTickLabel',{'CP' ; 'CLP[1]' ; 'CLP[10]' ; 'CLP[100]' ; 'CLP[1000]' ; 'CLP[10000]'});
legend('Tb','Location','southeast')
xlabel('Compression parameter \eta');
ylabel('F-measure');

% save figure
saveas(h,[outputFolder 'TbFigure4.fig']);
saveas(h,[outputFolder 'TbFigure4.png']);

toc