% GloVe com gradiente descendente:
% Dim = N�m. de dimens�es no vetor X.
% dx = Matriz de dist�ncias.

function X = get_glove(Dim, dx)
tic;
lr = 0.001;  % learn_rate = Taxa de import�ncia para o gradiente.
n_iter = 1500; % N�m. de itera��es.

dx = dx.*(1-eye(size(dx,1)))+eps; % Torna as diagnais iguais a zero (evita dist�ncia negativa).
% dx = log(dx);
% dx(dx<0) = eps;

N = size(dx,1); % N�m. de s�mbolos.
X = rand(N,Dim); % Inicializa��o aleat�ria dos s�mbolos.

global delta;  % Define o delta para a diferen�a finita.
delta = 0.00001;
global max_dx; % Define o m�ximo da matriz de dist�ncias dx.
max_dx = max(dx(:))*10;

for ite = 1:n_iter % Cada itera��o.
    for k = 1:N    % Cada s�mbolo k.
        
        grad = -lr*gradiente(X(k,:), X, dx(k,:));                 
        X(k,:) = X(k,:) + grad;
    end
    
    % Calcula o custo em cada itera��o.
    J_sum = 0;
    for k = 1:N        
        J_sum = J_sum + custo(X(k,:),X,dx(k,:));                
    end
    J(ite) = J_sum;
    
    % Caso n�o haja varia��o no custo, parar.
    if ite > 1
        if J(ite) == J(ite-1)
            break;
        end
    end
    
    clc
    fprintf('Itera��o: %d/%d', ite,n_iter);       
end

toc;
% Plota a curva da derivada, normalizada entre 0 e 1.
plot(J/max(J),'b'); grid on; title('Custo normalizado (GloVe)'); xlabel('Itera��es');
disp(J(end)/max(J));
end

% Fun��o de custo, X = Observa��o com n dimens�es.
% X = word vec 1, Y = word vec 2, X(end) = bias 1, Y(end) = bias 2.
% dx = ponto X(i,j).
function res = custo(X,Y,dx)
global max_dx; % M�ximo de X(i,j).
a = (X*Y' - log(dx)).^2;
b = (dx./max_dx).^(3/4); % Fun��o de peso.
c = a.*b;
res = sum(c);
end

% Calcula o gradiente.
% X = word vec 1
% Y = word vec 2.
% dx = ponto X(i,j).
function res = gradiente(X, Y, dx)
global max_dx;
a = (X*Y' - log(dx));
b = (dx/max_dx).^(3/4);
c = a.*b;
d = zeros(size(Y,1),size(Y,2));

for i = 1:size(Y,2)
    d(:,i) = Y(:,i).*c';
end

res = sum(d,1);
end