clear all
clc
clf

%Define number of sample
n = 1 : 3000;

%Define input signal
s = sin(2*pi*(n/12)) + cos(2*pi*(n/4));

%Define filter cofficients
M = 15;
b = zeros(M ,1);

%Define target signal
d = sin(2*pi*(n/12));

%Define step size
mu = 10^(-2);

%Initialize variable
u = zeros(15 ,1);
r = zeros(1  ,(length(n) - M - 1));
error_number = 16;
e = zeros(1 ,error_number);

%Define coverge display parameter
con = 0;

%Create a memory to storage the filter cofficients history
b_h = zeros([15 (length(n) - M - 1)]);

% Implement LMS adaptive filter
for i = 1 : length(n)
    %Get input signal
    for o = 15 : -1 : 2
        u(o) = u(o - 1);
    end
    u(1 ,1) = s(1 ,i)';
    
    %Compute output signal
    d_tilde = b' * u;
    
    %Compute error
    for z = 16 : -1 : 2
        e(z) = e(z - 1);
    end
    e(1 ,1) = d(i) - d_tilde;
    
    %Update filter cofficients
    b = b + mu*e(1)*u;
    for a = 1 : 15 
        b_h(a ,i) = b(a);
    end
    
    %Caculate the RMS value
    r(1 ,i) = sqrt(mean(e.^2));
    
    %Check for convergence
    if (r(1 ,i) < (0.1/sqrt(2))) && (con == 0)
        disp(['Converged after ',num2str(i),' samples (mu = 10^(-2))']);
        con = 1;
    end
end

disp(['Min RMS value : ' ,num2str(min(r)),' (mu = 10^(-2))']);

% Plot prediction error (r) vs. sample index (n)
figure(1);
plot(1 : length(n),r);
xlabel('Sample index');
ylabel('Prediction error (RMS)');
xlim([1 300]);
title('Prediction error vs. sample index (mu = 1e-2)');

% Plot filter coefficients vs. sample index
figure(2);
plot(1 : length(n),b_h);
xlabel('Sample index');
ylabel('Coefficient value');
xlim([1 300]);
title('Filter coefficients vs. sample index (mu = 1e-2)');

% Apply 64-point FFT to impulse response of converged filter
b_fft = fft([b;zeros(49,1)],64);
f = linspace(0,1,64/2+1)*0.5;
mag_response = abs(b_fft(1:64/2+1));
phase_response = angle(b_fft(1:64/2+1));

% Plot magnitude response of filter
figure(3);
plot(f,mag_response);
xlabel('Normalized frequency');
ylabel('Magnitude');
title('Magnitude response of filter(mu = 1e-2)');

% Change step size to 1e-4 and repeat simulation

%Define number of sample
n = 1 : 100000;

%Define input signal
s = sin(2*pi*(n/12)) + cos(2*pi*(n/4));

%Define filter cofficients
M = 15;
b = zeros(M ,1);

%Define target signal
d = sin(2*pi*(n/12));

%Define step size
mu = 10^(-4);

%Initialize variable
u = zeros(15 ,1);
r = zeros(1  ,(length(n) - M - 1));
error_number = 16;
e = zeros(1 ,error_number);

%Define coverge display parameter
con = 0;

%Create a memory to storage the filter cofficients history
b_h = zeros([15 (length(n) - M - 1)]);

% Implement LMS adaptive filter
for i = 1 : length(n)
    %Get input signal
    for o = 15 : -1 : 2
        u(o) = u(o - 1);
    end
    u(1 ,1) = s(1 ,i)';
    
    %Compute output signal
    d_tilde = b' * u;
    
    %Compute error
    for z = 16 : -1 : 2
        e(z) = e(z - 1);
    end
    e(1 ,1) = d(i) - d_tilde;
    
    %Update filter cofficients
    b = b + mu*e(1)*u;
    for a = 1 : 15 
        b_h(a ,i) = b(a);
    end
    
    %Caculate the RMS value
    r(1 ,i) = sqrt(mean(e.^2));
    
    %Check for convergence
    if (r(1 ,i) < (0.1/sqrt(2))) && (con == 0)
        disp(['Converged after ',num2str(i),' samples (mu = 10^(-4))']);
        con = 1;
    end
end

disp(['Min RMS value : ' ,num2str(min(r)),' (mu = 10^(-4))']);

% Plot prediction error (r) vs. sample index (n)
figure(4);
plot(1 : length(n),r);
xlabel('Sample index');
ylabel('Prediction error (RMS)');
xlim([1 8000]);
title('Prediction error vs. sample index (mu = 1e-4)');

% Plot filter coefficients vs. sample index
figure(5);
plot(1 : length(n),b_h);
xlabel('Sample index');
ylabel('Coefficient value');
xlim([1 8000]);
title('Filter coefficients vs. sample index (mu = 1e-4)');

% Apply 64-point FFT to impulse response of converged filter
b_fft = fft([b;zeros(49,1)],64);
f = linspace(0,1,64/2+1)*0.5;
mag_response = abs(b_fft(1:64/2+1));
phase_response = angle(b_fft(1:64/2+1));

% Plot magnitude response of filter
figure(6);
plot(f,mag_response);
xlabel('Normalized frequency');
ylabel('Magnitude');
title('Magnitude response of filter(mu = 1e-4)');