function vect_out = normalizeVect(vect_in)
norm_vect = norm(vect_in);
if(norm_vect~=0)
    vect_out = vect_in/norm_vect;
else
    error('Input vector cannot be a zero vector');
end