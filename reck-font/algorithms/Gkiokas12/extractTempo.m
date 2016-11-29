function extractTempo(InFile)

pkg load image
pkg load signal

%fprintf(1,'************************************************************\n');
%fprintf(1,'***************');
%fprintf(1,'%s ',InFile);
%fprintf(1,' STARTS **************************\n');
%fprintf(1,'************************************************************\n\n\n');

conditional_probs = load('conditional_probs');
conditional_probs=conditional_probs.conditional_probs;
fr = 200;         %  frame rate
q_val = 8;  % comes as parameter now (default 8)


%TEATURE EXTRACTION

%fprintf(1,'Extracting Features..\n');

[filterbanks chromas] = HarmPercSepMedian(InFile,fr);



%Extract Tempo Scores from filterbanks

%fprintf(1, 'Calculating periodicities for filterbank features');
filterbankTempoScores = getTempoNewConstantQ(filterbanks, fr, q_val);

%fprintf(1, '\nDone\nCalculating periodicities for tonal features');
%Extract Tempo Scores from Tonals
chromaTempoScores = getTempoNewConstantQ(chromas, fr, q_val);
%fprintf(1, '\nDone\n');

%SuperPosition
tempoScores = filterbankTempoScores.*chromaTempoScores;


tempo= probPeriods(tempoScores,conditional_probs);

% show tempo on screen
tempo









