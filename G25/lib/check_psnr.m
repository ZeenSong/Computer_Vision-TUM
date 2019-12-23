%check psnr: Vergleichen Sie ihre eigene Implementierung
%des PSNR mit der in der Image Processing
%Toolbox und prufen Sie, ob das Ergebnis
%innerhalb einer angemessenen Toleranz liegt.
function X_tolerenz = check_psnr(D,G) 
%G = pfmread('disp0.pfm');
%D = Disparity;
peaksnr = psnr(D,G,255);
p = 10*log10(255^2/calcMSE(D,G));
tolerenz = abs(peaksnr - p);
tolerenz = num2str(tolerenz);
X_tolerenz = ['The tolerenz is ' num2str(tolerenz) 'dB'];
%disp(X_tolerenz);
end


