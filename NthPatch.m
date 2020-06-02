function [ ls ] = NthPatch(ed, xId, yId,lX,lY,N,s4)
%this function is for finding the nth biggest variace patch
m = -1;
ls = [];
orig = [];
%finding the maximum of every patch
for row = 1 : lX
    for col = 1: lY
        i = xId(row);
        j = yId(col);    
        for k = 1:s4
%             if m<ed(i,j,k)
%                 m = ed(i,j,k);
%                 ind = k;
%             end
            orig(end+1) = ed(i,j,k);
        end
        pom = 1;
        so = sort(orig);
        [~, size2] = size(orig);
        for i2 = 1:size2
            if so(N) == orig(i2)
                m = i2;
                break;
            end
        end
        %m
        ls(end+1) = m;
        m = -1;
        orig= [];
    end
end

end

