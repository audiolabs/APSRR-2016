function mfccs = GetMfccFromCQT(Qtransform, mfcc_n)


len = length(Qtransform(:,1));
%len2 = length(Qtransform2(:,1));
bins_n = length(Qtransform(1,:));
bins_per_mfc = round(bins_n/mfcc_n);
feat_vector = zeros(len,12);
cent_space = round(bins_n/mfcc_n);
centers = [];
range_start = [];
range_stop = [];
cen_edges = round(linspace(1,bins_n, mfcc_n+2));
centers = cen_edges(2:mfcc_n+1);
range_start(1) = cen_edges(1);
range_stop(mfcc_n) = cen_edges(mfcc_n+2);
for m=1:mfcc_n
    range_start(m) = cen_edges(m);
    range_stop(m) = cen_edges(m+2);
end
mfcc_masks = zeros(bins_n, mfcc_n);


    
 
    
    

for m=1:mfcc_n      %for each mel
    bin_counter = 0;
    center = centers(m);
    %up step

    klisi = 1/(centers(m)-range_start(m));
    dc = -klisi*range_start(m);
    for j=range_start(m):centers(m);
        mfcc_masks(j,m)=klisi*j+dc; 
    end
    %down step
    klisi = 1/(centers(m)-range_stop(m));
    dc = -klisi*range_stop(m);
    for j=centers(m):range_stop(m)
        mfcc_masks(j,m)=klisi*j+dc; 
    end

       
end



mfccs = log10(Qtransform*mfcc_masks);
z = isnan(mfccs);
mfccs(z) = 0;
z = isinf(mfccs);
mfccs(z) = 0;



