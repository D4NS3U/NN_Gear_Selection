%Script for concatenating multiple .mat-files and build training data for NN
%development
clear;
clc;

fileList = dir('MEA_*.mat');
completeDataSet = [];
for i = 1:length(fileList)
%Load the ith file
    load(fileList(i).name);
    
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
    timeStep = 100;
    modulo = mod(length(dataSetValid), timeStep);
    modLoaded = (length(dataSetValid)-modulo)/timeStep;
    a = 1;
    k = 1;
    xTrainLoaded = cell(modLoaded-1,1);
    yTrainLoaded = cell(modLoaded-1,1);
    yTrainLoadedCategorical = cell(modLoaded-1,1);
    while k < modLoaded
        if a == 1 
            xTrainLoaded{k} = dataSetValid(a:k*timeStep,:)';
            yTrainLoaded{k} = gearShift(a:k*timeStep,:)';
            yTrainLoadedCategorical{k} = categorical(gearShift(a:k*timeStep,:)');
            a = k*timeStep; 
            k = k+1;
        else
            xTrainLoaded{k} = dataSetValid(a:k*timeStep-1,:)';
            yTrainLoaded{k} = gearShift(a:k*timeStep-1,:)';
            yTrainLoadedCategorical{k} = categorical(gearShift(a:k*timeStep-1,:)');
            a = k*timeStep; 
            k = k+1;
        end
    end
    
    if i == 1
       xTrain = xTrainLoaded;
       yTrain = yTrainLoaded;
       yTrainCat = yTrainLoadedCategorical;
    else
        xTrain = [xTrain; xTrainLoaded];
        yTrain = [yTrain; xTrainLoaded];
        yTrainCat = [yTrainCat; yTrainLoadedCategorical];
    end
end
save('OUTPUT/xTrain.mat','xTrain');
save('OUTPUT/yTrain.mat','yTrain');
save('OUTPUT/yTrainCat.mat','yTrainCat')

writecell(xTrain,'OUTPUT/xTrain.dat');
writecell(yTrain,'OUTPUT/yTrain.dat');
writecell(yTrainCat,'OUTPUT/yTrainCat.dat');

