clear
clc


%% Datos de problema
a = 6945;         % [km]  Semi-major axis
e = 0.00001;      % [-]   Eccentricity
i_deg = 97.6583;  % [deg] Inclination
w_deg = 0;        % [deg] Argument of perigee
theta_deg = 0;    % [deg] true anomaly
h = 566.9;        % [km]  Altitude

Lx = 0.2;  % [m]
Ly = Lx;   % [m]
Lz = 0.4;  % [m]

R_e = astroConstants(23);    % Earth's equatorial radius [km]
mu_E = astroConstants(13);   % Earth's gravitational parameter [km^3/s^2]

Initial_date = [2026, 4, 6, 10, 00, 00];         % Initial date 
initial_time_days = date2mjd2000(Initial_date);  % Initial time [days]
initial_time = initial_time_days * 86400;        % Initial time [s]

T =  2*pi*sqrt( a^3/mu_E);                       % Initial Orbital period (Kepler) [s]
T_min = T / 60;                                  % Initial Orbital period (Kepler) [min]


%% Calculo RAAN

% ibody = 3 Tierra (no estraggo con id sole perche se no viene tutto 0
% essendo centrato nel sole)
[kep_earth, ~] = uplanet(initial_time_days, 3); 

omega_earth_rad = kep_earth(5); % om (Argumento del perihelio)
theta_earth_rad = kep_earth(6); % theta (Anomalía verdadera)

% La longitud eclíptica verdadera de la Tierra es la suma de omega y theta
lambda_earth_rad = omega_earth_rad + theta_earth_rad;

% La longitud eclíptica verdadera del Sol es la de la Tierra + 180 grados (pi rad)
lambda_sun_rad = lambda_earth_rad + pi;

% Oblicuidad de la eclíptica (aprox 23.44 grados, en radianes)
epsilon_rad = deg2rad(23.4392911);

% Calculamos la Ascensión Recta del Sol (alpha_sun) usando trigonometría esférica
% alpha_sun = atan2(cos(epsilon) * sin(lambda_sun), cos(lambda_sun))
alpha_sun_rad = atan2(cos(epsilon_rad) * sin(lambda_sun_rad), cos(lambda_sun_rad));
alpha_sun_deg = mod(rad2deg(alpha_sun_rad), 360);

% Aplicamos el offset del Grupo 3 (22.5 grados) de la Tabla 2
angulo_offset = 22.5; 
RAAN_deg = mod(alpha_sun_deg + angulo_offset, 360);

% Mostrar en consola para verificar
fprintf('Ascensión Recta del Sol (calculada vía uplanet): %.2f deg\n', alpha_sun_deg);
fprintf('RAAN Inicial Calculado: %.2f deg\n', RAAN_deg);

kep = [a e i_deg RAAN_deg w_deg theta_deg];      % Keplerian elements



%% PRESUPUESTO DE POTENCIA 

% SUBSISTEMAS CONSTANTES [W]
P_OBDH = 3.5;               % On-Board Data Handling
P_Termico = 2.5;            % Control Térmico

% SUBSISTEMA ADCS (Diferentes modos) [W]
P_ADCS_Nominal = 0.8;       % Actitud nominal apuntando a Nadir
P_ADCS_Safe = 0.6;          % Control Y-Thomson (-2 deg/s)
P_ADCS_Mantenimiento = 0.5 + 0.4; % Mantenimiento de apuntamiento (5V + 12V)
P_ADCS_Seguimiento = 1.0 + 3.5;   % Seguimiento objetivo en Tierra (5V + 12V)
P_ADCS_Cambio = 1.0 + 4.0;        % Cambio de actitud (5V + 12V)
t_Cambio_min = 4;                 % Duración de la maniobra en minutos

% COMUNICACIONES [W]
P_Comms_Nominal = 9.5;      % Comunicaciones en modo nominal
P_Comms_Safe = 5.0;         % Emisión de paquete (cada 30s)

% CARGAS ÚTILES (EXPERIMENTOS) [W]
% Experimento 1: LEDs
P_Exp1_Pico = 9.0;          % Potencia pico
t_Exp1_ON = 10;             % Segundos encendido
t_Exp1_OFF = 20;            % Segundos apagado

% Experimento 2: Calidad del aire
P_Exp2 = 6.0;               % Operativo sobre ciudades objetivo

% Experimento 3: Fondo cósmico
P_Exp3 = 12.0;              % Operativo durante 1 órbita ininterrumpida

% Experimento 4: Basura espacial
P_Exp4 = 6.0;               
t_Exp4_min = 10;            % Duración mínima en minutos por órbita


