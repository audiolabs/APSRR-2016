% ---------------------------------------------------------------------------------------------------------------
% This is an edited and extended version of the example code for running the RPCA for source separation
% P.-S. Huang, S. D. Chen, P. Smaragdis, M. Hasegawa-Johnson,
% "Singing-Voice Separation From Monaural Recordings Using Robust Principal Component Analysis," in ICASSP 2012
%
% Original version written by Po-Sen Huang @ UIUC
% Edited and extended by Robin Ssenyonga
% For any questions on the original version, please email huang146@illinois.edu.
% For any questions on the extended version, please email robin.ssenyonga@fau.de.

% ---------------------------------------------------------------------------------------------------------------
%% addpath
clear; close all; clc;
work_folder = pwd;
cd ../../../
third_party = pwd;
cd(work_folder)
set(0,'DefaultFigureWindowStyle','docked','DefaultAxesFontSize',14)
addpath(genpath([third_party,'/singingvoiceseparationrpca']));
addpath([third_party,'/MIR-1K/Wavfile']);
parm.nFFT = 1024;
parm.windowsize = 1024;
parm.masktype = 1; %1: binary mask, 2: no mask
gains = [0.1, 0.5, 1, 1.5, 2];
lambda = [0.1, 0.5, 1, 1.5, 2, 2.5];
parm.power = 1;

total_no_lambda_5 = zeros(numel(lambda),3);
total_bin_lambda_5 = zeros(numel(lambda),3);
total_no_lambda_0 = zeros(numel(lambda),3);
total_bin_lambda_0 = zeros(numel(lambda),3);
total_no_lambda_min5 = zeros(numel(lambda),3);
total_bin_lambda_min5 = zeros(numel(lambda),3);

total_gain_5 = zeros(numel(gains),3);
total_gain_0 = zeros(numel(gains),3);
total_gain_min5 = zeros(numel(gains),3);

% Evaluating for different lambdas

no_lambda_5 = zeros(numel(lambda),3);
bin_lambda_5 = zeros(numel(lambda),3);
no_lambda_0 = zeros(numel(lambda),3);
bin_lambda_0 = zeros(numel(lambda),3);
no_lambda_min5 = zeros(numel(lambda),3);
bin_lambda_min5 = zeros(numel(lambda),3);

% Evaluating for different gains

gain_5 = zeros(numel(gains),3);
gain_0 = zeros(numel(gains),3);
gain_min5 = zeros(numel(gains),3);

% Collecting data for GNSDR

no_total_NSDR_5 = 0;
no_total_weight_5 = 0;
no_total_NSDR_0 = 0;
no_total_weight_0 = 0;
no_total_NSDR_min5 = 0;
no_total_weight_min5 = 0;

