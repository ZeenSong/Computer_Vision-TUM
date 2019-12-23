function  Merkmale=harris_detektor(Image,varargin) 
% In dieser Funktion soll der Harris-Detektor implementiert werden, der
% Merkmalspunkte aus dem Bild extrahiert


%% Input parser
P = inputParser;

% Liste der optionalen Parameter
% Fensterl?nge
P.addOptional('segment_length', 15, @isnumeric)
% Parameter f?r Harris-Matrix
P.addOptional('k', 0.03, @isnumeric);
% Schwellwertparameter tau, h?ngt stark von den Intensit?tswerten des
% Bildes ab
P.addOptional('tau', 1e6, @isnumeric);
% Kachelgr??e
P.addOptional('tile_size', [200,200], @isnumeric);
% Max. Anzahl Merkmale innerhalb einer Kachel
P.addOptional('N', 5, @isnumeric);
% Minimaler Abstand zwischen zwei Merkmalen
P.addOptional('min_dist', 20, @isnumeric);
% Plot ein/aus
P.addOptional('do_plot', false, @islogical);

% Lese den Input
P.parse(varargin{:});

% Extrahiere die Variablen aus dem Input-Parser
segment_length = P.Results.segment_length;
k = P.Results.k;
tau = P.Results.tau;
tile_size = P.Results.tile_size;
N = P.Results.N;
min_dist = P.Results.min_dist;
do_plot = P.Results.do_plot;

% Falls bei der Kachelgr??e nur die Kantenl?nge angegeben wird, verwende
% quadratische Kachel
if numel(tile_size) == 1
    tile_size=[tile_size,tile_size];
end

%% Vorbereitung zur Feature Detektion
% Approximation des Bildgradienten ?ber das Sobel-Filter
[Ix,Iy ]= sobel_xy(Image);

% Wir w?hlen ein Fenster mit Gau?-Gewichtung zur mittenbetonten Bestimmung
% der Merkmalsposition. sigma = Filterl?nge/5
l = segment_length;
x = [-l/2 + 0.5:l/2 - 0.5];
sigma = (log(l));
w = exp(0.5*((-x.^2)/(2*sigma^2)));
w = w/sum(w);
W = w' * w;

% Zun?chst werden alle Eintr?ge der Harris-Matrix f?r jeden Pixel im Bild
% bestimmt. Dies spart viele unn?tige Operationen gegen?ber einer
% for-Schleife ?ber alle Pixel im Bild!
% G(1,1) ist die Summe aller Ix^2 ?ber das Fenster W 
Ixqval  = double(conv2(Ix.*Ix,W,'same'));
% G(1,1) ist die Summe aller Iy^2 ?ber das Fenster W 
Iyqval  = double(conv2(Ix.*Iy,W,'same'));
%G(1,2) und G(2,1) ist die Summe aller Ix * Iy ?ber das Fenster W  
Ixyval  = double(conv2(Iy.*Iy,W,'same'));
 
 
%% Merkmalsextraktion ?ber die Harrismessung
% Harrismessung f?r alle Pixel des Bildes
corner   = ((Ixqval.*Iyqval - Ixyval.^2) - k*(Ixqval + Iyqval).^2);

% Bei der vorherigen Faltung wurden die R?nder automatisch mit Nullen
% aufgef?llt, wodurch die Harrismessung im Randbereicht des Bildes hohe
% Ausschl?ge liefert. Diese Werte werden nun mit Null ?berschrieben.
corner = corner.*zeroBorder(corner,ceil(segment_length/2));

%Schwellwertbildung der Merkmale
corner(corner<=tau)=0;

%% Kontrollmechanismus ?ber den Abstand zweier Merkmale und die maximale Anzahl von Merkmaln in einem Fenster
 
% Die Funktion cake erstellt eine "Kuchenmatrix", die eine kreisf?rmige
% Anordnung von Nullen beinhaltet und den Rest der Matrix mit Einsen
% auff?llt. Damit k?nnen, ausgehend vom st?rksten Merkmal, andere Punkte
% unterdr?ckt werden, die den Mindestabstand hierzu nicht einhalten.
Cake    = cake(min_dist);

