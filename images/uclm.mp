prologues := 1;

beginfig(1);
  path p[], ejex[], ejey[];
  color cu;

  inf = 4095;	% aproximacion de infinito
  d = 20;	% parametro de separacion
  r0 = 50;	% radio de la herradura
  cu = black;	% color de relleno
  z00 = (0,0);		% centro de la herradura
  z10 = (0,(1.2*d));	% centro del medio punto
  z20 = (0,d);		% centro de la ojiva
  z30 = (0,1.5*d);	% centro del cuadrado

% ---------------------
%   ARCO DE HERRADURA
% ---------------------
%       _______                            
%      /       \                           
%     /         \                          
%    /           \                         
%   |             |                       
%   |     z0      |                       
%   |             |                       
%    \           /                        
%     \         /                          
%      \       /                           
%      /       \                           
%     /         \                          
%    /z2        z1                         
%   |             |                        
%   |             |                        
%                                          
  ejex0 = (-inf,(ypart z00))--(inf,(ypart z00));
  ejey0 = ((xpart z00),-inf)--((xpart z00),inf);
  x01 = r0-d;
  x02 = -x01;
  ejey01 = (x01,-inf)--(x01,(ypart z0));
  ejey02 = (x02,-inf)--(x02,(ypart z0));
  % circulos principales de la herradura
  p07 = fullcircle rotated -90 scaled (2*r0) shifted z00;
  p08 = fullcircle rotated -90 scaled (2*(r0+d)) shifted z00;
  y01 = y02 = (ypart (p08 intersectionpoint ejey01)) - d;
  ejex01 = (-inf,y01)--(inf,y01);
  % circulitos secundarios de la herradura
  p03 = halfcircle scaled (2*d) shifted z01;
  p04 = halfcircle scaled (4*d) shifted z01;
  p05 = halfcircle scaled (2*d) shifted z02;
  p06 = halfcircle scaled (4*d) shifted z02;
  % herradura interna
  p01 = (x01+d,-inf)
  -- (p03 cutafter ejey01)
  -- (x01,(ypart z01)+d)
  -- (p07 cutbefore ejey01 cutafter ejey02)
  -- (x02,(ypart z01)+d)
  -- (p05 cutbefore ejey02)
  -- (x02-d,-inf) -- cycle;
  % herradura externa
  p02 = (x01+(2*d),-inf)
  -- (p04 cutafter ejey01 cutafter p08)
  -- (p08 cutbefore p04 cutafter p06)
  -- (p06 cutbefore ejey02 cutbefore p08)
  -- (x02-(2*d),-inf) -- cycle;

% -----------------------
%   ARCO DE MEDIO PUNTO
% -----------------------
%        _______                            
%       /       \                           
%      /         \                          
%     /           \                         
%    |             |                       
%    |     z10     |                       
%    |             |                       
%    |             |                        
%    |             |                        
%                                           
  r1 = r0 + (2*d);
  % medio punto interno
  p11 = (x10+r1,-inf)
  -- (halfcircle scaled (2*r1) shifted z10)
  -- (x10-r1,-inf)
  -- cycle;
  % medio punto externo
  p12 = (x10+r1+d,-inf)
  -- (halfcircle scaled (2*(r1+d)) shifted z10)
  -- (x10-r1-d,-inf)
  -- cycle;

% ---------------
%   ARCO OJIVAL
% ---------------
%        /\                           
%       /  \                           
%      /    \                           
%     /      \                           
%    /        \                          
%   /          \                         
%  |            |                       
%  |    z20     |                       
%  |            |                       
%  |            |                        
%  |            |                        
%                                         
  r2 = (2*r0) + (4*d);
  % ojiva interna
  p21 = (x20+r0+(4*d),-inf)
  -- ((halfcircle scaled (2*r2) shifted (x20-r0,y20)) cutafter ejey0)
  -- ((halfcircle scaled (2*r2) shifted (x20+r0,y20)) cutbefore ejey0)
  -- (x20-r0-(4*d),-inf)
  -- cycle;
  % ojiva externa
  p22 = (x20+r0+(5*d),-inf)
  -- ((halfcircle scaled (2*(r2+d)) shifted (x20-r0,y20)) cutafter ejey0)
  -- ((halfcircle scaled (2*(r2+d)) shifted (x20+r0,y20)) cutbefore ejey0)
  -- (x20-r0-(5*d),-inf)
  -- cycle;

% ------------
%   CUADRADO
% ------------
%      /\                           
%     /  \                           
%    / z30\                          
%    \    /
%     \  /
%      \/
%                                         
  p31 = unitsquare shifted (-.5,-.5) scaled (2*r2) rotated 45 shifted z30;

  % logo de UCLM desde el exterior hacia el centro
  vardef uclm (expr c) =
    begingroup
      save pic; picture pic;
      pic := nullpicture;
      addto pic contour (p31 cutbefore p22 cutafter p22)
      -- (reverse p22 cutbefore p31 cutafter p31)
      -- cycle withcolor c;
      addto pic contour (p31 cutafter ejex0 cutbefore p12 cutafter p21)
      -- (p21 cutbefore p31 cutafter p31)
      -- reverse (reverse p31 cutafter ejex0 cutbefore p12 cutafter p21)
      -- reverse (p12 cutbefore p31 cutafter p31)
      -- cycle withcolor c;
      addto pic contour (p31 cutafter ejex0 cutbefore p02 cutafter p11)
      -- (p11 cutbefore p31 cutafter p31)
      -- reverse (reverse p31 cutafter ejex0 cutbefore p02 cutafter p11)
      -- reverse (p02 cutbefore p31 cutafter p31)
      -- cycle withcolor c;
      addto pic contour (p31 cutafter ejex0 cutafter p01)
      -- (p01 cutbefore p31 cutafter p31)
      -- reverse (reverse p31 cutafter ejex0 cutafter p01)
      -- cycle withcolor c;
      pic shifted -z30 scaled (1/(xpart (urcorner bbox pic)))
    endgroup
  enddef;

  draw uclm(cu) scaled 100;

%   label.ulft("ã 2000," infont "rpsyr" scaled (.3*defaultscale), (50,-100));
%   label.urt("Francisco Moya (MetaPost code)"
%     infont "rphvr" scaled (.3*defaultscale), (50,-100));
endfig;

end
