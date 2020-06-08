function image=readDNG(filename,metaInfo,whiteBalanceCoeff,isMedianFilter)
% readDNG opens, processes and reads RAW image as Matlab image.
% Default output with linear response curve (gamma 1.0) and 16 bits per
% pixel

% This code is based on Robert Sumner's 'Processing RAW Images in MATLAB'
% guide (http://users.soe.ucsc.edu/~rcsumner/rawguide/ (accessed July
% 2014). It has been modified and published with author's permission.

warning off MATLAB:imagesci:tiffmexutils:libtiffWarning

% - - - checking parameters - - -
if (exist(filename, 'file')~=2)
    error('file does not exists! Make sure that the RAW files were converted to DNG and that the drive is connected.');
end
if exist('whiteBalanceCoeff','var') && ~isempty(whiteBalanceCoeff)
    if(length(whiteBalanceCoeff)==4)
        whiteBalanceCoeff=whiteBalanceCoeff(1:3);
    elseif(length(whiteBalanceCoeff)~=3)
        error('length of argument whiteBalanceCoeff must be equal to 3 or 4');
    end
end

% - - - Reading file - - -
%DNG file has tags in tiff format, read them
tiffStruct = Tiff(filename,'r');

%read raw image data instead of embedded (or not) miniature
offset = getTag(tiffStruct,'SubIFD');
setSubDirectory(tiffStruct,offset(1));
rawData = read(tiffStruct);
close(tiffStruct);

imageSub = metaInfo.SubIFDs{1};%tags embedded to dng image

if(imageSub.CFALayout~=1)
    error('Color filter array in camera is not rectangle and it''s not supported by this reader')
end

%Crop to default crop area (active area was bigger than default crop area)
xOrigin = imageSub.DefaultCropOrigin(1);
width = imageSub.DefaultCropSize(1);
yOrigin = imageSub.DefaultCropOrigin(2);
height = imageSub.DefaultCropSize(2);
rawData = rawData(yOrigin+1:yOrigin+height,xOrigin+1:xOrigin+width);

% - - - Linearize - - -
%Digital Negative Specification
%LinearizationTable describes a lookup table that maps stored values into
%linear values. This tag is typically used to increase compression ratios
%by storing the raw data in a non-linear, more visually uniform space with
%fewer total encoding levels

if isfield(imageSub,'LinearizationTable')
    ltab=imageSub.LinearizationTable;
    rawData = ltab(rawData+1);%shift by one, because matlab array indexing starts from one.
end

%luckily, matlab using saturation arithmetic by default. For unsigned types, when pixel value is less
%than blackLevel, the result is 0
if(size(imageSub.BlackLevel)==4) %if we have separate blackLevel for every channel
    rawData=rawData-reshape(repmat(reshape(uint16(imageSub.BlackLevel),2,2), size(rawData)./2), size(rawData));
else
    rawData=rawData-imageSub.BlackLevel(1);
end

% - - - White Balance - - -
%Set a default value of white balance (AsShot) if not set before
if ~exist('whiteBalanceCoeff','var') || isempty(whiteBalanceCoeff)
    whiteBalanceCoeff = (metaInfo.AsShotNeutral);
end
%If white balance values were provided as 'less than one' values (norm in DNG
%standard, not a norm in user visible values)
if dot(whiteBalanceCoeff,whiteBalanceCoeff) < 3
    whiteBalanceCoeff = whiteBalanceCoeff.^-1;
end

%Normalize white balance coefficients
[~,index] = min(whiteBalanceCoeff);
whiteBalanceCoeff = whiteBalanceCoeff./whiteBalanceCoeff(index);

cfaPattern = metaInfo.DigitalCamera.CFAPattern;
if(max(cfaPattern(5:8))>2)
    error('non rgb patterns are not supported by matlab demosaicing');
end
flags = 'rgb';
bayerType = flags(cfaPattern(5:8)+1);
maskWB = reshape(whiteBalanceCoeff(cfaPattern(5:8)+1),cfaPattern(1) ,cfaPattern(3));
maskWB = repmat(maskWB,height/size(maskWB,1),width/size(maskWB,2));

%apply white balance correction
balancedBayerWB = uint16(double(rawData) .* maskWB);
clear rawData;

% - - - Demoisaicing by internal matlab function - - -
image= demosaic(balancedBayerWB,bayerType);
clear balancedBayerWB;
image=double(image); % time to be in floating point arithmetic?

% Postfiltering by median filter
if isMedianFilter
    image=medianFiltering(image);
end

% - - - Saturation - should be the last step in raw processing
saturationLevel = imageSub.WhiteLevel;
image = image*((2^16-1)/saturationLevel);

% - - - Color Correction Matrix from DNG Info - - -
% - - - There is more information about colors in metaInfo under CameraCalibration and ForwardMatrix keys.
% - - - Not all are recognized by matlab, but can be accessed by TIFF Tag ID
temp = metaInfo.ColorMatrix2;
xyz2cam = reshape(temp,3,3)';

% - - - Color Space Conversion - - -
srgb2xyz = [0.4124564 0.3575761 0.1804375;
    0.2126729 0.7151522 0.0721750;
    0.0193339 0.1191920 0.9503041];

rgb2cam = xyz2cam * srgb2xyz;
rgb2cam = rgb2cam ./ repmat(sum(rgb2cam,2),1,3);
cam2rgb = rgb2cam^-1;

image = applyCmatrix(double(image),cam2rgb);
image = uint16(image);

end
