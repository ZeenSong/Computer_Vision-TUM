function [Disparity,distancemap,R,T] = disparitymap_census(scene_path)
%% Laden Bild
pathname = scene_path;
filename1 = 'im0.png';
im0_name = fullfile(pathname,filename1);
filename2 = 'im1.png';
im1_name = fullfile(pathname,filename2);

Image1 = double(imread(im0_name));
Image2 = double(imread(im1_name));
IGray1 = rgb_to_gray(Image1);
IGray2 = rgb_to_gray(Image2);
%% Laden calib.txt 
fileID = fopen(fullfile(scene_path,'calib.txt'));
C = textscan(fileID,'%s %s','Delimiter','=');
for i = 1:length(C{1})
    eval([C{1}{i},'=',C{2}{i},';']);
end
fclose(fileID);
f = cam0(1,1);
% Harris-Merkmale berechnen
Merkmale1 = harris_detektor(IGray1,'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);
Merkmale2 = harris_detektor(IGray2,'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);

%% Korrespondenzschaetzung
wl = round(width/65);
if mod(wl,2) == 0
    wl = wl+1;
end
Korrespondenzen = punkt_korrespondenzen(IGray1,IGray2,Merkmale1,Merkmale2,'window_length',wl,'min_corr',0.9,'do_plot',false);
% %% Essentielle 
 K1 = cam0;
 K2 = cam1;
 E = achtpunktalgorithmus(Korrespondenzen, K1,K2);
 Korrespondenzen_robust1 = F_ransac(Korrespondenzen,'tolerance', 0.04);
 Korrespondenzen_robust = Korrespondenzen_robust1{1};
%% Rekonstruktion
[T1, R1, T2, R2] = TR_aus_E(E); 
[T, R, lambda, P1] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust, K1,K2);
%% Down-Sample wenn die Bild zu groß ist
if height>1000
    height = height/4;
    width = width/4;
    ndisp = floor(ndisp/4);
    IGray1 = imresize(IGray1,0.25);
    IGray2 = imresize(IGray2,0.25);
end
%% wenn die Grenze der disparity zu groß, reduziren es
if abs(ndisp-width)<=100
    DSR = floor(width/40);
else
    DSR = ndisp;
end
%% Fenster und Disparity map initialisieren
win_Size = floor(width/150);
KernelL = zeros(win_Size,win_Size);
KernelR = zeros(win_Size,win_Size);
Disparity0 = zeros(height,width);
Disparity1 = zeros(height,width);
%% census_Transformation der graue Bild
censusRmap = census(IGray2,9);
censusLmap = census(IGray1,9);
fb = waitbar(0,'Please wait...');
d = win_Size; % die wert der Disparitymap ändert sich in dem ganz Fenster
%% Links Disparitymap generieren
for i = 1+floor(win_Size/2):d:width-floor(win_Size/2)  
    for j = 1+floor(win_Size/2):d:height-floor(win_Size/2)
        KernelL = Image1(j-floor(win_Size/2):j+floor(win_Size/2),i-floor(win_Size/2):i+floor(win_Size/2),:);
        censusL = censusLmap(j-floor(win_Size/2):j+floor(win_Size/2),i-floor(win_Size/2):i+floor(win_Size/2));
        MM = 255*ones(1,DSR);
        for k = 1:DSR
            x = i-k;
            if x-floor(win_Size/2)>0
                KernelR = Image2(j-floor(win_Size/2):j+floor(win_Size/2),x-floor(win_Size/2):x+floor(win_Size/2),:);
                censusR = censusRmap(j-floor(win_Size/2):j+floor(win_Size/2),x-floor(win_Size/2):x+floor(win_Size/2));
                diff = abs(KernelR-KernelL);
                for H = 1:win_Size^2
                    if ~isempty(censusR{H}) && ~isempty(censusL{H})
                        ham(H) = sum(xor(censusL{H},censusR{H}));
                    else
                        ham(H) = win_Size^2;
                    end
                end
                hamming = sum(ham);
                SAD = sum(diff(:))/3;
                cost = 2-exp(-hamming/1000)-exp(-k*SAD/10);
                MM(k) = cost;
            end
        end
        [~,loc] = min(MM);           
        Disparity0(j-floor(win_Size/2):j+floor(win_Size/2),i-floor(win_Size/2):i+floor(win_Size/2)) = loc;
    end
    waitbar(0.5*i/width,fb,'Processing Data!');
end
%% Rechts Disparitymap Bild generieren
for i = 1+floor(win_Size/2):d:width-floor(win_Size/2)  
    for j = 1+floor(win_Size/2):d:height-floor(win_Size/2)
        KernelR = Image2(j-floor(win_Size/2):j+floor(win_Size/2),i-floor(win_Size/2):i+floor(win_Size/2),:);
        censusR = censusRmap(j-floor(win_Size/2):j+floor(win_Size/2),i-floor(win_Size/2):i+floor(win_Size/2));
        MM = 255*ones(1,DSR);
        for k = 1:DSR
            x = i+k;
            if x+floor(win_Size/2)<width
                KernelL = Image1(j-floor(win_Size/2):j+floor(win_Size/2),x-floor(win_Size/2):x+floor(win_Size/2),:);
                censusL = censusLmap(j-floor(win_Size/2):j+floor(win_Size/2),x-floor(win_Size/2):x+floor(win_Size/2));
                diff = abs(KernelR-KernelL);
                for H = 1:win_Size^2
                    if ~isempty(censusR{H}) && ~isempty(censusL{H})
                        ham(H) = sum(xor(censusL{H},censusR{H}));
                    else
                        ham(H) = win_Size^2;
                    end
                end
                hamming = sum(ham);
                SAD = sum(diff(:))/3;
                cost = 2-exp(-hamming/1000)-exp(-k*SAD/10);
                MM(k) = cost;
            end
        end
        [~,loc] = min(MM);           
        Disparity1(j-floor(win_Size/2):j+floor(win_Size/2),i-floor(win_Size/2):i+floor(win_Size/2)) = loc;
    end
    waitbar(0.5*i/width+0.5,fb,'Processing Data!');
end
close(fb)
%% die Verfeinerung beides Bilder
DisparityN = refinement(Disparity0,Disparity1,ndisp,d);
Disparity1_1 = DisparityN{2};
Disparity1_0 = DisparityN{1};
Disparity1_1(:,width-DSR:width) = DisparityN{1}(:,width-DSR:width);
Disparity1_0(:,1:DSR) = DisparityN{2}(:,1:DSR);

%% Upsample wenn es vorher downsample gibt
if size(Disparity0,1)~=size(Image1,1)
    Disparity1_0 = imresize(Disparity1_0,4);
    Disparity1_1 = imresize(Disparity1_1,4);
    height = height*4;
    width  = width*4;
    ndisp = ndisp*4;
    f = f/4;
    doffs = doffs/4;
end
Disparity{1} = 255*Disparity1_0/max(Disparity1_0(:));
Disparity{2} = 255*Disparity1_1/max(Disparity1_1(:));
distancemap = baseline*f./(Disparity1_0+doffs);
end

