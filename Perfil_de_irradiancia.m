
clear
clc

% Calculo irradiancia 
% CODICE DA CORREGGERE - ELIMINARE PARTI NON NECESSARIE

%% 1 - Potencia media analitica

mu_E = astroConstants(13); 
R_E = astroConstants(23); 
h = 700; 
r = R_E + h; % [Km]

% Periodo
T = 2*pi*sqrt(r^3/mu_E) / 3600 %[h]

% Datos
G = 1361; % [W/m^2]
Ax = 0.1*0.3; %[m^2]
fp = 0.8; 
eta = 0.3; 
OMEGA = 90; %[deg] Ángulo relativo entre el RAAN de la órbita y el RA del Sol 

% Potencia media en la cara que tiene normal perpendicular al piano orbital -> la cara x 
Px = G * Ax * fp * eta * sind(OMEGA)
Pmx = 0; 
Py = 0; 
Pmy = 0; 

%% 2 - Potencia media numerica
clear
clc

mu_E = astroConstants(13); 
R_E = astroConstants(23); 
h = 700; 
r = R_E + h; % [Km]

% Periodo
T = 2*pi*sqrt(r^3/mu_E) / 3600 %[h]

% Datos
G = 1361; % [W/m^2]
A = 0.1*0.3; %[m^2] Ax = Ay
fp = 0.8; 
eta = 0.3; 
OMEGA = 90; %[deg] Ángulo relativo entre el RAAN de la órbita y el RA del Sol [deg]

% Inclinaciòn 
J2 = astroConstants(9); 
syms i
e = 0; 
a = r;
RAAN = 90; % [deg] al equinoccio de primavera
RAAN_dot = -3/2 * J2 * (R_E)^2 * 1/((1-e^2)^2) * sqrt(mu_E/a^7)*cosd(i); % [rad/s]
val = 2*pi/(365.25*24*60*60); 
solve((RAAN_dot-val),i); 
i = (180*(pi - acos(940233214828881/6610436648488277)))/pi % [deg]

% Vector Sol
S_ECI = [1,0,0]'; 

% Vectores normales a las caras
n_x = [1; 0; 0]; 
n_mx = [-1; 0; 0]; 
n_y = [0; 1; 0]; 
n_my = [0; -1; 0]; 

% Anomalia vera 
tvec = linspace(0,T*3600, 1000); 
omega = sqrt(mu_E/(a^3)); 
theta = rad2deg(omega*tvec); % Circular uniforme

% Matrices constantes
C_brefRSW = [0 0 1;... 
                  0 1 0;...
                  -1 0 0 ];
C_bbref = eye(3); % No cambio de actitud en punto 2

% Angulo critico de eclipse
rho = asind(R_E/(R_E+h)); 

Px_vec = zeros(length(tvec),1);
Py_vec = zeros(length(tvec),1);
Pmx_vec = zeros(length(tvec),1);
Pmy_vec = zeros(length(tvec),1);
eclisse_mask = zeros(1,length(tvec));

% Componente costante de potencia 
 cost = G * A * fp * eta; % No pongo T proque ya està en "mean" de MATLAB

% Ciclo temporal 
for j = 1:length(tvec)
    Cx_i = [1 0 0; ...
        0 cosd(i) sind(i); ...
        0 -sind(i) cosd(i)]; 
    Cz_OMEGA = [cosd(RAAN) sind(RAAN) 0; ...
        -sind(RAAN) cosd(RAAN) 0; ...
        0 0 1];
    Cz_theta = [cosd(theta(j)) sind(theta(j)) 0; ...
        -sind(theta(j)) cosd(theta(j)) 0; ...
        0 0 1]; % w = 0 argumento pericentro
    C_RSWi = Cz_theta*Cx_i*Cz_OMEGA; 
    C_bi = C_bbref*C_brefRSW*C_RSWi; 

    %Condiccion para ver si hai eclipse: disec. vera
    arg = [-1,0,0]*C_RSWi*S_ECI; 
    if acosd(arg) < rho
        eclisse_mask(j) = 1;
    else
        eclisse_mask(j) = 0;
    end

    % Calculo illuminacion de cada cara y potencia 
    if eclisse_mask(j) == 1 %eclipse
        Px_vec(j) = 0;
        Py_vec(j) = 0;
        Pmx_vec(j) = 0;
        Pmy_vec(j) = 0; 
    else       
        %Cara +x
        cos_theta_x = n_x' * C_bi * S_ECI;
        if cos_theta_x > 0
            Px_vec(j) = cost * cos_theta_x;
        else
            Px_vec(j) = 0; % propria sombra
        end
        
        %Cara -x
        cos_theta_mx = n_mx' * C_bi * S_ECI;
        if cos_theta_mx > 0
            Pmx_vec(j) = cost * cos_theta_mx;
        else
            Pmx_vec(j) = 0; 
        end

        %Cara +y
        cos_theta_y = n_y' * C_bi * S_ECI;
        if cos_theta_y > 0
            Py_vec(j) = cost * cos_theta_y;
        else
            Py_vec(j) = 0; 
        end

        %Cara -y
        cos_theta_my = n_my' * C_bi * S_ECI;
        if cos_theta_my > 0
            Pmy_vec(j) = cost * cos_theta_my;
        else
            Pmy_vec(j) = 0; 
        end
    end  
