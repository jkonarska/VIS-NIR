%% Hemispherical dual-wavelength (VIS-NIR) photo analysis
% This program imports and analyses near-infrared images to classify pixels
% into sky, buildings as well as green and woody plant elements.

% Created by Janina Konarska (University of Gothenburg) and Jan Filipski
% Published under the MIT licence
% contact: janina.konarska@gvc.gu.se

clear global; close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1. USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set path to the image folder. All images in the folder should be taken
% with the same camera and near-infrared filter.
folderPath = ('../../VIS-NIR/Sample images');

% Specify default settings. These settings will be applied to all images in
% the folder.
settings = imageSettings();
% To override the default settings, interact with settings object via
% setters, e.g.:
settings.imageFormatExtensions = {'dng'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 2. Set paths
outputPath=fullfile(folderPath,'output');
if ~exist(outputPath, 'dir')
    mkdir(outputPath)
end

settingsPath=fullfile(folderPath,'settings');
if ~exist(settingsPath, 'dir')
    mkdir(settingsPath)
end

dbstop if error
warning('off','images:initSize:adjustingMag');

% 3. Create a list of images
fileList=dir(fullfile(folderPath));

%% 4. Import and process images
for i=1:size(fileList,1)
    filename = [fileList(i).name];
    [~,name,ext] = fileparts(filename);
    if ~any(strcmpi(ext(2:end), settings.imageFormatExtensions))
        continue;
    end
    outputFilePath=fullfile(outputPath,strcat(name,'.tif'));

    % 4a. Skip analysis if output image exists
    if isfile(outputFilePath)
        continue;
    end
    
    % 4b. Display which photo is being analysed
    X = ['Analysing photo ',filename,'. '];
    disp(X)
    
    % 4c. Import and pre-process the image
    filename = fullfile(folderPath, filename);
    [image, imageDisp] = imageWorker(filename, settingsPath, settings);
    
    %% 5. Calculate NDVI
    % 5a. Define channels
    [VIS, NIR] = defineChannels(image, settings);
    
    % 5b. Calculate NDVI
    ndvi = ndviCalc(VIS, NIR);
    
    %% 6. Classify pixels into sky, buildings, leaves and branches
    [classifiedImage, classColorMap] = classifyPixels(image, imageDisp, VIS, NIR, ndvi, settings.autoMode);
    
    %% 7. Save the output figure
    imwrite(classifiedImage, classColorMap, outputFilePath, 'Compression', 'lzw');
end
