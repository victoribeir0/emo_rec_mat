%{
    Calcula o jitter do sinal x.
    x = Sinal de entrada.
    Tjan = Tempo de cada janela em ms.
    inds = Janelas a serem utilizados.
    Fs = Freq. de amostragem.
    mean_F0 = Média do F0, usado nos critérios de seleção.

    jitter_abs = Jitter absoluto.
    jitter_rel = Jitter relativo.
    jitter_sinal = Jitter do sinal.
%}

function [jitter_abs, jitter_rel, jitter_sinal] = get_jitter(x, Tjan, inds, Fs, mean_F0)

Njan = round((Tjan/1000)*Fs); % Num. de amostras em cada janela.
NAv = round((10/1000)*Fs);    % Num. de amostras para o avanço (sobreposição).

T0 = [];                             % Inicialização T0 (vetor de períodos).
jitter_abs = zeros(1,length(inds));  % Inicialização vetor de jit. abs.
jitter_rel = zeros(1,length(inds));  % Inicialização vetor de jit. rel.

for i = 1:length(inds) % Laço for para cada janela específica.
    
    aux = inds(i); % Define a janela específica.
    ap = ((aux-1)*NAv)+1;
    a = x(ap:ap+Njan-1);
    a = a-mean(a); % Remove o nível DC subtraindo pela média. 
    
                              % Filtro FIR passa-baixas, fc = 500 Hz, ordem = 200.
    h = fir1(200,(500*2)/Fs); % Coeficientes
    filt = conv(a,h);         % Sinal filtrado.
    mn = min(filt)*0.5; mx = max(filt)*0.5; % Limites para detecção dos picos.
    
    % plot(filt,'b'); hold on; plot([1 length(filt)],[mx mx],'r--'); hold on; plot([1 length(filt)],[mn mn],'r--'); grid on
    
    [~,loc_max] = findpeaks(filt,'MinPeakHeight',mx); % Obtém as posições dos picos.
    T0_prev = diff(loc_max);                          % Obtém as diferenças, período previsto.

    % Critério para seleção baseado na média do F0 obtido.
    T0_prev = T0_prev(T0_prev<(Fs/mean_F0)+30 & T0_prev>(Fs/mean_F0)-30);
    F0_prev = Fs./T0_prev;
        
    % Critério para seleção baseado na média do F0 obtido.
    idx = (F0_prev<mean_F0+30 & F0_prev>mean_F0-30);
    T0_prev = T0_prev(idx);    
    
    jitter_abs(i) = sum(abs(diff(T0_prev)))/length(T0_prev); % Jitter absoluto.
    jitter_rel(i) = 100*(jitter_abs(i)/mean(T0_prev));       % Jitter relativo.        
    
    T0 = [T0 T0_prev'];
            
end

idx_nan = ~isnan(jitter_abs);     % Remove os NaN, caso haja.
jitter_abs = jitter_abs(idx_nan);

idx_nan = ~isnan(jitter_rel);     % Remove os NaN, caso haja.
jitter_rel = jitter_rel(idx_nan);

% Calula o jitter para todos os T0 do sinal.
jitter_sinal = sum(abs(diff(T0)))/length(T0); 

end