end

% Verifica eclpise
if any(eclisse_mask) % = if at least on element is non-zero
    t_eclisse_min = (sum(eclisse_mask) / length(tvec)) * T * 60; 
    fprintf('Tiempo eclipse: %.2f', t_eclisse_min);
else
    t_eclisse_min = 0;
    fprintf('Tiempo eclipse = 0 min.\n');
end

%Potencia total de cada cara: integral su deltaT=cost => media aritmetica => "mean" function
P_x_media = mean(Px_vec)
P_mx_media = mean(Pmx_vec)
P_y_media = mean(Py_vec)
P_my_media = mean(Pmy_vec)

% Potencia total
P_tot_inst = Px_vec + Pmx_vec + Py_vec + Pmy_vec;
P_tot_media = mean(P_tot_inst)

% Plot
figure('Name', 'Potencia generada en cada cara en una órbita');
plot(tvec, Px_vec, 'DisplayName', '+X Panel', "LineWidth", 2); hold on;
plot(tvec, Pmx_vec, 'DisplayName', '-X Panel', "LineWidth", 2);
plot(tvec, Py_vec, 'DisplayName', '+Y Panel', "LineWidth", 2);
plot(tvec, Pmy_vec, 'DisplayName', '-Y Panel', "LineWidth", 2);
xlim("padded"); ylim("padded"); 
grid on;
xlabel('Tiempo [s]');
ylabel('Potencia generada [W]');
title('Potencia generada en cada cara en una órbita');
legend('show');

figure('Name', 'Potencia total generada en una órbita');
plot(tvec, P_tot_inst, 'LineWidth', 2);
grid on;
xlabel('Tiempo [s]'); xlim("padded"); ylim("padded"); 
ylabel('Potencia total generada [W]');
title('Potencia total generada en una órbita');

%% 3 - Potencia media con cambio de actitud 

clear
clc
close all

% fecha: 01 / 07, 12:00 hp
data_julio = [2026, 7, 1, 12, 0, 0]; % 1 Luglio 2026, ore 12:00
mjd2000_val = date2mjd2000(data_julio); 

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
S_ECI3 = S_ECI_vec / norm(S_ECI_vec) 

mu_E = astroConstants(13); 
R_E = astroConstants(23); 
h = 700; 
r = R_E + h; % [Km]

% Periodo
T = 2*pi*sqrt(r^3/mu_E) / 3600 %[h]

% Datos
G = 1361; % [W/m^2]
A = 0.1*0.3; %[m^2] Ax = Ay
fp = 0.8; 
eta = 0.3; 
OMEGA = 90; %[deg] Ángulo relativo entre el RAAN de la órbita y el RA del Sol
% ATENCION no es la RAAN de la orbita!!

% Inclinaciòn 
J2 = astroConstants(9); 
syms i
e = 0; 
a = r;
ang_sol = atan2(S_ECI3(2), S_ECI3(1));
RAAN = OMEGA + rad2deg(ang_sol) 
RAAN_dot = -3/2 * J2 * (R_E)^2 * 1/((1-e^2)^2) * sqrt(mu_E/a^7)*cosd(i); % [rad/s]
val = 2*pi/(365.25*24*60*60); 
solve((RAAN_dot-val),i); 
i = (180*(pi - acos(940233214828881/6610436648488277)))/pi % [deg]

% Vectores normales a las caras
n_x = [1; 0; 0]; 
n_mx = [-1; 0; 0]; 
n_y = [0; 1; 0]; 
n_my = [0; -1; 0]; 

% Anomalia vera òrbita
tvec = linspace(0,T*3600, 1000); 
omega = sqrt(mu_E/(a^3)); 
theta = rad2deg(omega*tvec); % Circular uniforme

% Matrices constantes
C_brefRSW = [0 0 1;... 
                  0 1 0;...
                  -1 0 0 ];

% Angulo critico de eclipse
rho = asind(R_E/(R_E+h)); 

