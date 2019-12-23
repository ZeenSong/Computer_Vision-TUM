function [Disparity,distancemap,R,T]  = disparitymap_SAD(scene_path)
pathname = scene_path;
filename1 = 'im0.png';
im0_name = fullfile(pathname,filename1);
filename2 = 'im1.png';
im1_name = fullfile(pathname,filename2);
%% Laden calib.txt 
fileID = fopen(fullfile(scene_path,'calib.txt'));
C = textscan(fileID,'%s %s','Delimiter','=');
for i = 1:length(C{1})
    eval([C{1}{i},'=',C{2}{i},';']);
end
fclose(fileID);
f = cam0(1,1);
%% Bild Laden
Image1 = double(imread(im0_name));
Image2 = double(imread(im1_name));
IGray1 = rgb_to_gray(Image1);
IGray2 = rgb_to_gray(Image2);

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
%% wenn die Grenze der disparity zu groß, reduziren es
win_Size = floor(width/200);
if abs(ndisp-width)<=100
    DSR = floor(width/40);
else
    DSR = ndisp;
end
%% Fenster und Disparity map initialisieren
KernelL = zeros(win_Size,win_Size);
KernelR = zeros(win_Size,win_Size);
Disparity1 = zeros(height,width);
IGray1 = [IGray1,zeros(height,DSR+win_Size)];
IGray1 = [IGray1;zeros(win_Size,width+DSR+win_Size)];
IGray2 = [IGray2,zeros(height,DSR+win_Size)];
IGray2 = [IGray2;zeros(win_Size,width+DSR+win_Size)];
fb = waitbar(0,'Please wait...');
d = win_Size;
%% Recht Disparitymap generieren
for i = 1:d:width  
    for j = 1:d:height
        KernelR = IGray2(j:j+win_Size-1,i:i+win_Size-1);
        MM = 99999*ones(1,DSR);
        for k = 1:DSR
            x = i+k;
            if x+win_Size-1<width
            KernelL = IGray1(j:j+win_Size-1,x:x+win_Size-1);
            diff = abs(KernelR-KernelL)+1/DSR*k;
            cost = sum(sum(diff));
            MM(k) = cost;
            end
        end
        [MIN,loc] = min(MM);           
        Disparity1(j:j+win_Size-1,i:i+win_Size-1) = loc;
    end
    waitbar(0.5*i/width,fb,'Processing Data!');
end
%% Links Disparitymap generieren
for i = 1:d:width
    for j = 1:d:height
        KernelL = IGray1(j:j+win_Size-1,i:i+win_Size-1);
        MM = 99999*ones(1,DSR);
        for k = 1:DSR
            x = i-k;
            if x > 0
            KernelR = IGray2(j:j+win_Size-1,x:x+win_Size-1);
            diff = abs(KernelR-KernelL)+1/DSR*k;
            cost = sum(sum(diff));
            MM(k) = cost;
            end
        end
        [MIN,loc] = min(MM);           
        Disparity0(j:j+win_Size-1,i:i+win_Size-1) = loc;
    end
    waitbar(0.5*i/width+0.5,fb,'Processing Data!');
end
waitbar(1,fb,'Finishing');
close(fb);
Disparity1 = Disparity1(1:height,1:width);
Disparity0 = Disparity0(1:height,1:width);
%% die Verfeinerung beides Bilder
DisparityN = refinement(Disparity0,Disparity1,ndisp,d);
Disparity1_1 = DisparityN{2};
Disparity1_0 = DisparityN{1};
Disparity1_1(:,width-DSR:width) = DisparityN{1}(:,width-DSR:width);
Disparity1_0(:,1:DSR) = DisparityN{2}(:,1:DSR);
Disparity{1} = 255*Disparity1_0/max(Disparity1_0(:));
Disparity{2} = 255*Disparity1_1/max(Disparity1_0(:));
distancemap = baseline*f./(Disparity1_0+doffs);
end




