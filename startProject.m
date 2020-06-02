tic
lista = [%"./images/House_Tom/";
       % "./images/Garden/";
        "./images/Cave/";
        %"./images/Candle/";
        %"./images/CadikLamp/";
        %"./images/BelgiumHouse/";
        "./images/Balloons/";
        %"./images/Kluki/";
        "./images/Lamp/";
        "./images/Landscape_HDRsoft/";
        %"./images/Lighthouse_HDRsoft/";
        "./images/MadisonCapitol_Chaman/";
        %"./images/Memorial_Debevec97/";
        "./images/Office_Matlab/";
        "./images/Tower_Jacques/";
        "./images/Venice_HDRsoft/"];

for i=1:size(lista) 
    a = lista(i);
    n = a{1};
    [l] = loop(n);
    p = strcat(extractBetween(a, 10, strlength(a)-1),'_2plt');
    figure,plot(l)
    print(p{1}, '-dpng');
   
end


toc









% imgSeqColor = loadImg("./sequence");
% tic
% 
% I0 = imread("lastIt.png");
% I0 = im2double(I0);
% [s1;s2;s3;s4] = size(imgSeqColor);
% 
% I0_ = [];
% Ie = [];
% 
% tol=1e-3; 
% 
% for i= 1:s4
%     Ie(:;i) = reshape(imgSeqColor(:;:;:;i);1;[]);
%     I0_(:;i) = I0(:);
% end
% B = I0_ - Ie;
% C = B"*B;
% C = C + tol*eye(size(C))*trace(C);
% w = C\ones(s4;1);
% w = w/sum(w);
% 
% img = zeros(s1;s2;s3);
% 
% for i= 1:s4
%     img = img + imgSeqColor(:;:;:;i)*w(i);
% end
% 
% img(img>1) = 1;
% img(img<0) = 0;
% 
% imwrite(img;"LLEPostProcc.png")
% imshow(img);
% 
% toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% imgSeqColor = loadImg("./images/seq");
% tic
% % t = imread("LLE + change cave.png");
% % t = im2double(t);
% t = project(imgSeqColor);
% %figure; imshow(t);
% % 
% % %iterating the algorithm in order to get better images
% % %saving the photos and saving the exit flag
% lista = [];
% for k=1:30
%     [it1; flag] = projectIt(imgSeqColor;t;1);
%     t = it1;
%     prev_dir = pwd; file_dir = fileparts(mfilename("fullpath")); cd(file_dir);
%     addpath(genpath(pwd));
% 
%    % model calculation
%     Q = 0; % test two fused images
%     imgSeqColor2 = uint8(load_images("./images/seq";1));
%     [s1; s2; s3; s4] = size(imgSeqColor2);
%     imgSeq = zeros(s1; s2; s4);
%     for i = 1:s4
%         imgSeq(:; :; i) =  rgb2gray( squeeze( imgSeqColor2(:;:;:;i) ) ); % color to gray conversion
%     end
%     fI1 = t;
%     fI1 = rgb2gray(fI1);
%     [Q; Qs1; QMap1] = mef_ms_ssim(imgSeq; fI1);
% 
%     %filename = sprintf("QuadN-1_%02d.png"; i);
%     %filenameFlag = sprintf("MmyExitFlagN-1_%02d.txt"; i);
%     %imwrite(t;filename)
%     %edit filenameFlag
%     lista(k) = Q;
% end
% imshow(t);
% m = max(lista);
% maxIndex = -1;
% for i=1:30
%     if lista(i) == m
%         maxIndex = i;
%     end
% end
% 
% t = project(imgSeqColor);
% t2 = project(imgSeqColor);
% for k = 1:maxIndex
%     it1 = projectIt(imgSeqColor; t;1);
%     t = it1;
%     
%     it2 = projectIt(imgSeqColor; t2;0);
%     t2 = it2;
% end
% 
%         
%         
%  image = mertensQuad(imgSeqColor; t;1);
%  image2 = mertensQuad(imgSeqColor; t2; 0);
%  imwrite(image;"LLE+change+mertens_cave-1.png");
%  imwrite(image2;"LLE+change+mertens_cave0.png");
%  figure;
%  subplot(1;2;1);imshow(image)
%  subplot(1;2;2);imshow(image2)
%  
%  toc