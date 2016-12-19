% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task: Reproduction of figure 3 of paper:
% "Repeating Pattern Extraction Technique (REPET): a simple method for voice/source separation"
%
% Authors: Zafar Rafii & Bryan Pardo
% Programmed by: Arjola Hysneli
% Audio Processing Seminar WS 2016/2017
% FAU Erlangen-Nuernberg/AudioLabs Erlangen
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc


% get paths to all files
currentpath= pwd;
cd ../
cd dataset
srcFiles = dir('./MIR-1K/Wavfile/*.wav'); 

for i = 1 : size(srcFiles,1)
 filename{i} = strcat('./MIR-1K/Wavfile/',srcFiles(i).name);
[soundCell{i},fs{i},nbits{i}] = audioread(filename{i});
 
  %% Case 1: voice and music have same original level
  
  % Cell creation
  ce(i).Mtx= deal(soundCell{1,i});                                         %read all the sound names from the cell to a matrix(that is inside a struct)
  ce(i).sound_mix= ce(i).Mtx(:,1) +ce(i).Mtx(:,2);
  ce(i).soundEst = repet(ce(i).sound_mix,fs{i});                           %take the repeating background using REPET
  ce(i).frgEst=ce(i).sound_mix-ce(i).soundEst;
  
  % Evaluation of parameters
  
  [SDR{i},SIR{i},SAR{i},perm{i}]=bss_eval( ce(i).soundEst',ce(i).Mtx(:,1)'); %using Bss_eval %background
  [SDRfrg{i},SIRfrg{i},SARfrg{i},permfrg{i}]=bss_eval( ce(i).frgEst',ce(i).Mtx(:,2)');
  
  % Calculation of power
  
  pw(i).pw1= (1/length(ce(i).Mtx(:,1)))*sum(abs(ce(i).Mtx(:,1)).^2);       %power of channel 1
  pw(i).pw2= (1/length(ce(i).Mtx(:,2)))*sum(abs(ce(i).Mtx(:,2)).^2);       %power of channel 2
  pw(i).pw_dB=pow2db(ceil(pw(i).pw1/pw(i).pw2));                           %power ratio
  
  if range(pw(i).pw_dB)==0                                                 %check if all the values in the vector are the same(for every song)
    gleich=pw(1).pw_dB;                                                    %takes just one value
  end
  

  %% Case 2: Music is louder
  
  % Cell creation
  ceMu(i).Mtx= deal(soundCell{1,i});
  ceMu(i).sound_IncMu=ceMu(i).Mtx(:,1) * 10^(5/20);                        %music channel increased with 5 db (v/m=-5)
  ceMu(i).sound_mix= ceMu(i).sound_IncMu +ceMu(i).Mtx(:,2);
  ceMu(i).soundEst = repet(ceMu(i).sound_mix,fs{i});                       %take the repeating background
  ceMu(i).frgEst=ceMu(i).sound_mix-ceMu(i).soundEst;                       %the estimated foreground/voice
  
  % Evaluation of parameters
  [SDRmu{i},SIRmu{i},SARmu{i},permmu{i}]=bss_eval( ceMu(i).soundEst',ceMu(i).sound_IncMu'); %background
  [SDRmufrg{i},SIRmufrg{i},SARmufrg{i},permmufrg{i}]=bss_eval( ceMu(i).frgEst',ceMu(i).Mtx(:,2)');
  
  % Calculation of power
   pwMu(i).pw2= (1/length(ceMu(i).Mtx(:,2)))*sum(abs(ceMu(i).Mtx(:,2)).^2);
   pwMu(i).pw1= (1/length(ceMu(i).sound_IncMu))*sum(abs(ceMu(i).sound_IncMu).^2);
   pwMu(i).pw_dB=pow2db(pwMu(i).pw2/ pwMu(i).pw1);
   
   if range(pwMu(i).pw_dB)==0
      music=pwMu(1).pw_dB;
   end     
  
  %% Case 2: Voice is louder(v/m=5)
  
  % Cell creation
  ceVo(i).Mtx= deal(soundCell{1,i});
  ceVo(i).sound_IncVo=ceVo(i).Mtx(:,2) * 10^(5/20);                        %Voice channel increased with 5 db (v/m=5)
  ceVo(i).sound_mix= ceVo(i).sound_IncVo +ceVo(i).Mtx(:,1);
  ceVo(i).soundEst = repet(ceVo(i).sound_mix,fs{i});                       %take the repeating background
  ceVo(i).frgEst=ceVo(i).sound_mix-ceVo(i).soundEst;                       %the estimated foreground/voice
  
  % Evaluation of parameters
  [SDRvo{i},SIRvo{i},SARvo{i},permvo{i}]=bss_eval( ceVo(i).soundEst',ceVo(i).sound_IncVo'); %background
  [SDRvofrg{i},SIRvofrg{i},SARvofrg{i},permvofrg{i}]=bss_eval( ceMu(i).frgEst',ceMu(i).Mtx(:,2)');
  
  % Calculation of power
  pwVo(i).pw1= (1/length(ceVo(i).Mtx(:,1)))*sum(abs(ceVo(i).Mtx(:,1)).^2);
  pwVo(i).pw2= (1/length(ceVo(i).sound_IncVo))*sum(abs(ceVo(i).sound_IncVo).^2);
  pwVo(i).pw=pwVo(i).pw2/ pwVo(i).pw1;
  pwVo(i).pw_dB=pow2db(pwVo(i).pw);
  
  if range(pwVo(i).pw_dB)==0
    voice=pwVo(1).pw_dB;
  end
  
end

SDRcel=[SDR ;SDRmu ;SDRvo];                                                  %concatinate all teh SDR taken from the 3 cases above
SDRcelfrg=[SDRfrg; SDRmufrg; SDRvofrg]; 
SDRmtx=cell2mat(SDRcel);                                                   %converts the cell structure to matrix
SDRmtxfrg=cell2mat(SDRcelfrg);  
powVec= [voice gleich music];                                              % power vector


% ploting 
figure (1)
fig1=boxplot(SDRmtx',powVec);
xlabel('Power ratios in dB');
ylabel('SDR evaluation/Music case')
title('Music-SDR evaluation')


figure (2)
fig1=boxplot(SDRmtxfrg',powVec)
xlabel('Power ratios in dB');
ylabel('SDR evaluation/Voice case')
title('Voice-SDR evaluation')


% saving the figures
hgsave('Music-SDR evaluation.fig');
hgsave('Voice-SDR evaluation.fig');

