classdef imageSettings
    properties
        
        %% SETTINGS
        % These settings will be applied to all images in the image folder.
        % Before running the code, double-check all settings and make
        % changes where necessary.
        
        %Image format list
        imageFormatExtensions={'jpg', 'jpeg', 'tif', 'tiff', 'png', 'dng'};
        % Specify image extensions to be processed by the script. RAW
        % formats (e.g. NEF or ORF) must be converted to DNG before
        % processing via external tools (Adobe DNG Converter).

        % Image channels
        nirChannel = 'R';   % Specify channel for near-infrared (NIR) light
        visChannel = 'B';   % Specify channel for visible (VIS) light
        % An image consists of three channels - red ('R'), green ('G') and
        % blue ('B'). Depending on the filter used, the NIR and VIS (red,
        % green and blue) light will be recorded in different channels.
        
        % White balancing
        whiteBalanceCoef = [];
        % By default, white balance settings from image tags (As Shot
        % Neutral) are used. To override the settings, specify coefficient
        % values as a three-element vector (e.g. [1 0.637 0.718]). A Vector
        % specified as ones(1, 3) means no white balancing.

        % Lens type
        fisheye = true;
        % Specify if the folder contains images taken with a circular
        % fisheye lens or a regular lens. Fisheye (hemispherical) images
        % are required for further analysis of LAI or SVF in external
        % software.
        
        % Sigma 4.5 mm vignetting correction
        vignCorrection = true;
        % If you are using a Sigma 4.5 mm circular fisheye lens, specify if
        % vignetting correction (Cauwerts et al. 2012) should be applied.
        
        % Median Filtering
        medianFiltering = true;
        % Specify if simple median filtering should be applied on RGB image
        % to remove salt-pepper noise from demosaiced image
        
        % Automatic classification
        autoClassification = false;
        % The classification of pixels into sky, buildings, stems and
        % foliage is based on automatic thresholding. These thresholds can
        % be manually adjusted if corrections are needed. Use this setting
        % to skip the manual adjustments (recommended for testing only).
        
    end
    
    methods
        
        function obj = set.imageFormatExtensions(obj,imageFormatExtensions)
            if ~isa(imageFormatExtensions,'cell') || ~ischar([imageFormatExtensions{:}])
                error('Permitted image extensions must be a cell array of chars')
            else
                obj.imageFormatExtensions = imageFormatExtensions;
            end
        end
        
        function obj = set.nirChannel(obj,nirChannel)
            if ~contains('rgb',nirChannel,'IgnoreCase',true)
                error('Channel setting must point to one of R, G, or B channel')
            else
                obj.nirChannel = upper(nirChannel);
            end
        end
        
        function obj = set.whiteBalanceCoef(obj,whiteBalanceCoef)
            if length(whiteBalanceCoef)~=3 || ~isa(whiteBalanceCoef, 'double')
                error('White balance coefficients must have 3 elements')
            else
                obj.whiteBalanceCoef = upper(whiteBalanceCoef);
            end
        end
        
        function obj = set.visChannel(obj,visChannel)
            if ~contains('rgb',visChannel,'IgnoreCase',true)
                error('Channel setting must point to one of R, G, or B channel')
            else
                obj.visChannel = upper(visChannel);
            end
        end
        
        function obj = set.fisheye(obj,fisheye)
            if ~islogical(fisheye)
                error('Fisheye setting can be only true or false')
            else
                obj.fisheye = fisheye;
            end
        end
        function obj = set.vignCorrection(obj,vignCorrection)
            if ~islogical(vignCorrection)
                error('Vignetting correction setting can be only true or false')
            else
                obj.vignCorrection = vignCorrection;
            end
        end
        function obj = set.medianFiltering(obj,medianFiltering)
            if ~islogical(medianFiltering)
                error('Median filtering setting can be only true or false')
            else
                obj.medianFiltering = medianFiltering;
            end
        end
        function obj = set.autoClassification(obj,autoClassification)
            if ~islogical(autoClassification)
                error('Automatic classification setting can be only true or false')
            else
                obj.autoClassification = autoClassification;
            end
        end
    end
end

