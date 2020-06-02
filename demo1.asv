

%% model calculation

lista = [
%         "./images/Cave/";
%         "./images/Venice_HDRsoft/"
%         "./images/Tower_Jacques/";
%         "./images/MadisonCapitol_Chaman/";
%         "./images/Lighthouse_HDRsoft/";
%         "./images/Lamp/";
%         "./images/Kluki/";
        "./images/Balloons/"
%         "./images/Memorial_Debevec97/";
%         "./images/Garden/";
%         "./images/Landscape_HDRsoft/";
%         "./images/Office_Matlab/";
%         "./images/CadikLamp/";
%         "./images/BelgiumHouse/";
%         "./images/House_Tom/";
%         "./images/Candle/";
        ];
    
    
k = 16;
grades = zeros(k,2);    
for j=1
Q = zeros(2,1); % test two fused images
name = lista(j);
imgSeqColor = uint8(load_images(name{1},1));
[s1, s2, s3, s4] = size(imgSeqColor);
imgSeq = zeros(s1, s2, s4);
for i = 1:s4
    imgSeq(:, :, i) =  rgb2gray( squeeze( imgSeqColor(:,:,:,i) ) ); % color to gray conversion
end

im1 = strcat(extractBetween(name,10,strlength(name)-1),"New1.png");
imshow(fu)
fI1 = im2double(fu);
fI1 = double(rgb2gray(fI1));
[Q(1), Qs1, QMap1] = mef_ms_ssim(imgSeq, 255*fI1);
im0 = strcat(extractBetween(name,10,strlength(name)-1),"New0.png");
fI2= imread(im0{1});
fI2 = double(rgb2gray(fI2));
[Q(2), Qs2, QMap2] = mef_ms_ssim(imgSeq, fI2);

grades(j,:) = Q;

end
%xlswrite('results.xlsx', grades, 'H2:I17');
grades