%Script for concatenating multiple .mat-files and build training data for NN
%development
clear;
clc;

inDir = input('Enter 0 for TRAINING and 1 for TEST: ');
if inDir == 0
    fprintf('Creating Training Data in TRAINING-Directory.\n')
    fileList = dir('TRAINING/MEA_*.mat');
elseif inDir == 1
    fprintf('Creating Test Data in TEST-Directory.\n')
    fileList = dir('TEST/MEA_*.mat');
else
    fprintf('Input not accepted. Please restart!')
    return
end
for i = 1:length(fileList)
%Load the ith file
    file = [fileList(i).folder '\' fileList(i).name];
    load(file);
    
%Load the required data from the ith file
    t    = D.V(:,D.Col.ColTCAN);    %time (0.2 second steps)
    vCar = D.V(:,D.Col.ColVFZG);    %velocity
    ap   = D.V(:,D.Col.ColFP);      %acceleration pedal position
    %apg  = D.V(:,D.Col.ColFPG);    %acceleration pedal gradient
    nEng = D.V(:,D.Col.ColNMOT);    %engine revolutions
    gEar = D.V(:,D.Col.ColGANG);    %active gear

    loadedData = [ vCar ap nEng gEar ];
    dataSet = loadedData;
    %filtering dataSet for invalid gears (neutral and reverse)
    indValid = find( (gEar > 0) & (gEar < 10));
    dataSetValid = dataSet(indValid,:);
    gearShift = [0; diff(dataSetValid(:,4))];
%Transform gearShift in array with values -1, 0, 1    
    for z = 1:length(gearShift)
        if gearShift(z)<-1
            gearShift(z)=-1;
        elseif gearShift(z)>1
            gearShift(z)=1;            
        end
    end
        
    timeStep = 100;
    modulo = mod(length(dataSetValid), timeStep);
    modLoaded = (length(dataSetValid)-modulo)/timeStep;
    a = 1;
    k = 1;
    xTrainLoaded = cell(modLoaded-1,1);
    yTrainLoaded = cell(modLoaded-1,1);
    yTrainLoadedCategorical = cell(modLoaded-1,1);
    xPyLoaded = cell(modLoaded-1,1);
    yPyLoaded = cell(modLoaded-1,1);
    while k < modLoaded
        if a == 1 
            xTrainLoaded{k} = dataSetValid(a:k*timeStep,:)';
            yTrainLoaded{k} = gearShift(a:k*timeStep,:)';
            yTrainLoadedCategorical{k} = categorical(gearShift(a:k*timeStep,:)');
            xPyLoaded{k} = dataSetValid(a:k*timeStep,:);
            yPyLoaded{k} = gearShift(a:k*timeStep,:);
            a = k*timeStep; 
            k = k+1;
        else
            xTrainLoaded{k} = dataSetValid(a:k*timeStep-1,:)';
            yTrainLoaded{k} = gearShift(a:k*timeStep-1,:)';
            yTrainLoadedCategorical{k} = categorical(gearShift(a:k*timeStep-1,:)');
            xPyLoaded{k} = dataSetValid(a:k*timeStep-1,:);
            yPyLoaded{k} = gearShift(a:k*timeStep-1,:);
            a = k*timeStep; 
            k = k+1;
        end
    end
    
    if i == 1
       xTrain = xTrainLoaded;
       yTrain = yTrainLoaded;
       yTrainCat = yTrainLoadedCategorical;
       xPy = xPyLoaded;
       yPy = yPyLoaded;
    else
        xTrain = [xTrain; xTrainLoaded];
        yTrain = [yTrain; xTrainLoaded];
        yTrainCat = [yTrainCat; yTrainLoadedCategorical];
        xPy = [xPy; xPyLoaded];
        yPy = [yPy; yPyLoaded];
    end
end
if inDir == 0

    save('TRAINING/OUTPUT/xTrain.mat','xTrain');
    save('TRAINING/OUTPUT/yTrain.mat','yTrain');
    save('TRAINING/OUTPUT/yTrainCat.mat','yTrainCat')
    save('TRAINING/OUTPUT/xPy.mat','xPy')
    save('TRAINING/OUTPUT/yPy.mat','yPy')

    writecell(xTrain,'TRAINING/OUTPUT/xTrain.dat');
    writecell(yTrain,'TRAINING/OUTPUT/yTrain.dat');
    writecell(yTrainCat,'TRAINING/OUTPUT/yTrainCat.dat');
    fprintf('Training Data Saved in "CURRENT FOLDER/TRAINING/OUTPUT"!')
elseif inDir == 1
    
    save('TEST/OUTPUT/xTest.mat','xTrain');
    save('TEST/OUTPUT/yTest.mat','yTrain');
    save('TEST/OUTPUT/yTestCat.mat','yTrainCat')
    save('TEST/OUTPUT/xPy.mat','xPy')
    save('TEST/OUTPUT/yPy.mat','yPy')

    writecell(xTrain,'TEST/OUTPUT/xTest.dat');
    writecell(yTrain,'TEST/OUTPUT/yTest.dat');
    writecell(yTrainCat,'TEST/OUTPUT/yTestCat.dat');
    fprintf('Test Data Saved in "CURRENT FOLDER/TEST/OUTPUT"!')
end
