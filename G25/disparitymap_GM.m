function [D,distancemap,R,T] = disparitymap_GM(scene_path)
    pathname = scene_path;
    filename1 = 'im0.png';
    im0_name = fullfile(pathname,filename1);
    filename2 = 'im1.png';
    im1_name = fullfile(pathname,filename2);
    %% load all camera setting parameter from calib.txt
    fileID = fopen(fullfile(scene_path,'calib.txt'));%open the calib.txt
    C = textscan(fileID,'%s %s','Delimiter','=');%save all the parameter in 2 cell
    for i = 1:length(C{1})
        eval([C{1}{i},'=',C{2}{i},';']);%read out all the parameter from cell
    end
    f = cam0(1,1);
    fclose(fileID);%close the calib.txt
    
    %% load all the bild from the scene_path
    Image1 = double(imread(im0_name)); %load im0.png as Image1
    Image2 = double(imread(im1_name)); %load im1.png as Image2
    IGray1 = rgb_to_gray(Image1);%turn Image1 into grayscale image as IGray1
    IGray2 = rgb_to_gray(Image2);%turn Image2 into grayscale image as IGray2
    
    %% Global matching Algorithm
    costmap = zeros(height,width);%creat a costmap matrix which later save the costvalue of each pixel
    disparity1 = costmap;%creat the diaparity matrix which has the same size as IGray1
    min_costmap = 9999*ones(height,width);%give a defalut value for the minimun costmap,later we will interate the value if cosmap has smaller value
    LAMBDA = 0.0001;%defalut lambda value, which has control the smooth energy. More Details see paper:A Taxonomy and Evaluation of Dense Two-Frame Stereo Correspondence Algorithms
    fb = waitbar(0,'Please wait...');%creat a waitbar 
    
    if ndisp == width%this for condition is for control the move length d not too long.
        ndisp = width/40;% when d goes to big e.g the whole width. the cost will be very instabil.
    end
    
    for d=1:ndisp%move d from 1 to ndisp, ndisp is the disparity boundary, which is given in the calib.txt
        costmap = abs([zeros(height,d),IGray2(:,1:width-d)]-IGray1);% right image IGray2 subtract the left image IGray1, and each iteration IGray2 will move "d" pixel towards right, the result is result matrix
        disparity1(costmap<min_costmap) = d;% for the pixel,whose subtract result is smaller than min_costmap, write the disparity of this pixel is d.
        costmap = costmap + LAMBDA*((disparity1-[zeros(height,1),disparity1(:,1:width-1)])+(disparity1-[disparity1(2:height,:);zeros(1,width)]));%based on the paper: A Taxonomy and Evaluation of Dense Two-Frame Stereo Correspondence Algorithms. The Algorithms is a global Method, so the cost function should add a smooth term to make the edge between pixel beeter. 
        min_costmap(costmap<min_costmap) = costmap(costmap<min_costmap);%for the pixel, whose cost is smaller than min_costmap, update the min_costmap with the vaule in the costmap
        waitbar(0.5*d/(ndisp),fb,'Processing Data!');%show a waitbar
    end
    min_costmap = 9999*ones(height,width);
    disparity2 = costmap;
    for d=1:ndisp%move d from 1 to ndisp, ndisp is the disparity boundary, which is given in the calib.txt
        costmap = abs([IGray1(:,1+d:width),zeros(height,d)]-IGray2);% right image IGray2 subtract the left image IGray1, and each iteration IGray2 will move "d" pixel towards right, the result is result matrix
        disparity2(costmap<min_costmap) = d;% for the pixel,whose subtract result is smaller than min_costmap, write the disparity of this pixel is d.
        costmap = costmap + LAMBDA*((disparity2-[zeros(height,1),disparity2(:,1:width-1)])+(disparity1-[disparity1(2:height,:);zeros(1,width)]));%based on the paper: A Taxonomy and Evaluation of Dense Two-Frame Stereo Correspondence Algorithms. The Algorithms is a global Method, so the cost function should add a smooth term to make the edge between pixel beeter. 
        min_costmap(costmap<min_costmap) = costmap(costmap<min_costmap);%for the pixel, whose cost is smaller than min_costmap, update the min_costmap with the vaule in the costmap
        waitbar(0.5+d/(ndisp),fb,'Processing Data!');%show a waitbar
    end
    waitbar(1,fb,'Finishing');close(fb);%again waitbar
    
    %% Gaussian  average filter
    w=[1 2 1;2 4 2;1 2 1]/16;%add a gassian average filter
    gaussian1=conv2(disparity1,w,'same');%filtering
    gaussian2 = conv2(disparity2,w,'same');
    D{1} = gaussian1;
    D{2} = gaussian2;
    %% Harris Detecter
    Merkmale1 = harris_detektor(IGray1,'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);
    Merkmale2 = harris_detektor(IGray2,'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);

    %% Korrespondenzschaetzung
    wl = round(width/65);
    if mod(wl,2) == 0
        wl = wl+1;
    end
    Korrespondenzen = punkt_korrespondenzen(IGray1,IGray2,Merkmale1,Merkmale2,'window_length',wl,'min_corr',0.9,'do_plot',false);

    %% Essentielle 
    K1 = cam0;
    K2 = cam1;
    E = achtpunktalgorithmus(Korrespondenzen, K1, K2);
    Korrespondenzen_robust1 = F_ransac(Korrespondenzen,'tolerance', 0.04);
    Korrespondenzen_robust = Korrespondenzen_robust1{1};
    
    %% Rekonstruktion
    [T1, R1, T2, R2] = TR_aus_E(E); 
    [T, R, ~, ~] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust, K1,K2);
    distancemap = baseline*f./(D{1}+doffs);
end

