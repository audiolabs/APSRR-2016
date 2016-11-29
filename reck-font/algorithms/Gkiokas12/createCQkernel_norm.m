function [Qkernel_DFT, kernelLens] = createCQkernel_norm(bins_po, fmin, fmax, sps, window_type )

bins_n = bins_po * log2(fmax/fmin);
bins_n = round(bins_n);
freqs_ratio = 2^(1/bins_po);
Q_val = 1/(freqs_ratio-1);

bins_freqs=zeros(bins_n,1);
bins_win_len=zeros(bins_n,1);
%bins_freqs = fmin*2.^((1:bins_n)/bins_po);
for b=1:bins_n
 bins_freqs(b) = fmin*2^((b-1)/bins_po);   
 bins_win_len(b) = round(Q_val*sps/bins_freqs(b));
    
end


%Claculate the kernels

Qkernel = zeros(max(bins_win_len), bins_n);

for b=1:bins_n
    win_len = bins_win_len(b);
    window = hanning(win_len);
    exp_series = 2*pi*j*Q_val/win_len*(0:win_len-1).';
   kernel_bin = (1/win_len)*window.*exp(exp_series);
    Qkernel(1:win_len,b) = kernel_bin;
    
end



Qkernel_DFT = zeros(max(bins_win_len), bins_n);
%Qkernel_DFT = Qkernel;
kernelLens = bins_win_len;


for b=1:bins_n
   
   bin_len =  bins_win_len(b);
   Qkernel_DFT(1:bin_len,b) = fft(Qkernel(1:bin_len,b))/bin_len; 
    
end

return;

kernelLens = bins_win_len;
return;