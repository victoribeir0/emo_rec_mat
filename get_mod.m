function [centros_gaus] = get_mod(n_quant,viz,plot_img)
%   triste - raiva - feliz - neutro

folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\wav\treino';
cd(folder);
% load('emo.mat');
% load('centros64.mat');

emocoes = ['T', 'W', 'F', 'N'];

for k = 1:4
    emo{k} = get_emo_feats(emocoes(k),0,'f0','treino');
end

dados = [];

emo{1} = emo{1}(:,1:590);
emo{2} = emo{2}(:,1:590);
emo{4} = emo{4}(:,1:590);

for k = 1:4
    dados = [dados emo{k}];
end

[~, centros] = kmeans2(dados,n_quant,0);

for k = 1:4
    seq{k,:} = get_clusters(emo{k},centros);
end

dx = zeros(n_quant,n_quant,4);
dxn = zeros(n_quant,n_quant,4);

for k = 1:4
    [dx(:,:,k),dxn(:,:,k),~] = get_com_voz(seq{k},viz,0,n_quant);
end

lim = 128;

for k = 1:4
    m = dxn(:,:,k);
    m(m >= lim | m == 0) = 255;
    m(m < lim) = 1;
    n_centros(k) = length(find(m == 1));
    dxn(:,:,k) = m;
end

for k = 1:4 % Obtém a posição dos centros.
    [l{k},c{k}] = find(dxn(:,:,k) == 1);
end

for k = 1:4 % Reduz o número de centros para o menor.
    tam(k) = length(l{k});
end

for k = 1:4
    l{k} = l{k}(1:min(tam));
    c{k} = c{k}(1:min(tam));
end

for k = 1:4
    centros_gaus(:,:,k) = [l{k} c{k}];
end

if plot_img
    subplot(221);
    imagesc(dxn(:,:,1)); title('Triste'); % --
    subplot(222);
    imagesc(dxn(:,:,2)); title('Raiva'); % --
    subplot(223);
    imagesc(dxn(:,:,3)); title('Feliz'); % --
    subplot(224);
    imagesc(dxn(:,:,4)); title('Neutro'); % --
    
    disp(n_centros);
end

end