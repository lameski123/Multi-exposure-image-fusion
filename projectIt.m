function [fuIt, exitFlag] = projectIt(imgSeqColor,tempfu,flag)

wSize = 11;
stepSize = 2;

imgSeqColor = double(imgSeqColor);
[s1,s2,s3,s4] = size(imgSeqColor);
%prevImg = double(prevImg);

x = s1-wSize+1;
y = s2-wSize+1;


fuIt = zeros(s1, s2, s3);
countMap = zeros(s1, s2, s3); 
countWindow = ones(wSize, wSize, s3);

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
%finding optimal coeficients' contribution
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

%weighted average filter
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
    matStore(:,:,k) = conv2(matStore(:,:,k), filter, 'same');
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
        fuIt(i:i+offset, j:j+offset, :) = fuIt(i:i+offset, j:j+offset, :) + rBlock;
        countMap(i:i+offset, j:j+offset, :) = countMap(i:i+offset, j:j+offset, :) + countWindow;
    end
end
%averaging the patches.
fuIt = fuIt ./ countMap;
fuIt(fuIt > 1) = 1;
fuIt(fuIt < 0) = 0;

end