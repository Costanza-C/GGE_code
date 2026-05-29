clear; clc;

%% PERFIL DE POTENCIA

figure('Name', 'Perfil de potencia integrado', 'Color', 'w');
hold on; grid on;


% CATEGORÍAS (Eje Y)
categories = {'Comms (Kir/San/Har)', 'Exp 2 (Mad/Rio/Del)','Eclipses','Control termico, OBDH, ADCS','Exp 3',...
    'Cambio de actitud', 'Seguimiento','Mantenimiento','Exp 4','Exp 1'};
colors = [
    0.000,  0.447,  0.741;  % 1. Blu - Comms
    0.850,  0.325,  0.098;  % 2. red - Exp 2
    0.466,  0.674,  0.188;  % 3. green - Exp 3
    0.300,  0.300,  0.300;  % 4. grey - eclipses
    0.494,  0.184,  0.556;  % 5. purple - ADCS Manovre
    0.929,  0.694,  0.125;  % 6. yellow
    0.301,  0.745,  0.933;  % 7. light blue
    0.635,  0.078,  0.184;  % 8. Bordeaux
    0.100,  0.100,  0.100;  % 9. black
    1.000,  0.400,  0.600;  % 10. pink
    0.000,  0.500,  0.500;  % 11. green light
    0.600,  0.400,  0.200   % 12. brown
];


% DATOS TEMPORALES (Horas decimales)
comms_data = [
    % Kiruna
    0.24, 0.38; 1.83, 1.96; 3.47, 3.52; 13.24, 13.33; 14.82, 14.95; 
    16.40, 16.53; 17.99, 18.08; 19.57, 19.62; 21.13, 21.19; 22.67, 22.77;
    % Santiago
    7.79, 7.90; 9.38, 9.48; 20.06, 20.19;
    % Hartebeesthoek
    1.42, 1.54; 3.04, 3.08; 13.63, 13.76
];

exp2_data = [
    % Madrid
    3.31, 3.44; 14.98, 15.04; 16.53, 16.66;
    % Rio
    6.23, 6.36; 18.42, 18.55;
    % Nueva Delhi
    10.20, 10.33; 11.82, 11.86; 22.44, 22.57
];

eclipses = [
    0.55, 1.12;  % Evento 1
    2.15, 2.72;  % Evento 2
    3.75, 4.32;  % Evento 3
    5.35, 5.92;  % Evento 4
    6.95, 7.52;  % Evento 5
    8.55, 9.12;  % Evento 6
    10.15, 10.72; % Evento 7
    11.75, 12.32; % Evento 8
    13.35, 13.92; % Evento 9
    14.95, 15.52; % Evento 10
    16.55, 17.12; % Evento 11
    18.15, 18.72; % Evento 12
    19.75, 20.32; % Evento 13
    21.35, 21.92; % Evento 14
    22.95, 23.52  % Evento 15
];

constantes = [0, 24];

exp3_data = [4.0, 5.6]; % 1 orbit


t_slew = 4/60; 
eventos_con_maniobra = [comms_data; exp2_data]; 
slew_data = [];
for i = 1:size(eventos_con_maniobra, 1)
    slew_data = [slew_data; eventos_con_maniobra(i,1)-t_slew, eventos_con_maniobra(i,1)];
    slew_data = [slew_data; eventos_con_maniobra(i,2), eventos_con_maniobra(i,2)+t_slew];
end

seguimiento_data = [comms_data; exp2_data];


% Cálculo de los intervalos libres o "huecos" (Modo Mantenimiento de apuntamiento)
tiempos_ocupados = sortrows([slew_data; seguimiento_data], 1);

mantenimiento_data = [];
tempo_attuale = 0;

