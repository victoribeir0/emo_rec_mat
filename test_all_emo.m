%{
    Determina o modelo parâmetros do GMM: pesos, centros e mat. cov.
    K = Núm. de gaussianas (centros).
    ext = Tipo de extrator (ex: 'mfcc', 'f0', 'lpcc').
    rnn = VAD com rede naural.

    p0 = Pesos;      |    c = Centros
    S = Mat. cov.;   |    L = Varossimilhança.
%}

function [p0,c,S,L] = test_all_emo(K,ext,rnn)

if strcmp(ext, 'mfcc')
    tam = 36;
    
elseif strcmp(ext, 'f0')
    tam = 8;
    
elseif strcmp(ext, 'lpcc')
    tam = 15;
end

c  = zeros(K,tam); % Inicialização dos parâmetros.
S  = zeros(K,tam);
p0 = zeros(1,K);
L  = zeros(1,10);

emos = ['W';'T'];  % Emoções a serem buscadas.

for emo = 1:length(emos)
        
    % Matriz de caracaterísticas para cada emoção.
    y = get_emo_feats(emos(emo),rnn,ext);     
    
    % Parâmetros do GMM para a matriz de características y.
    [p0n,cn,Sn,Ln] = gmm_em_2(y', K, 10, 0);
    
    p0 = cat(1,p0,p0n');
    L = cat(1,L,Ln);
    c = cat(3,c,cn);
    S = cat(3,S,Sn);
end

c = c(:,:,2:end); % Modelos GMM para cada orador.
S = S(:,:,2:end);
p0 = p0(2:end,:);
L = L(2:end,:);

end