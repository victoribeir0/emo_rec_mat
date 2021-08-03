function [vet, dx] = get_com_feat(x,viz)

folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2';
cd(folder);

load('centros64.mat');
seq = get_clusters(x,centros);
[~,dx_full] = get_mod(64,3);

N_cen = 25;

%if length(seq)-viz > viz+1
[dx,P] = get_com_voz(seq,viz,0,64);

vet_dx = reshape((dx),1,64*64);
vet_dx(1:64+1:length(vet_dx)) = 255;  % ---
[~, sortIndex] = sort(vet_dx(:));
minD = sortIndex(1:N_cen);
vet_dx(minD) = 1;

maxD = setdiff(sortIndex,minD);
vet_dx(maxD) = 255;
dx = reshape(vet_dx,64,64);

vet = zeros(1,4);

for k = 1:4
    mat = (dx_full(:,:,k)-dx);
    vet(k) = length(find(mat == 199))/N_cen;
end

nrg_dx = sum(P(:).^2)/(64*64);
ent_P = -sum(P(:).*log2(P(:)));

lins = [1:64]'*ones(1,64);
cols = lins';

aux = (lins-cols).^2;
contr_dx = sum(aux(:).*P(:))/(64*64);
homo_dx = sum(P(:)./(1+aux(:)));

vet = [vet nrg_dx ent_P contr_dx homo_dx];
% cor neg: nrg_gx e ent_P
% cor pos: nrg_gx e homo_dx
% cor neg: ent_P e homo_dx

end