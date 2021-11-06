%{
    Retorna uma matriz (NxM) com os N coeficientes LPC para M janelas.
    x = Sinal;    |    Fs = Freq. de amostragem.
    Tjan = Duração de cada janela (em ms).
    Tav = Tempo de avanço (em ms).
    rnn = Rede neural para o VAD (1 = sim, 0 = não usado).
    Ncoefs = Número de coeficientes LPC.

    mat_lpcc = Matriz de coefs. LPC.
    mat_H    = Matriz das amplitudes dos espectros LPC.    
%}

function [mat_lpcc, mat_H, formantes] = get_lpcc_mat(x, Fs, Tjan, Tav, rnn, Ncoefs)

% L = Comprimento de cada janela (am amostras).
L = round((Tjan/1000)*Fs);

% Num. de amostras para o avanço.
Avanco = round((Tav/1000)*Fs);

% Njan = Núm. de janelas totais (incluindo as sobrepostas).
Njan = round((length(x)-L)/Avanco);

janelaHamming = 0.54 - 0.46*cos(2*pi*(0:L-1)/L); %Melhora a análise espectral de curto termo
x = x(1:end-1)-0.97*x(2:end);

cc = 1;

for c = 1:Njan
    apontador = ((c-1)*Avanco) + 1;
    y = x(apontador:apontador + L - 1);
    y=y'.*janelaHamming; %Melhora a análise espectral de curto termo.
    formantes{c} = get_formantes(x,15,Fs);
    
    if rnn
        feats = vad_coefs_cada(y);
        prev = feed_vad(feats);
        
        if prev >= 0.6
            coefs = get_lpcc(y,12);
            mat_lpcc(:,cc) = coefs;
            cc = cc + 1;
        end
        
    else
        [coefs,H,~] = get_lpcc(y,Ncoefs,Fs,0);               
        mat_lpcc(:,c) = coefs;
        mat_H(:,c) = H;
    end
    
end

end