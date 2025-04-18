%  Transducer parameters for send and receive
fs = 100e6;                %  Sampling frequency [Hz]
c = 1540;                  %  Speed of sound [m/s]
f0 = 5e6;                  %  Transducer center frequency [Hz]
lambda = c/f0;             %  Wavelength [m]
width = lambda;            %  Width of element [m]
M_cycles_cfm = 4;          %  Number of cycles in transmit for CFM
element_height = 10/1000;  %  Height of element [m]
elevation_focus =  50/1000;%  Elevation focus depth [m]
kerf = 0.05/1000;          %  Kerf [m]
focus = [0 0 50]/1000;     %  Fixed initial focal point [m]
N_elements = 196;          %  Number of physical elements
rec_N_active = 64;         %  Number of active elements in receive
xmit_N_active = 64;        %  Number of active elements in transmit
F_number = 2;              %  Desired F-number for imaging
F_number_elevation = elevation_focus/element_height;  %  Elevation F-number

%  Parameters for the flow simulation
R = 5/1000;               %  Radius of blood vessel [m]
x_range = 80/1000;        %  x range for the scatterers  [m]
y_range = 2*R;            %  y range for the scatterers  [m]
z_range = 2*R;            %  z range for the scatterers  [m]
z_offset = 40/1000;       %  Offset of the mid-point of the scatterers [m]
theta = 45/180*pi;        %  Angle between ultrasound beam and flow [rad]
v0 = 1;                   %  Largest velocity of scatterers [m/s]
blood_to_stationary = 10; %  Ratio between amplitude of blood to stationary tissue
Tprf = 1/10e3;            %  Time between pulse emissions  [s]
fprf = 1/Tprf;            %  Pulse repetition frequency [Hz]

%  Imaging parameters
Ncfm = 10;                %  Number of emissions for color flow mapping
no_lines_CFM = 20;        %  Number of lines in image
image_width = 40/1000;    %  Lateral size of image sector  [m]

rec_zone_start = 5/1000;  %  Start for receive focusing [m]
rec_zone_stop = 100/1000; %  Last receive focus [m]
rec_zone_size = 2/1000;   %  Length of focal zones [m]
z_focus_transmit = 40/1000;   %  Transmit focuse [m]

D = 5;                    %  Sampling frequency decimation factor for display