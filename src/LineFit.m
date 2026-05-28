function [x_fitData, y_fitData, z_fitData] = LineFit(x,y,z)
xyz=[x,y,z];
r = mean(xyz);
xyz = bsxfun(@minus,xyz,r);
[~,~,V]=svd(xyz,0);
x_fit=@(z_fit) r(1)+(z_fit-r(3))/V(3,1)*V(1,1);
y_fit=@(z_fit) r(2)+(z_fit-r(3))/V(3,1)*V(2,1);
x_fitData = x_fit(z);
y_fitData = y_fit(z);
z_fitData = z;
%figure(1),clf(1)
%plot3(centData.RWT(1,:),centData.RWT(2,:),centData.RWT(3,:),'b')
%hold on
%plot3(x_fit(centData.RWT(3,:)),y_fit(centData.RWT(3,:)),centData.RWT(3,:),'r')