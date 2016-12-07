addpath('example/used_data');

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
