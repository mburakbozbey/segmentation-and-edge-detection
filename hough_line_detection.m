close all;clc;clear all;

% Generate diamond image
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

% Generate diamond image edges
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

% Add noise & canny edge detector
noiseImage = J + sqrt(144)*randn(256);
BW = edge(noiseImage,'Canny');
BW = logical(BW);
figure,imshow(BW)

% Builtin functions to find houghpeaks & houghlines
[H,T,R] = hough(BW, 'RhoResolution',.9,'Theta',-90:0.005:89);
imshow(H,[],'XData',T,'YData',R,...
            'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
P  = houghpeaks(H,45,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');
lines = houghlines(BW,T,R,P,'FillGap',3,'MinLength',40);
figure, imshow(BW), hold on
max_len = 0;

for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
