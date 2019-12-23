function p = validate_dmap(Disparity,Groundtruth)
%This function caculates the psnr value 
D = Disparity;
[value1,~] = min(D(:));%the max value of the D matrix(x:y)
[value2,~] = max(D(:));%the min value of the D matrix(x:y)
D = floor((D-value1).*255./(value2-value1));%normalize the D matrix[0,255] 
G = Groundtruth;
[value3,~] = min(G(:));% the min value of the G matrix(x:y)
[value4,~] = max(G(:));% the max value of the G matrix(x:y)
G = floor((G-value3).*255./(value4-value3));%normalize the G matrix[0,255]
p = 10*log10(255^2/calcMSE(D,G));%caculate the psnr with the formel 
end

function [MSE] = calcMSE(original,reconstruct) %the function for the caculate the MSE   
    [n1,n2,dim]= size(original);
    MSE = sum((original(:)-reconstruct(:)).^2)/(n1*n2*dim); 
end
