syms x1 x2 x3 v

% Define the systems parts
x = [x1;x2;x3];
f = [x2+x1*x2-x2*x2; x1*x2-x2*x2; x1+x1*x2-x2*x2-(x3-x1)^3];
g = [1;1;1];
h = x1-x2;

%% Input-State Feedback Linearization
% adfg f  
ad1fg = jacobian(g,x)*f - jacobian(f,x)*g;
ad2fg = jacobian(ad1fg,x)*f - jacobian(f,x)*ad1fg;

% Contrability
controllability = [g ad1fg ad2fg];
control_rank = rank(controllability);

% Involutibility
g_g = jacobian(g,x)*g - jacobian(g,x)*g;
ad1fg_ad1fg = jacobian(ad1fg,x)*ad1fg - jacobian(ad1fg,x)*ad1fg;
g_ad1fg = jacobian(ad1fg,x)*g - jacobian(g,x)*ad1fg;
ad1fg_g = jacobian(g,x)*ad1fg - jacobian(ad1fg,x)*g;
involute = [g ad1fg g_g g_ad1fg ad1fg_g ad1fg_ad1fg];
invol_rank = rank(involute);

disp(['The rank of the controlability matrix is: ', num2str(control_rank)])
disp(['The rank of the involutibility matrix is: ', num2str(invol_rank)])

%% ISFL

q = x1 - x3;
Lfq = jacobian(q,x)*f;
Lf2q = jacobian(Lfq,x)*f;
Lf3q = jacobian(Lf2q,x)*f;
LgLf2q = jacobian(Lf2q,x)*g;

Phi = [q; Lfq; Lf2q];

A = Lf3q;
B = LgLf2q;

% poles: -1, -2, -10

n1 = 20;
n2 = 32;
n3 = 13;

u =(v-A-n1*Phi(1)-n2*Phi(2)-n3*Phi(3))/B;


%% IOFL

Lfh = jacobian(h,x)*f;
Lf2h = jacobian(Lfh,x)*f;
LgLfh = jacobian(Lfh,x)*g;

u_iofl = (v-Lf2h-3*Lfh-2*h)/LgLfh;



