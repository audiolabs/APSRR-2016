function [out indexes] = findPeaks(x)

len = length(x);
out = zeros(len,1);
peaks_n = 0;
for i=2:len-1
   if (x(i) > x(i-1) && x(i) > x(i+1))
       peaks_n = peaks_n+1;
       indexes(peaks_n) = i;
       peaks(peaks_n) = x(i);
       out(i) = x(i);
   end
       
end