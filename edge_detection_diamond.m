clc;clear all;close all;
ImageWidth = 256;
ImageHeight =  256;
Image = 64.*ones(ImageHeight, ImageWidth);

Image(ImageHeight/2-64:ImageHeight/2+64,...
      ImageWidth/2-64:ImageWidth/2+64) = 128; 
  
Image(ImageHeight/2-32:ImageHeight/2+32,...
      ImageWidth/2-32:ImageWidth/2+32) = 192; 


J = imrotate(Image,45);
J(J==0) = 64;
r = centerCropWindow2d(size(J),[256 256]);
J = imcrop(J,r) ;


groundTruth = ones(256,256);
rows=128:-1:38;
cols=37:1:127;
for i=1:length(rows)
    groundTruth(rows(i),cols(i))= 0;
end
rows=38:1:128;
cols=128:1:218;
for i=1:length(rows)
    groundTruth(rows(i),cols(i))= 0;
end
rows=128:1:218;
cols=218:-1:128;
for i=1:length(rows)
    groundTruth(rows(i),cols(i))= 0;
end
rows=218:-1:128;
cols=127:-1:37;
for i=1:length(rows)
    groundTruth(rows(i),cols(i))= 0;
end


rows=128:-1:83;
cols=82:1:127;
for i=1:length(rows)
    groundTruth(rows(i),cols(i))= 0;
end
rows=83:1:128;
cols=128:1:173;
for i=1:length(rows)
    groundTruth(rows(i),cols(i))= 0;
end
rows=128:1:173;
cols=173:-1:128;
for i=1:length(rows)
    groundTruth(rows(i),cols(i))= 0;
end
rows=173:-1:128;
cols=127:-1:82;
for i=1:length(rows)
    groundTruth(rows(i),cols(i))= 0;
end
groundTruth = logical(groundTruth);
figure,imshow(groundTruth)



figure,imshow(uint8(J))
noiseImage = J + sqrt(144)*randn(256);

% Edge Detection
BW1 = 1 - edge(noiseImage,'sobel');
BW2 = 1 - edge(noiseImage,'Canny');

LoG = [0 1 0; 1 -4 1; 0 1 0];
BW3 = image_convolution(noiseImage, 3, LoG);
edgeImg = 1- edge(BW3,'zerocross')

figure,imshow(noiseImage,[])
figure,imshow(BW1)
figure,imshow(BW2)
figure,imshow(edgeImg)


% Performance
EP = 0;
Ngrt = (91+46)*4;
BW_ = zeros(256,256,3);
BW_(:,:,1) = BW1;
BW_(:,:,2) = BW2;
BW_(:,:,3) = edgeImg;

EPk = zeros(1,3);

for k=1:3
    gauss = 0;
    BW = BW_(:,:,k);
    for i=1:256
        for j=1:256
            if groundTruth(i,j) == 0
                if BW(i,j) == 0
                    EP = EP +1;
                elseif BW(i,j+1) == 0
                    EP = EP +.5;
                elseif BW(i,j+2) == 0
                    EP = EP +.5;
                elseif BW(i+1,j) == 0
                    EP = EP +.5;
                elseif BW(i+2,j) == 0
                    EP = EP +.5;
                elseif BW(i-1,j) == 0
                    EP = EP +.5;
                elseif BW(i-2,j) == 0
                    EP = EP +.5;
                elseif BW(i,j-1) == 0
                    EP = EP +.5;
                elseif BW(i,j-2) == 0
                    EP = EP +.5;
                end
            end
        end
        EPk(k) = EP;
    end
end

% For noise var=484

noiseImage = J + sqrt(484)*randn(256);

BW1 = 1 - edge(noiseImage,'sobel');
BW2 = 1 - edge(noiseImage,'Canny');
LoG = [0 1 0; 1 -4 1; 0 1 0];
BW3 = image_convolution(noiseImage, 3, LoG)
edgeImg = 1- edge(BW3,'zerocross')

figure,imshow(noiseImage,[])
figure,imshow(BW1)
figure,imshow(BW2)
figure,imshow(edgeImg)


% Performance
EP = 0;
Ngrt = (91+46)*4;
BW_ = zeros(256,256,3);
BW_(:,:,1) = BW1;
BW_(:,:,2) = BW2;
BW_(:,:,3) = edgeImg;

EPk2 = zeros(1,3);

for k=1:3
    EP = 0;
    BW = BW_(:,:,k);
    for i=1:256
        for j=1:256
            if groundTruth(i,j) == 0
                if BW(i,j) == 0
                    EP = EP +1;
                    
                elseif BW(i,j+1) == 0
                    EP = EP +.5;
                elseif BW(i,j+2) == 0
                    EP = EP +.5;
                elseif BW(i+1,j) == 0
                    EP = EP +.5;
                elseif BW(i+2,j) == 0
                    EP = EP +.5;
                elseif BW(i-1,j) == 0
                    EP = EP +.5;
                elseif BW(i-2,j) == 0
                    EP = EP +.5;
                elseif BW(i,j-1) == 0
                    EP = EP +.5;
                elseif BW(i,j-2) == 0
                    EP = EP +.5;
                end
            end
        end
        EPk2(k) = EP;
    end
end
