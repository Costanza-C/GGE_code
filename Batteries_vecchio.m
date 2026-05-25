% Prediseno potencia electrica

clear
clc
close all

%% ---------------------------------- Datos orbitales 
a = 6945; %[km]
e = 0.00001; % [-]
i = 97.6583; %[deg]
omega = 0; %[deg]
theta = 0; %[deg]
alfa = 22.5; %[deg] Ángulo entre el RAAN de la órbita y la ascensión recta del sol
t = [2026, 04, 06, 10, 00, 00]; 
mu_E = astroConstants(13); 
T = 2*pi*sqrt(a^3/mu_E); 
m = floor((24*3600)/T); %Numero de orbitas cada 24 oras

% Ascensión recta del sol
mjd2000_val = date2mjd2000(t); 
% Efemerides para calcular el vector unitario Sol S_ECI
[kep_E, ~] = uplanet(mjd2000_val, 3); % Resultados en sistema ecliptico 
a_E = kep_E(1); 
e_E = kep_E(2); 
i_E = rad2deg(kep_E(3)); 
RAAN_E = rad2deg(kep_E(4)); 
omega_E = rad2deg(kep_E(5)); 
theta_E = rad2deg(kep_E(6));
mu_S = astroConstants(4); 
[r_earth_ecl, ~] = kep2car(a_E, e_E, i_E, RAAN_E, omega_E, theta_E, mu_S);%vector Tierra
r_sun_ecl = -r_earth_ecl; % vector Sol, coord, eclipticas
eps = 23.4; % [deg]
R_ecl2eci = [1, 0, 0; 
             0, cosd(eps), -sind(eps); 
             0, sind(eps), cosd(eps)];
S_ECI_vec = R_ecl2eci * r_sun_ecl;
%pos_sol = planetEphemeris(jd, "Earth", "Sun"); 
RA_sol = atan2d(S_ECI_vec(2), S_ECI_vec(1)); %[deg]
RAAN = RA_sol+alfa; 

% Satellite scenario
startTime = datetime(2026, 4, 6, 10, 0, 0, "TimeZone", "UTC"); 
stopTime = startTime + hours(24); %15 orbitas
sampleTime = 60; %[s]
sc = satelliteScenario(startTime, stopTime, sampleTime); 
sat = satellite(sc, a*1e3, e, i, RAAN, omega, theta, "Name","Cubesat 16U"); 
show(sat); 
groundTrack(sat, "LeadTime", 24*3600)


%% --------- Baterias 

%------------- Dimensionamento eclipse
% Calcular el tiempo de eclipse y dimensionar la batería
Te = T*1/3; % Inicializar duración del eclipse
N = 1; % Numero de baterias indipendiente: en cubesat es 1
eta_b = 0.95; %Eficencia baterias ion-Litio
DoD = 0.6; 
Pe_reg = 3.5 + 2.5 + 0.8 + 0.5 + 0.4 + 6*10/96 + 9*10/30; 
Pe_noreg = 12;
Xe = 0.8; 
C1 = (Pe_reg*Te/Xe + Pe_noreg*Te) *1/(DoD*eta_b*N)*(1/3600) %[Wh]

%------------ Dimensionamento en pico 
% Pp_tot = 35.80 [W] Pico efectivo instantaneo
% Pp_tot = 29.8 [W] Pico considerando un Tp = 10 minutos, 
% porque el experimento 1 està encendido solo 10 segundos
% cada 30 -> su potencia debe ser multiplicada por 10/30
Pp_reg = 3.5 + 2.5 + 0.8 + 4.5 + 9*1/3 + 6; 
Pp_noreg = 9.5; 
Tp = 10*60; %[s] tiempo peor en el que hay todo los sistemas pidiendo potencia 
C2 = (Pp_reg*Tp/Xe + Pp_noreg*Tp) *1/(DoD*eta_b*N)*(1/3600) %[Wh]

%------------Dimensionamento en pico en ecplipse 
C3 = (Pe_reg*(Te-Tp)/Xe + Pe_noreg*(Te-Tp)/1 + Pp_reg*Tp/Xe + Pp_noreg*Tp) *1/(DoD*eta_b*N)*(1/3600) %[Wh]

C_vec = [C1, C2, C3]; 
% ------------Numero celdas en serie y paralelo
C_cell = 2.850*3.65; % [Wh] datasheet 
V_cell = 3.65; %[V] datasheet - voltaje nominal
V_batt = 12; %[V] maximum required voltage (ver los datos)
V_cell_min = 3.4; %[V] datasheet - minimo voltaje operativo, considerandoun DoD 60% (aprox.)

n_celdas_min_vec = [0 0 0]; 
for i = 1:3
    n_celdas_min_vec(i) = ceil(C_vec(i)/C_cell); % Preliminar
end 
n_celdas_min = max(n_celdas_min_vec)

I_max = 4; % [A] Ponendo un limite maximo en el bus (lo eligimos nosotros)
P_total = Pp_noreg/1 + (Pp_reg-9*1/3+9)/Xe; %Considero el pico efectivo en 10 segundos para exp.1
V_min = P_total / I_max; 

% 1) Con voltaje nominal 
Ns1 = ceil(V_min/V_cell); 
% 2) Con minimo voltaje operativo 
Ns2 = ceil(V_min/V_cell_min); 
Ns = max(Ns1, Ns2)

Np_vec = [0 0 0]; 
for i = 1:3
    Np_vec(i) = ceil(C_vec(i) / (C_cell * Ns));    
end 
Np = max(Np_vec)
