%Script for generating a sequence of ~5 seconds with one gear change at the end of the sequence from available data
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

    dataSet = [ vCar ap nEng gEar ];
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
    timeStep = 249;                 %Timestep of 249 + 1 equals to 5 seconds
    a = 0;
    for k = 1:length(gearShift)
       if gearShift(k, :) ~= 0
           if k<250
                continue
           end
           a = a + 1;
       end
    end
    xTrainLoaded = cell(a,1);
    yTrainLoaded = cell(a,1);
    yTrainLoadedCategorical = cell(a,1);
    yTrainLOneCat = cell(a,1);
    xPyLoaded = cell(a,1);
    yPyLoaded = cell(a,1);
    b = 1;
    for k = 1:length(gearShift)
        if gearShift(k, :) ~= 0
            if k<250
                continue
            end
            xTrainLoaded{b} = dataSetValid(k-249:k,:)';
            yTrainLoaded{b} = gearShift(k-249:k,:)';
            yTrainLoadedCategorical{b} = categorical(gearShift(k-249:k,:)');
            yTrainLOneCat{b} = categorical(gearShift(k,:));
            xPyLoaded{k} = dataSetValid(k-249:k,:);
            yPyLoaded{k} = gearShift(k-248:k,:);
            b = b + 1;
        end
    end
    
    if i == 1
       xTrainSeq = xTrainLoaded;
       yTrainSeq = yTrainLoaded;
       yTrainSeqCat = yTrainLoadedCategorical;
       yTrainOneCat = yTrainLOneCat;
       xPySeq = xPyLoaded;
       yPySeq = yPyLoaded;
    else
        xTrainSeq = [xTrainSeq; xTrainLoaded];
        yTrainSeq = [yTrainSeq; xTrainLoaded];
        yTrainSeqCat = [yTrainSeqCat; yTrainLoadedCategorical];
        yTrainOneCat = [yTrainOneCat; yTrainLOneCat];
        xPySeq = [xPySeq; xPyLoaded];
        yPySeq = [yPySeq; yPyLoaded];
    end
end
if inDir == 0

    save('TRAINING/OUTPUT/xTrainSeq.mat','xTrainSeq');
    save('TRAINING/OUTPUT/yTrainSeq.mat','yTrainSeq');
    save('TRAINING/OUTPUT/yTrainSeqCat.mat','yTrainSeqCat')
    save('TRAINING/OUTPUT/yTrainSeqOneCat.mat','yTrainOneCat')
    save('TRAINING/OUTPUT/xPySeq.mat','xPySeq')
    save('TRAINING/OUTPUT/yPySeq.mat','yPySeq')

    writecell(xTrainSeq,'TRAINING/OUTPUT/xTrainSeq.dat');
    writecell(yTrainSeq,'TRAINING/OUTPUT/yTrainSeq.dat');
    writecell(yTrainSeqCat,'TRAINING/OUTPUT/yTrainSeqCat.dat');
    writecell(yTrainOneCat,'TRAINING/OUTPUT/yTrainSeqOneCat.dat');
    
    fprintf('Training Data Saved in "CURRENT FOLDER/TRAINING/OUTPUT"!')
elseif inDir == 1
    
    save('TEST/OUTPUT/xTestSeq.mat','xTrainSeq');
    save('TEST/OUTPUT/yTestSeq.mat','yTrainSeq');
    save('TEST/OUTPUT/yTestCat.mat','yTrainSeqCat')
    save('TEST/OUTPUT/yTrainSeqOneCat.mat','yTrainOneCat')
    save('TEST/OUTPUT/xPySeq.mat','xPySeq')
    save('TEST/OUTPUT/yPySeq.mat','yPySeq')

    writecell(xTrainSeq,'TEST/OUTPUT/xTestSeq.dat');
    writecell(yTrainSeq,'TEST/OUTPUT/yTestSeq.dat');
    writecell(yTrainSeqCat,'TEST/OUTPUT/yTestSeqCat.dat');
    writecell(yTrainOneCat,'TEST/OUTPUT/yTrainSeqOneCat.dat');
    
    fprintf('TEST Data Saved in "CURRENT FOLDER/TEST/OUTPUT"!')
end
