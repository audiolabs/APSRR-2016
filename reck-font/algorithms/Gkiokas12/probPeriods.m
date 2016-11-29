function [beat_tempo] = probPeriods(periodicity_vector,conditionals)
%%Implements the Metrical Analysis Heuristic described in ICASSP2012 paper

max_tempo = 500;
min_tempo = 30;



%%comb filters to the partials
comb_periods = zeros(500,500);

fundamental_tempo = zeros(500,1);

%%% Calculates "Fundamental" Tempo i.e. the lowest tempo that its partials
%%% are strongest
for t=min_tempo:max_tempo
    index = 0;
    counter=0;
   while(1)
       index = index+t;
       counter=counter+1;
       %% up to 4 partials. Fundamental tempo is biased towards lowest
       %% values
       if(index>max_tempo || counter>4)
           break;
       end
       comb_periods(index,t)=1;
   end
    fundamental_tempo(t) = comb_periods(:,t)'*periodicity_vector/sum(comb_periods(:,t));
    fundamental_tempo(t) = comb_periods(:,t)'*periodicity_vector;
   
end

%conditional_probs(t1,t2) : periodicity vector weighting of t2 given t1 is
%the true tempo (precalculated: see ICASSP paper)
conditional_probs=conditionals;


[dummy period_peaks] = findPeaks(periodicity_vector);


[dummy fund_tempo] = max(fundamental_tempo);

%%Caldidate tempi should be a partial of the fundamental
candidate_tempos = (1:10)*fund_tempo;
%smaller than 500 bmp
in_range = find(candidate_tempos<max_tempo);

candidate_tempos = candidate_tempos(in_range);

%%Align candidate tempi to peaks in the periodicity function
for t=1:length(candidate_tempos)
   tempo =  candidate_tempos(t);
   dummy = tempo-period_peaks;
   [dummy idx] = min(abs(dummy));
   candidate_tempos(t) = period_peaks(idx);
end


temps_n = length(candidate_tempos);

tempo_combinations = zeros(temps_n);
max_val=-Inf;
tempos = [0 0];
%calculate joint tempo salience of all candidate combinations
for t=1:temps_n
    for t1=t+1:temps_n
       tempo_combinations(t,t1) = tempo_combinations(t,t1)+(periodicity_vector(candidate_tempos(t))+periodicity_vector(candidate_tempos(t1)))*conditional_probs(candidate_tempos(t1),candidate_tempos(t));
        if tempo_combinations(t,t1)>max_val
            max_val=tempo_combinations(t,t1);
            tempos = candidate_tempos([t t1]);
        end
    end
end

beat_tempo=tempos(1);


return;


 