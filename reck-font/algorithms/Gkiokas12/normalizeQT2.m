function normQT = normalizeQT2(Qtransform, bin_samples, size)


total_bins = length(bin_samples);
total_tone_segments = size;
normQT = zeros(total_tone_segments,total_bins);

for b=1:total_bins
            
    bin_ev = Qtransform(1:bin_samples(b),b);
    temp = imresize(bin_ev,[size 1],'bicubic');
    normQT(:,b) = temp;
    
    
end

return;