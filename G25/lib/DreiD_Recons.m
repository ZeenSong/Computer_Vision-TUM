function []=DreiD_Recons(distancemap,Image)
    width = size(Image,2);
    height = size(Image,1);
    [X,Y] = meshgrid(1:width,1:height);
    A(:,:,1) = X;
    A(:,:,2) = Y;
    A(:,:,3) = distancemap;
    figure
    ptCloud = pointCloud(A,'Color',Image/255);
    pcshow(ptCloud,'VerticalAxis', 'y', 'VerticalAxisDir', 'down');
end