function w = mikolov(arquivoEntrada, filtro, viz)

% Leitura do arquivo e determina��o dos caracteres.
fileID = fopen(arquivoEntrada);
format = '%c';
texto = fscanf(fileID,format);
car = regexp(texto, '\S', 'match'); % Determina os caracteres.
car = cell2mat(car);                % Transforma em um vetor.
C = unique(car);                    % Obt�m os caracteres �nicos.

if filtro == 1
    C(regexp(C,'[!,'',",(,),*,-,.,/,_,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,-,-,:,;,?,`,�,�,�]')) = [];
    car(regexp(car,'[!,'',",(,),*,-,.,/,_,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,-,-,:,;,?,`,�,�,�]')) = [];
end

% Rede neural para obter o espa�o sem�ntico v:
w = rand(length(C),length(C)+1);      % Matriz w da rede neural.
passo = 0.001;
custofinal = zeros(1,100000);

% Plota o espa�o inicial (aleat�rio).
for k = 1:length(C)
    plot(w(1,k),w(2,k),'b*'); hold on; grid on;
    text(w(1,k),w(2,k),C(k),'Fontsize',14);
end

% Itera��es da rede neural.
for i = viz:100000
    % Entrada do tipo one hot (1 no caractere de interesse).    
    x = zeros(length(C),1);  
    
    for s = 0:abs(1-viz)
        x(find(car(i-s) == C)) = 1;
    end
    
    x = [1; x];
    y = 1./(1+exp(-w*x)); % sigmiode

    % y = exp(w*z)/sum(exp(w*z)); % softmax
      
    % Estima um caractere a partir do anterior.
    alvo = zeros(length(C),1); 
    alvo(find(car(i+1) == C)) = 1;
    e = alvo-y;    
    retro = e .* (y.*(1-y)); % Derivada da sigmoide.
    
    wnovo = w+passo*(retro*x');    
    w = wnovo;
    
    custofinal(i) = sum(mean(e.^2)); % Calcula o custo.
    
end

figure,
for k = 1:length(C)
    plot(w(k,1),w(k,2),'b*'); hold on; grid on;
    text(w(k,1),w(k,2),C(k),'Fontsize',14);
end

figure, plot(custofinal);

end