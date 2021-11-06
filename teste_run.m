tic;
for n = 1:7
    [p0,C,cov,L,dims] = get_emo_gmm(25,'pro_jan');
    res = res_emo(C,p0,cov,0,'pro_jan',dims);
    min_erro(n) = emo_teste(res);
    fprintf('Erro: %d \n', n);
end,
toc
mean(min_erro)*100
std(min_erro)*100

subplot(611)
plot(dados(1,1:784),dados(2,1:784),'bo'); hold on, plot(dados(1,784*3:784*4),dados(2,784*3:784*4),'ro'); grid on
subplot(612)
plot(dados(1,1:784),dados(2,1:784),'bo'); hold on, plot(dados(1,784*3:784*4),dados(2,784*3:784*4),'ro'); grid on
subplot(613)
plot(dados(1,1:784),dados(2,1:784),'bo'); hold on, plot(dados(1,784*3:784*4),dados(2,784*3:784*4),'ro'); grid on
subplot(614)
plot(dados(1,1:784),dados(2,1:784),'bo'); hold on, plot(dados(1,784*3:784*4),dados(2,784*3:784*4),'ro'); grid on
subplot(615)
plot(dados(1,1:784),dados(2,1:784),'bo'); hold on, plot(dados(1,784*3:784*4),dados(2,784*3:784*4),'ro'); grid on
subplot(616)
plot(dados(1,1:784),dados(2,1:784),'bo'); hold on, plot(dados(1,784*3:784*4),dados(2,784*3:784*4),'ro'); grid on

seq_emo = cell2mat(seq_emo);
emok = [];
targ = [];
targ = 0*ones(784,1);
for k = 1:3
    targ = [targ; k*ones(784,1)];
end

for k = 1:4
    emok = [emok; y_5(seq_emo(k,:),:)];
end

seq_emo_mds = [emok targ];



