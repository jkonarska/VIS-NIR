function outputImage = changeGamma(image, gammaValue)
%Changing image gamma
if isa(image,'double')
    outputImage = image.^gammaValue;
else
    if isa(image,'uint8')
        index=2^8;
        gammaLookup=uint8(((1:index)./index).^(gammaValue)*index);
        %gammaLookup(gammaLookup>index-1)=index-1;
    elseif isa(image,'uint16')
        index=2^16;
        gammaLookup=uint16(((1:index)./index).^(gammaValue)*index);
        %gammaLookup(gammaLookup>index-1)=index-1;
    end
    outputImage=gammaLookup(image+1);
end
