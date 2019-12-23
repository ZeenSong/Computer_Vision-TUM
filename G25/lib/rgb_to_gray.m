function gray_image = rgb_to_gray(input_image)
    % Diese Funktion soll ein RGB-Bild in ein Graustufenbild umwandeln. Falls
    % das Bild bereits in Graustufen vorliegt, soll es direkt zurueckgegeben werden.
    input_image = double(input_image);
    if ndims(input_image) == 3
        gray_image = 0.299*input_image(:,:,1)+0.587*input_image(:,:,2)+0.114*input_image(:,:,3);
    else
        gray_image = input_image;
    end
end