bin_total_NSDR_5 = 0;
bin_total_NSDR_0 = 0;
bin_total_NSDR_min5 = 0;
%% Extract files and process
N = 10;
files = dir([third_party,'/MIR-1K/Wavfile/*.wav']);
for k = 1:N
    [wavinmix, fs] = audioread(files(k).name);
    parm.fs = fs;
    wavinA = wavinmix(:,1);
    wavinE = wavinmix(:,2);
    
    % Mixing at different SNR
    
    g_5 = rms(wavinE) / (10^0.5 * rms(wavinA));
    g_min5 = rms(wavinA) / (10^0.5 * rms(wavinE));
    
    wavinmix5 = g_5*wavinmix(:,1) + wavinmix(:,2); % 5dB
    wavinmix0 = wavinmix(:,1) + wavinmix(:,2); % 0dB
    wavinmix_min5 = wavinmix(:,1) + g_min5*wavinmix(:,2); % -5dB
    parm.outname = [third_party, filesep, 'APSRR-2016/Ssenyonga-Huang/output', filesep, files(k).name(1:end-4)];
    
    %% Run RPCA for different lambdas
    parm.gain = 1;
    for i=1:numel(lambda)
        parm.masktype = 2; % 2: no mask
        parm.lambda = lambda(i);
        outputs5 = rpca_mask_execute(wavinmix5, parm);
        outputs0 = rpca_mask_execute(wavinmix0, parm);
        outputs_min5 = rpca_mask_execute(wavinmix_min5, parm);
        %% Run evaluation
        for ii=1:3
            if ii==1
                % SDR,SIR,SAR computation
                evaluation_results =rpca_mask_evaluation(wavinA, wavinE, outputs5);
                no_lambda_5(i,:) = [evaluation_results.SDR, ...
                    evaluation_results.SAR, evaluation_results.SIR];
                if parm.lambda==1
                    [s_target, e_interf, e_artif] = bss_decomp_gain(wavinmix5', 1, wavinE');
                    [sdr_mixture, sir_mixture, sar_mixture] = bss_crit(s_target, e_interf, e_artif);
                    %% NSDR = SDR(estimated voice, voice) - SDR(mixture, voice)
                    no_total_weight_5 = no_total_weight_5 + numel(wavinmix5);
                    no_total_NSDR_5 = no_total_NSDR_5 + numel(wavinmix5)*(evaluation_results.SDR - sdr_mixture);
                end
            elseif ii==2
                % SDR,SIR,SAR computation
                evaluation_results =rpca_mask_evaluation(wavinA, wavinE, outputs0);
                no_lambda_0(i,:) = [evaluation_results.SDR, ...
                    evaluation_results.SAR, evaluation_results.SIR];
                if parm.lambda==1
                    [s_target, e_interf, e_artif] = bss_decomp_gain(wavinmix0', 1, wavinE');
                    [sdr_mixture, sir_mixture, sar_mixture] = bss_crit(s_target, e_interf, e_artif);
                    %% NSDR = SDR(estimated voice, voice) - SDR(mixture, voice)
                    no_total_weight_0 = no_total_weight_0 + numel(wavinmix0);
                    no_total_NSDR_0 = no_total_NSDR_0 + numel(wavinmix0)*(evaluation_results.SDR - sdr_mixture);
                end
            else
                % SDR,SIR,SAR computation
                evaluation_results =rpca_mask_evaluation(wavinA, wavinE, outputs_min5);
                no_lambda_min5(i,:) = [evaluation_results.SDR, ...
                    evaluation_results.SAR, evaluation_results.SIR];
                if parm.lambda==1
                    [s_target, e_interf, e_artif] = bss_decomp_gain(wavinmix_min5', 1, wavinE');
                    [sdr_mixture, sir_mixture, sar_mixture] = bss_crit(s_target, e_interf, e_artif);
                    %% NSDR = SDR(estimated voice, voice) - SDR(mixture, voice)
                    no_total_weight_min5 = no_total_weight_min5 + numel(wavinmix_min5);
                    no_total_NSDR_min5 = no_total_NSDR_min5 + numel(wavinmix_min5)*(evaluation_results.SDR - sdr_mixture);
                end
            end
        end
    end
    
    total_no_lambda_5 = total_no_lambda_5 + no_lambda_5;
    total_no_lambda_0 = total_no_lambda_0 + no_lambda_0;
    total_no_lambda_min5 = total_no_lambda_min5 + no_lambda_min5;
    
    
    for i=1:numel(lambda)
        parm.lambda = lambda(i);
        parm.masktype = 1; %1: binary mask
        outputs5 = rpca_mask_execute(wavinmix5, parm);
        outputs0 = rpca_mask_execute(wavinmix0, parm);
        outputs_min5 = rpca_mask_execute(wavinmix_min5, parm);
        %% Run evaluation
        for ii=1:3
            if ii==1
                % SDR,SIR,SAR computation
                evaluation_results =rpca_mask_evaluation(wavinA, wavinE, outputs5);
                bin_lambda_5(i,:) = [evaluation_results.SDR, ...
                    evaluation_results.SAR, evaluation_results.SIR];
                if parm.lambda==1
                    [s_target, e_interf, e_artif] = bss_decomp_gain(wavinmix5', 1, wavinE');
                    [sdr_mixture, sir_mixture, sar_mixture] = bss_crit(s_target, e_interf, e_artif);
                    %% NSDR = SDR(estimated voice, voice) - SDR(mixture, voice)
                    bin_total_NSDR_5 = bin_total_NSDR_5 + numel(wavinmix5)*(evaluation_results.SDR - sdr_mixture);
                end
            elseif ii==2
                % SDR,SIR,SAR computation
                evaluation_results =rpca_mask_evaluation(wavinA, wavinE, outputs0);
                bin_lambda_0(i,:) = [evaluation_results.SDR, ...
                    evaluation_results.SAR, evaluation_results.SIR];
                if parm.lambda==1
                    [s_target, e_interf, e_artif] = bss_decomp_gain(wavinmix0', 1, wavinE');
                    [sdr_mixture, sir_mixture, sar_mixture] = bss_crit(s_target, e_interf, e_artif);
                    %% NSDR = SDR(estimated voice, voice) - SDR(mixture, voice)
                    bin_total_NSDR_0 = bin_total_NSDR_0 + numel(wavinmix0)*(evaluation_results.SDR - sdr_mixture);
                end
            else
                % SDR,SIR,SAR computation
                evaluation_results =rpca_mask_evaluation(wavinA, wavinE, outputs_min5);
                bin_lambda_min5(i,:) = [evaluation_results.SDR, ...
                    evaluation_results.SAR, evaluation_results.SIR];
                if parm.lambda==1
                    [s_target, e_interf, e_artif] = bss_decomp_gain(wavinmix_min5', 1, wavinE');
                    [sdr_mixture, sir_mixture, sar_mixture] = bss_crit(s_target, e_interf, e_artif);
                    %% NSDR = SDR(estimated voice, voice) - SDR(mixture, voice)
                    bin_total_NSDR_min5 = bin_total_NSDR_min5 + numel(wavinmix_min5)*(evaluation_results.SDR - sdr_mixture);
                end
            end
        end
    end
    
    total_bin_lambda_5 = total_bin_lambda_5 + bin_lambda_5;
    total_bin_lambda_0 = total_bin_lambda_0 + bin_lambda_0;
    total_bin_lambda_min5 = total_bin_lambda_min5 + bin_lambda_min5;
    
    
    %% Run RPCA for different gains
    parm.lambda = 1;
    for i=1:numel(gains)
        parm.gain = gains(i);
        parm.masktype = 1; %1: binary mask, 2: no mask
        outputs5 = rpca_mask_execute(wavinmix5, parm);
        outputs0 = rpca_mask_execute(wavinmix0, parm);
        outputs_min5 = rpca_mask_execute(wavinmix_min5, parm);
        %% Run evaluation
        for ii=1:3
            if ii==1
                % SDR,SIR,SAR computation
                evaluation_results =rpca_mask_evaluation(wavinA, wavinE, outputs5);
                gain_5(i,:) = [evaluation_results.SDR, ...
                    evaluation_results.SAR, evaluation_results.SIR];
            elseif ii==2
                % SDR,SIR,SAR computation
                evaluation_results =rpca_mask_evaluation(wavinA, wavinE, outputs0);
                gain_0(i,:) = [evaluation_results.SDR, ...
                    evaluation_results.SAR, evaluation_results.SIR];
            else
                % SDR,SIR,SAR computation
                evaluation_results =rpca_mask_evaluation(wavinA, wavinE, outputs_min5);
                gain_min5(i,:) = [evaluation_results.SDR, ...
                    evaluation_results.SAR, evaluation_results.SIR];
            end
        end
    end
    
    total_gain_5 = total_gain_5 + gain_5;
    total_gain_0 = total_gain_0 + gain_0;
    total_gain_min5 = total_gain_min5 + gain_min5;
    
