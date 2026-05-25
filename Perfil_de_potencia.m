clear; clc;
figure('Name', 'Perfil de potencia integrado', 'Color', 'w');
hold on; grid on;

% PERFIL DE POTENCIAA
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

t_vec = 0:0.01:24; % Vector temporal de alta resolución
P_totale = zeros(size(t_vec));

for i = 1:length(t_vec)
    t = t_vec(i);
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
plot(t_vec, P_totale, 'LineWidth', 2, 'Color', [0.850, 0.325, 0.098]);
grid on;
xlim([0 24]); xticks(0:2:24);
ylim([0 40]);
xlabel('Tiempo de misión [Horas]','FontSize',13);
ylabel('Potencia total consumida [W]','FontSize',13);
title('Perfil de potencia consumida total (modo nominal)','FontSize',15,'FontWeight','bold');