function [base, Sf] = get_loc_gmm(emo,metade,rnn,ext)
folder = 'E:\Arquivos Mestrado\Dataset - Biochaves(Emo)\Emotion_database';
cd(folder);
as = dir('*.wav');
N = numel(as);
j = 1;

if strcmp(ext, 'mfcc')
    base = zeros(39,1);
    
elseif strcmp(ext, 'f0')
    base = zeros(3,1);
    
else
    base = zeros(2,1);
end

% dMFCC = zeros(18,1);
count = 0;
Sf = [];
a = [];

for n = 1:N
    str = as(n).name;
    em = str(9:10);    
    
    if emo == em
        folder = 'E:\Arquivos Mestrado\Dataset - Biochaves(Emo)\Emotion_database';
        cd(folder);
        dados = importdata(str);
        
        % Obtém a matriz do espectrograma.
        [S, L] = mat_fft(dados.data, dados.fs, 40, 10, 0, rnn);
        
        % Obtém o MFCC.
        MFCC = get_ce(S, L, dados.fs);
        
        if rnn == 0 % Caso rnn não seja solicitado.
            lim = mean(MFCC(1,:));
            idx = find(MFCC(1,:) > lim);
            MFCC = MFCC(2:end,idx);
            Sf = [Sf S(:,idx)];
            
        else % Caso rnn  seja solicitado.
            MFCC = MFCC(2:end,:);
            idx = 1:size(MFCC,2); % Nesse caso, todos os índices sao uteis.
        end
        
        % Caso o extrator seja mfcc:
        if strcmp(ext, 'mfcc')
            dMFCC = dmfcc(MFCC,3);
            MFCC = [MFCC; dMFCC];
            [k_0n,~,coef,zcr] = fix_f0(dados.data,idx);
            y = [MFCC; k_0n; zcr(idx); coef(idx)];
        end
        
        % Caso o extrator seja f0:
        if strcmp(ext, 'f0')
            [k_0n,~,coef,zcr] = fix_f0(dados.data,idx);
            % din = get_coefs_f0(k_0n,3);
            % din = [din(1) din(1) din din(end)];
            
            y = [k_0n; zcr(idx); coef(idx)];
        end
        
        if strcmp(ext, 'poly_spec')
            for i = 1:80:size(Sf,2)
                for n = 1:55:200
                    idx = n:n+55;
                    [coefs,~] = poly_spec(Sf(idx,i)',0);
                    a = [a coefs];
                end                
            end
            y = a;
        end
        
        base = [base y];
        
        % dMFCC = [dMFCC dmfcc(get_ce(S, L, dados.fs),3)];
        
        if metade % Pega somente metade do dataset (treino).
            count = count + 1;
            
            if count > 20
                break;
            end
        end
        
    end
    
end

base = base(:,2:end);
end