end

%% plotting

% bars  plots for lambda_k
figure(1);
subplot(321)
bar(total_no_lambda_5/N)
colormap(jet)
ylabel('dB')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('no mask, SNR=5,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(322)
bar(total_bin_lambda_5/N)
ylabel('dB')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('binary mask, SNR=5,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(323)
bar(total_no_lambda_0/N)
ylabel('dB')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('no mask, SNR=0,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(324)
bar(total_bin_lambda_0/N)
ylabel('dB')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('binary mask, SNR=0,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(325)
bar(total_no_lambda_min5/N)
ylabel('dB')
xlabel('k(of \lambda_k)')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('no mask, SNR=-5,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(326)
bar(total_bin_lambda_min5/N)
ylabel('dB')
xlabel('k(of \lambda_k)')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('binary mask, SNR=-5,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')


% bar  plots for gains

figure(2);
subplot(311)
bar(total_gain_5/N)
ylabel('dB')
colormap(jet)
set(gca,'XLim',[0 6],'YLim',[-15 30],'XTickLabel',gains)
title('binary mask, SNR=5,\lambda_1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(312)
bar(total_gain_0/N)
ylabel('dB')
set(gca,'XLim',[0 6],'YLim',[-15 20],'XTickLabel',gains)
title('binary mask, SNR=0,\lambda_1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(313)
bar(total_gain_min5/N)
ylabel('dB')
xlabel('gain')
set(gca,'XLim',[0 6],'YLim',[-15 10],'XTickLabel',gains)
title('binary mask, SNR=-5,\lambda_1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')


% bar  plots for GNSDR
GNSDR = [-0.51, 0.52, bin_total_NSDR_min5/no_total_weight_min5, no_total_NSDR_min5/no_total_weight_min5, 5.82
    0.91, 1.11, bin_total_NSDR_0/no_total_weight_0, no_total_NSDR_0/no_total_weight_0, 8.36
    0.17, 1.10, bin_total_NSDR_5/no_total_weight_5, no_total_NSDR_5/no_total_weight_5, 10.62];
figure(3);
bar(GNSDR)
colormap(jet)
xlabel('Voice-to-Music Ratio(dB)')
ylabel('GNSDR(dB)')
set(gca,'XLim',[0 4],'YLim',[-1 14],'XTickLabel',[-5,0,5])
legend('Hsu','Rafii','binary mask,\lambda_1,gain=1','no mask,\lambda_1,gain=1','ideal','Location','North','Orientation','horizontal')

hgexport(1,'../output/figures/lambda');
hgexport(2,'../output/figures/gain');
hgexport(3,'../output/figures/GNSDR');