for i = 1:size(tiempos_ocupados, 1)
    inizio_occupato = tiempos_ocupados(i,1);
    fine_occupato = tiempos_ocupados(i,2);
    
    % Si existe un intervalo libre entre el fin del último evento y el inicio del siguiente
    if inizio_occupato > tempo_attuale
        mantenimiento_data = [mantenimiento_data; tempo_attuale, inizio_occupato];
    end
    
    % Actualización del tiempo actual al final del evento operativo actual
    if fine_occupato > tempo_attuale
        tempo_attuale = fine_occupato;
    end
end

% Añadimos el último intervalo restante hasta completar las 24 horas del día de misión
if tempo_attuale < 24
    mantenimiento_data = [mantenimiento_data; tempo_attuale, 24];
end



periodo_orbita = 1.6; % 96 minutos en horas
duracion_exp4 = 10/60; % 10 minutos en horas
exp4_data = zeros(15, 2); % Matriz para 15 órbitas

for n = 1:15
    t_inicio = (n-1) * periodo_orbita + 0.1; % Iniciamos 6 min después del inicio de órbita
    exp4_data(n, :) = [t_inicio, t_inicio + duracion_exp4];
end


exp1_data = [0, 24]; 

% DIBUJO DE LAS BARRAS
plot_bars(comms_data, 1, colors(1,:));
plot_bars(exp2_data, 2, colors(2,:));
plot_bars(eclipses, 3, colors(4,:));
plot_bars_sottile(constantes, 4, colors(11,:));
plot_bars_sottile(exp3_data, 5, colors(10,:));
plot_bars(slew_data, 6, colors(5,:));
plot_bars(seguimiento_data, 7, colors(6,:));
plot_bars(mantenimiento_data, 8, colors(7,:));
plot_bars(exp4_data, 9, colors(3,:));
plot_bars_sottile(exp1_data, 10, colors(12,:));


% CONFIGURACIÓN DEL GRÁFICO
num_lines = length(categories);
yticks(1:num_lines);
yticklabels(categories);
set(gca, 'YDir', 'reverse'); 

ylim([0.5, length(categories) + 0.5]);   
xlim([0 24]);
xticks(0:2:24);
xlabel('Tiempo de misión [Horas]');
title('Perfil de potencia','FontSize',15,'FontWeight','bold');


% LEYENDA TEMPORAL
h1 = plot(nan,nan,'s','MarkerFaceColor',colors(1,:),'MarkerEdgeColor','none','MarkerSize',10);
h2 = plot(nan,nan,'s','MarkerFaceColor',colors(2,:),'MarkerEdgeColor','none','MarkerSize',10);
h3 = plot(nan,nan,'s','MarkerFaceColor',colors(4,:),'MarkerEdgeColor','none','MarkerSize',10);
h4 = plot(nan,nan,'s','MarkerFaceColor',colors(11,:),'MarkerEdgeColor','none','MarkerSize',10);
h5 = plot(nan,nan,'s','MarkerFaceColor',colors(10,:),'MarkerEdgeColor','none','MarkerSize',10);
h6 = plot(nan,nan,'s','MarkerFaceColor',colors(5,:),'MarkerEdgeColor','none','MarkerSize',10);
h7 = plot(nan,nan,'s','MarkerFaceColor',colors(6,:),'MarkerEdgeColor','none','MarkerSize',10);
h8 = plot(nan,nan,'s','MarkerFaceColor',colors(7,:),'MarkerEdgeColor','none','MarkerSize',10);
h9 = plot(nan,nan,'s','MarkerFaceColor',colors(3,:),'MarkerEdgeColor','none','MarkerSize',10);
h10 = plot(nan,nan,'s','MarkerFaceColor',colors(12,:),'MarkerEdgeColor','none','MarkerSize',10);

legend([h1, h2, h3, h4, h5, h6, h7, h8, h9, h10], {'Comms (9.5 W)', 'Exp 2 (6.0 W)', 'Eclipses', 'Consumos constantes (6.8 W)', ...
     'Exp 3 (1 orbit) (12 W)','Cambio de actitud (5 W)','Seguimiento de objetivo a tierra (4.5 W)','Mantenimiento de apuntamiento (0.9 W)',... 
     'Exp 4 (6 W)','Exp 1 (3 W media)'}, 'Location', 'northeast');


