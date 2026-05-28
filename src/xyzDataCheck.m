function [x_flag, y_flag, z_flag] = xyzDataCheck(vectIndices)
% make sure no x, y or z coordinates are missing
x_flag = 1;
y_flag = 1;
z_flag = 1;
n = length(vectIndices);
if(mod(n,3)~=0)
    n = n - mod(n,3);
end
counter = 1;
for i = 1:n/3
    if(any(vectIndices(counter,1)~=1))
        x_flag = 0;
    else
        counter = counter + 1;
    end
    if(any(vectIndices(counter,1)~=2))
        y_flag = 0;
    else
        counter = counter + 1;
    end
    if(any(vectIndices(counter,1)~=3))
        z_flag = 0;
    else
        counter = counter + 1;
    end
end