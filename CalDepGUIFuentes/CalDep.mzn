
% Modelo .mzn
% Este archivo contiene el modelo y las restricciones.

int: n; % Número de equipos
int: Min; % Mínimo de giras y permanencias
int: Max; % Máximo de giras y permanencias

array[1..n, 1..n] of int: D; % Matriz de costos que representa las distancias entre los equipos.

% Variables del calendario
array [1..2*(n-1),1..n] of var -n..n: Cal;
% Matriz de variables que representa el calendario de partidos, donde cada elemento representa el equipo local o visitante en un determinado partido.

% Variables auxiliares creadas para las restricciones de mínimo y máximo de giras y permanencias.
array[1..2*(n-1), 1..n] of var 0..Max: ContG; % Contador de Max de giras
array[1..2*(n-1), 1..n] of var 0..Max: ContP; % Contador de Max de permanencia

% RESTRICCIONES DEL MODELO

% Calendario válido
% Se asegura que los valores de Cal estén dentro del rango válido, es decir, entre -n y n, para representar el equipo local y visitante de un partido.
constraint forall (i in 1..2*(n-1), j in 1..n) (
(abs(Cal[i, j]) >= 1 /\ abs(Cal[i, j]) <= n)
);

% Asegurar que los partidos concuerden entre si (local-visiante)
% Se establecen restricciones para asegurar que los partidos locales y visitantes sean coherentes entre sí.
constraint forall (i in 1..2*(n-1), j in 1..n, k in -n..n) (
(if (k > 0 /\ Cal[i,j]=k) then Cal[i,k]=-j endif) /\
(if (k > 0 /\ Cal[i,k]=-j) then Cal[i,j]=k endif)/\
(if (k < 0 /\ Cal[i,j]=k) then Cal[i,-k]=j endif)/\
(if (k < 0 /\ Cal[i,-k]=j) then Cal[i,j]=k endif)
);

% Número de partidos por equipo de ida y vuelta
% Se establece el número correcto de partidos de ida y vuelta para cada equipo.
constraint forall (j in 1..n)(
sum(i in 1..2*(n-1))(Cal[i, j] > 0) = n - 1 /\
sum(i in 1..2*(n-1))(Cal[i, j] < 0) = n - 1
);

% Elementos de las filas distintos para asegurar que todos jueguen un partido
% Se asegura que cada equipo juegue exactamente un partido en cada jornada.
constraint forall (j in 1..n)(
forall (i1 in 1..2*(n-1), i2 in 1..2*(n-1) where i1 < i2)(Cal[i1, j]!= Cal[i2, j])
);

% Elementos de las columnas distintos para asegurar que los partidos no se repitan
% Se asegura que no haya partidos repetidos en ninguna jornada.
constraint forall (i in 1..2*(n-1))(
forall (j1 in 1..n , j2 in 1..n where j1 < j2)(Cal[i, j1] != Cal[i, j2])
);

% Asegura un mínimo de giras consecutivas
% Se asegura que cada equipo realice al menos el número mínimo de giras consecutivas especificadas.
constraint forall (j in 1..n)(
        forall (i in 2..2*(n-1))(
           (if i == 2*(n-1) then
               (if Cal[i,j] < 0 then ContG[i,j]>=Min endif)
          else
             (if (Cal[i,j] > 0)then
               (if(Cal[i-1,j] < 0) then ContG[i-1,j]>=Min endif)            
             endif)
           endif)
        )
);

% Asegura que no se supere el máximo de giras consecutivas
% Se asegura que el número de giras consecutivas para cada equipo no supere el valor máximo especificado.
constraint forall (i in 1..2*(n-1))(
        forall (j in 1..n)(
           (if Cal[i,j] < 0 then
             (if i==1 then ContG[i,j] = 1 else ContG[i,j] = ContG[i-1,j] + 1 endif)
           else ContG[i,j] = 0
           endif)
        )
);

% Asegura un mínimo de permanencias consecutivas
% Se asegura que cada equipo tenga al menos el número mínimo de permanencias consecutivas especificadas.
constraint forall (j in 1..n)(
        forall (i in 2..2*(n-1))(
           (if i == 2*(n-1) then
               (if Cal[i,j] > 0 then ContP[i,j]>=Min endif)
          else
             (if (Cal[i,j] < 0)then
               (if(Cal[i-1,j] > 0)then ContP[i-1,j]>=Min endif)            
             endif)
           endif)
        )
);

% Asegura que no se supere el máximo de permanencias consecutivas
% Se asegura que el número de permanencias consecutivas para cada equipo no supere el valor máximo especificado.
constraint forall (i in 1..2*(n-1))(
        forall (j in 1..n)(
           (if Cal[i,j] > 0 then
             (if i==1 then ContP[i,j] = 1 else ContP[i,j] = ContP[i-1,j] + 1 endif)
             else ContP[i,j] = 0
           endif)
        )
);

% No repetición del mismo partido de ida y vuelta consecutivamente
% Se asegura que un equipo no juegue contra el mismo equipo en jornadas consecutivas.
constraint forall (j in 1..n) (
forall (i in 1..2*(n-1)-1) (
abs(Cal[i, j]) != abs(Cal[i+1, j])
)
);

% Añade una restricción extra para que las fechas de ida y vuelta sean siempre las mismas para cada equipo
% Se asegura que las fechas de ida y vuelta sean siempre las mismas para cada equipo.
constraint forall (j in 1..n-1) (
forall (i in 1..2*(n-1)-1) (
forall (k in 1..2*(n-1)-1) (
(if(abs(Cal[i, j]) == abs(Cal[k, j]))then abs(Cal[i, j+1]) = abs(Cal[k, j+1]) endif)
)
)
);

% Función objetivo
var int: objective = sum(i in 1..2*(n-1), j in 1..n) (
(if (Cal[i,j] < 0 /\ Cal[i-1,j] < 0) then
(if (i=2*(n-1)) then D[abs(Cal[i-1, j]), abs(Cal[i, j])]+D[abs(Cal[i,j]),j] else D[abs(Cal[i-1, j]), abs(Cal[i, j])] endif)
else (if (i=1 /\ Cal[i,j]<0) then
D[j, abs(Cal[i,j])]
else (if (Cal[i,j] < 0) then
(if (i=2*(n-1)) then D[j, abs(Cal[i,j])] + D[abs(Cal[i,j]),j] else D[j, abs(Cal[i,j])] endif)  % Suma de distancia de ida y regreso a la ciudad natal
else
(if (Cal[i,j] > 0 /\ Cal[i-1,j] < 0 ) then D[abs(Cal[i-1, j]), j] else 0 endif)  % No se considera en la función objetivo cuando el equipo juega en casa
endif)
endif)
endif)
);

% Meta a optimizar
solve minimize objective;

% Salida
% Se muestra el calendario generado y el costo total obtenido.
output ["Calendario: \(Cal)\n","Costo total: \(objective)"];
