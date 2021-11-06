% Calcula os coeficientes LFPC.
% S = Matriz do espectrograma.
% L = Comprimento de cada janela (am amostras).
% MFCC = Coeficientes Mel-Cepstrais.

function LFPC = get_lfpc(S, L, Fs, num_bandas)

b = zeros(1,num_bandas); % Largura de cada bandas.
f = zeros(1,num_bandas); % Frequência de cada banda.
b(1) = 54;
f(1) = 127;
alpha = 1.4;

escala = ((0:round(L/2)-1)*Fs)/L;

for n = 2:num_bandas
   b(n) = alpha*b(n-1);  
   f(n) = f(1) + sum(b(1:n-1)) + (b(n)-b(1))/2;
end

W = zeros(num_bandas,size(S,1));
larg = zeros(1,num_bandas);

for n = 1:num_bandas
    [~, freq_i] = min(abs(escala - (f(n) - b(n))));
    [~, freq_f] = min(abs(escala - (f(n) + b(n))));
    W(n,round(freq_i):round(freq_f)) = 1;
    larg(n) = freq_f-freq_i;
end

% mat_div = (ones(size(S,2),1)*larg)';
LFPC = 10*log10((W*S+(10^-6)).^2);

end