% Use this editor as a MiniZinc scratch book
% Archivo de Datos .dzn
n = 6;
Min = 1;
Max = 3;
%D = [| 0, 745, 665, 929 |
%     745, 0, 80, 337 |
%     665, 80, 0, 380|
%     929, 337, 380, 0|];

D = [| 0, 144, 336, 321, 124, 141|
144, 0, 480, 465, 268, 233|
336, 480, 0, 425, 392, 477|
321, 465, 425, 0, 197, 462|
124, 268, 392, 197, 0, 265|
141, 233, 477, 462, 265, 0|];

%D = [| 0, 553, 204, 248|
%553, 0 ,443, 305|
%204, 443, 0, 138|
%248, 305, 138, 0|];


% Modelo .mzn
int: n;
int: Min; % Mínimo de giras y permanencias
int: Max; % Máximo de giras y permanencias
array[1..n, 1..n] of int: D;

% Variables
array [1..2*(n-1),1..n] of var -n..n: Cal;

% Restricciones

% Calendario válido
constraint forall (i in 1..2*(n-1), j in 1..n) (
 (abs(Cal[i, j]) >= 1 /\ abs(Cal[i, j]) <= n)
);

constraint forall (i in 1..2*(n-1), j in 1..n, k in -n..n) (
 (if (k > 0 /\ Cal[i,j]=k) then Cal[i,k]=-j endif) /\
 (if (k > 0 /\ Cal[i,k]=-j) then Cal[i,j]=k endif)
);

% Número de partidos por equipo
constraint forall (j in 1..n)(
 sum(i in 1..2*(n-1))(Cal[i, j] > 0) = n - 1 /\
 sum(i in 1..2*(n-1))(Cal[i, j] < 0) = n - 1
);

constraint forall(j in 1..n)(%elementos de las filas distintos
 forall(i1 in 1..2*(n-1), i2 in 1..2*(n-1) where i1 < i2)(Cal[i1, j]!= Cal[i2, j])
);

constraint forall(i in 1..2*(n-1))(%elementos de las columnas distintos
 forall(j1 in 1..n , j2 in 1..n where j1 < j2)(Cal[i, j1] != Cal[i, j2])
);

constraint forall(j in 1..n)(%min gira
 forall(i in 1..(2*(n-1))-Min)(if (Cal[i,j]<0) then forall(w in 0..Min-1)(Cal[i+w,j]<0)  endif)
);

constraint forall(j in 1..n)(%max gira
 forall(i in 1..(2*(n-1))-Max)(if forall(w in 0..Max-1)(Cal[i+w,j]<0)  then Cal[i+Max,j]>0  endif)
);
%Nueva
constraint forall (j in 1..n) (
 forall (i in 1..2*(n-1)-1) (
   abs(Cal[i, j]) != abs(Cal[i+1, j])
 )
);
%Funcion objetivo
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
output [
 "Calendario: \(Cal)\n",
 "Costo total: \(objective)"
];