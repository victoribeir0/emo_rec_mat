% Gradiente descendente, learn_rate = Taxa de importância para o gradiente. 
% n_iter = Núm. iterações. 
% delta = Intervalo para diferença finita central.
function X = get_sig_otm(dx)  
    learn_rate = 1000;
    n_iter = 1000;
    delta = 0.001;
    Dim = size(dx,2);
    tic;
    
    X = 1+round(abs(100*randn(1,Dim)));        % Inicialização aleatória da observação inicial.
    diff = zeros(Dim,n_iter); % Inicialização do vetor de derivadas.

    for ite = 1:n_iter                
        for k = 1:Dim
            P = zeros(1,Dim);
            P(k) = 1;
            diff(k,ite) = -learn_rate*gradiente(X-P*delta, X+P*delta, delta, dx); % Calcula a derivada no ponto X.
            X(1,k) = X(1,k)+diff(k,ite); % Atualiza o ponto X.
            clc
            fprintf('Iteração: (%d/%d) (%d/%d)', k, Dim, ite, n_iter);
        end
        J(ite) = custo(X,dx);                        
    end
    
    fprintf('\n');
    toc;
    % Plota a curva da derivada, normalizada entre 0 e 1.    
    plot(J/max(J),'b'); grid on;
end

% Função de custo, X = Observação com n dimensões.
function res = custo(X,dx)
    entropia = get_p(dx,X);
    res = sum((entropia - 0.1).^2);
end
        
% Gradiente, X1, X2 = Observações com n dimensões. delta = Intervalo para diferença finita.
function res = gradiente(X1, X2, delta, dx)    
    res = (custo(X2,dx) - custo(X1,dx))/(2*delta);
end

% Determina a matriz de distâncias, p(i,j), para o t-sne.
% X = Matriz com os dados (NxDim).
% sig = Variância da gaussiana.

% px = Matriz de distâncias (probabilidades), p(i,j).
function entropia = get_p(X,sig)
tic;

[N,Dim] = size(X);
% Caso a matriz esteja transposta (DimxN), transpõe para NxDim.
if Dim > N
    X = X';
    [N,~] = size(X);
end

px = zeros(N);         % Inicia a matriz px.
entropia = zeros(1,N);

% Determina o numerador de p(i,j).
for i = 1:N    
    
    soma = get_dij(X,sig(i)); % Determina o denominador de p(i,j).
    
    % Determina o calculo do p(i,j) para cada vetor X(i,:).
    mat_temp = repmat(X(i,:),N,1) - X;
    mat_temp = sqrt(diag(mat_temp*mat_temp'));
    mat_temp = exp(-(mat_temp.^2)/(2*(sig(i)^2)));
    mat_temp(i) = 0;
    mat_temp = mat_temp/soma;
    px(i,:) = mat_temp;    
    entropia(i) = entro(nonzeros(px(i,:)));
end
end

% Determina o denominador de p(i,j).
function soma = get_dij(X,sig)
N = size(X,1);
soma = 0;

for i = 1:N    
    % Determina o calculo do denominador de p(i,j) para cada vetor X(i,:).
    mat_temp = repmat(X(i,:),N,1) - X;
    mat_temp = sqrt(diag(mat_temp*mat_temp'));
    mat_temp = exp(-(mat_temp.^2)/(2*(sig^2)));
    mat_temp(i) = 0;
    soma = soma + sum(mat_temp);       
end
end

function res = entro(p)
res = -sum(p.*log(p));
end