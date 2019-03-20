function [ ITDG ] = calcITDG( x_t, fs )
% calcITDG
% Estimates the initial time delay gap
% * Requires the Signal Processing Toolbox
%
% ---------------------------
% INPUTS
%
% x_t   :   Time Domain IR ( 1 x t )
% fs    :   Sample Rate (Hz)
%
% OUTPUTS
% ITDG  :   Initial Time Delay Gap 

ITDG = zeros(1,size(x_t,2));
np = 20;
for ch = 1:size(ITDG,2)
    H = x_t(:,ch);
    E = envelope(H,np,'peak');
    [peak_a, peak_t] = findpeaks(E);
    while length(peak_a)<2
        np = np-2;
        if np < 0
            disp('Failed to find the ITDG')
            return
        end
        E = envelope(H,np,'peak');
        [peak_a, peak_t] = findpeaks(E);
    end
    peak_a = abs(peak_a);
    [D,D_idx] = max(peak_a);
    [FR,FR_idx]=max(peak_a(peak_a<D));
    time_diff_samples = peak_t(FR_idx+1)-peak_t(D_idx);
    ITDG(ch) = time_diff_samples/fs;
end

end


