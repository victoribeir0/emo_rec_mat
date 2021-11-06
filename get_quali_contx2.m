%{
    Calcula o jitter s shimmer do sinal x.
    x = Sinal de entrada                |    Tjan = Tempo de cada janela em ms.
    inds = Janelas a serem utilizados.  |    Fs = Freq. de amostragem.
    mean_F0 = M�dia do F0, usado nos crit�rios de sele��o.

    jit_abs = Jitter absoluto           |    jit_rel = Jitter relativo.
    jit_sinal = Jitter do sinal.
    shim_abs = Shimmer absoluto         |    shim_rel = Shimmer relativo.
    amp_std = Desv. pad. das amplitudes dos per�odos em uma janela.
    amp_x = Amplitudes dos per�odos para todo o sinal.
%}

function [jit_abs, jit_rel, jit_sinal, shim_abs, shim_rel, amp_std, mean_dif_picos, idx_nan] = get_quali_contx2(x, Tjan, inds, Fs, F0)

Njan = round((Tjan/1000)*Fs);      % Num. de amostras em cada janela.
NAv  = round((10/1000)*Fs);        % Num. de amostras para o avan�o (sobreposi��o).

jit_abs  = zeros(1,length(inds)); jit_rel  = zeros(1,length(inds));
shim_abs = zeros(1,length(inds)); shim_rel = zeros(1,length(inds));
amp_std  = zeros(1,length(inds)); mean_dif_picos = zeros(1,length(inds));
T0 = Fs./F0;
t = 2;

x = x-mean(x);

% Filtro FIR passa-baixas, fc = 500 Hz, ordem = 200.
h = fir1(200,(500*2)/Fs);  % Coeficientes
filt = conv(x,h);          % Sinal filtrado.
filt = filt(101:end-100);

% Filtro FIR passa-altas, fc = 100 Hz, ordem = 200.
h = fir1(200, (50*2)/Fs, 'high');
filt = conv(filt,h);
filt = filt(101:end-100);

mat_x = buffer(filt, Njan, Njan-NAv, 'nodelay');

for i = 1:length(inds)-2  % La�o for para cada janela espec�fica.
    
    aux = inds(i);  % Define a janela espec�fica.    
    a = mat_x(:,aux);   
    %a = a-mean(a);  % Remove o n�vel DC subtraindo pela m�dia.        
    mx = max(a)*0.5;  % Limites para detec��o dos picos.
    
    jit_abs(i) = sum(abs(diff(T0(i:i+t))))/length(T0(i:i+t));
    jit_rel(i) = 100*(jit_abs(i)/mean(T0(i:i+t)));
    
    [shim_abs(i), shim_rel(i), ~, amp_std(i), mean_dif_picos(i)] = get_shimmer(a, mean(F0), Fs, mx);
    
    % Caso o shimmer d� zero, faz a m�dia entre os dois anteriores.
    if shim_abs(i) == 0 && i >= 2
        shim_abs(i) = shim_abs(i-1);
        shim_rel(i) = shim_rel(i-1);
        amp_std(i) = amp_std(i-1);
    end
    
end

jit_abs(end-(t-1):end) = jit_abs(end-(t-1)-2:end-(t-1)-1);
jit_rel(end-(t-1):end) = jit_rel(end-(t-1)-2:end-(t-1)-1);

shim_abs(end-(t-1):end) = shim_abs(end-(t-1)-2:end-(t-1)-1);
shim_rel(end-(t-1):end) = shim_rel(end-(t-1)-2:end-(t-1)-1);
amp_std(end-(t-1):end) = amp_std(end-(t-1)-2:end-(t-1)-1);
mean_dif_picos(end-(t-1):end) = mean_dif_picos(end-(t-1)-2:end-(t-1)-1);

% Calula o jitter para todos os T0 do sinal.
jit_sinal = sum(abs(diff(T0)))/length(T0);

end