function plot_bars(data, y_pos, color)
    for i = 1:size(data, 1)
        line([data(i,1), data(i,2)], [y_pos, y_pos], 'Color', color, 'LineWidth', 15);
    end
end

function plot_bars_sottile(data, y_pos, color)
    for i = 1:size(data, 1)
        line([data(i,1), data(i,2)], [y_pos, y_pos], 'Color', color, 'LineWidth', 8);
    end
end




%% GENERACIÓN DEL PERFIL DE POTENCIA REAL 

t_vec_pot = 0:0.01:24; % Vector temporal de alta resolución
P_totale = zeros(size(t_vec_pot));

for i = 1:length(t_vec_pot)
    t = t_vec_pot(i);
    p = 6.8; % Potencia base constante siempre activa (OBDH + Control Térmico + ADCS Base)
    
    % Suma de los consumos de los módulos si están activos en el instante 't'
    if any(t >= comms_data(:,1) & t <= comms_data(:,2)), p = p + 9.5; end
    if any(t >= exp2_data(:,1) & t <= exp2_data(:,2)), p = p + 6.0; end
    if (t >= exp3_data(1) && t <= exp3_data(2)),       p = p + 12.0; end
    if any(t >= exp4_data(:,1) & t <= exp4_data(:,2)), p = p + 6.0; end
    
    % Suma de los modos ADCS adicionales 
    if any(t >= slew_data(:,1) & t <= slew_data(:,2)),                   p = p + 5.0; end
    if any(t >= seguimiento_data(:,1) & t <= seguimiento_data(:,2)),     p = p + 4.5; end
    if any(t >= mantenimiento_data(:,1) & t <= mantenimiento_data(:,2)), p = p + 0.9; end
    
    % Para el Experimento 1 (LEDs), añadimos el consumo MEDIO (3.0 W) 
    % para el perfil continuo. Los picos de 9W se detallarán analíticamente en la memoria.
    p = p + 3.0; 
    
    P_totale(i) = p;
end


figure('Name', 'Perfil de potencia consumida', 'Color', 'w');
plot(t_vec_pot, P_totale, 'LineWidth', 2, 'Color', [0.850, 0.325, 0.098]);
grid on;
xlim([0 24]); xticks(0:2:24);
ylim([0 40]);
xlabel('Tiempo de misión [Horas]','FontSize',13);
ylabel('Potencia total consumida [W]','FontSize',13);
title('Perfil de potencia consumida total (modo nominal)','FontSize',15,'FontWeight','bold');



%%  OPERACION NOMINAL DEL SATELITE

%% DATOS 
a = 6945;         % [km]  Semi-major axis
e = 0.00001;      % [-]   Eccentricity
i_deg = 97.6583;  % [deg] Inclination
w_deg = 0;        % [deg] Argument of perigee
theta_deg = 0;    % [deg] true anomaly
h = 566.9;        % [km]  Altitude

R_e = astroConstants(23);    % Earth's equatorial radius [km]
mu_E = astroConstants(13);   % Earth's gravitational parameter [km^3/s^2]

Initial_date = [2026, 4, 6, 10, 00, 00];         % Initial date 
initial_time_days = date2mjd2000(Initial_date);  % Initial time [days]
initial_time = initial_time_days * 86400;        % Initial time [s]

T =  2*pi*sqrt( a^3/mu_E);                       % Initial Orbital period (Kepler) [s]
T_min = T / 60;                                  % Initial Orbital period (Kepler) [min]

G_0 = 1367;         % [W/m^2] mean solar constant
t_vec = 0:10:86400;  % Vector temporal de alta resolución


