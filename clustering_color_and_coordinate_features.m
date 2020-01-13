close all;clc;clear all;

starImg = imread('...\12003.jpg');
gztImg = imread('...\HW_Segmen_Image_Gazete.bmp');
pcbImg = imread('...\PCB.BMP');

% Image histograms to find number of k:
I{1} = starImg;
I{2} = gztImg;
I{3} = pcbImg;

% Neighbors for star,gzt and pcb:
nk(1)=32;nk(2)=32;nk(3)=32;

for imagN=1:3
    J = im2double(I{imagN}); 
    imgSize = size(J);% 
    % If RGB image, reshape differently
    if imagN==1
        feats = zeros(length(J(:))/3,5);
        feats(:,1:3) = reshape(J(:),[length(J(:))/3,3]);  
        xCorr = 1:imgSize(1);
        feats(:,4) = repmat(xCorr',length(feats(:,1))/length(xCorr),1);  
        xCorr = 1:imgSize(2);
        yCorr = repmat(xCorr,length(feats(:,1))/length(xCorr),1);
        feats(:,5) = yCorr(:);  
    else
        feats = zeros(length(J(:)),3);
        feats(:,1) = J(:);
        xCorr = 1:imgSize(1);
        feats(:,2) = repmat(xCorr',length(feats(:,1))/length(xCorr),1);  
        xCorr = 1:imgSize(2);
        yCorr = repmat(xCorr,length(feats(:,1))/length(xCorr),1);
        feats(:,3) = yCorr(:);  
    end
    
    k     = nk(imagN);
    centers = feats( round(rand(k,1)*size(feats,1)) ,:);             
    eucDist   = zeros(size(feats,1),k+2);                         
    iterN   = 10;                    
    b = .9; % K-means Iteration
    
    % Add weights to feature to create more plausible results
    weights = [b/3 b/3 b/3 (1-b)/2 (1-b)/2];
    for n = 1:iterN
       for i = 1:size(feats,1)
          for j = 1:k  
            eucDist(i,j) = norm((feats(i,:) - centers(j,:)));      
          end
          [dist indices] = min(eucDist(i,1:k));             
          eucDist(i,k+1) = indices;                               
          eucDist(i,k+2) = dist;                         
       end
       for i = 1:k
          xCorr = (eucDist(:,k+1) == i);                         
          centers(i,:) = mean(feats(xCorr,:));  
          %If feature is nan
          if sum(isnan(centers(:))) ~= 0                    
             ind = find(isnan(centers(:,1)) == 1);          
             for Ind = 1:size(ind,1)
                centers(ind(Ind),:) = feats(randi(size(feats,1)),:);
             end
          end
       end
    end
    finalVec = zeros(size(feats));
    for i = 1:k
        idx = find(eucDist(:,k+1) == i);
        finalVec(idx,:) = repmat(centers(i,:),size(idx,1),1); 
    end
    
    % Reshape RGB Image
    if imagN==1
        imgVec = finalVec(:,1:3);
        imgVec = imgVec(:);
        finalImg = reshape(imgVec(:,1),size(J,1),size(J,2),3);
    else 
        finalImg = reshape(finalVec(:,1),size(J));
    end
       
    figure()
    subplot(121); imshow(J);title('Image')
    subplot(122); imshow(finalImg);title("Segmented Image");
end