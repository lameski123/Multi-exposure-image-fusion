function [fu, exitFlag] = project(imgSeqColor, varargin)
params = inputParser;

wSize = 39;
stepSize = 2;

addRequired(params,'imgSeqColor');
addParameter(params,'wSize',wSize,@isnumeric);
addParameter(params,'stepSize',stepSize,@isnumeric);

parse(params,imgSeqColor, varargin{:});

imgSeqColor = double(imgSeqColor);
[s1,s2,s3,s4] = size(imgSeqColor);

wSize = params.Results.wSize;
stepSize = params.Results.stepSize;

window = ones(wSize);
window = window/ sum(window(:));
x = s1-wSize+1;
y = s2-wSize+1;
lMu = zeros(x,y,s4);
lMuSq = zeros(x,y,s4);
temp = zeros(x,y,s3);

fu = zeros(s1, s2, s3);
tempfu = fu;
for i = 1 : s4
    for j = 1 : s3
        temp(:,:,j) = filter2(window, imgSeqColor(:, :, j, i), 'valid');
    end
    lMu(:,:,i) = mean(temp, 3); % (R + G + B) / 3;
    lMuSq(:,:,i) = lMu(:,:,i) .* lMu(:,:,i);
end

sigmaSq = zeros(x, y, s4); % signal strength from variance
for i = 1 : s4
    for j = 1 : s3
        temp(:,:,j) = filter2(window, imgSeqColor(:, :, j, i).*imgSeqColor(:, :, j, i), 'valid') - lMuSq(:,:,i);
    end
    sigmaSq(:,:,i) = mean(temp, 3);
end
sigma = sqrt( max( sigmaSq ,0) );
ed = sigma * sqrt( wSize^2 * s3 ) + 0.001; % signal strengh

countMap = zeros(s1, s2, s3); 
countWindow = ones(wSize, wSize, s3);

xId = 1:stepSize:x;
xId = [xId xId(end)+1 :x];

yId = 1:stepSize:y;
yId = [yId yId(end)+1 :y];

lX = length(xId);
lY = length(yId);

offset = wSize-1;


%s4-1 means not the maximum, but the lower element
ls = NthPatch(ed,xId,yId,lX,lY,s4,s4);

%length(ls)
k = 1;

% constructing the image from the patch with best L2 norm of mean
% difference
for row = 1 : lX
    for col = 1: lY
        
        i = xId(row);
        j = yId(col);
        blocks = imgSeqColor(i:i+offset, j:j+offset, :, :);
        rBlock = zeros(wSize, wSize, s3);
        
        
        rBlock = rBlock + blocks(:, :, :, ls(k));
        
        tempfu(i:i+offset, j:j+offset, :) = tempfu(i:i+offset, j:j+offset, :) + rBlock;
        
        countMap(i:i+offset, j:j+offset, :) = countMap(i:i+offset, j:j+offset, :) + countWindow;
        k = k+1;
    end
end

tempfu = tempfu ./ countMap;
tempfu(tempfu > 1) = 1;
tempfu(tempfu < 0) = 0;

%figure,imshow(tempfu);

%imwrite(tempfu, 'initialImage.png')
tol = 1e-3;
store = [];
count = 1;
exitFlag = [];
%finding optimal coeficients for contribution
for row = 1 : lX
    for col = 1: lY
        i = xId(row);
        j = yId(col);
        aBlocks = imgSeqColor(i:i+offset, j: j+offset,:,:);
       % rBlock = zeros(wSize,wSize, s3);
        tBlocks = tempfu(i:i+offset, j: j+offset,:);
        
        for k = 1:s4
            A(:,k) = reshape(aBlocks(:,:,:,k),1,[]);
            t(:,k) = reshape(tBlocks,1,[]);
        end
        
        B = A - t;
        C = B'*B;
        C = C + tol*eye(size(C))*trace(C);
        w = C\ones(s4,1);
        w = w/sum(w);
        
        for k = 1:s4
            store(count,k) = w(k);
        end
        count = count+1;
%         i = xId(row);
%         j = yId(col);
%         aBlocks = imgSeqColor(i:i+offset, j: j+offset,:,:);
%         tBlocks = tempfu(i:i+offset, j: j+offset,:);
%         for k = 1:s4
%             A(:,k) = reshape(aBlocks(:,:,:,k),1,[]);
%         end
%         
%         t = tBlocks(:);
% 
%         %The parameters for quadprog in order to find the optimal coeficients. 
%         H = A'*A;
%         f = -A'*t;
%         Aeq = ones(s4,1)';
%         beq = 1;
%         if flag == 0
%             lb = zeros(s4,1);
%         else
%             lb = -ones(s4,1);
%         end
%         ub = ones(s4,1);
%         [w, fval, exitflag] = quadprog(H,f,[],[],Aeq,beq,lb,ub);
%         
%         for k = 1:s4
%             store(count,k) = w(k);
%         end
%         exitFlag(count) = exitflag;
%         count = count+1;


        
    end
end

filter = [1/16,1/8,1/16; 1/8,1/4,1/8; 1/16,1/8,1/16];

matStore = zeros(lX,lY,s4);

%constructing matrices of coeficients
c =1;
for q = 1:lX
    for r = 1:lY
        for k = 1:s4
            matStore(q,r,k) = matStore(q,r,k) + store(c,k);
        end
        c = c+1;
    end
end

suma = zeros(lX,lY);

%using weighted avg filter
for k = 1:s4
    matStore(:,:,k) = imfilter(matStore(:,:,k), filter);
end

for q = 1:lX
    for r = 1:lY
        for k = 1:s4
            suma(q,r) = suma(q,r) + matStore(q,r,k);
        end
    end
end

%re-normalizing 
for q = 1:lX
    for r = 1:lY
        for k = 1:s4
            matStore(q,r,k) = matStore(q,r,k)/suma(q,r); 
        end
    end
end
 

%reproduction of new HDR
for row = 1 : lX
    for col = 1: lY
        
        i = xId(row);
        j = yId(col);
        blocks = imgSeqColor(i:i+offset, j:j+offset, :, :);
        rBlock = zeros(wSize, wSize, s3);
        for q = 1:s4
            rBlock = rBlock + blocks(:, :, :, q)*matStore(row,col,q);
        end
        fu(i:i+offset, j:j+offset, :) = fu(i:i+offset, j:j+offset, :) + rBlock;
        
    end
end
fu = fu ./ countMap;
fu(fu > 1) = 1;
fu(fu < 0) = 0;

end