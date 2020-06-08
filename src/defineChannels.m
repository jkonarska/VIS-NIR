function [VIS, NIR] = defineChannels(inputImage, settings)
% This function defines the visible (VIS) and near-infrared (NIR) channels
% in the input image, based on user input in imageSettings. Depending on
% the filter used, the NIR and VIS light will be recorded in different
% channels.
flags = 'rgb';
NIR = im2double(inputImage(:,:,flags==lower(settings.nirChannel)));
VIS = im2double(inputImage(:,:,flags==lower(settings.visChannel)));
end
