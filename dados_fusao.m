function [dados, rot] = dados_fusao(res1,res2,res3)

idxn = 1:size(res1,1);
idxn = randperm(length(idxn),31);

jj = 1;
verdadeiro = [];
falso = [];

for i = 1:31:size(res1,1)
    idx = i:i+30;
    plot3(res1(idx,jj), res2(idx,jj), res3(idx,jj), 'b*'); hold on
    verdadeiro = [verdadeiro; res1(idx,jj) res2(idx,jj) res3(idx,jj)];
    
    plot3(res1(idxn(~ismember(idxn,idx)),jj),res2(idxn(~ismember(idxn,idx)),jj),res3(idxn(~ismember(idxn,idx)),jj),'ro'); hold on; grid on; xlabel('Score_{mfcc}'); ylabel('Score_{f0}'); zlabel('Score_{com}');
    falso = [falso; res1(idxn(~ismember(idxn,idx)),jj) res2(idxn(~ismember(idxn,idx)),jj) res3(idxn(~ismember(idxn,idx)),jj)];
    
    jj = jj+1;
end

rot1 = ones(size(verdadeiro,1),1);
rot2 = zeros(size(falso,1),1);
rot = [rot1; rot2]';

dados = [verdadeiro; falso]';
end