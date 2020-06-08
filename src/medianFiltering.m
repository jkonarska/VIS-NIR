function image = medianFiltering(image)
mRG = medfilt2(image(:, :, 1)-image(:, :, 2));
mBG = medfilt2(image(:, :, 3)-image(:, :, 2));
image=cat(3,image(:,:,2)+mRG, (image(:, :, 1)+image(:,:, 3)-mRG-mBG)/2, image(:, :, 2)+mBG);
end
