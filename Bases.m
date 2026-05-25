clear
clc
close all 

% Plot bases 
% -------------------------------------------------------------------------
figure('Name', 'Cronograma de Conexiones del CubeSat (24h)', 'Color', 'w');
hold on; grid on;

% Nombres de las estaciones (Eje Y)
stations = {'Kiruna (Comms)', 'Hartebeesthoek (Comms)', 'Santiago (Comms)', ...
            'Nueva Norcia (Comms)','Redu (Comms)','Hawai (Comms)', ...
            'Madrid (Exp 2)', 'Nueva Delhi (Exp 2)', 'Rio (Exp 2)',...
            'Nagoya (Exp 2)', 'Toronto (Exp 2)','Los Angeles (Exp 2)'};


% --- ESTACIONES DE COMUNICACIÓN (Comms) ---
kiruna = [0.24, 0.38; 
          1.83, 1.96; 
          3.47, 3.52; 
          13.24, 13.33; 
          14.82, 14.95; 
          16.40, 16.53; 
          17.99, 18.08; 
          19.57, 19.62; 
          21.13, 21.19; 
          22.67, 22.77];

hartebeesthoek = [1.42, 1.54; 
                  3.04, 3.08; 
                  13.63, 13.76];

santiago = [7.79, 7.90; 
            9.38, 9.48; 
            20.06, 20.19];

nueva_norcia = [7.26, 7.40; 
                19.02, 19.08; 
                20.57, 20.69];

redu = [1.77, 1.89; 
        3.35, 3.47; 
        14.91, 15.02; 
        16.49, 16.61];

hawaii = [2.24, 2.37; 
          12.84, 12.93; 
          14.41, 14.51];

% --- CIUDADES DE OBSERVACIÓN (Experimento 2) ---
madrid = [3.31, 3.44; 
          14.98, 15.04; 
          16.53, 16.66];

delhi = [10.20, 10.33; 
         11.82, 11.86; 
         22.44, 22.57];

rio = [6.23, 6.36; 
       18.42, 18.55];

nagoya = [6.96, 7.09; 
          17.68, 17.81];

toronto = [8.12, 8.25; 
           9.77, 9.79; 
           21.32, 21.45];

los_angeles = [0.58, 0.68; 
               11.27, 11.40; 
               22.98, 23.08];

% Dibujar las barras (Azul para Comms, Rojo para Exp 2)
plot_gantt(kiruna, 12, [0 0 1]); % Azul puro
plot_gantt(hartebeesthoek, 11, [0 0 1]);
plot_gantt(santiago, 10, [0 0 1]);
plot_gantt(nueva_norcia, 9, [0 0 1]); % Azul puro
plot_gantt(redu, 8, [0 0 1]);
plot_gantt(hawaii, 7, [0 0 1]);

plot_gantt(madrid, 6, [1 0 0]); % Rojo puro
plot_gantt(delhi, 5, [1 0 0]);
plot_gantt(rio, 4, [1 0 0]);
plot_gantt(nagoya, 3, [1 0 0]); % Rojo puro
plot_gantt(toronto, 2, [1 0 0]);
plot_gantt(los_angeles, 1, [1 0 0]);

% Configuración del gráfico
yticks(1:12);
yticklabels(flip(stations)); 
ylim([0 13]);
xlim([0 24]);
xticks(0:2:24);
xlabel('Tiempo de Simulación (Horas)');
title('Distribución de Contactos durante 24 Horas');

% Leyenda 
h1 = plot(nan, nan, 's', 'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
h2 = plot(nan, nan, 's', 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', 'none', 'MarkerSize', 10);
legend([h1, h2], {'Comunicaciones (3.5 W)', 'Experimento 2 (6.0 W)'}, 'Location', 'northeast');

% Función auxiliar para crear los bloques
function plot_gantt(data, y_pos, color)
    for i = 1:size(data, 1)
        line([data(i,1), data(i,2)], [y_pos, y_pos], 'Color', color, 'LineWidth', 12);
    end
end