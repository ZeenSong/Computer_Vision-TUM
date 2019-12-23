function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % Diese Funktion berechnet die Sampson Distanz basierend auf der
    % Fundamentalmatrix F
    e3_hat = skew_matrix([0 0 1]);
    sd = sum(x2_pixel.*(F*x1_pixel)).^2 ./ (sum((e3_hat*F*x1_pixel).^2) + sum((e3_hat*F'*x2_pixel).^2));
    function [Vhat]=skew_matrix(V)
        Vhat = [0 -V(3) V(2); V(3) 0 -V(1); -V(2) V(1) 0];
    end
end