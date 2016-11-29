function [mfccs tonals] = HarmPercSepMedian(fn,fr)


[x Fs] = wavread(fn);
x = filter([1 -0.97], 1, x);   
[Qkernel_DFT, kernelLens] = createCQkernel_norm(12, 25, 5000, Fs);
[Qtransform, bin_samples] = CQT(x, Qkernel_DFT, kernelLens, 1);


new_len = round(length(x)/Fs*fr);
normQT = normalizeQT2(Qtransform, bin_samples, new_len);


gamma = 0.6;
W = abs(normQT).^(2*gamma);
n = length(W(:,1));
m = length(W(1,:));
P = zeros(n,m);
H = zeros(n,m);

for t=1:n
    P(t,:) = medfilt1(W(t,:),10);
    
end

for h=1:m
    H(:,h) = medfilt1(W(:,h),10);
end

%Masking

Mh = H.^2./(H.^2+P.^2);
Mp = P.^2./(H.^2+P.^2);
z = isnan(Mh);
Mh(z)=0;
z = isnan(Mp);
Mp(z)=0;


H = W.*Mh;
P = W.*Mp;



tonals = GetTonalFromCQT(H);
mfccs = GetMfccFromCQT(P,8);



end