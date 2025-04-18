%  Set parameters for the simulation
define_parameters

%  Calculate the averaging interval
d_x = image_width/(no_lines_CFM-1);     % Distance between CFM lines
est_dist = c/f0 * M_cycles_cfm / 4;     % Axial distance between velocity estimates [m]
Navg = round(M_cycles_cfm/f0 * fs / 2); %  Half length of averaging interval (M_cycles_cfm/f0:脉冲持续时间)
Ndist = floor(2*est_dist/c * fs/D);     %  Rf samples between velocity estimates

% Load the data for one image line and a number of pulse emissions
for i = 1 : no_lines_CFM

    min_sample = 0;
    data = 0;

    for k = 1 : Ncfm

        cmd=['load sim_flow/rft',num2str(k),'l',num2str(i),'.mat'];
        eval(cmd)

        %  Decimate the data and store it in data
        if (tstart>0)
            rf_sig = [zeros(round(tstart * fs - min_sample), 1); rf_data];
        else
            rf_sig = rf_data(abs(round(tstart * fs)) : max(size(rf_data))) ;
        end

        rf_sig = hilbert(rf_sig(1 : D : max(size(rf_sig))));

        data(1:max(size(rf_sig)),k) = rf_sig;
    end

    % Make the velocity estimation
    [Nsamples, M] = size(data);

    RMS = std(data(:, 1));

    % Make echo canceling for data
    mean_data = mean(data, 2);
    echo_data = data - repmat(mean_data, [1 size(data,2)]);

    index=1;
    % Make the velocity estimation for all the data
    for k = 1 : Ndist : Nsamples
        %  Find the proper data
        vdata=echo_data(max([k-Navg,1]):min(k+Navg, Nsamples), :);

        %  Calculate the autocorrelation and the velocity
        if (mean(std(vdata)) > RMS/5)
            auto=0;

            for j = 1 : size(vdata,1)
                auto  = auto + vdata(j,2:(M-1)) * vdata(j,1:(M-2))';
            end

            v_est(index,i) = c*fprf/(4*pi*f0) * atan2(imag(auto),real(auto));

        else
            v_est(index,i)=0;
        end

        index = index + 1;
    end

end


[Nz,Nx] = size(v_est);
imagesc(((0:Nx-1)-Nx/2)*d_x*1000,(1:Nz)*Ndist*D/fs*c/2*1000,v_est)
map = [1:64; zeros(2,64)]/64;
colormap(map')
colorbar
ylabel('Depth in tissue [mm]')
xlabel('Lateral distance [mm]')
axis('image')
drawnow


% Make an interpolated image
ID=25;
[n,m]=size(v_est);
new_est1=zeros(n,m*ID);
for i=1:n
    new_est1(i,:)=abs(interp(v_est(i,:),ID));
end
[n,m]=size(new_est1);
new_est=zeros(n*5,m);
Ndist=Ndist/5;
for i=1:m
    new_est(:,i)=abs(interp(new_est1(:,i),5));
end

[Nz,Nx]=size(new_est);
new_est=new_est/max(max(new_est));
imagesc(((0:Nx-1)-Nx/2)*d_x/ID*1000,(1:Nz)*Ndist*D/fs*c/2*1000,new_est)
map=[1:64; zeros(2,64)]/64;
colormap(map')
colormap(hot(64))
colorbar
ylabel('Depth in tissue [mm]')
xlabel('Lateral distance [mm]')
axis('image')