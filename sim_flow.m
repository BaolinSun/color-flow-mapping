% Set parameters for the simulation
define_parameters

% Set the sampling frequency
set_sampling(fs);

% Generate aperture for emission
xmit_aperture = xdc_focused_array (N_elements, width, element_height, kerf, elevation_focus, 1, 10, focus);

% Set the impulse response and excitation of the xmit aperture
impulse_response = sin(2*pi*f0*(0:1/fs:1/f0));
impulse_response = impulse_response.*hanning(max(size(impulse_response)))';
xdc_impulse(xmit_aperture, impulse_response);

excitation = sin(2*pi*f0*(0:1/fs:M_cycles_cfm/f0));
xdc_excitation(xmit_aperture, excitation);

% Generate aperture for reception
receive_aperture = xdc_focused_array (N_elements, width, element_height, kerf, elevation_focus, 1, 10,focus);

% Set the impulse response for the receive aperture
xdc_impulse(receive_aperture, impulse_response);

% Do for the number of CFM lines
for k = 1 : Ncfm

    disp(['Making CFM lines ',num2str(k),' of ', num2str(Ncfm)]);

    % Load the computer phantom
    cmd=['load sim_flow/scat_',num2str(k),'.mat'];
    eval(cmd);
    
    % Do linear array imaging
    d_x = image_width/(no_lines_CFM-1);   %  Increment for image
    
    % Set the different focal zones for reception
    focal_zones_center = (rec_zone_start : rec_zone_size : rec_zone_stop)';
    focal_zones = focal_zones_center - 0.5 * rec_zone_size;
    Nf = max(size(focal_zones));
    focus_times = focal_zones / c;

    %  Set a Hanning apodization on the receive aperture
    %  Dynamic opening aperture is used.
    rec_N_active_dyn = round(focal_zones_center ./ (F_number * (width + kerf)));

    for ii = 1 : Nf
        if rec_N_active_dyn(ii) > rec_N_active
            rec_N_active_dyn(ii) = rec_N_active;
        end

        rec_N_pre_dyn(ii) = ceil(rec_N_active/2  - rec_N_active_dyn(ii)/2);
        rec_N_post_dyn(ii) = rec_N_active - rec_N_pre_dyn(ii) - rec_N_active_dyn(ii);

        rec_apo = (ones(1,rec_N_active_dyn(ii)));

        rec_apo_matrix_sub(ii, :) = [zeros(1,rec_N_pre_dyn(ii)) rec_apo zeros(1,rec_N_post_dyn(ii))];
    end

    
    
    % Set a Hanning apodization on the xmit aperture
    xmit_apo=hanning(xmit_N_active)';
    
    % Do imaging line by line
    x = -image_width / 2;
    for i = 1 : no_lines_CFM
        
        disp(['Making line ',num2str(i),' of ',num2str(no_lines_CFM)]);

        % Set the focus for this direction
        xdc_center_focus (xmit_aperture, [x 0 0]);
        xdc_focus (xmit_aperture, 0, [x 0 z_focus_transmit]);
        xdc_center_focus (receive_aperture, [x 0 0]);
        xdc_focus (receive_aperture, focus_times, [x*ones(Nf,1), zeros(Nf,1), focal_zones]);

        
        % Calculate the apodization
        xmit_N_pre  = round(x/(width+kerf) + N_elements/2 - xmit_N_active/2);
        xmit_N_post = N_elements - xmit_N_pre - xmit_N_active;
        xmit_apo_vector = [zeros(1,xmit_N_pre) xmit_apo zeros(1,xmit_N_post)];

        rec_N_pre = round(x/(width+kerf) + N_elements/2 - rec_N_active/2);
        rec_N_post = N_elements - rec_N_pre - rec_N_active;
        rec_apo_matrix = [zeros(size(focus_times,1), rec_N_pre) rec_apo_matrix_sub zeros(size(focus_times,1), rec_N_post)];

        xdc_apodization (xmit_aperture, 0, xmit_apo_vector);
        xdc_apodization (receive_aperture, focus_times , rec_apo_matrix);

        %   Calculate the received response
        [rf_data, tstart]=calc_scat(xmit_aperture, receive_aperture, positions, amp);

        %  Store the result
        cmd = ['save sim_flow/rft', num2str(k), 'l', num2str(i), '.mat rf_data tstart'];
        eval(cmd)
        disp(['Saving using the command: ', cmd])

        % Steer in another direction
        x = x + d_x;
        
        
    end  % Loop for lines
    
end % CFM loop

xdc_free(xmit_aperture)
xdc_free(receive_aperture)