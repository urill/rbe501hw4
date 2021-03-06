%% RBE501 HW4
% joint angles
q = sym('q', [3, 1], 'real');

% joint velocities
q_dot = sym('q_dot', [3, 1], 'real');

% joint accelerations
q_ddot = sym('q_ddot', [3, 1], 'real');

% position of end of joints
p = sym('p', [3, 3], 'real');

% center of mass
pm = sym('pm', [4, 3], 'real');

% mass of joints [mA mB mC mL]'
m = sym('m', [4, 1], 'real');

% length of arms [A B C]'
len = sym('len', [3, 1], 'real');

syms g real;

%% 1
% theta, d, a, alpha
dh = horzcat(q, zeros(3, 1), len, zeros(3, 1))
T = sym(zeros(4, 4, size(dh, 1)));
for joint = 1:size(dh, 1)
    T(:,:, joint) = dh2mat(dh(joint, 1), dh(joint, 2), dh(joint, 3), dh(joint, 4));
end
% ans
T_0_3 = T(:,:, 1) * T(:,:, 2) * T(:,:, 3)

%% 2

p_tip = T_0_3 * [0; 0; 0; 1];
p_tip = p_tip(1:3,:);
J_upper = jacobian(p_tip, q);
J_lower = [0, 0, 0; ...
    0, 0, 0; ... % thetas contribute to rotation in z
    1, 1, 1];
% ans
J = vertcat(J_upper, J_lower)

% top 3 rows are translation. bottom 3 rows are rotation. columns are joint
% variables.


%% 3a
len_n = [0.8; 0.4; 0.2]; % m
q_n = [sym(pi) / 4; sym(pi) / 12; -sym(pi) / 6]; % rad

% ans
T_0_3_n = double(subs(T_0_3, [len; q], [len_n; q_n])) % mm

%% 3b
q_dot_n = [sym(pi) / 6; sym(pi) / 6; sym(pi) / 6]; % rad/s

p_tip_dot = J * q_dot;

% ans m/s, rad/s
P_tip_dot_n = double(subs(p_tip_dot, [len; q; q_dot], [len_n; q_n; q_dot_n]))


%% 4
% mass of the thing
syms mL real;
tau_gravitycomp = J' * [0; mL * g; 0; 0; 0; 0]

%% 5
g_n = 9.8; % m*s^-2
mL_n = 1.5 % kg
% ans N*m
tau_gravitycomp_n = double(subs(tau_gravitycomp, [len; q; q_dot; mL; g], [len_n; q_n; q_dot_n; mL_n; g_n]))

%% 5a
len_n = [0.8; 0.4; 0.2]; % m
m_n = [2; 1; 0.5; 1.5]; % kg

% position of center of masses wrt F0
pm = cat(3, [len(1) * 0.5 * cos(q(1)); len(1) * 0.5 * sin(q(1)); 0; 1], ...
    T(:,:, 1)*[len(2) * 0.5; 0; 0; 1], ...
    T(:,:, 1)*T(:,:, 2)*[len(3) * 0.5; 0; 0; 1], ...
    T(:,:, 1)*T(:,:, 2)*T(:,:, 3)*[0; 0; 0; 1]);
num_mass = size(pm, 3);

% jacobian for this arm
planar_arm_jac = @(pos, joint_var) vertcat(jacobian(pos, joint_var), ...
    [0, 0, 0; 0, 0, 0; 1, 1, 1]);

J_pm = sym(zeros(6, 3, num_mass));
pm_dot = sym(zeros(6, 1, num_mass));
K = sym(zeros(num_mass, 1));
P = sym(zeros(num_mass, 1));

for i = 1:num_mass
    % jacobian of the mass
    J_pm(:,:, i) = planar_arm_jac(pm(1:3,:, i), q);
    % velocity of the mass
    pm_dot(:,:, i) = J_pm(:,:, i) * q_dot;
    % linear velocity
    v = pm_dot(1:3,:, i);
    % kinetic energy of the mass 0.5*m*v^2
    K(i) = 0.5 * m(i) * (v' * v);
    % potential energy of the mass m*g*y
    P(i) = m(i) * g * pm(2,:, i);
end

% ans
K
% numerical
K_n = simplify(vpa(subs(K, [m; g; len], [m_n; g_n; len_n])))
% ans
P
% numerical
P_n = simplify(vpa(subs(P, [m; g; len], [m_n; g_n; len_n])))

%% 5b
% ans
L = sum(K) - sum(P)
% numerical
L_n = simplify(vpa(subs(L, [m; g; len], [m_n; g_n; len_n])))

%% 5c
% Lagrange�s�Equation
% some magic involved
% ans
tau = jacobian(jacobian(L, q_dot)', q_dot) * q_ddot - jacobian(L, q)'
% numerical
tau_n = simplify(vpa(subs(tau, [m; g; len], [m_n; g_n; len_n])))

% to extract the q_ddot, I can set them to zero and subtract with the
% original equation. It should give me the coefficients.

%% 6

% because all z are parallel
alpha = q_dot

% I'm running out of time...