eclipses = [                     % [h] Eclipses duration
    0.55, 1.12 ;  % Evento 1
    2.15, 2.72 ;  % Evento 2
    3.75, 4.32;   % Evento 3
    5.35, 5.92;   % Evento 4
    6.95, 7.52;   % Evento 5
    8.55, 9.12;   % Evento 6
    10.15, 10.72; % Evento 7
    11.75, 12.32; % Evento 8
    13.35, 13.92; % Evento 9
    14.95, 15.52; % Evento 10
    16.55, 17.12; % Evento 11
    18.15, 18.72; % Evento 12
    19.75, 20.32; % Evento 13
    21.35, 21.92; % Evento 14
    22.95, 23.52  % Evento 15
];

eclipses_sec = eclipses * 3600;   % [s] Eclipses duration

% Vector normals to the faces of the body (Body-mounted)
% Remember: -X is Nadir, +X is Zenit, Z is velocidad, Y is cross-track
n_px = [+1; 0; 0];  % Face +X (Zenit, 0.08 m2)
n_mx = [-1; 0; 0];  % Face -X (Nadir - NO PANELES SOLARES)
n_py = [0; +1; 0];  % Face +Y (Lateral, 0.08 m2)
n_my = [0; -1; 0];  % Face -Y (Lateral, 0.08 m2)
n_pz = [0; 0; +1];  % Face +Z (Frontal con MPPT, 0.04 m2)
n_mz = [0; 0; -1];  % Face -Z (Trasera/Lanzador - NO PANELES SOLARES)

% % Vector normals to the faces of the Deployable panels
% Let's assume that they close on y face and they open 90 degrees pointing Zenit (+X)
n_ala1 = [1; 0; 0]; % Ala 1 (0.08 m2)
n_ala2 = [1; 0; 0]; % Ala 2 (0.08 m2)





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



%% ORBITAL DYNAMICS AND SUN VECTOR

% Definition of the True 3D Sun Vector in inertial axes (ECI)
% We use the true ecliptic longitude (lambda) and obliquity (epsilon) calculated in Step 1
S_ECI = [cos(lambda_sun_rad); ...
         cos(epsilon_rad) * sin(lambda_sun_rad); ...
         sin(epsilon_rad) * sin(lambda_sun_rad)];
     
S_ECI = S_ECI / norm(S_ECI); % Ensure it is a unit vector

% Static alignment matrix: from RSW axes to Body axes (C_brefRSW)
% R = Radial (Zenith), S = Along-track (Velocity), W = Cross-track
% Based on geometry: X_body = +R, Z_body = +S. By right-hand rule (X x Y = Z), Y_body = -W.
C_brefRSW = [1  0  0;  ... % X_body points to +R (Zenith)
             0  0 -1;  ... % Y_body points to -W (Inverse Cross-track)
             0  1  0];     % Z_body points to +S (Velocity)

% Initialize the matrix that will store the Sun vector as seen by the satellite
S_body_mat = zeros(3, length(t_vec));

% Mean angular velocity of the orbit (assuming near-circular orbit)
omega_orb = sqrt(mu_E / (a^3)); % [rad/s]

% Main time loop for kinematics
for j = 1:length(t_vec)
    
    % True anomaly at instant j
    theta_j = rad2deg(omega_orb * t_vec(j)); 
    
    % Rotation matrices (ECI -> RSW)
    Cx_i = [1  0            0; ...
            0  cosd(i_deg)  sind(i_deg); ...
            0 -sind(i_deg)  cosd(i_deg)]; 
        
    Cz_RAAN = [cosd(RAAN_deg)  sind(RAAN_deg) 0; ...
              -sind(RAAN_deg)  cosd(RAAN_deg) 0; ...
               0               0              1];
           
    Cz_theta = [cosd(theta_j)  sind(theta_j) 0; ...
               -sind(theta_j)  cosd(theta_j) 0; ...
                0              0             1]; 
            
    % Total matrix ECI -> RSW
    C_RSWi = Cz_theta * Cx_i * Cz_RAAN; 
    
    % Total matrix ECI -> Body
    C_bi = C_brefRSW * C_RSWi; 
    
    % Projection of the Sun Vector onto the satellite's body axes
    S_body_mat(:, j) = C_bi * S_ECI;
    
