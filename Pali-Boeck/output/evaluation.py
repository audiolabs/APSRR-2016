"""
Created on Sun Dec 18 13:51:34 2016

@author: OrnelaP
"""
import numpy as np
import madmom.evaluation.onsets
import os.path
from os import listdir
from os.path import isfile, join

onsetPath = os.path.abspath(os.path.join(os.pardir, 'Pali-Boeck/output/resultOnsets'))
annotationsPath = os.path.abspath(os.path.join(os.pardir, 'Pali-Boeck/output/annotations'))

onsetListNames = [f for f in listdir(onsetPath) if isfile(join(onsetPath, f))]
annotationsListNames = [f for f in listdir(annotationsPath) if isfile(join(annotationsPath, f))]

outFile = open(os.path.abspath(os.path.join(os.pardir, 'Pali-Boeck/output'))+'/'+'outputEval.txt', 'w+')                        

onsetEval = []

for itemOnset, itemAnnotations in zip(onsetListNames, annotationsListNames):
    outFile.write(itemOnset+ ' ' + itemAnnotations+'\n')
    #Read the onsets file first - save onsets to a np.array             
    onsetsFloat = []
    with  open(onsetPath+'/'+itemOnset) as fonsets:
            onsetList = [line.strip() for line in fonsets if line.strip()]
                         
    for item in onsetList:
        onsetsFloat.append(float(item))    
    
    onsetsArr = np.asarray(onsetsFloat)
    
    #Read the annotations file first - save annotations to a np.array
    annotationsFloat = []
    with open(annotationsPath+'/'+itemAnnotations) as fannotations:
        annotationsList = [line.strip() for line in fannotations if line.strip()]
    
    for i in annotationsList:
        annotationsFloat.append(float(i))
       
    annotationsArr = np.asarray(annotationsFloat)
    
    #Evaluation with a window = 0.025 and no delay
    print >> outFile, madmom.evaluation.onsets.OnsetEvaluation((onsetsArr), (annotationsArr), 0.025, 0.03, 0)
    
    onsetEval.append(madmom.evaluation.onsets.OnsetEvaluation((onsetsArr), (annotationsArr), 0.025, 0.03, 0))
    
    print madmom.evaluation.onsets.OnsetSumEvaluation(onsetEval)
    print madmom.evaluation.onsets.OnsetMeanEvaluation(onsetEval)
    
    fonsets.close()
    fannotations.close()
    
outFile.close()