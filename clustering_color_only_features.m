clc;clear all;close all;

star = imread('...\12003.jpg');
gzt = imread('...\HW_Segmen_Image_Gazete.bmp');
pcb = imread('...\PCB.BMP');

% RGB Histogram plot for star image
nBins = 256;
r = imhist(star(:,:,1), nBins);
g = imhist(star(:,:,2), nBins);
b = imhist(star(:,:,3), nBins);

hFig = figure;
subplot(2,1,1); 
imshow(star); 
title('Input image');

figure,
h(1) = area(1:nBins, r, 'FaceColor', 'r'); hold on; 
h(2) = area(1:nBins, g,  'FaceColor', 'g'); hold on; 
h(3) = area(1:nBins, b,  'FaceColor', 'b'); hold on; 
axis([0 255 0 5000])
title('Starfish RGB Histogram');

%Histogram Plot
figure, imhist(pcb),title("PCB Histogram"); % 3 Peaks
figure, imhist(gzt),title("Gzt Histogram"); % 2 Peaks

img{1} = star;
img{2} = pcb;
img{3} = gzt;

nk(1) = 4;
nk(2) = 3;
nk(3) = 2;

for imag=1:3
    I = im2double(img{imag});                   
    vecI = I(:);  
    k = nk(imag);                                            
    centers = vecI( ceil(rand(k,1)*size(vecI,1)) ,:);             
    eucDist   = zeros(size(vecI,1),k+2);                         
    iterN   = 10;                                           
    for n = 1:iterN
       for i = 1:size(vecI,1)
          for j = 1:k  
            eucDist(i,j) = norm(vecI(i,:) - centers(j,:));      
          end
          [dist  ind] = min(eucDist(i,1:k));                
          eucDist(i,k+1) = ind;                                
          eucDist(i,k+2) = dist;                          
       end
       for i = 1:k
          A = (eucDist(:,k+1) == i);                        
          centers(i,:) = mean(vecI(A,:));   % If random center is NaN                 
          if sum(isnan(centers(:))) ~= 0                    
             newC = find(isnan(centers(:,1))==1);            %#ok<COMPNOP>
             for Ind = 1:size(newC,1)
             centers(newC(Ind),:) = vecI(randi(size(vecI,1)),:);
             end
          end
       end
    end
    segVec = zeros(size(vecI));
    for i = 1:k
        idx = find(eucDist(:,k+1) == i);
        segVec(idx,:) = repmat(centers(i,:),size(idx,1),1); 
    end
    if imag==1
        segmentedImage = reshape(segVec,size(I,1),size(I,2),3);
    else 
        segmentedImage = reshape(segVec,size(I));
    end
    
    figure()
    subplot(121); imshow(I);title("Original Image");
    subplot(122); imshow(segmentedImage);title("Segmented Image");
end