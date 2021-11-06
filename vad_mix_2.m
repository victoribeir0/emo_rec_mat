% VAD - Detector de atividade vocal.
% x = Sinal de voz.
% t = Tempo da janela em ms.
% av = Tempo de avanço em ms.
% jans = Índices das janelas com voz.

function [jans,nrg,lognrg,coef,zcr] = vad_mix_2(x,t,av, Fs)

Tjan = round((t/1000)*Fs); % Tamanho da janela em amostras.
Tav = round((av/1000)*Fs); % Tamanho do avanço em amostras.
Njan = round((length(x)-Tjan)/Tav); % Número de janelas.

% Inicialização das variáveis.
zcr = zeros(1,Njan);
nrg = zeros(1,Njan);
coef = zeros(1,Njan);
zcr_n = 0;

mat_x = buffer(x, Tjan, Tjan-Tav, 'nodelay');

%% Zero Crossing Rate
% Determina a taxa de cruazamento por zero em uma janela.
% Altas taxas indicam janelas sem voz.
% O resultado é quantizado em 0 ou 1.
% 1 indica janela com voz, 0 sem voz.

for i = 1:Njan
    ap = ((i-1)*Tav)+1;
    y = x(ap:ap+Tjan-1);
    
    for j = 2:length(y)
        a = y(j);
        b = y(j-1);
        zcr_n = (abs((sign(a)) - (sign(b))) * (1/(2*length(y)))) + zcr_n;
    end
    
    zcr(i) = zcr_n;
    zcr_n = 0;
    res = zcr;
    res(res <= mean(zcr)) = 1;
    res(res ~= 1) = 0;
end

%% Short-Time Energy
% Determina a energia de uma janela.
% Valores altos indicam janelas com voz (acima de 0.05 - normalizado de 0 à 1).

nrg = mat_x.^2;
nrg = sum(nrg,1);
nrg = nrg(1:Njan);
lognrg = log(nrg);

% Normalizado entre 0 e 1.
nrg = (nrg-min(nrg))./(max(nrg)-min(nrg));

%% Autocorrelation Coef.
% Determina a correlação entre as amostras.
% Valores altos indicam janelas com voz (acima de 0.85).

for i = 1:Njan
    ap = ((i-1)*Tav)+1;
    y = x(ap:ap+Tjan-1);
    sumj = 0;
    
    for j = 3:length(y)
        sumj = (y(j)*y(j-2)) + sumj;
    end
    
    coef(i) = sumj/sqrt(sum(y(2:end).^2)*sum(y(1:end).^2));        
end

%% Janelas com voz
jans = find(res == 1 & nrg >= 0.05 & coef >= 0.85);
end