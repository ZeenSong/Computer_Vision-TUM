function DisparityN = refinement(Disparity0,Disparity1,ndisp,d)
[height,width] = size(Disparity0);
fb = waitbar(0,'in refinement');
for ite = 1:3
    Disparity_0 = [zeros(height,ndisp),Disparity0];
    Disparity_1 = [Disparity1,zeros(height,ndisp)];
    ReconsDL = zeros(height,width);
    for j = 1:height
        for i = 1:width
        ReconsDL(j,i) = Disparity_0(j,i+round(Disparity1(j,i)));
        end
    end
    ReconsDR = zeros(height,width);
    for j = 1:height
        for i = 1:width
        ReconsDR(j,i) = Disparity_1(j,i+ndisp-round(Disparity0(j,i)));
        end
    end
    ErrorR = ReconsDR-Disparity1;
    ErrorL = ReconsDL-Disparity0;
    %%
    win_Size = d;
    tau = d*2/ite;
    %DisparityN1 = Disparity1;
    for i = 1+floor(win_Size/2):width-floor(win_Size/2)
        for j = 1+floor(win_Size/2):height-floor(win_Size/2)
            if abs(ErrorR(j,i))>tau
                window = Disparity1(j-floor(win_Size/2):j+floor(win_Size/2),i-floor(win_Size/2):i+floor(win_Size/2));
                mu = median(window(:));
                Disparity1(j,i) = mu;
            end
        end
    end
    for i = 1+floor(win_Size/2):width-floor(win_Size/2)
        for j = 1+floor(win_Size/2):height-floor(win_Size/2)
            if abs(ErrorL(j,i))>tau
                window = Disparity0(j-floor(win_Size/2):j+floor(win_Size/2),i-floor(win_Size/2):i+floor(win_Size/2));
                mu = median(window(:));
                Disparity0(j,i) = mu;
            end
        end
    end
    waitbar(ite/3,fb,'in refinement');
end
DisparityN{1} = Disparity0;
DisparityN{2} = Disparity1;
close(fb);
end