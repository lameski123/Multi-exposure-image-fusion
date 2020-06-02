function fu = mertensQuad(imgSeqColor, tempfu, flag)

wSize = 11;
stepSize = 2;

imgSeqColor = double(imgSeqColor);
[s1,s2,s3,s4] = size(imgSeqColor);
%prevImg = double(prevImg);

x = s1-wSize+1;
y = s2-wSize+1;

countMap = zeros(s1, s2, s4); 
countWindow = ones(wSize, wSize, s4);

xId = 1:stepSize:x;
xId = [xId xId(end)+1 :x];

yId = 1:stepSize:y;
yId = [yId yId(end)+1 :y];

lX = length(xId);
lY = length(yId);

offset = wSize-1;
    
store = [];
count = 1;

exitFlag = [];
tol = 1e-3;

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
        tBlocks = tempfu(i:i+offset, j: j+offset,:);
        for k = 1:s4
            A(:,k) = reshape(aBlocks(:,:,:,k),1,[]);
        end
        
        t = tBlocks(:);

        %The parameters for quadprog in order to find the optimal coeficients. 
        H = A'*A;
        f = -A'*t;
        Aeq = ones(s4,1)';
        beq = 1;
        if flag == 0
            lb = zeros(s4,1);
        else
            lb = -ones(s4,1);
        end
        ub = ones(s4,1);
        [w, fval, exitflag] = quadprog(H,f,[],[],Aeq,beq,lb,ub);
        
        for k = 1:s4
            store(count,k) = w(k);
        end
        exitFlag(count) = exitflag;
        count = count+1;


        
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

matStore2 = zeros(s1,s2,s4);
for row = 1 : lX
    for col = 1: lY
        i = xId(row);
        j = yId(col);
        
        for k = 1:s4
            matStore2(i:i+offset, j:j+offset, k) = matStore2(i:i+offset, j:j+offset, k) + matStore(row,col,k);
            countMap(i:i+offset, j:j+offset, k) = countMap(i:i+offset, j:j+offset, k) + countWindow(:,:,k);
        end
    end
end

matStore2 = matStore2./countMap;

%reproduction of new HDR

pyr = gaussian_pyramid(zeros(s1,s2,3));
nlev = length(pyr);

% multiresolution blending

for k = 1:s4
        % construct pyramid from each input image
            pyrW = gaussian_pyramid(matStore2(:,:,k));
            pyrI = laplacian_pyramid(imgSeqColor(:,:,:,k));
            %size(pyr{2})
            %size(pyrI{3})
            %size(pyrW{4})
            %ans = 166   252     3
            %ans = 341   512     3
            %ans = 166   252
            
            %ans = 171   256     3
            %ans =  86   128     3
            %ans =  21    32
    % blend
            for l = 1:nlev
                w = repmat(pyrW{l},[1 1 3]);
                pyr{l} = pyr{l} + w.*pyrI{l};
            end
end

% reconstruct
fu = reconstruct_laplacian_pyramid(pyr);

% for row = 1 : lX
%     for col = 1: lY
%         
%         i = xId(row);
%         j = yId(col);
%         blocks = imgSeqColor(i:i+offset, j:j+offset, :, :);
%         rBlock = zeros(wSize, wSize, s3);
%         for q = 1:s4
%             rBlock = rBlock + blocks(:, :, :, q)*matStore(row,col,q);
%         end
%         fu(i:i+offset, j:j+offset, :) = fu(i:i+offset, j:j+offset, :) + rBlock;
%         
%     end
% end
% fu = fu ./ countMap;
% fu(fu > 1) = 1;
% fu(fu < 0) = 0;

end