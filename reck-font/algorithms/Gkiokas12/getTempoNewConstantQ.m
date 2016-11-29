function [sum_of_scores final_scores] = getTempoNewConstantQ(signal, fr, Q_val)


input_dim = length(signal(1,:));

sig_len = length(signal);


%initializations
min_tempo = 30;
max_tempo = 500;

f_counter = 0;                  % current frame counter

sps = fr;

%fft_len=2*fft_len;

norms_ref=zeros(max_tempo,1);


refSignals = zeros(max_tempo, sig_len);
%Create Ref Signals



for t=min_tempo:max_tempo
    
    omega = 2*pi*t/(60*sps);

    period = 60*fr/t;
    osc_len = round(Q_val*period);

    y = oscillator(omega, 8, osc_len,0, 0);
    fft_osc = fft(y, sig_len).';

    
    diff_order = double(int32((20-0.019*(t-20))*sps/200));
    diff_fft = differential_fft(diff_order,sig_len);
%    refSignals(t,:) = fft_osc.*diff_fft/(norm(diff_fft)*norm(fft_osc));
    refSignals(t,:) = fft_osc.*diff_fft/osc_len;%(norm(diff_fft)*norm(fft_osc));

 
end

sig_ffts = zeros(sig_len, input_dim);
for i=1:input_dim
   sig_ffts(:,i) = fft(signal(:,i)); 
    
end



%Windowing Analysis

max_frames = 0;
frames = zeros(max_tempo,1);
for t=min_tempo:max_tempo

    period = 60*fr/t;
    win_len = round(Q_val*period);
    win_step = round(win_len/4);
    

    for i=1:input_dim
        f_counter = 0;
        index = 1;
        response = ifft(sig_ffts(:,i).*refSignals(t,:).');
        while(index+win_len<sig_len)
            f_counter=f_counter+1;
           win = response(index:index+win_len);
           scores(t,f_counter,i) = max(abs(win));
      %     scores(t,f_counter,i) = norm(win);          
           
          index = index + win_step;          
       end
    end
    max_frames = f_counter;    
    frames(t)=f_counter;
    
    
end
ids = find(frames==0);
frames(ids) = 1;
final_scores = zeros(max_tempo, max_frames);

for t=min_tempo:max_tempo
   for f=1:frames(t)
      final_scores(t,f) = sum(scores(t,f,:)); 
       
   end   
   x = imresize(final_scores(t,1:frames(t)), [1 max_frames], 'bicubic');
   final_scores(t,:) = x;
end



sum_of_scores = zeros(max_tempo,1);
for t=min_tempo:max_tempo
   sum_of_scores(t) = sum(final_scores(t,:)); 

end


return;