%% MODO NOMINAL
% Peak and mean power requested caso 1 (exp3)
P_peak = P_Termico + P_OBDH + P_ADCS_Nominal + P_Exp3 + P_Exp1_Pico + P_Exp4 + P_ADCS_Mantenimiento;
P_mean = P_Termico + P_OBDH + P_ADCS_Nominal + P_ADCS_Mantenimiento + P_Exp3 + P_Exp1_Pico*(10/30) + P_Exp4*(10/T_min)  ;

% Peak and mean power requested caso 2 (exp2)
P_peak2 = P_Termico + P_OBDH + P_ADCS_Nominal + P_ADCS_Seguimiento + P_Exp1_Pico + P_Exp4 + P_Comms_Nominal;
P_mean2 = P_Termico + P_OBDH + P_ADCS_Nominal + P_ADCS_Seguimiento*(30/T_min) + P_ADCS_Cambio*(24/T_min) + P_ADCS_Mantenimiento*((T_min-54)/T_min) + P_Exp2*(20/T_min) + P_Exp1_Pico*(10/30) + P_Exp4*(10/T_min) + P_Comms_Nominal*(10/T_min);

% RESULTADOS DEL PRESUPUESTO DE POTENCIA (Impresión en consola)
fprintf('\n========================================================\n');
fprintf('         RESULTADOS DEL PRESUPUESTO DE POTENCIA         \n');
fprintf('========================================================\n');

fprintf('--- CASO 1: Worst-Case Energía (Experimento 3) ---\n');
fprintf('Potencia Media (P_mean1):      %5.2f W\n', P_mean);
fprintf('Potencia de Pico (P_peak1):    %5.2f W\n', P_peak);
fprintf('\n');

fprintf('--- CASO 2: Worst-Case Pico (Comms + Exp 2)    ---\n');
fprintf('Potencia Media (P_mean2):      %5.2f W\n', P_mean2);
fprintf('Potencia de Pico (P_peak2):    %5.2f W\n', P_peak2);
fprintf('========================================================\n\n');


%% MODO SAFE

% Potencia de Pico (El instante en el que el beacon transmite)
P_peak_safe = P_Termico + P_OBDH + P_ADCS_Safe + P_Comms_Safe;

% Potencia Media
t_beacon_ON = 1; % Asumimos 1 segundo de transmisión por paquete
P_mean_safe = P_Termico + P_OBDH + P_ADCS_Safe + P_Comms_Safe * (t_beacon_ON / 30);

fprintf('--- MODO SAFE (SUPERVIVENCIA) ---\n');
fprintf('Potencia Media (P_mean_safe):   %5.2f W\n', P_mean_safe);
fprintf('Potencia de Pico (P_peak_safe): %5.2f W\n', P_peak_safe);
fprintf('========================================================\n\n');



%% PANELES SOLARES

% Tiempos de luz y eclipse obtenidos de la simulación GMAT
T_eclipse = 2052;            % 34.2 minutos
T_daylight = T - T_eclipse;  % Resto de la órbita 

% Eficiencias del sistema Direct Energy Transfer (DET)
Xe = 0.65; 
Xd = 0.85; 

% Potencia requerida en ambos periodos
P_d = P_mean;
P_ec = P_d;

% Potencia media que deben generar los paneles solares durante el día
P_daylight = ( (P_ec*T_eclipse)/Xe + (P_d*T_daylight)/Xd ) / T_daylight;

fprintf('--- DIMENSIONAMIENTO DE PANELES SOLARES ---\n');
fprintf('Potencia requerida a los paneles (P_sa): %5.2f W\n', P_daylight);
fprintf('========================================================\n\n');


%% POTENCIA REQUERIDA A LOS PANELES (MODO SAFE)
P_d_safe = P_mean_safe;
P_ec_safe = P_mean_safe;

P_daylight_safe = ( (P_ec_safe * T_eclipse)/Xe + (P_d_safe * T_daylight)/Xd ) / T_daylight;

fprintf('--- POTENCIA PANELES (MODO SAFE) ---\n');
fprintf('Potencia requerida (P_sa_safe): %5.2f W\n', P_daylight_safe);
fprintf('========================================================\n\n');

%% DIMENSIONAMIENTO FÍSICO DE PANELES SOLARES (ÁREA)

G = 1367;          % Irradiancia solar [W/m^2]
eta = 0.28;        % Eficiencia de la célula [-]
f_p = 0.7;         % Factor de empaquetamiento [-]
Omega_deg = 22.5;  % Ángulo de incidencia máximo (RAAN-Sol) [deg]

% Paneles orientables
A_orientable = P_daylight / (G * eta * f_p * cos(deg2rad(Omega_deg)));