end

disp('Step 2 completed: True 3D Sun Vector in body axes calculated successfully!');



%% ECLIPSES AND TRACKING MANEUVERS

% Eclipse mask (0 = eclipse, 1 = sun)
illumination_factor = ones(1, length(t_vec)); 

for k = 1:size(eclipses_sec, 1)
    t_start = eclipses_sec(k, 1);
    t_end   = eclipses_sec(k, 2);
    
    idx_eclipse = (t_vec >= t_start) & (t_vec <= t_end);
    illumination_factor(idx_eclipse) = 0; 
end


comms_data = [
    0.24, 0.38; 1.83, 1.96; 3.47, 3.52; 13.24, 13.33; 14.82, 14.95; 
    16.40, 16.53; 17.99, 18.08; 19.57, 19.62; 21.13, 21.19; 22.67, 22.77; % Kiruna
    7.79, 7.90; 9.38, 9.48; 20.06, 20.19;                                 % Santiago
    1.42, 1.54; 3.04, 3.08; 13.63, 13.76                                  % Hartebeesthoek
];

exp2_data = [
    3.31, 3.44; 14.98, 15.04; 16.53, 16.66;  % Madrid
    6.23, 6.36; 18.42, 18.55;                % Rio
    10.20, 10.33; 11.82, 11.86; 22.44, 22.57 % Nueva Delhi
];

t_slew = 4/60; % 4 minutes in hours
eventos_con_maniobra = [comms_data; exp2_data]; 
slew_data = [];

for i = 1:size(eventos_con_maniobra, 1)
    slew_data = [slew_data; eventos_con_maniobra(i,1)-t_slew, eventos_con_maniobra(i,1)];
    slew_data = [slew_data; eventos_con_maniobra(i,2), eventos_con_maniobra(i,2)+t_slew];
end

% Combine all tracking events (Tracking + Slew)
all_tracking_events_hours = [eventos_con_maniobra; slew_data];

% Convert hours to seconds
tracking_events_sec = all_tracking_events_hours * 3600;

attitude_factor = ones(1, length(t_vec));

for k = 1:size(tracking_events_sec, 1)
    t_start = tracking_events_sec(k, 1);
    t_end   = tracking_events_sec(k, 2);
    
    idx_tracking = (t_vec >= t_start) & (t_vec <= t_end);
    attitude_factor(idx_tracking) = 0.8; % Apply the 20% penalty
end

global_irradiance_factor = illumination_factor .* attitude_factor;

disp('Step 3 completed: Eclipse and Tracking masks generated successfully!');




%% EFFECTIVE IRRADIANCE PER FACE [W/m^2]

% We calculate the cosine of the angle between the normal of each face and the Sun vector.
% Using vectorized operations (matrix multiplication), this is done for all times at once!
cos_px   = n_px' * S_body_mat;
cos_py   = n_py' * S_body_mat;
cos_my   = n_my' * S_body_mat;
cos_pz   = n_pz' * S_body_mat;
cos_ala1 = n_ala1' * S_body_mat;
cos_ala2 = n_ala2' * S_body_mat;

% Auto-shadowing mask: if the cosine is negative, the face is pointing away from the Sun.
% We force all negative values to 0.
cos_px(cos_px < 0) = 0;
cos_py(cos_py < 0) = 0;
cos_my(cos_my < 0) = 0;
cos_pz(cos_pz < 0) = 0;
cos_ala1(cos_ala1 < 0) = 0;
cos_ala2(cos_ala2 < 0) = 0;

