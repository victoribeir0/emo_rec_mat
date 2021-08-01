% Obt�m o modelo GMM para cada emo��o.
% K = N�mero de centros (gaussianas) para o GMM.
% ext = Tipo de extrator a ser usado ('mfcc', 'f0', etc.).
% rnn = VAD com rede neural (0 ou 1).
% [p0,c,S,L] = Par�metros do GMM (para cada emo��o).

function [p0,C,cov,L] = get_emo_gmm(K,ext,rnn)

% Inicializa��o para cada tipo de extrator ('mfcc', 'f0', etc.).
if strcmp(ext, 'mfcc')
    tam = 36;
    
elseif strcmp(ext, 'f0')
    tam = 12;
    
else
    tam = 2;
end

% Inicaliza��o dos par�metros do GMM (para cada emo��o).
C = zeros(K,tam);
cov = zeros(K,tam);
p0 = zeros(1,K);
L = zeros(1,10);

% Emo��es a serem procuradas.
emos = ['T';'W';'A';'F';'N'];
% emos = 'T';

% La�o for para cada emo��o.
for emo = 1:length(emos)
    
    % Extrai as caracter�sticas para cada emo��o.
    % emo��o, vad-rnn (1 ou 0), extrator ('mfcc', 'f0', ...).
    y = get_emo_feats(emos(emo),rnn,ext);     
    
    % Determina os par�metros do GMM para uma emo��o.
    [p0n,cn,Sn,Ln] = gmm_em_2(y', K, 10, 0);
    
    % Agrupa os par�metros do GMM, cada emo��o em uma dimens�o diferente.
    p0 = cat(1,p0,p0n');
    L = cat(1,L,Ln);
    C = cat(3,C,cn);
    cov = cat(3,cov,Sn);
    
end

% Remove as primeiras colunas (que s�o vazias).
C = C(:,:,2:end);
cov = cov(:,:,2:end);
p0 = p0(2:end,:);
L = L(2:end,:);