Px_vec = zeros(length(tvec),1);
Py_vec = zeros(length(tvec),1);
Pmx_vec = zeros(length(tvec),1);
Pmy_vec = zeros(length(tvec),1);
eclisse_mask = zeros(1,length(tvec));

% Componente costante de potencia 
 cost = G * A * fp * eta; % No pongo T proque ya està en "mean" de MATLAB

% Ciclo temporal 
for j = 1:length(tvec)
    Cx_i = [1 0 0; ...
        0 cosd(i) sind(i); ...
        0 -sind(i) cosd(i)]; 
    Cz_OMEGA = [cosd(RAAN) sind(RAAN) 0; ...
        -sind(RAAN) cosd(RAAN) 0; ...
        0 0 1];
    Cz_theta = [cosd(theta(j)) sind(theta(j)) 0; ...
        -sind(theta(j)) cosd(theta(j)) 0; ...
        0 0 1]; % w = 0 argumento pericentro
    C_RSWi = Cz_theta*Cx_i*Cz_OMEGA; 

    % Cambio de actitud 
    w_rot = 0.1; %[rad/s]
    alpha = w_rot*tvec(j); 
    C_bbref = [cos(alpha) sin(alpha) 0; ...
                -sin(alpha) cos(alpha) 0; ...
                0 0 1]; 
    
    C_bi = C_bbref*C_brefRSW*C_RSWi; 

    %Condiccion para ver si hai eclipse: disec. vera
    arg = [-1,0,0]*C_RSWi*S_ECI3; 
    if acosd(arg) < rho
        eclisse_mask(j) = 1;
    else
        eclisse_mask(j) = 0;
    end

    % Calculo illuminacion de cada cara y potencia 
    if eclisse_mask(j) == 1 %eclipse
        Px_vec(j) = 0;
        Py_vec(j) = 0;
        Pmx_vec(j) = 0;
        Pmy_vec(j) = 0; 
    else       
        %Cara +x
        cos_theta_x = n_x' * C_bi * S_ECI3;
        if cos_theta_x > 0
            Px_vec(j) = cost * cos_theta_x;
        else
            Px_vec(j) = 0; % propria sombra
        end
        
        %Cara -x
        cos_theta_mx = n_mx' * C_bi * S_ECI3;
        if cos_theta_mx > 0
            Pmx_vec(j) = cost * cos_theta_mx;
        else
            Pmx_vec(j) = 0; 
        end

        %Cara +y
        cos_theta_y = n_y' * C_bi * S_ECI3;
        if cos_theta_y > 0
            Py_vec(j) = cost * cos_theta_y;
        else
            Py_vec(j) = 0; 
        end

        %Cara -y
        cos_theta_my = n_my' * C_bi * S_ECI3;
        if cos_theta_my > 0
            Pmy_vec(j) = cost * cos_theta_my;
        else
            Pmy_vec(j) = 0; 
        end
    end  
end

% Verifica eclpise
if any(eclisse_mask) % = if at least on element is non-zero
    t_eclisse_min = (sum(eclisse_mask) / length(tvec)) * T * 60; 
    fprintf('Tiempo eclipse: %.4f', t_eclisse_min);
else
    t_eclisse_min = 0;
    fprintf('Tiempo eclipse = 0 min.\n');
end

%Potencia total de cada cara: integral su deltaT=cost => media aritmetica => "mean" function
P_x_media = mean(Px_vec)
P_mx_media = mean(Pmx_vec)
P_y_media = mean(Py_vec)
P_my_media = mean(Pmy_vec)

% Potencia total
P_tot_inst = Px_vec + Pmx_vec + Py_vec + Pmy_vec;
P_tot_media = mean(P_tot_inst)

% Plot
figure('Name', 'Potencia generada en cada cara en una órbita');
plot(tvec, Px_vec, 'DisplayName', '+X Panel', "LineWidth", 0.5); hold on;
plot(tvec, Pmx_vec, 'DisplayName', '-X Panel', "LineWidth", 0.5);
plot(tvec, Py_vec, 'DisplayName', '+Y Panel', "LineWidth", 0.5);
plot(tvec, Pmy_vec, 'DisplayName', '-Y Panel', "LineWidth", 0.5);
xlim("padded"); ylim("padded"); 
grid on;
xlabel('Tiempo [s]');
ylabel('Potencia generada [W]');
title('Potencia generada en cada cara en una órbita');
legend('show');

figure('Name', 'Potencia total generada en una órbita');
plot(tvec, P_tot_inst, 'LineWidth', 1);
grid on;
xlabel('Tiempo [s]'); xlim("padded"); ylim("padded"); 
ylabel('Potencia total generada [W]');
title('Potencia total generada en una órbita');