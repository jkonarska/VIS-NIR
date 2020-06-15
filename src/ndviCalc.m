function [ndviImage] = ndviCalc(VIS, NIR)
% Calculates NDVI image from provided image

ndviImage = (NIR-VIS)./(NIR+VIS);

% deal with floating point error rounding
ndviImage(abs(ndviImage)<2*eps)=0;

end