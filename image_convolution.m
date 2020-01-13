function [ I2 ] = image_convolution(I,w,G)
m= (w-1)/2;
N= size(I,1);
M=size(I,2);
for i=1:N
    for j=1:M
        if (i > N-m-1 || j > M-m-1 || i<m+1 || j <m+1)
            I2(i,j) = 0;
            continue;
        end
        sum1 = 0;
        for u=1:w
            for v=1:w
                sum1 = sum1+I(i+u-m-1,j+v-m-1)*G(u,v);
            end
        end
        I2(i,j)=sum1;
    end
end

end