function d = external_disturbance(t, params)
    % Combined step and sinusoidal disturbance
    d_step = params.d_step*(t >= params.step_time);
    d_sin = params.d_sin_amp * sin(params.d_sin_freq * t);
    d = d_step + d_sin;
end