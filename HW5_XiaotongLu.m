%HW5
%GB comments
1a 70 Missing an output image of the segmentation
1b 100
1c 70 No explanation of your resulting image
1d 100
2yeast: 90. Becareful in your script. You implement imfill to create img4_mark but you end up filling in the whole object because the edges were not previously well defined. I believe you could have just taken the complement of the image using the function imcomplement to achieve a similar goal. 
2worm: 100
2bacteria: 75 The segmentation could be significantly better. There are many tools you have learned in class. Expect to implement these tools to get better segmentation.
2phase: 85 Illastik is not the best tool for all types of images. When you import your segmentation mask, you start with a very messy image. You have done your best to further segment, but you are still left with a lot of masks with “holes” in them and a lot of tiny masks that don’t contribute to any real objects in the image.  Many of the masks can be filled in using the function imfill on the final image and a lot of the mask debris (tiny spots) can be cleaned up using the function bwareaopen. With all this said, I think the question would have been best approached not using Illastik.
Overall: 86

% Note. You can use the code readIlastikFile.m provided in the repository to read the output from
% ilastik into MATLAB.

%% Problem 1. Starting with Ilastik

% Part 1. Use Ilastik to perform a segmentation of the image stemcells.tif
% in this folder. Be conservative about what you call background - i.e.
% don't mark something as background unless you are sure it is background.
% Output your mask into your repository. What is the main problem with your segmentation?  
The mask has been outputed into my repository.
The main problem is that the cell intensity is kind of similar to the background so when I marke the cell with label 1, 
the background can also be marked by the label 1. 

% Part 2. Read you segmentation mask from Part 1 into MATLAB and use
% whatever methods you can to try to improve it. 
img_ori=h5read('stemcells_Simple Segmentation_norm.h5','/exported_data');
img_ori=squeeze(img_ori==1);
imshow(img_ori);
img_filter=imfilter(img_ori,fspecial('gaussian',4,2));
img_bg=imopen(img_filter,strel('disk',100));
img_bgsub=imsubtract(img_filter,img_bg);
img_thre=img_bgsub>0.9;
imshow(img_thre);
im_open=imopen(img_thre,strel('disk',5));
imshow(im_open)



% Part 3. Redo part 1 but now be more aggresive in defining the background.
% Try your best to use ilastik to separate cells that are touching. Output
% the resulting mask into the repository. What is the problem now?
img_ori=h5read('stemcells_Simple Segmentation_aggre.h5','/exported_data');
img_ori=squeeze(img_ori==1);
imshow(img_ori);
img_filter=imfilter(img_ori,fspecial('gaussian',4,2));
img_bg=imopen(img_filter,strel('disk',100));
img_bgsub=imsubtract(img_filter,img_bg);
img_thre=img_bgsub>0.9;
imshow(img_thre);
im_open=imopen(img_thre,strel('disk',6));
imshow(im_open)

% Part 4. Read your mask from Part 3 into MATLAB and try to improve
% it as best you can.
im_bw=im_open>0.5;
CC=bwconncomp(im_bw);
stats=regionprops(CC,'Area');
area=[stats.Area];
AA=mean(area)+std(area);
fusedcandidates=area>AA;
sublist=CC.PixelIdxList(fusedcandidates);
sublist=cat(1,sublist{:});
fusedmask=false(size(im_open));
fusedmask(sublist)=1;
s=round(1.2*sqrt(mean(area))/pi);
nucmin=imerode(fusedmask,strel('disk',s));
outside=~imdilate(fusedmask,strel('disk',1));
basin=imcomplement(bwdist(outside));
basin=imimposemin(basin,nucmin|outside);
pcolor(basin);shading flat;
L=watershed(basin);
imshow(L,[]);colormap('jet');caxis([0 20]);
newmask=L>1|(im_bw-fusedmask);
imshow(newmask,'InitialMagnification','fit');






%% Problem 2. Segmentation problems.

% The folder segmentationData has 4 very different images. Use
% whatever tools you like to try to segement the objects the best you can. Put your code and
% output masks in the repository. If you use Ilastik as an intermediate
% step put the output from ilastik in your repository as well as an .h5
% file. Put code here that will allow for viewing of each image together
% with your final segmentation. 
img1=h5read('bacteria_SimpleSegmentation.h5','/exported_data');
img1=squeeze(img1==1);
imshow(img1);
img1_open=imopen(img1,strel('disk',10));
imshow(img1_open)


img2=h5read('cellPhaseContrast_Simple Segmentation_cell.h5','/exported_data');
img2=squeeze(img2==1);
imshow(img2)
img2_filter=imfilter(img2,fspecial('gaussian',4,2));
img2_bg=imopen(img2_filter,strel('disk',100));
img2_bgsub=imsubtract(img2_filter,img2_bg);
img2_thre=img2_bgsub>0.15;
imshow(img2_thre);
img2_double=im2double(img2_thre);
edge2_img=edge(img2_double,'canny');
imshow(edge2_img,[0.01 0.05])
img2_smooth=imfilter(img2_double,fspecial('gaussian',4,2));
edge_img2=edge(img2_smooth,'canny',[0.01 0.05]);
img2_mark=imerode(imfill(edge_img2,'holes'),strel('disk',3));
toshow=cat(3,img2_mark,im2double(imadjust(img2_double)),zeros(size(img2_double)));
imshow(toshow)

img3=h5read('worm2.h5','/exported_data');
img3=squeeze(img3==1);
imshow(img3)
img3_filter=imfilter(img3,fspecial('gaussian',4,2));
img3_bg=imopen(img3_filter,strel('disk',100));
img3_bgsub=imsubtract(img3_filter,img3_bg);
img3_thre=img3_bgsub>0.15;
imshow(img3_thre);
img3_erode=imerode(img3_thre,strel('sphere',1));
imshow(img3_erode)
img3_dilate=imdilate(img3_erode,strel('disk',7));
imshow(img3_dilate);


img3_close=imclose(img3_thre,strel('sphere',5));
imshow(img3_close)
img3_open=imopen(img3_thre,strel('sphere',1));
imshow(img3_open)
img3_dilate=imdilate(img3_thre,strel('sphere',4));
imshow(img3_dilate);

img4=h5read('yeast_Simple Segmentation_yeast.h5','/exported_data');
img4=squeeze(img4==1);
imshow(img4)
img4_filter=imfilter(img4,fspecial('gaussian',4,2));
img4_bg=imopen(img4_filter,strel('disk',100));
img4_bgsub=imsubtract(img4_filter,img4_bg);
img4_thre=img4_bgsub>0.15;
imshow(img4_thre);
img4_double=im2double(img4_thre);
edge4_img=edge(img4_double,'canny');
imshow(edge4_img,[0.01 0.05])
img4_smooth=imfilter(img4_double,fspecial('gaussian',4,2));
edge_img4=edge(img4_smooth,'canny',[0.01 0.05]);
img4_mark=imerode(imfill(edge_img4,'holes'),strel('disk',3));
imshow(img4_mark)
img_bw4=img4_mark>0.5;
imshow(img_bw4)
D=bwdist(~img_bw4);
D=-D;
D(~img_bw4)=-Inf;
L=watershed(D);
L(~img_bw4)=0;
rgb4=label2rgb(L,'jet',[.5 .5 .5]);
figure;
imshow(rgb4,'InitialMagnification','fit');


subplot(2,2,1);
imshow(img1_open);
subplot(2,2,2);
imshow(toshow);
subplot(2,2,3);
imshow(img3_dilate);
subplot(2,2,4);
imshow(rgb4);
