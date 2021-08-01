% Obtém o modelo GMM para cada emoção.
% K = Número de centros (gaussianas) para o GMM.
% ext = Tipo de extrator a ser usado ('mfcc', 'f0', etc.).
% rnn = VAD com rede neural (0 ou 1).
% [p0,c,S,L] = Parâmetros do GMM (para cada emoção).

function [p0,C,cov,L] = get_emo_gmm(K,ext,rnn)

% Inicialização para cada tipo de extrator ('mfcc', 'f0', etc.).
if strcmp(ext, 'mfcc')
    tam = 36;
    
elseif strcmp(ext, 'f0')
    tam = 12;
    
else
    tam = 2;
end

% Inicalização dos parâmetros do GMM (para cada emoção).
C = zeros(K,tam);
cov = zeros(K,tam);
p0 = zeros(1,K);
L = zeros(1,10);

% Emoções a serem procuradas.
emos = ['T';'W';'A';'F';'N'];
% emos = 'T';

% Laço for para cada emoção.
for emo = 1:length(emos)
    
    % Extrai as características para cada emoção.
    % emoção, vad-rnn (1 ou 0), extrator ('mfcc', 'f0', ...).
    y = get_emo_feats(emos(emo),rnn,ext);     
    
    % Determina os parâmetros do GMM para uma emoção.
    [p0n,cn,Sn,Ln] = gmm_em_2(y', K, 10, 0);
    
    % Agrupa os parâmetros do GMM, cada emoção em uma dimensão diferente.
    p0 = cat(1,p0,p0n');
    L = cat(1,L,Ln);
    C = cat(3,C,cn);
    cov = cat(3,cov,Sn);
    
end

% Remove as primeiras colunas (que são vazias).
C = C(:,:,2:end);
cov = cov(:,:,2:end);
p0 = p0(2:end,:);
L = L(2:end,:);