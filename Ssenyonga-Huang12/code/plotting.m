% bars  plots for lambda_k
num = numel(files);
figure;
subplot(321)
bar(total_no_lambda_5/num)
colormap(jet)
ylabel('dB')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('no mask, SNR=5,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(322)
bar(total_bin_lambda_5/num)
ylabel('dB')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('binary mask, SNR=5,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(323)
bar(total_no_lambda_0/num)
ylabel('dB')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('no mask, SNR=0,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(324)
bar(total_bin_lambda_0/num)
ylabel('dB')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('binary mask, SNR=0,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(325)
bar(total_no_lambda_min5/num)
ylabel('dB')
xlabel('k(of \lambda_k)')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('no mask, SNR=-5,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(326)
bar(total_bin_lambda_min5/num)
ylabel('dB')
xlabel('k(of \lambda_k)')
set(gca,'XLim',[0 7],'YLim',[-15 35],'XTickLabel',lambda)
title('binary mask, SNR=-5,gain=1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')


% bar  plots for gains

figure;
subplot(311)
bar(total_gain_5/num)
ylabel('dB')
colormap(jet)
set(gca,'XLim',[0 6],'YLim',[-15 30],'XTickLabel',gains)
title('binary mask, SNR=5,\lambda_1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(312)
bar(total_gain_0/num)
ylabel('dB')
set(gca,'XLim',[0 6],'YLim',[-15 20],'XTickLabel',gains)
title('binary mask, SNR=0,\lambda_1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')
legend HIDE
subplot(313)
bar(total_gain_min5/num)
ylabel('dB')
xlabel('gain')
set(gca,'XLim',[0 6],'YLim',[-15 10],'XTickLabel',gains)
title('binary mask, SNR=-5,\lambda_1','FontWeight','normal')
legend('SDR','SAR','SIR','Location','BestOutside','Orientation','horizontal')


% bar  plots for GNSDR
GNSDR = [-0.51, 0.52, bin_total_NSDR_min5/no_total_weight_min5, no_total_NSDR_min5/no_total_weight_min5, 5.82
    0.91, 1.11, bin_total_NSDR_0/no_total_weight_0, no_total_NSDR_0/no_total_weight_0, 8.36
    0.17, 1.10, bin_total_NSDR_5/no_total_weight_5, no_total_NSDR_5/no_total_weight_5, 10.62];
figure;
bar(GNSDR)
colormap(jet)
xlabel('Voice-to-Music Ratio(dB)')
ylabel('GNSDR(dB)')
set(gca,'XLim',[0 4],'YLim',[-1 14],'XTickLabel',[-5,0,5])
legend('Hsu','Rafii','binary mask,\lambda_1,gain=1','no mask,\lambda_1,gain=1','ideal','Location','North','Orientation','horizontal')