% Non orientable panels
A_non_orientable = (P_daylight *2 * pi) / (3 * G * eta * f_p * cos(deg2rad(Omega_deg)));

% Mostrar resultado en consola
fprintf('--- CONFIGURACIÓN A: PANELES ORIENTABLES (SADA) ---\n');
fprintf('Potencia a generar (P_sa):  %5.2f W\n', P_daylight);
fprintf('Área requerida (BOL):       %6.4f m^2\n', A_orientable);
fprintf('========================================================\n\n');

fprintf('--- CONFIGURACIÓN B: PANELES NO ORIENTABLES ---\n');
fprintf('Potencia a generar (P_sa):  %5.2f W\n', P_daylight);
fprintf('Área requerida (BOL):       %6.4f m^2\n', A_non_orientable);
fprintf('========================================================\n\n');

%% VERIFICACIÓN MODO SAFE (TUMBLING)
A_cuerpo = 0.28;        % [m^2] Área total en el cuerpo del satélite (4 caras)
factor_tumbling = 1/pi; % Factor de iluminación media para rotación

P_gen_safe = G * A_cuerpo * eta * f_p * factor_tumbling;

fprintf('--- VERIFICACIÓN DE SUPERVIVENCIA (TUMBLING) ---\n');
fprintf('Potencia requerida (Safe):      %5.2f W\n', P_daylight_safe);
fprintf('Potencia generada por cuerpo:   %5.2f W\n', P_gen_safe);
if P_gen_safe >= P_daylight_safe
    fprintf('=> ÉXITO: El satélite sobrevive solo con los paneles del cuerpo.\n');
else
    fprintf('=> FALLO: Se requiere más área.\n');
end
fprintf('========================================================\n\n');


%% --------- Dimensionamento baterias ---------- 

N = 1;               % Número de baterías independientes
eta_b = 0.95;        % Eficiencia de descarga Li-Ion
DoD = 0.6;           % Profundidad de descarga (según apuntes)
Xe_bat = 0.8;        % Eficiencia del regulador DC/DC


% ------------- CASO 1: Dimensionamiento por Eclipse -------------
% En el Modo Nominal (Caso 1), el único componente conectado directamente 
% a la tensión de batería es el Experimento 3 (12 W). El resto va a 5V/3.3V/12V.
Pe_noreg = P_Exp3;                  % 12 W (No regulado)
Pe_reg = P_mean - Pe_noreg;         % El resto pasa por el regulador

C1 = ((Pe_reg * T_eclipse) / Xe_bat + (Pe_noreg * T_eclipse)) / (DoD * eta_b * N * 3600); % [Wh]


% ------------- CASO 2: Dimensionamiento por Pico de Potencia -------------
% El pico efectivo se evalúa sobre Tp = 10 minutos (600 s).
% El Experimento 1 (9W) está encendido 10s de cada 30s, por lo que 
% aplicamos el duty cycle (10/30) para promediar su consumo en el pico.

Tp = 10 * 60;   % [s] Tiempo de duración del pico (10 minutos)

Pp_noreg = P_Comms_Nominal; % 9.5 W
Pp_reg = P_OBDH + P_Termico + P_ADCS_Nominal + P_ADCS_Seguimiento + (P_Exp1_Pico * (10/30)) + P_Exp4; 

C2 = ((Pp_reg * Tp) / Xe_bat + (Pp_noreg * Tp)) / (DoD * eta_b * N * 3600); % [Wh]


% ------------- CASO 3: Dimensionamiento por Pico + Eclipse -------------
% En el peor de los casos, el pico de potencia de 10 min (Caso 2) 
% se produce íntegramente durante el periodo de eclipse (Caso 1).
% La batería debe soportar ambos regímenes consecutivamente.

Energia_pico = (Pp_reg * Tp) / Xe_bat + (Pp_noreg * Tp);
Energia_resto_eclipse = (Pe_reg * (T_eclipse - Tp)) / Xe_bat + (Pe_noreg * (T_eclipse - Tp));

C3 = (Energia_pico + Energia_resto_eclipse) / (DoD * eta_b * N * 3600); % [Wh]

% --- SELECCIÓN DEL CASO PEOR ---
C_vec = [C1, C2, C3];
Capacidad_Requerida = max(C_vec);

% IMPRESIÓN DE RESULTADOS FINALES
fprintf('--- RESUMEN DIMENSIONAMIENTO DE BATERÍAS ---\n');
fprintf('Capacidad Caso 1 (Eclipse):          %5.3f Wh\n', C1);
fprintf('Capacidad Caso 2 (Pico 10 min):      %5.3f Wh\n', C2);
fprintf('Capacidad Caso 3 (Pico en Eclipse):  %5.3f Wh\n', C3);
fprintf('========================================================\n');
fprintf('=> CAPACIDAD MÍNIMA REQUERIDA:       %5.3f Wh\n', Capacidad_Requerida);
fprintf('========================================================\n\n');




