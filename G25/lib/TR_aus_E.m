function [T1, R1, T2, R2, U, V]=TR_aus_E(E)
    % Diese Funktion berechnet die moeglichen Werte fuer T und R
    % aus der Essentiellen Matrix
    Rz = [0 -1 0;1 0 0;0 0 1];
    [U,D,V] = svd(E);
    if det(U)<0 
        U = U*diag([1,1,-1]);        
    end
    if det(V)<0
        V = V*diag([1,1,-1]);
    end
    R1 = U*Rz'*V';
    R2 = U*Rz*V';
    T1_dach = U*Rz*D*U';
    T1 = [T1_dach(3,2);T1_dach(1,3);T1_dach(2,1)];
    T2_dach = U*Rz'*D*U';
    T2 = [T2_dach(3,2);T2_dach(1,3);T2_dach(2,1)];
end