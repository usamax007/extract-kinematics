function [psi, theta, phi, detR, errorR] = axes2rpyAngles(axes1, axes2)
% axes1 rotation to axes2 in this order: yaw(phi), pitch(theta), roll(psi)
% about the current axes
R = axes2/axes1;
detR = det(R);
checkR = R'-inv(R);
checkR = checkR(:);
errorR = sqrt(checkR'*checkR);
phi = atan2(R(2,1),R(1,1));
theta = atan2(-R(3,1),sqrt(R(3,2)^2+R(3,3)^2));
psi = atan2(R(3,2),R(3,3));
end