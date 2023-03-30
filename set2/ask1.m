pkg load image;
pkg load signal;
clear;
close all;

f = double(imread('Lena_512.jpg')); % Image (f)
R = rows(f);
C = columns(f);

% Filter (h)
h = [[1/16 1/8 1/16];
   [1/8  1/4  1/8];
   [1/16 1/8 1/16]];

printf("Calculating convolution...\n");
g_convolution = imfilter(f, h); % Filtered Image Convolution (g_convolution)
printf("    OK!\n");

% Image padding
f_padded = zeros(R+2, C+2);
f_padded(1:R, 1:C) = f;

% Filter padding
h_padded = zeros(R+2, C+2);
h_padded(1,1)=1/4;
h_padded(1,2)=1/8;
h_padded(2,1)=1/8;
h_padded(2,2)=1/16;
h_padded(1,C+2)=1/8;
h_padded(2,C+2)=1/16;
h_padded(R+2,1) = 1/8;
h_padded(R+2,2)=1/16;
h_padded(R+2,C+2) = 1/16;

printf("Calculating image DFT...\n");
F_fourier = fft2(f_padded); % Image DFT (F_fourier)
printf("    OK!\n");

printf("Calculating filter DFT...\n");
H_fourier = fft2(h_padded); % Filter DFT (H_fourier)
printf("    OK!\n");

printf("Calculating filtered image DFT...\n");
G_fourier = H_fourier.*F_fourier; % Filtered Image DFT (G_fourier)
printf("    OK!\n");

printf("Calculating filtered image...\n");
g = ifft2(G_fourier); % Filtered Image (g)
g = g(1:R, 1:C);
printf("    OK!\n");

% Error on screen
printf("Calculating MSE...\n");
MSE = ((sum(sum((g-g_convolution) .^2)))/(R*C))
printf("    OK!\n");

% Needed for imshow (?)
F_fourier = fftshift(log(1+abs(F_fourier)));
H_fourier = fftshift(log(1+abs(H_fourier)));
G_fourier = fftshift(log(1+abs(G_fourier)));

% Figure to pdf
figure;

subplot(2,3,1);
imshow(f,[]);
title('Image');

subplot(2,3,2);
imshow(real(g),[]);
title('Filtered Image');

subplot(2,3,3);
imshow(g_convolution,[]);
title('Filtered Image Convolution');

subplot(2,3,4);
imshow(real(F_fourier),[]);
title('Image DFT');

subplot(2,3,5);
imshow(real(H_fourier),[]);
title('Filter DFT');

subplot(2,3,6);
imshow(real(G_fourier),[]);
title('Filtered Image DFT');
