clc;clear all;close all;

gauss = imread('...\Gauss_rgb1.png');

I = im2double(gauss);
subplot(121);
imshow(I);
Isizes = size(I); 
Jfinal = zeros(Isizes(1), Isizes(2));
flagLabel = 1;

% Params
seed = 3;
reg_maxdist_lim = .3;
max_iter = 5000;
max_iter_seed = 100;
reg_maxdist = 10/255;

[X,Y] = ginput(seed);
X = round(X);
Y = round(Y);
hold on;
plot(X,Y,'xg','MarkerSize',20,'LineWidth',2);
hold off;
temp=X;
X=Y;
Y=temp;

Isizes = size(I); 

reg_mean = zeros(seed,3);
for i=1:seed
    reg_mean(i,:) = [I(X(i),Y(i),1) I(X(i),Y(i),2) I(X(i),Y(i),3)];
end

reg_size = ones(1,seed);
neigb = [-1,-1;0,-1;1,-1;-1,0;1,0;-1,1;0,1;1,1];
c=0;c2=0;   
n=3;

while(flagLabel)
    
    for kx=1:seed
         
        x=X(kx);
        y=Y(kx);
        neg_free = 16384; neg_pos = 0;
        neg_list = zeros(neg_free,5); 
        pixdist = 0; 
        Jfinal(x,y) = kx*60; 
%         disp(kx)
        c2=0; 
        while(pixdist<reg_maxdist&&reg_size(kx)<numel(I)/3&&c2<max_iter_seed)
            n=3; 
            
            for j=1:8

                xn = x + neigb(j,1); yn = y + neigb(j,2);

                ins = (xn>=1)&&(yn>=1)&&(xn<=Isizes(1))&&(yn<=Isizes(2));

                
                if(ins&&(Jfinal(xn,yn)==0)) 
                        neg_pos = neg_pos+1;
                        neg_list(neg_pos,:) = [xn yn I(xn,yn,2) I(xn,yn,1) I(xn,yn,3)];
                end
            end
            while(neg_pos==0)
                
                n = n + 2; 
                elem=0;
                neighZero = zeros(n*n,2);
                for p=1:n
                    for q=1:n
                        elem = elem+1;
                        neighZero(elem,:) = [p-(n+1)/2 q-(n+1)/2];
                    end
                end
                neighZero((n+1)*(n-1)/2+1,:) = [];

                for j=1:(n*n-1)

                    xn = x + neighZero(j,1); yn = y + neighZero(j,2);

                    ins = (xn>=1)&&(yn>=1)&&(xn<=Isizes(1))&&(yn<=Isizes(2));


                    if(ins&&(Jfinal(xn,yn)==0)) 
                            neg_pos = neg_pos+1;
                            neg_list(neg_pos,:) = [xn yn I(xn,yn,2) I(xn,yn,1) I(xn,yn,3)];
                    end
                    if neg_pos >0
                        break
                    end
                end
                if neg_pos>0
                    break
                end
            end
            c2 = c2 +1;

            dist = sqrt(sum(abs((neg_list(1:neg_pos,3:5)-reg_mean(kx,:).*ones(neg_pos,3)).^2)'));
            [pixdist, index] = min(dist);
            reg_mean(kx,:) = (reg_mean(kx,:)*reg_size(kx) + neg_list(index,3:5))./(reg_size(kx)+1);
            x = neg_list(index,1); y = neg_list(index,2);
            Jfinal(x,y) = kx*60; reg_size(kx) = length(Jfinal(Jfinal==kx*60));
            neg_list(index,:) = []; 
            neg_pos = neg_pos-1;

        end



    end
    if c>max_iter/5
        if isempty(Jfinal(Jfinal==0))
            flagLabel = 0;
        else
            if reg_maxdist<reg_maxdist_lim
                reg_maxdist = reg_maxdist + 15/255;
            elseif c>max_iter
                subplot(122);
                imshow(uint8(Jfinal));
                return
            end
        end
    end
    c = c+1;
    if c>1153
        subplot(122);
        imshow(uint8(Jfinal));
        return
    end
end

BW1 = edge(Jfinal,'canny');


match = 0;
dismatch = 0;
im = logical(zeros(128,128)); %#ok<LOGL>
im(65,:) = 1;
im(1:65,65) = 1;
imshow(BW1)
for i=1:128
    for j=1:128
       if im(i,j)==0&&BW1(i,j)==0
       else
           if im(i,j)==1&&BW1(i,j)==1
               match = match+1;
           else
               dismatch = dismatch+1;
           end
       end
    end
end

IoU = match/(match+dismatch);

disp(IoU);

