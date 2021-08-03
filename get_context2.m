function v = get_context2(arquivoEntrada, filtro)

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
v = rand(2,length(C)); % Inicia o espa�o sem�ntico. v = rand(2,length(C));
w = rand(2,2);         % Matriz w da rede neural.
passo = 0.001;
custofinal = zeros(1,50000);

% Plota o espa�o inicial (aleat�rio).
for k = 1:length(C)
    plot(v(1,k),v(2,k),'b*'); hold on; grid on;
    text(v(1,k),v(2,k),C(k));
end

% Itera��es da rede neural.
for i = 1:50000
    % Entrada do tipo one hot (1 no caractere de interesse).
    x = zeros(length(C),1);
    x(find(car(i) == C)) = 1;
    
    vn = v(:,find(car(i) == C));
    y = w*vn;
    
    % Estima um caractere a partir do anterior.
    vnmu = v(:,find(car(i+1) == C));
    e = vnmu-y;
    
    wnovo = w+passo*(e*vn');
    vnovo = v+passo*(w'*e)*x';
    
    w = wnovo;
    v = vnovo;
    
    custofinal(i) = sum(mean(e.^2)); % Calcula o custo.
    
end

figure,
for k = 1:length(C)
    plot(v(1,k),v(2,k),'b*'); hold on; grid on;
    text(v(1,k),v(2,k),C(k));
end

figure, plot(custofinal);

end