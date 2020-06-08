function [ndviImage] = ndviCalc(VIS, NIR)
% Calculates NDVI image from provided image

ndviImage = (NIR-VIS)./(NIR+VIS);
end