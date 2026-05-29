%% DIMENSIONAMIENTO DE CONDUCTORES 
clear; clc;

%% PARÁMETROS GENERALES
rho   = 1.68e-8;  % [Ohm·m] Resistividad del cobre a 20°C
l     = 0.5;      % [m] Longitud física del cable (andata)
L     = 2 * l;    % [m] Longitud total del circuito (andata + ritorno)
dV_pc = 0.03;     % [-] Caída de tensión máxima permitida (3%)

%% TENSIONES DE BUS
V_bat  = 16.0;  % [V] Tensión nominal del bus de batería
V_33   =  3.3;  % [V]
V_5    =  5.0;  % [V]
V_12   = 12.0;  % [V]

%% CORRIENTES DE PICO POR BUS (peor caso simultáneo)

% Bus Vbat: Exp3 (12W) es el mayor consumidor individual
% Comms nominales (9.5W) y Exp3 son incompatibles, tomamos Exp3
P_Vbat = [9.5, 12.0];                % [W] Comms nominales, Exp3
label_Vbat = {'Comms nom', 'Exp3'};
I_Vbat_max = max(P_Vbat) / V_bat;    % Peor caso individual

% Bus 3.3V: OBDH + ADCS base + Exp1 pico (todos simultáneos)
P_33 = [3.5, 0.8, 9.0];              % [W] OBDH, ADCS base, Exp1
label_33 = {'OBDH', 'ADCS base', 'Exp1'};
I_33_max = sum(P_33) / V_33;

% Bus 5V: Control termico + Exp2 + seguimiento 
% (Y-Thomson es modo safe, no simultaneo con nominal)
P_5 = [2.5, 6.0, 1.0];               % [W] Termico, Exp2, Seguimiento
label_5 = {'Termico', 'Exp2', 'Seguimiento 5V'};
I_5_max = sum(P_5) / V_5;

% Bus 12V: Seguimiento + cambio actitud 
P_12 = [4.0, 6.0];                   % [W] Seguimiento 12V, Cambio 12V, Exp4
label_12 = {'Cambio 12V', 'Exp4'};
I_12_max = sum(P_12) / V_12;

%% SECCIÓN MÍNIMA REQUERIDA
% S = (rho * L * I) / dV_max

dV_Vbat = dV_pc * V_bat;
dV_33   = dV_pc * V_33;
dV_5    = dV_pc * V_5;
dV_12   = dV_pc * V_12;

S_Vbat = (rho * L * I_Vbat_max) / dV_Vbat * 1e6;  % [mm²]
S_33   = (rho * L * I_33_max)   / dV_33   * 1e6;  % [mm²]
S_5    = (rho * L * I_5_max)    / dV_5    * 1e6;  % [mm²]
S_12   = (rho * L * I_12_max)   / dV_12   * 1e6;  % [mm²]

%% TABLA AWG COMERCIAL (seccion en mm²)
% AWG: 28, 26, 24, 22, 20, 18
AWG_num = [28,    26,    24,    22,    20,    18];
AWG_S   = [0.081, 0.129, 0.205, 0.326, 0.518, 0.823]; % [mm²]

% Función para seleccionar el AWG mínimo que cumple
seleccionar_AWG = @(S_min) AWG_num(find(AWG_S >= S_min, 1, 'first'));
seleccionar_S   = @(S_min) AWG_S(find(AWG_S >= S_min, 1, 'first'));

AWG_Vbat = seleccionar_AWG(S_Vbat);  S_sel_Vbat = seleccionar_S(S_Vbat);
AWG_33   = seleccionar_AWG(S_33);    S_sel_33   = seleccionar_S(S_33);
AWG_5    = seleccionar_AWG(S_5);     S_sel_5    = seleccionar_S(S_5);
AWG_12   = seleccionar_AWG(S_12);    S_sel_12   = seleccionar_S(S_12);

%% VERIFICACIÓN CAÍDA DE TENSIÓN REAL
dV_real_Vbat = (rho * L * I_Vbat_max) / (S_sel_Vbat * 1e-6) ;
dV_real_33   = (rho * L * I_33_max)   / (S_sel_33   * 1e-6) ;
dV_real_5    = (rho * L * I_5_max)    / (S_sel_5    * 1e-6) ;
dV_real_12   = (rho * L * I_12_max)   / (S_sel_12   * 1e-6) ;

dV_pc_Vbat = (dV_real_Vbat / V_bat) * 100;
dV_pc_33   = (dV_real_33   / V_33)  * 100;
dV_pc_5    = (dV_real_5    / V_5)   * 100;
dV_pc_12   = (dV_real_12   / V_12)  * 100;

%% RESULTADOS
fprintf('========================================================\n');
fprintf('       DIMENSIONAMIENTO DE CONDUCTORES\n');
fprintf('========================================================\n');
fprintf('Parámetros: rho=%.2e Ohm·m, L=%.1f m, dV_max=%.0f%%\n\n',...
    rho, L, dV_pc*100);

buses    = {'Vbat (16V)', '3.3V', '5V', '12V'};
I_max    = [I_Vbat_max, I_33_max, I_5_max, I_12_max];
S_min    = [S_Vbat, S_33, S_5, S_12];
AWG_sel  = [AWG_Vbat, AWG_33, AWG_5, AWG_12];
S_sel    = [S_sel_Vbat, S_sel_33, S_sel_5, S_sel_12];
dV_pcs   = [dV_pc_Vbat, dV_pc_33, dV_pc_5, dV_pc_12];

fprintf('%-12s %8s %10s %6s %10s %8s\n', ...
    'Bus', 'I_max[A]', 'S_min[mm2]', 'AWG', 'S_sel[mm2]', 'dV[%]');
fprintf('%s\n', repmat('-',1,58));
for k = 1:4
    fprintf('%-12s %8.3f %10.4f %6d %10.4f %8.3f\n', ...
        buses{k}, I_max(k), S_min(k), AWG_sel(k), S_sel(k), dV_pcs(k));
end
fprintf('========================================================\n');