% Final irradiance calculation: G_0 * cos(theta) * global_irradiance_factor
% We apply the eclipse and tracking masks element-wise (.*)
G_eff_px   = G_0 * cos_px   .* global_irradiance_factor;
G_eff_py   = G_0 * cos_py   .* global_irradiance_factor;
G_eff_my   = G_0 * cos_my   .* global_irradiance_factor;
G_eff_pz   = G_0 * cos_pz   .* global_irradiance_factor;
G_eff_ala1 = G_0 * cos_ala1 .* global_irradiance_factor;
G_eff_ala2 = G_0 * cos_ala2 .* global_irradiance_factor;

disp('Step 4 completed: Effective irradiance calculated for all active faces!');



t_hours = t_vec / 3600;

figure('Name', 'Irradiancia Efectiva por Cara (24 Horas)', 'NumberTitle', 'off');
hold on; grid on;

plot(t_hours, G_eff_px, 'LineWidth', 1.5, 'DisplayName', '+X (Zenit)');
plot(t_hours, G_eff_py, 'LineWidth', 1.5, 'DisplayName', '+Y (Lateral)');
plot(t_hours, G_eff_my, 'LineWidth', 1.5, 'DisplayName', '-Y (Lateral)');
plot(t_hours, G_eff_pz, 'LineWidth', 1.5, 'DisplayName', '+Z (Frontal MPPT)');
plot(t_hours, G_eff_ala1, '--', 'LineWidth', 1.5, 'DisplayName', 'Alas 1 & 2');

xlabel('Tiempo de misión [Horas]');
ylabel('Irradiancia Efectiva [W/m^2]');
title('Perfil de Irradiancia Efectiva sobre los Paneles (24h)');
legend('show', 'Location', 'best');
xlim([0 24]);
ylim([-50 1500]); % Un po' di margine sopra e sotto
hold off;



%% THERMAL MODEL (Solar Array Temperature)

% Thermal constants 
alpha_1 = 0.0015; % [s^-1] Heating constant during daylight 
alpha_2 = 0.003;  % [s^-1] Cooling constant during eclipse 

T_panels = zeros(1, length(t_vec));

% Initialize the tracking timers (in seconds)
t_s = 0; % Time elapsed since exiting the eclipse
t_e = 0; % Time elapsed since entering the eclipse

% Simulation time step (must match t_vec resolution, i.e., 10s)
step_t = 10; 

for j = 1:length(t_vec)
   
    if illumination_factor(j) == 1
        t_s = t_s + step_t;         % Advance daylight timer
        t_e = 0;                    % Reset eclipse timer
        
        % Exponential heating equation 
        T_panels(j) = -20 + 80 * (1 - exp(-alpha_1 * t_s));
        
    else
        t_e = t_e + step_t; % Advance eclipse timer
        t_s = 0;            % Reset daylight timer
        
        % Exponential cooling equation 
        T_panels(j) = 60 - 80 * (1 - exp(-alpha_2 * t_e));
    end
end

disp('Step 5 completed: Solar array temperature profile calculated successfully!');

figure('Name', 'Solar Array Thermal Profile (24 Hours)', 'NumberTitle', 'off');
plot(t_hours, T_panels, 'r', 'LineWidth', 1.5);
grid on;
xlabel('Mission Time [Hours]');
ylabel('Solar Array Temperature [°C]');
title('Solar Array Temperature Evolution over 24 Hours');
xlim([0 24]);
ylim([-30 70]);




%% DYNAMIC EPS SIMULATION (DET + BATTERY)

% Solar cell parameters (Azur Space 3G28C) at BOL
Voc_cell = 2.667; % [V]
Vmp_cell = 2.371; % [V]
Isc_cell = 0.506; % [A]
Imp_cell = 0.487; % [A]

beta_Voc  = -6.0e-3;  % [V/°C]  (viene de -6.0 mV/°C)
alpha_Isc =  0.32e-3; % [A/°C]  (viene de 0.32 mA/°C)
beta_Vmp  = -6.1e-3;  % [V/°C]  (viene de -6.1 mV/°C)
alpha_Imp =  0.28e-3; % [A/°C]  (viene de 0.28 mA/°C)

T_ref = 28; % [°C] Reference temperature from datasheet
G_ref = 1367; % [W/m^2]

