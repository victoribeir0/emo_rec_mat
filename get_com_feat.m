function [vet, dx] = get_com_feat(x,viz)

folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2';
cd(folder);

load('centros64.mat');
seq = get_clusters(x,centros);
[~,dx_full] = get_mod(64,3);

N_cen = 25;

%if length(seq)-viz > viz+1
[dx,~,~] = get_com_voz(seq,viz,0,64);

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

%     [l,c] = find(dx == 1);
%
%     ll = []; cc = [];
%
%     for k = 1:size(cen_g,3)
%
%         for i = 1:length(c)
%             ll = [ll length(find(cen_g(:,1,k) == l(i)))/N_cen]; % quant. de centros que coincidem.
%             cc = [cc length(find(cen_g(:,2,k) == c(i)))/N_cen];
%         end
%
%         vet(k) = sum(sqrt((ll.^2)+(cc.^2)));
%         ll = []; cc = [];
%     end
%
%else
%    dx = 0;
%    vet = 's';
%end

end