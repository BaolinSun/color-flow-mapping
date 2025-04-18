% Set parameters for the simulation
define_parameters

% Set the number of scatterers.
N = round(10 * x_range/(F_number*lambda) * y_range/(F_number_elevation*lambda) * z_range/(lambda*M_cycles_cfm));
disp([num2str(N),' Scatterers']);

% Generate the coordinates and amplitude
% Coordinates are rectangular within the range.
% The amplitude has a Gaussian distribution.

x = x_range*(rand(1,N)-0.5);
y = y_range*(rand(1,N)-0.5);
z = z_range*(rand(1,N)-0.5);

% Find which scatterers that lie within the blood vessel
r = (y.^2+z.^2).^0.5;
within_vessel= r < R;

% Assign an amplitude and a velocity for each scatterer
amp = randn(1,N).*((1-within_vessel) + within_vessel*blood_to_stationary);
amp = amp';
amp = abs(amp);

velocity = v0*5 * (1-(r/R).^2).*within_vessel;

for i = 1:Ncfm*10

    %  Generate the rotated and offset block of sample
    xnew = x * cos(theta) + z * sin(theta);
    znew = z * cos(theta) - x * sin(theta) + z_offset;
    positions = [xnew; y; znew;]';

    sc = scatter3(x, y, z, amp, '.', 'r');
    axis equal;
    drawnow;
    
    x = x + velocity * Tprf;
    outside_range =  (x > x_range/2);
    x = x - x_range * outside_range;

end