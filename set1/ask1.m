pkg load image;
pkg load signal;
clear;
close all;

function d = deviation(img)
  snr = 5;
  sum_diff = 0;
  avg_brightness = sum(sum(img,1))/(rows(img)*columns(img));
  for i=1:rows(img)
    for j=1:columns(img)
      sum_diff = sum_diff + (img(i,j) - avg_brightness)^2;
    endfor
  endfor
  d =  ((1/(rows(img)*columns(img))) * sum_diff) / (10^(snr/10)) ;
  endfunction

% main
img = mat2gray(imread("lena512.jpg"));

printf("Calculating deviation...");
dev = deviation(img);
printf(" OK\n");

mse = zeros(1,50);
current_sum = zeros(rows(img),columns(img));
avg_noisy_img = zeros(rows(img),columns(img));

for i=1:50
  noisy_img = imnoise(img, "Gaussian", 0, dev);
  current_sum = current_sum + noisy_img;
  avg_noisy_img = current_sum / i;
  printf("Loop #%d",i);
  for m=1:rows(img)
    for n=1:columns(img)
      mse(i) = mse(i) + (img(m,n)-avg_noisy_img(m,n))^2;
    endfor
  endfor
  mse(i) = mse(i) / (rows(img)*columns(img)) ;
  printf(" -> MSE: %f\n", mse(i));
endfor

figure(1);
imshow(noisy_img, []);
title("Noisy Image: ");

figure(2);
imshow(avg_noisy_img, []);
title("Average of 50: ");

figure(3);
imshow(img,[]);
title("Original: ");

figure(4);
plot(1:50, mse);
xlabel("Loop number");
ylabel("MSE");