% Solar array configuration 
Ns = 8;       % Cells in series per string to exceed 16.8 V
Np = 11;       % Total parallel strings

% Battery parameters (4S1P configuration with Samsung 29E cells)
C_bat_Ah = 2.85;    % [Ah] Total battery capacity
V_bat_max = 4.2*4;  % [V] Battery voltage at 100% SoC 
V_bat_min = 3.4*4;  % [V] Battery voltage at 0% operational SoC



% Power vector adaptation (Interpolation)
% We convert t_vec_pot (which was in hours) to seconds to match
% the orbital t_vec (8641 points)
t_vec_pot_sec = t_vec_pot * 3600; 
P_consumed = interp1(t_vec_pot_sec, P_totale, t_vec, 'linear', 'extrap');

% Initialization of state vectors for the Battery
SoC = zeros(1, length(t_vec));
SoC(1) = 0.80;                  % Initial condition: 80%

V_bat      = zeros(1, length(t_vec));
I_gen_DET  = zeros(1, length(t_vec)); 
I_gen_MPPT = zeros(1, length(t_vec)); 
I_gen_tot  = zeros(1, length(t_vec)); 
I_cons     = zeros(1, length(t_vec)); 
P_gen_tot  = zeros(1, length(t_vec));

eta_MPPT = 0.93;  

A_ala = (2 * 8 * 0.0032) / 0.70;  % = 0.0731 m² per ala

A_MPPT = 0.04;   Np_MPPT = 1;
A_DET  = 0.24 + 2*A_ala;  Np_DET = 10;  % = 0.3863 m²

G_eq_DET = (G_eff_px*0.08 + G_eff_py*0.08 + G_eff_my*0.08 + ...
            G_eff_ala1*(2*A_ala)) / A_DET;
G_eq_MPPT = G_eff_pz;

%% STEP 6.3: DYNAMIC SIMULATION (DET + MPPT Power Loop)

warning('off', 'all'); % Silence lambertw solver warnings

