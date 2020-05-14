%Script for generating a sequence of ~5 seconds with one gear change at the end of the sequence from available data
clear;
clc;

fileList = dir('MEA_*.mat');
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

    dataSet = [ vCar ap nEng gEar ];
%filtering dataSet for invalid gears (neutral and reverse)
    indValid = find( (gEar > 0) & (gEar < 10));
    dataSetValid = dataSet(indValid,:);
    gearShift = [0; diff(dataSetValid(:,4))];
    timeStep = 249;                 %Timestep of 249 equals to roughly 5 seconds
    a = 0;
    for k = 1:length(gearShift)
       if gearShift(k, :) ~= 0
           a = a + 1;
       end
    end
    xTrainLoaded = cell(a,1);
    yTrainLoaded = cell(a,1);
    b=1;
    for k = 1:length(gearShift)
        if gearShift(k, :) ~= 0
            if k<250
                continue
            end
            xTrainLoaded{b} = dataSetValid(k-249:k,:);
            yTrainLoaded{b} = gearShift(k-249:k,:);
            b = b + 1;
        end
    end
    
    if i == 1
       xTrainSeq = xTrainLoaded;
       yTrainSeq = yTrainLoaded;
    else
        xTrainSeq = [xTrainSeq; xTrainLoaded];
        yTrainSeq = [yTrainSeq; xTrainLoaded];
    end
end
save('OUTPUT/xTrainSeq.mat','xTrainSeq');
save('OUTPUT/yTrainSeq.mat','yTrainSeq');

writecell(xTrainSeq,'OUTPUT/xTrainSeq.dat');
writecell(yTrainSeq,'OUTPUT/yTrainSeq.dat');

