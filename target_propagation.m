clear; clc; close all;
% Моделирование распространения изображения миры в адаптивной оптической
% системе для когерентного и некогерентного случая
%%  Coherent Imaging
A=imread('target_gost','png');    % read image file 
A(A<10)=0;
%A(A>=5)=255;
A(701:end,:)=[]; A(:,701:end)=[]; % square image
[M,N]=size(A);                    % get image sample size 
A=flipud(A);                      % reverse row order 
Ig=single(A);                     % integer to floating 
Ig=Ig/max(max(Ig));               % normalize ideal image 

ug=sqrt(Ig);                      % ideal image field 
L=1.7e-3;                         % image plane side length for №1(m) 
du=L/M;                           % sample interval (m) 
u=-L/2:du:L/2-du; v=u; 

figure();  
subplot(2,2,1)
imagesc(u,v,Ig);                  % check ideal image 
colormap('gray'); xlabel('u (m)'); ylabel('v (m)'); 
axis square;
axis xy;
title('ideal image');
set(gca,'FontName', 'Times New Roman'); 

%  Define the imaging system parameters and generate the coherent transfer function
lambda=0.633*10^-6;                     % wavelength 
% Parameters of the first lens
wxp_1 = 7.509e-3;                       % exit pupil radius 
zxp_1 = 300.996411e-3;                  % exit pupil distance 
f0_1 = wxp_1/(lambda*zxp_1);            % cutoff frequency 
% Parameters of the second lens
wxp_2 = 24e-3;                          % exit pupil radius 
zxp_2 = 501.660685e-3;                  % exit pupil distance 
f0_2 = wxp_2/(lambda*zxp_2);            % cutoff frequency 
% Parameters of the third lens
wxp_3 = 24.5e-3;                        % exit pupil radius 
zxp_3 = 150.556448e-3;                  % exit pupil distance 
f0_3 = wxp_3/(lambda*zxp_3);            % cutoff frequency 

fu=-1/(2*du):1/L:1/(2*du)-(1/L);        %freq coords 
fv=fu; 
[Fu,Fv]=meshgrid(fu,fv); 
H_OS=circ(sqrt(Fu.^2+Fv.^2)/f0_1).*circ(sqrt(Fu.^2+Fv.^2)/f0_2).*circ(sqrt(Fu.^2+Fv.^2)/f0_3); 

subplot(2,2,2)                        %check H 
surf(fu,fv,H_OS.*.99);
camlight left; lighting flat;
colormap('gray'); 
shading interp; 
ylabel('fu (cyc/m)'); xlabel('fv (cyc/m)');
title('transfer function');
set(gca,'FontName', 'Times New Roman'); 

% Generate the simulated image
H_OS=fftshift(H_OS); 
Gg=fft2(fftshift(ug)); 
Gi=Gg.*H_OS; 
ui=ifftshift(ifft2(Gi)); 
Ii=(abs(ui)).^2; 

subplot(2,2,3)                         %image result 
imagesc(u,v,nthroot(Ii,2)); 
colormap('gray'); xlabel('u (m)'); ylabel('v (m)'); 
axis square; 
axis xy; 
title('coherent image');
set(gca,'FontName', 'Times New Roman'); 

subplot(2,2,4)                     % horizontal image slice 
vvalue= 0.6e-3;                    % select row (y value) 
vindex=round(vvalue/du+(M/2+1));   % convert row index 
plot(u,Ii(vindex,:),u,Ig(vindex,:),':'); 
legend('cogerent image','ideal image');
grid on;
xlabel('u (m)'); ylabel('Irradiance');
title('horizontal image slice');
set(gca,'FontName', 'Times New Roman'); 
set(gcf, 'Color', 'w');
%%  Incoherent Imaging
figure();  
subplot(2,2,1)
imagesc(u,v,Ig);                  % check ideal image 
colormap('gray'); xlabel('u (m)'); ylabel('v (m)'); 
axis square;
axis xy;
title('ideal image');
set(gca,'FontName', 'Times New Roman'); 

% OTF for first lens
H_1=circ(sqrt(Fu.^2+Fv.^2)/f0_1); 
OTF_1=ifft2(abs(fft2(fftshift(H_1))).^2); 
OTF_1=abs(OTF_1/OTF_1(1,1));    
% OTF for second lens
H_2=circ(sqrt(Fu.^2+Fv.^2)/f0_2); 
OTF_2=ifft2(abs(fft2(fftshift(H_2))).^2); 
OTF_2=abs(OTF_2/OTF_2(1,1));
% OTF for third lens
H_3=circ(sqrt(Fu.^2+Fv.^2)/f0_3); 
OTF_3=ifft2(abs(fft2(fftshift(H_3))).^2); 
OTF_3=abs(OTF_3/OTF_3(1,1));

OTF_OS = OTF_1.*OTF_2.*OTF_3;

subplot(2,2,2)                   % check OTF 
surf(fu,fv,fftshift(OTF_OS)) 
camlight left; lighting phong 
colormap('gray') 
shading interp 
ylabel('fu (cyc/m)'); xlabel('fv (cyc/m)'); 
title('optical transfer function');
set(gca,'FontName', 'Times New Roman'); 

%% Generate the simulated image
Gg=fft2(fftshift(Ig));      %convolution 
Gi=Gg.*OTF_OS; 
Ii=ifftshift(ifft2(Gi)); 
%remove residual imag parts, values < 0 
Ii=real(Ii); mask=Ii>=0; Ii=mask.*Ii; 

subplot(2,2,3)                   %image result 
imagesc(u,v,nthroot(Ii,2)); 
colormap('gray'); xlabel('u (m)'); ylabel('v (m)'); 
axis square; 
axis xy; 
title('incoherent image');
set(gca,'FontName', 'Times New Roman'); 

subplot(2,2,4)                   %horizontal image slice 
vvalue=-0.6e-3;            %select row (y value) 
vindex=round(vvalue/du+(M/2+1)); %convert row index 
plot(u,Ii(vindex,:),u,Ig(vindex,:),':');
legend('cogerent image','ideal image');
grid on;
xlabel('u (m)'); ylabel('Irradiance');
axis([-1e-3 1e-3 0 1.8])
title('horizontal image slice');
set(gca,'FontName', 'Times New Roman'); 
set(gcf, 'Color', 'w');