for j = 1:length(t_vec)
    
    % --- BATTERY STATE ---
    % Assuming linear SoC-Voltage relationship in the operational region
    V_bat(j) = V_bat_min + (V_bat_max - V_bat_min) * SoC(j);
    
    % Current demanded by the satellite systems
    I_cons(j) = P_consumed(j) / V_bat(j);
    
    % --- TEMPERATURE ---
    dT = T_panels(j) - T_ref;
    
    % --- MPPT CHANNEL (+Z Face) ---
    if G_eq_MPPT(j) > 0
        % The MPPT always operates at Vmp and Imp
        Vmp_pan_Z = (Vmp_cell + beta_Vmp * dT) * Ns;
        Imp_pan_Z = (Imp_cell + alpha_Imp * dT) * (G_eq_MPPT(j) / G_ref) * Np_MPPT;
        
        P_MPPT = Vmp_pan_Z * Imp_pan_Z * eta_MPPT; % Actual extracted power
        I_gen_MPPT(j) = P_MPPT / V_bat(j);         % Injected into the bus as current
    else
        I_gen_MPPT(j) = 0;
    end
    
    % --- DET CHANNEL (X, Y, Wings Faces) ---
    if G_eq_DET(j) > 0
        % Recalculate characteristic points for the 10 DET strings
        Voc_pan_DET = (Voc_cell + beta_Voc * dT) * Ns;
        Vmp_pan_DET = (Vmp_cell + beta_Vmp * dT) * Ns;
        Isc_pan_DET = (Isc_cell + alpha_Isc * dT) * (G_eq_DET(j) / G_ref) * Np_DET;
        Imp_pan_DET = (Imp_cell + alpha_Imp * dT) * (G_eq_DET(j) / G_ref) * Np_DET;
        
        % Karmalkar-Haneefa Model
        K = (1 - (Imp_pan_DET/Isc_pan_DET) - (Vmp_pan_DET/Voc_pan_DET)) / (2*(Imp_pan_DET/Isc_pan_DET) - 1);
        lamb_kal = -(Voc_pan_DET/Vmp_pan_DET)^(1/K) * (1/K) * log(Vmp_pan_DET/Voc_pan_DET);
        m = lambertw(-1, lamb_kal) / log(Vmp_pan_DET/Voc_pan_DET) + 1/K + 1;
        gamma = (2*(Imp_pan_DET/Isc_pan_DET) - 1) / ((m-1) * (Vmp_pan_DET/Voc_pan_DET)^m);
        
        % The battery imposes its voltage (V_bat) on the solar arrays
        if V_bat(j) < Voc_pan_DET
            I_gen_DET(j) = Isc_pan_DET * (1 - (1-gamma)*(V_bat(j)/Voc_pan_DET) - gamma*(V_bat(j)/Voc_pan_DET)^m);
        else
            I_gen_DET(j) = 0; % Battery voltage above Voc
        end
    else
        I_gen_DET(j) = 0;
    end
    
    % --- GLOBAL BALANCE AND COULOMB COUNTING ---
    I_gen_tot(j) = I_gen_DET(j) + I_gen_MPPT(j);
    P_gen_tot(j) = I_gen_tot(j) * V_bat(j);
    
    if j < length(t_vec)
        I_net = I_gen_tot(j) - I_cons(j);
        
          if I_net >= 0
              eta_b = 0.95;
              % Fase di carica: efficienza riduce la corrente effettiva immagazzinata
              SoC(j+1) = SoC(j) + (I_net * step_t * eta_b) / (C_bat_Ah * 3600);
          else
              eta_b = 0.95;
              % Fase di scarica: efficienza riduce la corrente effettivamente disponibile
              SoC(j+1) = SoC(j) + (I_net * step_t / eta_b) / (C_bat_Ah * 3600);
          end
        
        % Battery physical limits (Regulators)
        if SoC(j+1) > 1
            SoC(j+1) = 1; % Regulator dissipates excess (Battery full)
        elseif SoC(j+1) < 0.40
            SoC(j+1) = 0.40; % Límite DoD 60%
            % Aquí se activaría el modo de recarga
        end
    end
end

disp('Step 6 Completed: Dynamic EPS Simulation finished successfully!');

%% FINAL ENERGY BALANCE VISUALIZATION
figure('Name', 'Battery voltage and SoC evolution', 'NumberTitle', 'off', 'Color', 'w');

% Plot 1: Battery Voltage and SoC Evolution
yyaxis left;
plot(t_hours, V_bat, 'b-', 'LineWidth', 1.5);
ylabel('Bus Voltage [V]', 'FontSize', 11);
ylim([13 17.5]);
yyaxis right;
ax = gca;
ax.YAxis(2).Color = [0.2 0.6 0.2]; % forza colore asse destro
plot(t_hours, SoC * 100, 'g-', 'LineWidth', 2);
ylabel('State of Charge (SoC) [%]', 'FontSize', 11);
ylim([0 105]);
title('Battery Evolution: SoC and Voltage', 'FontSize', 13, 'FontWeight', 'bold');
grid on;

figure('Name', ' Generated vs Consumed Power', 'NumberTitle', 'off', 'Color', 'w');

% Plot 2: Generated vs Consumed Power
plot(t_hours, P_gen_tot, 'Color', [0.4660, 0.6740, 0.1880], 'LineWidth', 1.5, 'DisplayName', 'Generated Power (Arrays)');
hold on;
plot(t_hours, P_consumed, 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 1.5, 'DisplayName', 'Consumed Power (Systems)');
xlabel('Mission Time [Hours]', 'FontSize', 11);
ylabel('Power [W]', 'FontSize', 11);
title('Satellite Power Balance (DET + MPPT)', 'FontSize', 13, 'FontWeight', 'bold');
legend('show', 'Location', 'best');
xlim([0 24]);
grid on; hold off;



