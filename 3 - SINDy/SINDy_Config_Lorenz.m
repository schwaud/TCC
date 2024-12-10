clc;clear;close

addpath("../1 - aux")
addpath("../2 - systems")

% Sistema
sigma = 10;
rho = 28;
beta = 8/3;
f = @(t,x) lorenz(t,x,sigma,rho,beta);

% Configs p/ Simulação
x0 = [-8 8 27];
nVars = length(x0);
dt = 0.01;
tspan = 0:dt:20; tspan2 = tspan(3:end-2);
odeOptions = odeset('RelTol',1e-3,'AbsTol',1e-3*ones(1,nVars));

% Configs da Biblioteca de Funções Candidatas
polyDeg = 3;
fourierLib = [];

% Configs de Ruído 
noise = 1;

% Configs p/ Validação Cruzada
nFolds = 10;
rng("default");
cv = cvpartition(length(tspan2),"KFold",nFolds);
eps = logspace(-8,-0.5,30);

% Parâmetro Escolhido
epsilon = 1e-1;

% Configs p/ Validação do Modelo
x0_test = [4 -3 10];
tspan_test = 0:dt:20; 