%% ----- Numero celdas en serie y paralelo -------

C_cell = 2.850*3.65; % [Wh] datasheet 
V_cell = 3.65;       % [V] datasheet - voltaje nominal
V_batt_nom = 12;         % [V] maximum required voltage (ver los datos)
V_cell_min = 3.4;    % [V] datasheet - minimo voltaje operativo, considerandoun DoD 60% (aprox.)

% Cálculo preliminar del número mínimo total de celdas por capacidad
n_celdas_min_vec = [0 0 0]; 
for i = 1:3
    n_celdas_min_vec(i) = ceil(C_vec(i)/C_cell); 
end 
n_celdas_min = max(n_celdas_min_vec);

% Límite de corriente y cálculo de la tensión mínima del bus
I_max = 4;      % [A] Límite máximo de corriente en el bus elegido por diseño

% Consideramos el pico efectivo en 10 segundos para Exp.1 (usando variables)
P_total = Pp_noreg + (Pp_reg - (P_Exp1_Pico*10/30) + P_Exp1_Pico) / Xe_bat; 
V_min = P_total / I_max; 

% voltaje nominal
Ns1 = ceil(V_min/V_cell); 
% mínimo voltaje operativo
Ns2 = ceil(V_min/V_cell_min); 

Ns_battery = max(Ns1, Ns2);

% Cálculo de celdas en Paralelo (Np)
Np_vec = [0 0 0]; 
for i = 1:3
    Np_vec(i) = ceil(C_vec(i) / (C_cell * Ns_battery));    
end 
Np_battery = max(Np_vec);

fprintf('--- CONFIGURACIÓN FINAL DE LA BATERÍA ---\n');
fprintf('Pico máximo instantáneo (P_total):   %5.2f W\n', P_total);
fprintf('Tensión mínima requerida del bus:    %5.2f V (para I_max = %d A)\n', V_min, I_max);
fprintf('Celdas en serie necesarias (Ns):     %d\n', Ns_battery);
fprintf('Celdas en paralelo necesarias (Np):  %d\n', Np_battery);
fprintf('=> CONFIGURACIÓN SELECCIONADA:       %dS%dP\n', Ns_battery, Np_battery);
fprintf('=> Número total de celdas físicas:   %d\n', Ns_battery * Np_battery);
fprintf('========================================================\n\n');



%% Sizing of solar cells (Azur Space 3G28C)

I_sc = 0.506;        % Corriente de cortocircuito [A]
V_oc = 2.667;        % Tensión de circuito abierto [V]
I_mp = 0.487;        % Corriente máxima potencia [A]
V_mp = 2.371;        % Tensión máxima potencia [V]
A_cell = 0.0032;     % Área física de la célula (40x80 mm = 32 cm^2 convertidos a m^2)

V_cell_batt_max = 4.2;
V_bat_max = Ns_battery * V_cell_batt_max;

% Número de células en serie (Ns)
Ns_calc = V_bat_max / V_mp;
Ns_SP = ceil(Ns_calc);   

V_string = Ns_SP * V_mp; % Tensión real de la cadena generada

% Paso 3: Número de cadenas en paralelo (Np) y total de células
% Usamos el A_non_orientable y f_p (0.7) calculados previamente
A_celulas_puras = A_non_orientable * f_p; % Área estrictamente cubierta por células fotovoltaicas
N_teo = A_celulas_puras / A_cell;         % Número teórico de células necesarias 

Np_calc = N_teo / Ns_SP;                     % Número de cadenas teóricas en paralelo
Np_SP = ceil(Np_calc);                       % Redondeo hacia arriba por seguridad 

N_total_nominal = Np_SP * Ns_SP;                        % Células totales para el Modo Nominal (Alas + Cuerpo)


fprintf('--- CONFIGURACIÓN DE CÉLULAS SOLARES (MODO NOMINAL DET) ---\n');
fprintf('Tensión máxima de batería:        %5.2f V\n', V_bat_max);
fprintf('Células solares en serie (Ns_SP): %d (Tensión de string: %5.2f V)\n', Ns_SP, V_string);
fprintf('Cadenas en paralelo (Np_SP):      %d\n', Np_SP);
fprintf('=> TOTAL CÉLULAS (Ns_SP x Np_SP): %d\n', N_total_nominal);
fprintf('Área de células real resultante:  %6.4f m^2\n', N_total_nominal * A_cell);
fprintf('========================================================\n\n');