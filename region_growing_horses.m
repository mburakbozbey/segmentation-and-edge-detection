
horses = imread('...\Berkeley_horses.jpg');
groundTruth = load('...\berkeley_horses.mat');
I = im2double(horses);

% Define region growing params
maxDistance = 61.5/255;
eightNeighbors = [ -1,-1; 
                    0,-1; 
                    1,-1; 
                    -1,0; 
                     1,0; 
                    -1,1; 
                     0,1; 
                    1,1];
imshow(I);

% Select two pixels one horses
[ySeed, xSeed] = ginput(2); ySeed = round(ySeed); xSeed = round(xSeed);
imSize = size(I);
J = zeros(imSize(1),imSize(2));

for k=1:length(xSeed)
    % Initalize
    pixDist = 0; 
    x = xSeed(k);
    y = ySeed(k);    maxLength = 10000; 
    newPix = 0;
    neighborsList = zeros(maxLength,5); 
    regMean = squeeze(I(xSeed(k),ySeed(k),:))'; 
    regSize = 1; 
    
    while(pixDist < maxDistance)
        for j=1:8
            newX = x + eightNeighbors(j,1); 
            newY = y + eightNeighbors(j,2);
            
            checkFlag = (newX >= 1)&&( newY >=1)&&(newX <=imSize(1))&&(newY <=imSize(2));
            if(checkFlag&&(J(newX,newY)==0)) 
                    newPix = newPix+1;
                    neighborsList(newPix,:) = [newX newY squeeze(I(newX,newY,:))']; J(newX,newY)=-1;
            end
        end
        % If all neighbors are labeled, break loop
        if newPix ==0
            break
        
        else
            dist = sqrt(sum(abs(neighborsList(1:newPix,3:5) - regMean.*ones(newPix,3)).^2,2));
            [pixDist index] = min(dist);
            J(x,y) = k + 1; 
            regSize=regSize+1;
            regMean = (double(regMean).*regSize + neighborsList(index,3:5))./(regSize+1);
            x = neighborsList(index,1); y = neighborsList(index,2);
            neighborsList(index,:)=neighborsList(newPix,:); newPix=newPix-1;
        end
    end
end


J(J==-1) = 1;
J(J==0) = 1;
figure, imshow(uint8(J.*60));

% Merge ground truth segmentation maps to 3 regions
groundTruth = groundTruth.groundTruth;  
groundtruth1 = groundTruth{1,1}.Segmentation;
groundtruth2 = groundTruth{1,2}.Segmentation;
groundtruth2(groundtruth2==5) = 3;
groundtruth3 = groundTruth{1,3}.Segmentation;
groundtruth3(groundtruth3==4) = 3;
groundtruth4 = groundTruth{1,4}.Segmentation;
groundtruth4(groundtruth3==4) = 3;
groundtruth5 = groundTruth{1,5}.Segmentation;
groundtruth5(groundtruth5==5) = 2;
groundtruth5(groundtruth5==10) = 3;
groundtruth6 = groundTruth{1,6}.Segmentation;
groundtruth5(groundtruth5==4) = 3;
groundtruth_ = zeros(321,481,6);
groundtruth_(:,:,1) = groundtruth1;
groundtruth_(:,:,2) = groundtruth2;
groundtruth_(:,:,3) = groundtruth3;
groundtruth_(:,:,4) = groundtruth4;
groundtruth_(:,:,5) = groundtruth5;
groundtruth_(:,:,6) = groundtruth6;

% Calculate IoU Scores
for k=1:6
    groundtruth = groundtruth_(:,:,k);
    match1 = 0;
    dismatch1 = 0;
    match2 = 0;
    dismatch2 = 0;
    match3 = 0;
    dismatch3 = 0;

    for i=1:321
        for j=1:481
           if groundtruth(i,j)==1&&J(i,j)==1
               match1 = match1+1;
           elseif groundtruth(i,j)==2&&J(i,j)==2
               match2 = match2+1;
          elseif groundtruth(i,j)==3&&J(i,j)==3
               match3 = match3+1;
           end
        end
    end
    disp(k);
    IoU1 = match1/(-match1+length(groundtruth(groundtruth==1))+length(J(J==1)));
    IoU2 = match2/(-match2+length(groundtruth(groundtruth==2))+length(J(J==2)));
    IoU3 = match3/(-match3+length(groundtruth(groundtruth==3))+length(J(J==3)));
    disp(IoU1);disp(IoU2);disp(IoU3);
end


