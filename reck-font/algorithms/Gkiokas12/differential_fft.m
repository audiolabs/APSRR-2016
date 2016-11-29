function  [freq_response] = differential_fft(order, response_len)

%returns the frequency response of the differential filter with
%coefficients "coeff" calculated below
if mod(order,2)==0
    order=order+1;
end
h_ord=(order-1)/2;

coeff=h_ord:-1:-h_ord;
coeff=coeff(:);
coeff=coeff/sum(abs(coeff)); 
freq_response = freqz(coeff,1,response_len, 'whole');