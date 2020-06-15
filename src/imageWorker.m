function [image, imageDisp] = imageWorker(filename,settingsPath,settings)
% imageWorker imports and pre-processes an image.

%% 1. Check image format and lens model
metaInfo = imfinfo(filename);
isDng = isfield(metaInfo,'DNGVersion');

% Find lens model in exif
unknownTags = metaInfo.DigitalCamera.UnknownTags;
lensModel = unknownTags([unknownTags.ID]==42036);

%% 2. Import the image
if ~isDng
    image=imread(filename);
else
    image = readDNG(filename, metaInfo, settings.whiteBalanceCoef, settings.medianFiltering);
end

%% 3. For circular fisheye images - specify circular image area

% 3a. Check if the images were taken with a circular fisheye lens
if ~settings.fisheye
    
    % If not, analyse the entire image
    imageArea = true(size(image,1),size(image,2));
else
    
    % 3a. If yes, specify the circular image area
    
    % Check if a file with predefined image area settings exists
    radiusFile = fullfile(settingsPath,'radius.mat');
    
    % If yes, load existing settings
    if isfile(radiusFile)
        load(radiusFile,'imageRadius','centreX','centreY', 'imageSize', 'lensModelForRadius', 'circlePixels', 'circlePixelsDist'); % predefined settings for all images
    end
    if ~exist('imageSize', 'var') || all(imageSize~=size(image)) || ~exist('lensModelForRadius', 'var') || ~isequal(lensModelForRadius,lensModel)
        % If its not saved or size differs, ask for user input
        [imageRadius,centreX,centreY] = specifyRadius(image, isDng);
        imageSize = size(image);
        % Save the settings for the remaining images in the folder
        lensModelForRadius=lensModel;

        % 3b. Specify circular image area
        [columnsInImage, rowsInImage] = meshgrid((1:imageRadius*2)-imageRadius, (1:imageRadius*2)-imageRadius);
        circlePixels = rowsInImage.^2 +columnsInImage.^2 <= imageRadius.^2;
        circlePixelsDist = (rowsInImage.^2 +columnsInImage.^2)/(imageRadius.^2);
        save(radiusFile,'imageRadius','centreX','centreY', 'imageSize', 'lensModelForRadius', 'circlePixels', 'circlePixelsDist');
    end

    % 3b. Crop the image
    image = imcrop(image,[centreX-imageRadius, centreY-imageRadius, imageRadius*2-1, imageRadius*2-1]);
    imageArea = circlePixels;
end

%% 4. Image corrections

% 4a. Apply vignetting correction (DNG format only, Sigma 4.5 mm circular
% fisheye lens)
if(settings.vignCorrection && all(size(lensModel)==1)) && strcmp(lensModel.Value, '5.0 mm f/2.8')
    aperture = metaInfo.DigitalCamera.FNumber;
    aperture = roundn(aperture,-1);
    image = vignCorrectionSigma45(image,circlePixelsDist,aperture);
end

% 4b. Apply noise filtering
image = imgaussfilt3(image);

% 4c. Set pixel values outside of image area to 0
ind = find(imageArea==0);
image([ind; ind+numel(imageArea); ind+numel(imageArea)*2])=0;

% 4d. Change brightness and gamma
if isDng
    imageDisp = changeGamma(image, 1.0/3.2);
else
    imageDisp = image; % no corrections for other formats
end
