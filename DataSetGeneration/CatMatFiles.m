%Script for concatenating multiple .mat-files and buil training data for NN
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

    loadedData = [ t vCar ap nEng gEar ];
    dataSet = loadedData;
    %filtering dataSet for invalid gears (neutral and reverse)
    indValid = find( (gEar > 0) & (gEar < 10));
    dataSetValid = dataSet(indValid,:);
    gearShift = [0; diff(dataSetValid(:,5))];
    timeStep = 10000;
    modulo = mod(length(dataSetValid), timeStep);
    modLoaded = (length(dataSetValid)-modulo)/timeStep;
    a = 1;
    k = 1;
    xTrainLoaded = cell(1, modLoaded);
    yTrainLoaded = cell(1, modLoaded);
    while k < modLoaded
        xTrainLoaded{k} = dataSetValid(a:k*timeStep,:);
        yTrainLoaded{k} = gearShift(a:k*timeStep,:);
        a = k*timeStep; 
        k = k+1;
    end
    
    if i == 1
       xTrain = xTrainLoaded;
       yTrain = yTrainLoaded;
    else
        xTrain = [xTrain, xTrainLoaded];
        yTrain = [yTrain, xTrainLoaded];
    end
end
save('OUTPUT/xTrain.mat','xTrain');
save('OUTPUT/yTrain.mat','yTrain');

