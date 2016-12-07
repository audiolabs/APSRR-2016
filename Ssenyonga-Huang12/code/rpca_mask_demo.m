% This is an edit of the example code for running the RPCA for source separation
% P.-S. Huang, S. D. Chen, P. Smaragdis, M. Hasegawa-Johnson,
% "Singing-Voice Separation From Monaural Recordings Using Robust Principal Component Analysis," in ICASSP 2012
%
% Original version written by Po-Sen Huang @ UIUC
% Edited and extended by Robin Ssenyonga
% For any questions on the original version, please email huang146@illinois.edu.

%% addpath
clear all; close all;
set(0,'DefaultFigureWindowStyle','docked','DefaultAxesFontSize',14)
addpath('bss_eval');
addpath('example');
addpath(genpath('inexact_alm_rpca'));
%% Global Parameters
filename = 'yifen_2_01'; % Generate the spectogram as in paper using RPCA
[wavinmix, fs] = audioread('yifen_2_01_SNR5.wav');

% In order to check the spectrograms as in the paper, enable this plotting
% in stft.m and rpca_mask_execute.m

parm.outname = ['example', filesep, 'output', filesep, filename];
parm.nFFT = 1024;
parm.windowsize = 1024;
parm.power = 1;
parm.fs = fs;
parm.masktype = 2; %1: binary mask, 2: no mask
parm.lambda = 1;
parm.gain = 1;
outputs = rpca_mask_execute(wavinmix, parm);

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

