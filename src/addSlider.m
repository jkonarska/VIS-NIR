function mask = addSlider(sliderSettings)
sharedProperties = hstruct();
data.settings=sliderSettings;

f = figure();
f.Color=[1 1 1];
f.MenuBar='none';
f.NumberTitle='off';
f.Name=sliderSettings.title;

imshow(sliderSettings.baseImage);
f.NextPlot='add';

welcome = uicontrol();
welcome.Parent=f;
welcome.Style='text';
welcome.String=sliderSettings.welcomeMessage;
welcome.BackgroundColor=[1,1,1];

text = uicontrol();
text.Parent=f;
text.Style='text';
text.Position=[40,20,70,20];
text.String=num2str(sliderSettings.threshold);
data.text=text;

slider = uicontrol();
slider.Parent=f;
slider.Style='slider';
slider.Position=[120,20,450,23];
slider.Value=sliderSettings.threshold;
slider.Min=0;
slider.Max=1;
slider.UserData=sharedProperties;
slider.Callback =  @(h, ed) slider_callback(h);

button = uicontrol();
button.Parent=f;
button.Style='togglebutton';
button.Position=[580,20,100,23];
button.String='On/Off mask';
data.button=button;
button.UserData=sharedProperties;

drawSubstractivePolygon = uicontrol();
drawSubstractivePolygon.Parent=f;
drawSubstractivePolygon.Style='pushbutton';
drawSubstractivePolygon.Position=[680,20,120,23];
drawSubstractivePolygon.String=sliderSettings.buttonLabels{1};
drawSubstractivePolygon.Callback = @(h, ed) drawSubstractivePolygon_callback(h);
drawSubstractivePolygon.UserData=sharedProperties;

drawAdditivePolygon = uicontrol();
drawAdditivePolygon.Parent=f;
drawAdditivePolygon.Style='pushbutton';
drawAdditivePolygon.Position=[800,20,120,23];
drawAdditivePolygon.String=sliderSettings.buttonLabels{2};
drawAdditivePolygon.Callback = @(h, ed) drawAdditivePolygon_callback(h);
drawAdditivePolygon.UserData=sharedProperties;



% if ~isempty(sliderSettings.gapThreshold)
%     edt = uicontrol();
%     edt.Parent=f;
%     edt.Style='edit';
%     edt.Position=[990,20,70,23];
%     edt.String=sliderSettings.gapThreshold;
%     edt.Callback = @(h,ed) editGapThreshold_callback(h);
%     edt.UserData=sharedProperties;
% end


closeButton = uicontrol();
closeButton.Parent=f;
closeButton.Style='pushbutton';
closeButton.Position=[920,20,70,23];
closeButton.String='Finish';
closeButton.Callback = @(h, ed) uiresume();

sharedProperties.data=data;
slider_callback(slider);
button.Callback = @(h, ed) button_callback(h);

f.WindowState = 'maximized';
drawnow;
pause(1);
ax=gca;
ax.Position(4)=ax.Position(4)-0.05;
welcome.Position=[f.Position(3)/4,f.Position(4)-80,f.Position(3)/2,80];

uiwait();

ax = gca;
list = ax.Children;
substractivePolygons = findobj(list, 'Type', 'images.roi.polygon', 'Color', [1, 0, 0]);
additivePolygons = findobj(list, 'Type', 'images.roi.polygon', 'Color', [0, 1, 0]);
[~, mask] = fuseImage(sharedProperties.data.settings, substractivePolygons, additivePolygons);

close(f);
end

function slider_callback(hObject)
data=hObject.UserData.data;
threshold=hObject.Value;
data.settings.threshold=threshold;
data.button.Value=0;
data.text.String=num2str(threshold);
hObject.UserData.data=data;
[data.fused]=redrawFused(hObject.UserData);
hObject.UserData.data=data;
end

% function editGapThreshold_callback(hObject)
% if all(ismember(hObject.String, '0123456789'))
%     hObject.UserData.data.settings.gapThreshold=str2num(hObject.String);
%     redrawFused(hObject.UserData);
% end
% end
 
function button_callback(hObject)
currentState=hObject.Value;
ax = gca;
list = ax.Children;
im=findobj(list, 'Type', 'image');
if currentState == 1
    im.CData=hObject.UserData.data.settings.baseImage;
else
    im.CData=hObject.UserData.data.fused;
end
end

function drawAdditivePolygon_callback(hObject)
pol = drawpolygon('Color','g');
pol.addlistener('DeletingROI',@(h,~) deleteAction(h,hObject.UserData));
redrawFused(hObject.UserData);
uiwait();
end

function drawSubstractivePolygon_callback(hObject)
pol = drawpolygon('Color','r');
pol.addlistener('DeletingROI',@(h,~) deleteAction(h,hObject.UserData));
redrawFused(hObject.UserData);
uiwait();
end

function fused = redrawFused(userData)
f = gcf;
f.Pointer = 'watch';
data=userData.data;
ax = gca;
list = ax.Children;

substractivePolygons = findobj(list, 'Type', 'images.roi.polygon', 'Color', [1, 0, 0]);
additivePolygons = findobj(list, 'Type', 'images.roi.polygon', 'Color', [0, 1, 0]);
[fused, ~] = fuseImage(data.settings, substractivePolygons, additivePolygons);

im=findobj(list, 'Type', 'image');
im.CData=fused;
data.fused=fused;
userData.data=data;
drawnow;
f.Pointer = 'arrow';
end

function deleteAction(h, userData)
h.HandleVisibility='off';
redrawFused(userData);
end