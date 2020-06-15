classdef setSlider
    properties
        threshold;
        baseImage;
        thresholdImage;
        welcomeMessage;
        erodeMaskSize;
        fillGaps;
        alreadyClassified=0;
        title;
        buttonLabels;
    end
    
    methods
        function obj = set.threshold(obj,threshold)
            if ~isa(threshold, 'double') || threshold>1 || threshold<0 || numel(threshold)>1
                error('threshold must be a value between 0 and 1')
            else
                obj.threshold = threshold;
            end
        end
        function obj = set.baseImage(obj,baseImage)
            if ndims(baseImage)~=3
                error('baseImage must be a valid matlab encoded image')
            else
                obj.baseImage = baseImage;
            end
        end
        function obj = set.thresholdImage(obj,thresholdImage)
            if ~isa(thresholdImage, 'double') || max(thresholdImage,[],'all')>1 || min(thresholdImage,[],'all')<0
                error('baseImage must be a valid matlab double encoded image')
            else
                obj.thresholdImage = thresholdImage;
            end
        end
        function obj = set.welcomeMessage(obj,welcomeMessage)
            if ~isa(welcomeMessage,'cell') || ~ischar([welcomeMessage{:}])
                error('welcomeMessage must be a cell array of chars')
            else
                obj.welcomeMessage = welcomeMessage;
            end
        end
        
        function obj = set.erodeMaskSize(obj,erodeMaskSize)
            if any([mod(erodeMaskSize,1) ~= 0,0]) || ~isnumeric(erodeMaskSize) || numel(erodeMaskSize)>1
                error('erodeMaskSize must be an integer value')
            else
                obj.erodeMaskSize = erodeMaskSize;
            end
        end
            
        function obj = set.fillGaps(obj,fillGaps)
            if ~islogical(fillGaps)
                error('fillGaps must be true or false')
            else
                obj.fillGaps = fillGaps;
            end
        end
        function obj = set.alreadyClassified(obj,alreadyClassified)
            if ~islogical(alreadyClassified) && ~ismatrix(alreadyClassified)
                error('alreadyClassified must be a mask array')
            else
                obj.alreadyClassified = alreadyClassified;
            end
        end
        function obj = set.title(obj,title)
            if ~ischar(title)
                error('title must be a char array')
            else
                obj.title = title;
            end
        end
        function obj = set.buttonLabels(obj,buttonLabels)
            if ~isa(buttonLabels,'cell') || ~ischar([buttonLabels{:}])
                error('Permitted buttonLabels must be a cell array of chars')
            else
                obj.buttonLabels = buttonLabels;
            end
        end
    end
end

