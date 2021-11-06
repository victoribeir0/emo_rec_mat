function [dados, rot] = dados_fusao(res1,res2,res3)

idxn = 1:size(res1,1);
idxn = randperm(length(idxn),31);

jj = 1;
verdadeiro = [];
falso = [];

for i = 1:31:size(res1,1)
    idx = i:i+30;
    %plot3(res1(idx,jj), res2(idx,jj), res3(idx,jj), 'b*'); hold on
    %plot3(res1(idxn(~ismember(idxn,idx)),jj), res2(idxn(~ismember(idxn,idx)),jj), res3(idxn(~ismember(idxn,idx)),jj), 'ro'); hold on; grid on; xlabel('Score_{f01}'); ylabel('Score_{com}'); zlabel('Score_{f03}');
    
    %figure,
    plot3(log10(res1(idx,jj)), log10(res2(idx,jj)), log10(res3(idx,jj)), 'b*'); hold on
    plot3(log10(res1(idxn(~ismember(idxn,idx)),jj)), log10(res2(idxn(~ismember(idxn,idx)),jj)), log10(res3(idxn(~ismember(idxn,idx)),jj)), 'ro'); hold on; grid on; xlabel('log Score_{f01}'); ylabel('log Score_{com}'); zlabel('log Score_{f03}');
    
    verdadeiro = [verdadeiro; res1(idx,jj) res2(idx,jj) res3(idx,jj)];    
    falso = [falso; res1(idxn(~ismember(idxn,idx)),jj) res2(idxn(~ismember(idxn,idx)),jj) res3(idxn(~ismember(idxn,idx)),jj)];
    
    jj = jj+1;
end

rot1 = ones(size(verdadeiro,1),1);
rot2 = zeros(size(falso,1),1);
rot = [rot1; rot2];

dados = (([verdadeiro; falso]));
end