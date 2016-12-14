 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% download.m
%
% All the neccessary files for reproduction of the paper:
% "Repeating Pattern Extraction Technique (REPET): a simple method for voice/source separation"
% by Zafar Rafii & Bryan Pardo
% 
% Programmed by: Arjola Hysneli
% Audio Processing Seminar WS 2016/2017
% FAU Erlangen-Nuernberg/AudioLabs Erlangen
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc;

%% Download dataset
options = weboptions('Timeout',Inf);

%% Download REPET and the evaluation toolbox
bss_eval= websave('./bss_eval.m','http://bass-db.gforge.inria.fr/bss_eval/bss_eval_sources.m')








