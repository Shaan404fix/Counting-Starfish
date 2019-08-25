%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template script to Count Starfish in any given file
% Script contains functions required to fulfill ACW for Module 600100
% Author: Shaan Ishaq
% Date: 28 January 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Development and test Matlab code snippets to run specific functions
% Add functions for each part of your Image Processing Pipeline
% Add lines to run Toplevel function once loaded into Matlab
%Cleanup Everything
CleanUp()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Four top level Matlab calls for ACW demo
% Ensure these work for some ACw images prior to demo
% Process PRIMARY image
 StarfishCounts('C:\Users\shaan\Documents\Computer Science\Year 3\Semester 2\Computer Vision\Labs\ACW\Images', 'Starfish.jpg');
% Process different Noise image - SECOND image
% Starfish_noiseN will be replaced with for example Starfish_noise5
% StarfishCounts('C:\Users\shaan\Documents\Computer Science\Year 3\Semester 2\Computer Vision\Labs\ACW\Images', 'Starfish_noise5.jpg');
% Process different Colour Map image - THIRD image
% Starfish_mapM will be replaced with for example Starfish_map1
% StarfishCounts('C:\Users\shaan\Documents\Computer Science\Year 3\Semester 2\Computer Vision\Labs\ACW\Images', 'Starfish_map1.jpg');
% Process FOURTH image
% StarfishCounts('C:\Users\shaan\Documents\Computer Science\Year 3\Semester 2\Computer Vision\Labs\ACW\Images', 'starfish_5.jpg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Following line is example of script that calls intermediary function
% Source = readimagefile('X:\MyDrive\ComputerVision\ACW\Images', 'Starfish.jpg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% StarfishCount/2 - Runs Image Processing Pipeline
function StarfishCounts( folder, filename)
% Template Top Level function to Count number of Starfish in given image
% Ensure All functions or code lines are fully commented
  Source = readimagefile( folder, filename);
  figure
  hold on
  subplot(2,3,1);
  imshow(Source);title('Source');
  Grayimage = rgb2gray(Source); %convert to  a GrayScale image
  AdjustImage = imadjust(Grayimage); %increase the contrast of the image
  subplot(2,3,2);
  imshow(AdjustImage);title('Increased Contrast');
  %Remove Noise
  Grayimage = meds(AdjustImage);
  Grayimage = meanl(Grayimage);
  Grayimage = imadjust(Grayimage);
  subplot(2,3,3);
  imshow(Grayimage);title('Removed Noise');
  %Threshold/segment the image
  SegImage = threshimage(Grayimage);
  subplot(2,3,4);
  imshow(SegImage);title('segmented image');
  %Morph the image to make objects more noticeable
  morphed = Morph(SegImage);
  %Remove unwanted objects and keeponly the star fish
  Starfish = Feature(morphed);
  subplot(2,3,5);
  imshow(Starfish); title('extracted starfish');
  %Count the number of Starfiish in image
%   Starfish = acC(Grayimage,Starfish);
  [NumofStarfish,CC] = countFish(Starfish);
  subplot(2,3,6);
  imshow(Starfish); title(NumofStarfish);
  bb(CC);
  hold off

end % End of Top Level Matlab Function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function active = acC(Grayimage,BW)
%         active = activecontour(Grayimage, BW, 400, 'Chan-Vese');
% end
%BoundingBoxes
function bb(CC)
     image = regionprops(CC,'BoundingBox');
    for k = 1:length(image)
         currentBB = image(k).BoundingBox;            
         rectangle('Position',[currentBB(1),currentBB(2),currentBB(3) currentBB(4)],'Edgecolor','r','Linewidth',2);          
    end
end
% Count Starfish
function [NumFish,CC] = countFish(image)
    CC = bwconncomp(image,8);
    L = labelmatrix(CC);
    Label = bwlabel(L);
    m = CC.NumObjects;
    NumFish = m;
end
%Feature extraction
function extract = Feature(binimage)
    binimage = bwpropfilt(binimage, 'Area', [360, 1000]);
    binimage = bwpropfilt(binimage, 'Solidity', [-Inf, 0.8]);
    binimage = bwpropfilt(binimage, 'MajorAxisLength', [-Inf, 50 - eps(50)]);
    extract = bwpropfilt(binimage, 'Eccentricity', [-Inf, 0.9 - eps(0.9)]);
end
%Morphed image
function image = Morph(SegImage)
    SegImage = imclearborder(SegImage);
    se = strel('disk',10);
    SegImage = imclose(SegImage,se);
    se = strel('disk',1);
    SegImage = imerode(SegImage,se);
    binimage = bwareaopen(SegImage,100);
    image = imfill(binimage,'holes');
end
%Thresh the image
function image = threshimage(Grayimage)
    level = graythresh(Grayimage);
    bin = imbinarize(Grayimage,level);
    image = imcomplement(bin);
end
%Meadian filter used to remove any salt and pepper noise from within the
%image
function clean = meds(image)    
    image = medfilt2(image, [5 5]);
    clean = image;
end
%Mean filter to remove any noise and blur the image
function m = meanl(image)
    filt = fspecial('average',[5 5]);
    image2 = conv2(image, filt,'same');    
    m = uint8(image2);
end
%Clean Everything up
function CleanUp()
   clc; %clears command window
   clear all; %clears all figure windowas except those created by imtool
   close all;
   imtool close all; %close all figure windows created by imtool
   workspace; %makes sure that the workspace panel is showing
end
% readimagefile/2 Returns image
function image = readimagefile( folder, filename)
% just read file and return as image
% could have file checks
  fullfilename = fullfile(folder, filename);
  image = imread(fullfilename);
end % of readimagefile( folder, filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Empty function definition for returning multiple results
function [result1 result2] = DummyFunction( Arg1, Arg2, Arg3 )
end % of DummyFunction( Arg1, Arg2, Arg3 )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%eof