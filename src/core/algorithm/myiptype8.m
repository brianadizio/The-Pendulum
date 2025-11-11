function  nth_deriv = myiptype8(t, th, J, ksp, ma, Iz, bv, gr, ln, kj,IPtypeNum)
%
% re-write the 2nd order diff eq, th" = (ma*ln*gr)/(ma*ln^2+Iz)*sin(th) - ksp/(ma*ln^2+Iz)*th -bv/(ma*ln^2+Iz)*th'
%                             as a system of two 1st order diff eq's
% where t= time step, the assumed MATLAB variable with respect to which the derivatives are taken
%       th= is the dependent variable and its first derivative (theta,
%       angle of pendulum)
%       ksp= a torsional spring acting around the pivot pooint
%       ma = mass
%       Iz = moment of inertia around CG
%       bv = viscous damping
%       gr= accel due to gravity
%       ln= length of inv pend
%       i= unit vector in imaginary axis  (0 + i1)
%
%  ka = (ma*ln*gr)/(ma*ln^2+Iz); % gravity torque constant
%  ks = ksp/(ma*ln^2+Iz); % spring constant
%  kb = bv/(ma*ln^2+Iz);  % damping constant
%
% The second order differential equation can be rearraged:
% th" = ka*sin(th) - ks*th - kb*th';
%
% The differential equation is rewritten in first-derivative vector form
% as:
%  +-
%  |th(1)' = th(2);
%  |th(2)' = ka*sin(th(1)) - ks*th(1) - kb*th(2);
%  +-

%NOTE on OLDCORE vs NEWCORE kj   AB EDIT 032124
% OLDCORE had myip7  with  th0(2)=th(2)+ joyd(j,2)*simparams(17)    (where simparams(17)= kj_oldcore)
% NEWCORE has acceleration term having  kj*J  as done below here in nth_deriv(2)
% The Kj in newcore  cannot be same magnitude as kj of oldcore to get same dynamics.
% kj_newcore = kj_oldcore/tinc

ka = (ma*ln*gr)/(ma*ln^2+Iz); % gravity torque constant
ks = ksp/(ma*ln^2+Iz); % spring constant
kb = bv/(ma*ln^2+Iz);  % damping constant

if IPtypeNum ==1 || IPtypeNum==2 % 1D cases
    nth_deriv=[0; 0]; % allocate column vector for nth derivative
    nth_deriv(1)= th(2); % first row must be first deriv
    nth_deriv(2)= ka*sin(th(1)) - ks*th(1) - kb*th(2)  + kj*J; % last row must be highest deriv
    % ddth_withoutJoy=(ka*sin(th(1)) - ks*th(1) - kb*th(2));
    % [kj J  kj*J        nan       nth_deriv(1)  ddth_withoutJoy  nth_deriv(2)]

elseif IPtypeNum==3 % Linear 2D 
    
    YVyXVx=th;% th is now [Y Vy X Vx ] ;  Also J=[Jy Jx ] % Choose Y X (instead of X Y) coz Joystick J(2) is left-right and J(1) is away-near, so matches
    
    nth_deriv=[0; 0; 0; 0]; % allocate column vector for nth derivative  [dxdt dvxdt dydt dvydt];
   
    % Y ODEs: 
    nth_deriv(1)= YVyXVx(2); % first row must be first deriv
    nth_deriv(2)= ka*YVyXVx(1) - ks*YVyXVx(1) - kb*YVyXVx(2)  + kj*J(1); %J(1) is near-far so Jy (for top-down control on screen)

    % X ODEs:
    e=2;
    nth_deriv(1+e)= YVyXVx(2+e); % first row must be first deriv
    nth_deriv(2+e)= ka*YVyXVx(1+e) - ks*YVyXVx(1+e) - kb*YVyXVx(2+e)  + kj*J(2);% J(2) is left-right so Jx 
end

% One could make a single nth_deriv definition (instead of separate one for dual axis) using 4-vectors always for
% th. In that case 1D cases will have the 3rd and 4th elment defind as 0 = 0.
% Right now made separate set of equations for 2D with an elseif. Can unify
% 1D and 2D,if needed, later. 




end
