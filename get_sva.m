% Multidimensional Scaling (MDS):
% Dim = N�m. de dimens�es no vetor X.
% dx = Matriz de dist�ncias.

function X = get_sva(Dim, dx)
tic;
lr = 0.001;  % learn_rate = Taxa de import�ncia para o gradiente.
n_iter = 1000; % N�m. de itera��es.

N = size(dx,1);
X = rand(N,Dim);       % Inicializa��o aleat�ria da observa��o inicial.
J_sum = 0;
d_prev = zeros(N,N);

for ite = 1:n_iter
    
    % Atualiza os vetores.
    for k = 1:N        
        mat_temp = repmat(X(k,:),N,1);
        X_n = -lr*gradiente(mat_temp, X, dx(k,:), k);        
        X(k,:) = X(k,:) + X_n;
    end
        
    % Calcula o custo.
    for k = 1:N        
        mat_temp = repmat(X(k,:),N,1);
        d_prev = (diag(sqrt((mat_temp-X)*(mat_temp-X)')) - dx(k,:)').^2;
        J_sum = J_sum + sum(d_prev);        
    end   
    
    J(ite) = J_sum;
    J_sum = 0;
        
    % Caso o gradiente n�o mude, para o la�o.
    if ite > 1
        if J(ite) == J(ite-1) || J(ite) > J(ite-1)
            break;
        end
    end  
    
    clc
    fprintf('Itera��o: %d/%d', ite, n_iter);
end

% Plota a curva da derivada, normalizada entre 0 e 1.
plot(J/max(J),'b'); grid on; title('Custo normalizado (MDS)'); xlabel('Itera��es'); 

fprintf('\n');
toc;
disp(J(end)/max(J));
end

% Gradiente, X1, X2 = Observa��es com n dimens�es. delta = Intervalo para diferen�a finita.
function res = gradiente(X, Y, dx, k)
d_prev = sqrt((X-Y)*(X-Y)');
d_prev = diag(d_prev); % dist�ncias euclidianas de X(k,:) para todos os outros.
a = d_prev - dx';
b = X-Y;
c = zeros(size(X,1),size(X,2));

for i = 1:size(X,2)
    c(:,i) = 2*a.*(b(:,i)./d_prev);
end
c(k,:) = [];

res = sum(c,1);
end