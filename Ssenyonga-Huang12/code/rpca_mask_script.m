% ---------------------------------------------------------------------------------------------------------------
% This is an edit of the example code for running the RPCA for source separation
% P.-S. Huang, S. D. Chen, P. Smaragdis, M. Hasegawa-Johnson,
% "Singing-Voice Separation From Monaural Recordings Using Robust Principal Component Analysis," in ICASSP 2012
%
% Original version written by Po-Sen Huang @ UIUC
% Edited and extended by Robin Ssenyonga
% For any questions on the original version, please email huang146@illinois.edu.
% For any questions on the extended version, please email robin.ssenyonga@fau.de.

% ---------------------------------------------------------------------------------------------------------------
%% addpath
clear all; close all;
set(0,'DefaultFigureWindowStyle','docked','DefaultAxesFontSize',14)
addpath('bss_eval');
addpath(genpath('example'));
addpath(genpath('inexact_alm_rpca'));

%% Global Parameters
parm.nFFT = 1024;
parm.windowsize = 1024;
parm.power = 1;
parm.masktype = 2; %1: binary mask, 2: no mask

%% For use when ruuning the extended demo version

lambda = [0.1, 0.5, 1, 1.5, 2, 2.5];
gains = [0.1, 0.5, 1, 1.5, 2];

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

%% Loop for all files
files = dir(['example/used_data','/*_music.wav']);
for count = 1:numel(files)
    filename = files(count).name(1:end-10);
    
    [wavinmix5, ~] = audioread([filename,'_SNR5.wav']);
    [wavinmix0, ~] = audioread([filename,'_SNR0.wav']);
    [wavinmix_min5, fs] = audioread([filename,'_SNRmin5.wav']);
    wavinA = audioread([filename, '_music.wav']);  % Load groundtruth music files
    wavinE = audioread([filename, '_vocal.wav']);  % Load groundtruth vocal files
    parm.outname = ['example', filesep, 'output', filesep, filename];
    parm.gain = 1;
    parm.fs = fs;
        
    %% Run RPCA for different lambdas
    
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

plotting
