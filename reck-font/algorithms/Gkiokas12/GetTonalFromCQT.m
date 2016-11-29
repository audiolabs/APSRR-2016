function chromas = GetTonalFromCQT(Qtransform)

len = length(Qtransform(:,1));

bins_n = length(Qtransform(1,:));
feat_vector = zeros(len,12);

for t=1:12      %for each tone
    bin_counter = 0;
    index = t;
    while(1)
        if (index>= bins_n)
            break;
        end
        feat_vector(:,t) = feat_vector(:,t) + abs(Qtransform(:,index));
        bin_counter = bin_counter+1;
        
        index = index+12;


        
    end
       
end

z = isnan(feat_vector);
feat_vector(z) = 0;
z = isinf(feat_vector);
feat_vector(z) = 0;
chromas = feat_vector;
