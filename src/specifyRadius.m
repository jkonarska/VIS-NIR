function [radius,centreX,centreY] = specifyRadius(image)
% Function to specify the circular image area
threshold = 0.2;
blurMaskSize = 3;

[height, width, ~]=size(image);

% Assuming that lens are centered on image area
centreY = height/2;
centreX = width/2;

% Convert to doubles to make thresholding easier
lum = im2double(rgb2gray(image));
lightDistribution = sum(lum(:,:),1);

% Blur distribution with neighbours and edge detection via convolution
gradientAndBlur=conv2(ones(1,blurMaskSize)./blurMaskSize,[-1 0 1]./2);
lightDistribution = conv2(lightDistribution, gradientAndBlur);

% Find indices with values higher than threshold, omitting edges
query = find(abs(lightDistribution(1+length(gradientAndBlur):end-length(gradientAndBlur))) > threshold);

% Max and min index are on bounds of circle
radius = ceil((query(end) - query(1))/2);
end