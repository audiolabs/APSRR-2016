%% addpath
addpath('example');
addpath('MIR-1K/Wavfile');
%% Extract at most N files and put in examples folder
N = 10; % Instead of 1000
files = dir(['MIR-1K/Wavfile','/*.wav']);
index = randi([1 1000],N,1); % random index
for k = 1:N
    [wavinmix, fs] = audioread(files(index(k)).name);
    outname = ['example', filesep, 'used_data', filesep, files(index(k)).name(1:end-4)];
    audiowrite([outname, '_music.wav'],wavinmix(:,1),fs);
    audiowrite([outname, '_vocal.wav'],wavinmix(:,2),fs);
    
    % Mixing at different SNR
    
    g_5 = rms(wavinmix(:,2)) / (10^0.5 * rms(wavinmix(:,1)));
    g_min5 = rms(wavinmix(:,1)) / (10^0.5 * rms(wavinmix(:,2)));
    
    audiowrite([outname, '_SNR5.wav'],g_5*wavinmix(:,1)+wavinmix(:,2),fs); % 5dB
    audiowrite([outname, '_SNR0.wav'],wavinmix(:,1)+wavinmix(:,2),fs); % 0dB
    audiowrite([outname, '_SNRmin5.wav'],wavinmix(:,1)+g_min5*wavinmix(:,2),fs); % -5dB
end