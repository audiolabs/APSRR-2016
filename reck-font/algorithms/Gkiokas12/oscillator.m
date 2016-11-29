function [out] = oscillator(freq, gamma, win_len, der, norm)

if (norm ==0)
    x = gamma*(sin(freq*(1:win_len))-1);%/freq;
else
    x = gamma*(cos(freq*(1:win_len))-1)/freq;
end
    
o = 1+tanh(x);

%x = cos(2*freq*(1:win_len))-1;
%o2 = 1+tanh(x);

%x = cos(4*freq*(1:win_len))-1;
%o3 = 1+tanh(x);

if(der == 0)
%out = o+o2+o3;
%return;
    out = o;
    return;
else
    enum = gamma*freq*cos(freq*(1:win_len));
    enum2 = sech(x).*sech(x);
    dem = cosh(x).*cosh(x);
    out = enum.*enum2;
   % out = enum./dem;
    return;
end


dem = cosh(x).*cosh(x);
enum = freq*cos(freq*(1:win_len));
out = enum./dem;

%return;
dem2 = (exp(2*x)+1).*(exp(2*x)+1);
enum2 = sech(x).*sech(x);
out = enum./dem2;
return;
