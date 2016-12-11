% soundCell= cell(1,length(srcFiles));
% for i = 1 : length(srcFiles)
%   filename{i} = strcat('C:\Users\hysnelaa\Desktop\repet\Wavfile\',srcFiles(i).name);
%   [soundCell{i},fs{i},nbits{i}] = wavread(filename{i});
%   ce(i).Mtx= deal(soundCell{1,i});
%   ce(i).sound_mix= ce(i).Mtx(:,1) +ce(i).Mtx(:,2);
%   ce(i).soundEst = repet(ce(i).sound_mix,fs{i}); %take the repeating background
%   ce(i).frgEst=ce(i).sound_mix-ce(i).soundEst;
%   [SDR{i},SIR{i},SAR{i},perm{i}]=bss_eval_sources( ce(i).soundEst',ce(i).sound_IncMu'); %background
% 
% end
% 

 srcFiles = dir('C:\Users\Algert\Desktop\repet1\Wavfile\*.wav'); 

soundCell= cell(1,length(srcFiles));

for i = 1 : length(srcFiles)
 filename{i} = strcat('C:\Users\Algert\Desktop\repet1\Wavfile\',srcFiles(i).name);
 [soundCell{i},fs{i},nbits{i}] = wavread(filename{i});
  %voice and music have same original level
  ce(i).Mtx= deal(soundCell{1,i});
  ce(i).sound_mix= ce(i).Mtx(:,1) +ce(i).Mtx(:,2);
  ce(i).soundEst = repet(ce(i).sound_mix,fs{i}); %take the repeating background
  ce(i).frgEst=ce(i).sound_mix-ce(i).soundEst;
  [SDR{i},SIR{i},SAR{i},perm{i}]=bss_eval_sources( ce(i).soundEst',ce(i).Mtx(:,1)'); %background
  pw(i).pw1= (1/length(ce(i).Mtx(:,1)))*sum(abs(ce(i).Mtx(:,1)).^2);
  pw(i).pw2= (1/length(ce(i).Mtx(:,2)))*sum(abs(ce(i).Mtx(:,2)).^2);
  pw(i).pw_dB=pow2db(ceil(pw(i).pw1/pw(i).pw2));
  
  %boxplot(SDR,pw(i).pw_dB)

  %music is louder
  ceMu(i).Mtx= deal(soundCell{1,i});
  ceMu(i).sound_IncMu=ceMu(i).Mtx(:,1) * 10^(5/20);  %music channel increased with 5 db (v/m=-5)
  ceMu(i).sound_mix= ceMu(i).sound_IncMu +ceMu(i).Mtx(:,2);
  ceMu(i).soundEst = repet(ceMu(i).sound_mix,fs{i}); %take the repeating background
  ceMu(i).frgEst=ceMu(i).sound_mix-ceMu(i).soundEst; %the estimated foreground/voice
%lyricsName{i} = strcat('C:\Users\hysnelaa\Desktop\repet\LyricsWav\',srcLyrics(i).name);
%[lyricsCell{i},fsL{i},nbitsL{i}] = wavread(lyricsName{i});
%[SDR{i},SIR{i},SAR{i},perm{i}]=bss_eval_sources( ce(i).frgEst',ce(i).Mtx(:,2)');
 [SDRmu{i},SIRmu{i},SARmu{i},permmu{i}]=bss_eval_sources( ceMu(i).soundEst',ceMu(i).sound_IncMu'); %background
  pwMu(i).pw1= (1/length(ceMu(i).Mtx(:,1)))*sum(abs(ceMu(i).Mtx(:,1)).^2);
  pwMu(i).pw2= (1/length(ceMu(i).sound_IncMu))*sum(abs(ceMu(i).sound_IncMu).^2);
  %pwMu(i).pw=pwMu(i).pw2/ pwMu(i).pw1;
  pwMu(i).pw_dB=pow2db(ceil(pwMu(i).pw2/ pwMu(i).pw1));
  
  %voice is louder
  ceVo(i).Mtx= deal(soundCell{1,i});
  ceVo(i).sound_IncVo=ceVo(i).Mtx(:,2) * 10^(5/20);  %Voice channel increased with 5 db (v/m=5)
  ceVo(i).sound_mix= ceVo(i).sound_IncVo +ceVo(i).Mtx(:,1);
  ceVo(i).soundEst = repet(ceVo(i).sound_mix,fs{i}); %take the repeating background
  ceVo(i).frgEst=ceVo(i).sound_mix-ceVo(i).soundEst; %the estimated foreground/voice
  [SDRvo{i},SIRvo{i},SARvo{i},permvo{i}]=bss_eval_sources( ceVo(i).soundEst',ceVo(i).sound_IncVo'); %background
  pwVo(i).pw1= (1/length(ceVo(i).Mtx(:,1)))*sum(abs(ceVo(i).Mtx(:,1)).^2);
  pwVo(i).pw2= (1/length(ceVo(i).sound_IncVo))*sum(abs(ceVo(i).sound_IncVo).^2);
  pwVo(i).pw=pwVo(i).pw2/ pwVo(i).pw1;
  pwVo(i).pw_dB=pow2db(pwVo(i).pw);
end

SDRmtx=[SDR SDRMu SDRVo]
  
 %soundEst = repet(sound_mix,fs);
 %[MER,perm]=bss_eval_mix(soundEst,sound_mix);

 
%  % voice louder than music 5
% srcFiles = dir('C:\Users\hysnelaa\Desktop\repet\Wavfile\*.wav'); 
%  % the folder in which ur images exists
%  soundCellVo= cell(1,length(srcFiles)); 
% for i = 1 : length(srcFiles)
% %   filename{i} = strcat('C:\Users\hysnelaa\Desktop\repet\Wavfile\',srcFiles(i).name);
% %   [soundCellVo{i},fs{i},nbits{i}] = wavread(filename{i});
% %   ceVo(i).Mtx= deal(soundCellVo{1,i});
% %   ceVo(i).sound_IncVo=ceVo(i).Mtx(:,2) * 10^(5/20);  %Voice channel increased with 5 db (v/m=5)
% %   ceVo(i).sound_mix= ceVo(i).sound_IncVo +ceVo(i).Mtx(:,1);
% %   ceVo(i).soundEst = repet(ceVo(i).sound_mix,fs{i}); %take the repeating background
% %   ceVo(i).frgEst=ceVo(i).sound_mix-ceVo(i).soundEst; %the estimated foreground/voice
% %   %power
%   pwVo(i).pw1= (1/length(ceVo(i).Mtx(:,1)))*sum(abs(ceVo(i).Mtx(:,1)).^2);
%   pwVo(i).pw2= (1/length(ceVo(i).sound_IncVo))*sum(abs(ceVo(i).sound_IncVo).^2);
%   pwVo(i).pw=pwVo(i).pw2/ pwVo(i).pw1;
%   pwVo(i).pw_dB=pow2db(pwVo(i).pw);
% %   [SDRvo{i},SIRvo{i},SARvo{i},permvo{i}]=bss_eval_sources( ceVo(i).soundEst',ceVo(i).sound_IncVo'); %background
% 
% end

% 
%  powerxch2= (1/length(sound_IncVo))*sum(abs(sound_IncVo).^2);
%  a=powerxch2/powerxch1;
% a_db=pow2db(a)