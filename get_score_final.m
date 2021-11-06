function rf = get_score_final(r1,r2,r3)

for i = 1:size(r1,1)
   for j = 1:size(r1,2) 
       ent = [r1(i,j); r2(i,j); r3(i,j)];
       prev = feed_fusion(abs(log(ent)));
       rf(i,j) = prev;
   end
end

end

function prev = feed_fusion(ent)

folder = 'C:\Users\victo\Documents\Matlab Arquivos\REC\EMOREC\pesos_fusao';
cd(folder);
load('w1.mat');
load('w2.mat');

x = [1; ent];
z = tanh(w1*x);
z = [1; z];
y = 1./(1+exp(-w2*z));
prev = y;

end