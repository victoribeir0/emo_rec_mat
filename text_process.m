function [X1,X2] = text_process(seq,dim)
% Leitura do arquivo e determinação dos caracteres.
% fileID = fopen(arquivo);
% format = '%c';
% texto = fscanf(fileID,format);
% texto = regexp(texto, '\S', 'match'); % Determina os caracteres.
% seq = cell2mat(car);                % Transforma em um vetor.
car = unique(seq);

[dx1,~] = get_dist_text(seq,1,0,2, 1);
[dx2,~] = get_dist_text(seq,1,0,2, 0);
figure, X1 = get_mds_3(dim,dx1); 
figure, X2 = get_glove(dim,dx2);

figure,
for k = 1:length(car)
    plot(X1(k,1),X1(k,2),'bo'); hold on; grid on;
    text(X1(k,1),X1(k,2),car(k),'FontSize',18);
end
title('MDS');

figure,
for k = 1:length(car)
    plot(X2(k,1),X2(k,2),'bo'); hold on; grid on;
    text(X2(k,1),X2(k,2),car(k),'FontSize',18);
end
title('GloVe');
end