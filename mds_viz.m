cd('C:\Users\victo\Documents\Dataset _ EmoDB2');
load('emo_f0_3_treino.mat');
load('centros64_2.mat');
%load('mat_mds_3.2.mat');
%load('mat_mds_5.2.mat');

emo = emo_f0_3_treino;

emo{1} = emo{1}(:,1:784);
emo{2} = emo{2}(:,1:784);
emo{4} = emo{4}(:,1:784);

dados = [];

for k = 1:7
    dados = [dados emo_pro_jan_treino{k}];
end

% [~, centros] = kmeans2(dados,64,0);

for k = 1:7
    seq_emo{k,:} = get_clusters(emo_pro_jan_treino{k},centros);
end

seq_full = [];
for k = 1:7
    seq_full = [seq_full seq_emo{k}]; 
end

seq_full = [seq_emo{1,:} seq_emo{2,:} seq_emo{3,:} seq_emo{4,:}];
[dx3,~] = get_com_voz(seq_full,3,0,64,2); % seq_emo{k}
%[dx5,~] = get_com_voz(seq_full,16,0,64,3);

[y_3,stress,dy] = get_mds(dx3,1:10);
%[y_5,stress,dy] = get_mds(dx5,1:10);

var1 = [5 7];
emos = [2 3];

seq_emo = cell2mat(seq_emo);
plot3(y_5(seq_emo(emos(1),:),var1(1)), y_5(seq_emo(emos(1),:),var1(2)), y_5(seq_emo(emos(1),:),var1(3)),'b*'); hold on;
plot3(y_5(seq_emo(emos(2),:),var1(1)), y_5(seq_emo(emos(2),:),var1(2)), y_5(seq_emo(emos(2),:),var1(3)),'ro'); ...
    grid on; legend('raiva','feliz');

figure,   
plot3(y_3(seq_emo(emos(1),:),var1(1)), y_3(seq_emo(emos(1),:),var1(2)), y_3(seq_emo(emos(1),:),var1(3)),'b*'); hold on;
plot3(y_3(seq_emo(emos(2),:),var1(1)), y_3(seq_emo(emos(2),:),var1(2)), y_3(seq_emo(emos(2),:),var1(3)),'ro'); ...
    grid on; legend('raiva','feliz'); xlabel('5'); ylabel('6'); zlabel('7');
   
