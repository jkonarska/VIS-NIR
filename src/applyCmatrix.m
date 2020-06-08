function corrected = applyCmatrix(im,cmatrix)
% CORRECTED = apply_cmatrix(IM,CMATRIX)
% Applies CMATRIX to RGB input IM. Finds the appropriate weighting of the
% old color planes to form the new color planes.

% Modified from: Robert Sumner, 2014, Processing RAW Images in Matlab.
% https://www.rcsumner.net/raw_guide/RAWguide.pdf

if size(im,3)~=3
    error('Apply cmatrix to RGB image only.')
end

xy = size(im);
im=reshape(im,[],3);
im=im*cmatrix';
corrected=reshape(im,xy);
