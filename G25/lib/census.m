function censusmap = census(image,win_Size)
    fb = waitbar(0,'census transforming');
    height = size(image,1);
    width = size(image,2);
    censusmap =cell(height,width);
    for i = 1+floor(win_Size/2):1:width-floor(win_Size/2)
        for j = 1+floor(win_Size/2):1:height-floor(win_Size/2)
            block = image(j-floor(win_Size/2):j+floor(win_Size/2),i-floor(win_Size/2):i+floor(win_Size/2));        
            center = block(ceil(win_Size/2),ceil(win_Size/2));
            censusBlock = uint8(zeros(win_Size,win_Size));
            censusBlock(block>center) = uint8(1);
            censusBlock(block<center) = uint8(0);
            censusmap{j,i} = censusBlock(:);
        end
        waitbar(i/width,fb,'census transforming');
    end
    close(fb);
end