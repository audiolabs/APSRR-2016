function my_spectrogram(d,type, f, w, h, sr)
%MY_SPECTROGRAM Summary of this function goes here
%   Detailed explanation goes here
if nargin < 3;  f = 256; end
if nargin < 4;  w = f; end
if nargin < 5;  h = 0; end
if nargin < 6;  sr = 16000; end

if length(w) == 1
  if w == 0
    % special case: rectangular window
    win = ones(1,f);
  else
    if rem(w, 2) == 0   % force window to be odd-len
      w = w + 1;
    end
    halflen = (w-1)/2;
    halff = f/2;   % midpoint of win
    halfwin = 0.5 * ( 1 + cos( pi * (0:halflen)/halflen));
    win = zeros(1, f);
    acthalflen = min(halff, halflen);
    win((halff+1):(halff+acthalflen)) = halfwin(1:acthalflen);
    win((halff+1):-1:(halff-acthalflen+2)) = halfwin(1:acthalflen);
  end
else
  win = w;
end

w = length(win);
% now can set default hop
if h == 0
  h = floor(w/2);
end

figure
tt = [0:size(d,2)]*h/sr;
ff = [0:size(d,1)]*sr/f;
imagesc(tt,ff,20*log10(abs(d)));
axis('xy');
xlabel('Time');
ylabel('Frequency (Hz)')
if type
    title('Sparse Matrix S','FontSize',14)
else
    title('Low-Rank Matrix L','FontSize',14)
end
colormap(jet)

end

