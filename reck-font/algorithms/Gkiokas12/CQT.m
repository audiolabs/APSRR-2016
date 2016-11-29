function [Qtransform, bin_samples] = CQT(signal, kernel, kernel_lens, verbose)

if (verbose ==1)
   %fprintf(1,'\nStarting CQT..\n');
end
len = length(signal);

bins_n = length(kernel(1,:));

%apply the tranform for all bins and corresponding window
min_kernel_len = min(kernel_lens);
max_segments_n = round(2*len/min_kernel_len+1);
Qtransform = zeros(max_segments_n,bins_n);

bin_samples = zeros(bins_n,1);    % num of segment per bin
for b=1:bins_n
    
    index=1;
    segments_n=0;
    seg_len = kernel_lens(b);
    seg_step = round(seg_len/2);    %half Window Overlap

    bin_kernel = kernel(1:seg_len,b)';
    while(1)
       if (index > len - seg_len)
           break;
       end 
       segments_n=segments_n+1;
       seg = signal(index:index+seg_len-1);
       fft_seg = fft(seg,seg_len);
       val = bin_kernel*fft_seg;
       Qtransform(segments_n,b) = abs(val);
       index = index + seg_step;
    end
   
    bin_samples(b) = segments_n;
    if (verbose ==1)
        %fprintf(1,'.');
    end
end
if (verbose ==1)
   %fprintf(1,'\nCQT Finished..\n');
end


return;