% Es muss sichergestellt werden, dass auch die Region um einen Merkmalspunkt am Rand
% elementweise mit der cake-Matrix multipliztiert werden kann. Hierzu muss
% ein Nullrand angef?gt werden.
Z = zeros(size(corner,1)+2*min_dist,size(corner,2)+2*min_dist);
Z((min_dist + 1):(size(corner,1)+min_dist),(min_dist + 1):(size(corner,2)+min_dist)) = corner;
corner = Z;

% Sortiere alle Merkmale der St?rke nach absteigend
[sorted_list,sorted_index] = sort(corner(:),'descend');

% Eliminiere alle Eintr?ge, deren Merkmalsst?rke auf null gesetzt wurde
sorted_index(sorted_list==0)=[];

% Anzahl an Merkmalen ungleich null und Gr??e des Suchfeldes
no_points = numel(sorted_index);
size_corner = size(corner);

% Das AKKA ist ein Akkumulatorfeld (Ein Eintrag pro Kachel), welches Aufschluss dar?ber gibt, wie
% viele Merkmale pro Kachel schon gefunden wurden.
AKKA = zeros(ceil(size(Image,1)/tile_size(1)),ceil(size(Image,2)/tile_size(2)));

% Alloziere ein Array, in dem die Merkmale gespeichert werden.
Merkmale=zeros(2,min(numel(AKKA)*N,no_points));
% Feature-Z?hler
feature_count=1;

for  current_point = 1:no_points
    % Nehme n?chstes Element aus sortierter Liste
    pt_index = sorted_index(current_point);
    % ?berpr?fen, ob dieser Merkmalspunkt noch g?ltig ist    
    if(corner(pt_index)==0)
            continue;
    else
           % Extrahiere Reihen- und Spalten-Index. Die Matlab-Funktion ind2sub macht das gleiche,
           % ben?tigt aber l?nger.
           col = floor(pt_index/size_corner(1));
           row = pt_index - col*size_corner(1);
           col = col + 1;
    end

    
    %Berechnung der Indizes, und damit der ID der zum gefundenen
    %Merkmalspunkt korrespondierenden Kachel Ex und Ey
    Ex = floor((row-min_dist-1)/(tile_size(1)))+1;
    Ey = floor((col-min_dist-1)/(tile_size(2)))+1;
    
    % Erh?he den entsprechenden Eintrag im Akkumulatorarray
    AKKA(Ex,Ey)=AKKA(Ex,Ey)+1;
    
    % Multipliziere Region um den gefundenen Merkmalspunkt elementweise mit der Kuchenmaske
    corner(row-min_dist:row+min_dist,col-min_dist:col+min_dist)=corner(row-min_dist:row+min_dist,col-min_dist:col+min_dist).*Cake;
    
    %Teste, ob die entsprechende Kachel schon gen?gend Merkmale beinhaltet
    if AKKA(Ex,Ey)==N
        %Falls ja, setzte alle verbleibenden Merkmale innerhalb dieser Kachel auf 0
        corner((((Ex-1)*tile_size(1))+1+min_dist):min(size(corner,1),Ex*tile_size(1)+min_dist),(((Ey-1)*tile_size(2))+1+min_dist):min(size(corner,2),Ey*tile_size(2)+min_dist))=0;   
    end
    
    %Speichere den Merkmalspunkt und ber?cksichtige dabei den angef?gten Nullrand.
    Merkmale(:,feature_count)=[col-min_dist;row-min_dist];
    % Erh?he den Z?hler der Schleife
    feature_count = feature_count+1;
end

% Reduziere die Merkmalsliste auf die g?ltigen Merkmale
Merkmale = Merkmale(:,1:feature_count-1);

%% Darstellung der gefundenen Merkmale
% if do_plot
%     figure  
%     colormap('gray')
%     imagesc(Image)
%     hold on;
%     plot(Merkmale(1,:), Merkmale(2,:), 'gs');
%     plot(Merkmale(1,:), Merkmale(2,:), 'g.');
%     axis('off');
% end
end

function Mask=zeroBorder(I,W)
Mask=zeros(size(I));
Mask((W+1):(size(I,1)-W),(W+1):(size(I,2)-W))=1;
end

function Cake=cake(min_dist)
[X,Y]=meshgrid(-min_dist:min_dist,[-min_dist:-1,0:min_dist]);
Cake=sqrt(X.^2+Y.^2)>min_dist;
end