%{
    Fun��o para determinar o Shimmer.
    idx = Vator l�gico dos per�odos;     |    loc_max = Loc. dos valores m�ximos.
    amp_max = Amp. dos valores m�ximos;  |    mean_F0 = M�dia do F0;
    Fs = Freq. Amostragem;               |    filt = Sinal fitrado.
    
    shim_abs = Shim. absoluto;           |    shim_rel = Shim. relativo.
    amp_x = Amp. dos per�odos de todas as janelas;
    amp_std = Desv. pad. dos per�odos dentro de uma janela.
%}
function [shim_abs, shim_rel, amp_prev, amp_std, mean_dif_picos] = get_shimmer(x, mean_F0, Fs, mx)

x = [zeros(200,1); x; zeros(200,1)]; % Padding do sinal (evita problemas ...).
% Determina os m�ximos, com um valor m�nimo e com uma dist�ncia m�nima (m�d. F0 + 15).
[amp_max, loc_max] = findpeaks(x,'MinPeakHeight',mx, 'MinPeakDistance',Fs/(mean_F0+15)); 
idx = ones(length(amp_max),1);

if ~isempty(idx)
    
    % Avalia os picos, remove picos fora do comum baseado do idx.
    idxn = [idx(1); idx];        % Vetor l�gico dos per�odos, com o 1� termo repetido.
    loc = zeros(1,length(idxn)); % Vetor l�gico de localiza��o dos picos.
    
    for n = 1:length(idxn)
        
        % Se n = 1 ou �ltimo, mantem o mesmo valor l�gico de idxn.
        if n == 1 || n == length(idxn)
            loc(n) = idxn(n);
        else
            
            % Caso n ~= de 1, testa se h� valor l�gico 1 no idxn(n) ou no idxn(n+1)
            if idxn(n) == 1 || idxn(n+1) == 1
                loc(n) = 1;
            end
        end
    end
    
    %loc_max = loc_max(logical(loc')); % Atualiza as loc. dos m�ximos.
    %amp_max = amp_max(logical(loc')); % Atualiza as amp. dos m�ximos.
    
    T0_med = round(Fs/mean_F0);       % Per�odo m�dio, baseado no F0 m�dio.
    
    T = round(T0_med/2);
    % sinal_cut = zeros(1,(round(T0_med/2)*2)+1);
    loc_min = zeros(1,length(loc_max));
    amp_min = zeros(1,length(loc_max));
    
    for n = 1:length(loc_max)
        ini = loc_max(n)-T; fim = loc_max(n)+T;
        %if ini >= 1 && fim <= length(x)
            
            sinal_cut = [x(ini:loc_max(n)-1)' x(loc_max(n):fim)'];
            mx_rel = max(-sinal_cut)*0.5;
            [amp_min_prev, loc_min_prev] = findpeaks(-sinal_cut,'MinPeakHeight',mx_rel);
            
            if isempty(amp_min_prev)
                amp_min(n) = 0;
                loc_min(n) = 0;
            else
                amp_min(n) = max(amp_min_prev);
                loc_min(n) = max(loc_min_prev);
            end
            
            % loc_min_prev = max(loc_min_prev);
            loc_min(n) = re_scale(loc_min(n),(1:size(sinal_cut,2)),(ini:fim));
        %end
    end
    
    amp_prev = amp_max'+amp_min; % Amplitde pico a pico, max(x)-min(x).
    %mdn = median(amp_prev);      % Mediana para o crit�rio de sele��o.
    %amp_prev = amp_prev(amp_prev<mdn+mdn/3 & amp_prev>mdn-mdn/3); % Crit�rio de sele��o.
    amp_std  = std(amp_prev);    % Desvio pad. das amp. pico a pico da janela.
    
    shim_abs = sum(abs(diff(amp_prev)))/length(amp_prev); % Shim. absoluto.
    shim_rel = 100*(shim_abs/mean(amp_prev));             % Shim. relativo
    
    dif_picos = abs(loc_max-loc_min'); % Lagrura dos 'picos'.
    % mdn = median(dif_picos);
    % dif_picos = dif_picos(dif_picos<mdn+mdn/2 & dif_picos>mdn-mdn/2);
    mean_dif_picos = mean(dif_picos);
    
else
    shim_abs = NaN;
    shim_rel = NaN;
    amp_prev = NaN;
    amp_std  = NaN;
    mean_dif_picos = NaN;
end

end