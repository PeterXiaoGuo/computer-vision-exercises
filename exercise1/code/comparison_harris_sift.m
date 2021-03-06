% Exercise 1
% Comparison between the Harris features and the SIFT
close all;
run ~/Development/MATLAB/libraries/vlfeat-0.9.20/toolbox/vl_setup.m

IMG_NAME1 = 'images/I1.jpg';
IMG_NAME2 = 'images/I2.jpg';

% read in image
img1 = im2double(imread(IMG_NAME1));
img2 = im2double(imread(IMG_NAME2));

img1 = imresize(img1, 1);
img2 = imresize(img2, 1);

% convert to gray image
imgBW1 = rgb2gray(img1);
imgBW2 = rgb2gray(img2);

% Task 1.1 - extract Harris corners
[corners1, H1] = extractHarrisCorner(imgBW1', 4e-4);
[corners2, H2] = extractHarrisCorner(imgBW2', 4e-4);

% show images with Harris corners
showImageWithCorners(img1, corners1, 10);
showImageWithCorners(img2, corners2, 11);

% Compute the SIFT features
[f1, d1] = vl_sift(single(imgBW1));
[f2, d2] = vl_sift(single(imgBW2));

perm1 = randperm(size(f1,2));
perm2 = randperm(size(f2,2));
sel1 = perm1(1:500);
sel2 = perm2(1:500);
showImageWithCorners(img1, f1(1:2,sel1), 31);
showImageWithCorners(img2, f2(1:2,sel2), 32);
print('../report/images/sift1','-djpeg90','-f31')
print('../report/images/sift2','-djpeg90','-f32')

% Task 1.2 - extract your own descriptors
descr1 = extractDescriptor(corners1, imgBW1');
descr2 = extractDescriptor(corners2, imgBW2');

% Task 1.3 - match the descriptors
matches = matchDescriptors(descr1, descr2, .08);

showFeatureMatches(img1, corners1(:, matches(1,:)), img2, corners2(:, matches(2,:)), 20);

% Match SIFT descriptor
[matches, scores] = vl_ubcmatch(d1, d2);
matches_s = matches(:,scores>5E4);
showFeatureMatches(img1, f1(1:2, matches_s(1,:)), img2, f2(1:2, matches_s(2,:)), 40);
print('../report/images/matching_sift', '-djpeg90', '-f40')
