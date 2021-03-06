function [classifiedImage, classColorMap] = classifyPixels(image, imageDisp, VIS, NIR, ndvi, autoMode)
% This function classifies pixels into sky, buildings as well as green and
% woody plant elements.

% OBS pewnie musze napisac cos wiecej o algorytmach (graythresh itp.)


%% 1. Classify sky pixels

% 1a. Set an automatic threshold using Otsu's method
VIS(ndvi>0)=0;
skyThreshold = graythresh(VIS);

% 1b. Manually adjust the threshold if needed
text = [{['Automatic threshold is ',num2str(skyThreshold), '. Use the slider to adjust it manually if necessary. Increasing the threshold will classify fewer pixels as sky.']},...
{'Click the ‘Fill non-sky’ button to mark non-sky areas (e.g. windows) misclassified as sky.'}, ...
{'Click the ‘Fill sky’ button to mark sky areas misclassified as buildings/vegetation.'}, ...
{'To remove a polygon, right-click on it and select ‘Delete polygon’.'}];
sliderSettings = setSlider();
sliderSettings.threshold=skyThreshold;
sliderSettings.baseImage=imageDisp;
sliderSettings.thresholdImage=VIS;
sliderSettings.fillGaps=true;
sliderSettings.welcomeMessage=text;
sliderSettings.title='Classify pixels as sky';
sliderSettings.buttonLabels={'Fill non-sky', 'Fill sky'};
if autoMode
    [~, skyMask] = fuseImage(sliderSettings);
else
    skyMask = addSlider(sliderSettings);
end

%% 2. Classify building pixels

% 2a. Specify if there are any human-made structures in the image
if autoMode
    buildings = 'Yes';
else
    buildings = questdlg('Are there any human-made structures (buildings, lamp poles etc.) in the image?', 'Question', 'Yes', 'No', 'Yes');
end
if strcmp(buildings,'No')
    buildingMask = false(size(image,1),size(image,2),1);
else
    % Convert to <0,1> values
    revNdvi=-ndvi;
    revNdvi=(revNdvi+1)./2;
    %revNdvi(ndvi>0)=0;
    
    % 2b. If so, set an automatic threshold is simple 0 in ndvi
    ndviThreshold = 0.5;
    
    % 2c. Manually adjust the threshold if needed
        text = [{['Automatic threshold is ',num2str(ndviThreshold), '. Use the slider to adjust it manually if necessary. Increasing the threshold will classify fewer pixels as buildings.']}, ...
{'Click the ‘Fill non-building’ button to mark areas misclassified as buildings.'}, ...
{'Click the ‘Fill building’ button to mark buildings misclassified as vegetation.'}, ...
{'To remove a polygon, right-click on it and select ‘Delete polygon’.'}];
    
    sliderSettings.thresholdImage=revNdvi;
    sliderSettings.threshold=ndviThreshold;
    sliderSettings.welcomeMessage=text;
    sliderSettings.fillGaps=false;
    sliderSettings.erodeMaskSize=9;
    sliderSettings.alreadyClassified=skyMask;
    sliderSettings.title='Classify pixels as buildings';
    sliderSettings.buttonLabels={'Fill non-building', 'Fill building'};
    if autoMode
        [~, buildingMask] = fuseImage(sliderSettings);
    else
        buildingMask = addSlider(sliderSettings);
    end
end

%% 3. Divide vegetation pixels into green and woody plant elements

% 3a. Set a threshold based on the NIR channel
revNIR=(1-NIR);
nirThreshold = graythresh(revNIR((skyMask | buildingMask)==0));

text = [{['Automatic threshold is ',num2str(nirThreshold), '. Use the slider to adjust it manually if necessary. Increasing the threshold will classify more pixels as stems/branches.']},...
{'Click the ‘Fill foliage’ button to mark foliage areas misclassified as stems/branches.',} ...
{'Click the ‘Fill branches’ button to mark stems/branches misclassified as foliage.',} ...
{'To remove a polygon, right-click on it and select ‘Delete polygon’.'}];

sliderSettings.thresholdImage=revNIR;
sliderSettings.threshold=nirThreshold;
sliderSettings.welcomeMessage=text;
sliderSettings.fillGaps=false;
sliderSettings.erodeMaskSize=[];
sliderSettings.alreadyClassified=skyMask | buildingMask;
sliderSettings.title='Classify pixels as stems/branches';
sliderSettings.buttonLabels={'Fill foliage', 'Fill branches'};
if autoMode
    [~, branchMask] = fuseImage(sliderSettings);
else
    branchMask = addSlider(sliderSettings);
end
branchMask(NIR==0)=0;
leafMask=true(size(image,1),size(image,2),1);

leafMask(branchMask | skyMask | buildingMask | NIR==0)=0;

%% 4. Merge masks into a single classified image

% 4a. Create a classified image
classifiedImage = ones(size(skyMask));

% 4b. Assign different values to each class
classifiedImage(skyMask) = 2;
classifiedImage(leafMask) = 3;
classifiedImage(branchMask) = 4;
classifiedImage(buildingMask) = 5;

% 4c. Assign different colours to each class
    classColorMap = ...
    [0 0 0;
    1 1 1;  ...        % sky - white
    0 1 0; ...          % leaves - green
    0 0.5 0; ...        % woody elements - dark green
    1 0 0];             % buildings - red

end
