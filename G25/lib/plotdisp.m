function [] = plotdisp(Disparity)
    figure
    subplot(1,2,1)
    imshow(Disparity{1},[]),colormap(gca,jet);title('Links Disparity')
    subplot(1,2,2)
    imshow(Disparity{2},[]),colormap(gca,jet);title('Rechts Disparity')
    saveas(gcf,'misc/Disparitymap.pdf');
end