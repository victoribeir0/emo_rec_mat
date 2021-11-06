% Obtém o modelo GMM para cada emoção.
% K = Número de centros (gaussianas) para o GMM.
% ext = Tipo de extrator a ser usado ('mfcc', 'f0', etc.).
% rnn = VAD com rede neural (0 ou 1).
% [p0,c,S,L] = Parâmetros do GMM (para cada emoção).

function [p0,C,cov,L,dims] = get_emo_gmm(K,ext)

folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\dados\dados_75_25';
cd(folder);

load('emo_lfpc_treino.mat');
load('emo_pro_jan_treino.mat');
load('centros_pro_jan_64.mat');
%load('mds_pro_16432');
%load('mds_pro_16433');
%load('mds_pro_16452');
load('mds_pro_16453');
dims = [];

% load('emo_f0_aud_treino.mat');

% Inicalização dos parâmetros do GMM (para cada emoção).
C = []; cov = []; p0 = []; L = [];

% Emoções a serem procuradas.
emos = ['F','A','N','T','E','L','W'];

% Laço for para cada emoção.
for k = 1:length(emos)
    
    % Extrai as características para cada emoção.
    % emoção, vad-rnn (1 ou 0), extrator ('mfcc', 'f0', ...).
    % y = get_emo_feats(emos(k),rnn,ext,'treino');
    if strcmp(ext, 'pro_jan')
        y = emo_pro_jan_treino{k};        
        seq = get_clusters(y,centros);
        dims = get_otm_dims(emo_pro_jan_treino, centros, y_3);
        y = [y; y_3(seq,dims)'];
        
    elseif strcmp(ext, 'f0_3')
        y = emo_f0_3_treino{k};
        y = y(:,1:784);
        seq = get_clusters(y,centros);
        % y = centros(4,seq);
        y = [y; y_3(seq,[5 7])'];
        
    elseif strcmp(ext, 'mfcc')
        y = emo_mfcc_treino{k};
        
    elseif strcmp(ext, 'lfpc-coef')
        y = emo_lfpc_treino{k};        
        
    elseif strcmp(ext, 'lfpc-env')
        y = emo_lfpc_env_treino{k};
        inds = randperm(size(y,2),3965); % Seleciona amostras aleatórias.
        y = y(:,inds);
        
    elseif strcmp(ext, 'lpcc-coef')
        y = emo_lpcc_treino{k};
        inds = randperm(size(y,2),3965); % Seleciona amostras aleatórias.
        y = y(:,inds);
        
    elseif strcmp(ext, 'linfpc')
        y = emo_linfpc_12_treino{k};
        inds = randperm(size(y,2),7307); % Seleciona amostras aleatórias.
        y = y(:,inds);
        
    elseif strcmp(ext, 'form')
        y = emo_5form_treino{k};
        inds = randperm(size(y,2),3965); % Seleciona amostras aleatórias.
        y = y(:,inds);
    end
    
    % Determina os parâmetros do GMM para uma emoção.
    [p0n,cn,Sn,Ln] = gmm_em_2(y', K, 15, 0);
    
    % Agrupa os parâmetros do GMM, cada emoção em uma dimensão diferente.
    p0 = cat(1,p0,p0n');
    L = cat(1,L,Ln);
    C = cat(3,C,cn);
    cov = cat(3,cov,Sn);
end