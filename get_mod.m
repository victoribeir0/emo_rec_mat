function [centros_gaus,dx] = get_mod(n_quant,viz)
%   triste - raiva - feliz - neutro

folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2';
cd(folder);
load('emo_full_treino.mat');
% load('centros64.mat');

% emocoes = ['T', 'W', 'F', 'N'];

%for k = 1:4
%    emo{k} = get_emo_feats(emocoes(k),0,'f0','treino');
%end

dados = [];

% emo{1} = emo{1}(:,1:784);
% emo{2} = emo{2}(:,1:784);
% emo{4} = emo{4}(:,1:784);

for k = 1:7
    dados = [dados emo_pro_jan_treino{k}];
end

[~, centros] = kmeans2(dados,n_quant,0);

for k = 1:7
    seq{k,:} = get_clusters(emo_pro_jan_treino{k},centros);
end

dx = zeros(n_quant,n_quant,4);
dxn = zeros(n_quant,n_quant,4);

for k = 1:4
    [dx(:,:,k),~] = get_com_voz(seq{k},viz,0,n_quant);
end

N_cen = 100;

for k = 1:4
    vet_dx = reshape((dx(:,:,k)),1,n_quant*n_quant);    
    vet_dx(1:n_quant+1:length(vet_dx)) = 255;  % ---
    [~,sortIndex] = sort(vet_dx(:));
    minD = sortIndex(1:N_cen);
    vet_dx(minD) = 200;
    
    maxD = setdiff(sortIndex,minD);
    vet_dx(maxD) = 255;
    dx(:,:,k) = reshape(vet_dx,64,64);
end

% lim = 128;
% 
% for k = 1:4
%     m = dxn(:,:,k);
%     m(m >= lim | m == 0) = 255;
%     m(m < lim) = 1;
%     n_centros(k) = length(find(m == 1));
%     dxn(:,:,k) = m;
% end

l = zeros(N_cen,4);
c = zeros(N_cen,4);
centros_gaus = zeros(N_cen,2,4);

for k = 1:4 % Obt�m a posi��o dos centros.
    [l(:,k),c(:,k)] = find(dx(:,:,k) == 200);
end

for k = 1:4
    centros_gaus(:,:,k) = [l(:,k) c(:,k)];
end

end