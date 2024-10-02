%% ROB599-HW2-Problem-3A
% Simulating inverted pendulum controller using a 
% linearised model (linearized only @equillibrium x1=0, x2=0.
%% Cleanup
clear
clc
close all

%% System Parameters (SI)

% Intertial
param.m = 0.2;      %kg
param.J = 0.006;    %kgm2
param.l = 0.3;      %m

% Non-Conservative
param.gamma = 0.1; %N*m*sec/rad

% Fundamental
param.g = 9.81;    %N/kg

% Disturmabces
param.w = 3;       %rad/sec

% Controller Gains
param.kp = 5;
param.kd = 0.1;


param

%% Evaluating Numerical A and B

% State Matrix
a_1 = [0, 1];
a_2 = [(1/(param.J + param.m * param.l^2)) * ((param.m*param.g - param.kp)*param.l), ...
     - (param.gamma + param.l*param.kd) * (1/(param.J + param.m * param.l^2)); ];

A = [a_1; a_2]


% Input Matrix
b_1 = 0; % assuming no disturbance
b_2 = (1/(param.J + param.m * param.l^2)) * param.kp*param.l;

B = [b_1; b_2]

%% Checking Stability of the System

[V, D] = eig(A);
D 


%% Solve for x(t->inf) (Stable Linearized System)
X_final = -inv(A) * B
X_final_eval = X_final*systemInput()

%% Simulation Parameters
to = 0;
tFinal = 10;

% Generating the time vector
tSim = to:0.01:tFinal;

% Initial Conditions
xo = [pi/10; 0.3];

% Input Signal (Constant)
theta_command = systemInput(tSim) * ones(size(tSim));

%% Run Simulation
[tOut, xOut] = ode45(@(t,x) LinearizedInvertedPendulumFB(t, x, param), tSim, xo);

%% Display the Results
figure('Position', [100, 100, 1200, 900]);  % Width: 1200, Height: 900


sgtitle('Figure 1. Linearized Inverted Pendulum. Feedback Controller. Kp = 5, Kd = 0.1',...
    'FontSize', 24, 'FontWeight', 'bold');
 
% Plot Pendulum Angle Command Signal    
subplot(3,1,1);
plot(tSim, theta_command, 'LineWidth', 3, 'Color', 'r');
ylabel('\fontsize{14}{16}\textbf{Input $\theta_{\mathrm{cmd}}$ (rad)}', 'FontSize', 20, ...
    'FontWeight', 'bold', 'Interpreter', 'latex');
set(gca, 'FontSize', 12); 
grid on;


% Plot Pendulum Angular Position
subplot(3,1,2);
plot(tOut, xOut(:,1), 'LineWidth', 3, 'Color', 'b');
ylabel('\fontsize{14}{16}\textbf{x1 = ${\theta}$ (rad)}', 'FontSize', 20, ...
    'FontWeight', 'bold', 'Interpreter', 'latex');
set(gca, 'FontSize', 12);
grid on;

% Plot Pendulum Angular Velocity
subplot(3,1,3);
plot(tOut, xOut(:,2), 'LineWidth', 3, 'Color', 'g');
ylabel('\fontsize{14}{16}\textbf{x2 = $\dot{\theta}$ (rad/s)}', 'FontSize', 20, ...
    'FontWeight', 'bold', 'Interpreter', 'latex');
set(gca, 'FontSize', 12); 
xlabel('Time (s)', 'FontSize', 16, 'FontWeight', 'bold');
grid on;

% Reduce Margins
set(gca, 'LooseInset', max(get(gca, 'TightInset'), 0.02));

print(gcf, 'ROB599-HW#2-Problem_3A-Inverted_Pendulum_PD_Control.png', ...
    '-dpng', '-r300'); 


%% Target Angle Calculator
function theta_comand = systemInput(t)
    theta_comand = pi/3;
end

%% State Space Of the System (Linearized)
function xdot = LinearizedInvertedPendulumFB(t, x, param)

    % State variables
    x1 = x(1);
    x2 = x(2);
    theta_command = systemInput(t);
   
    x1dot = x2 + param.w;
    x2dot = (1/(param.J + param.m * param.l^2))* ((param.m*param.g - param.kp)*param.l * x1 ...
        - (param.gamma + param.l*param.kd)*x2 ...
        + param.kp*param.l*theta_command);
    
    xdot = [x1dot; x2dot];

end