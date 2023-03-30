pkg load image;
pkg load signal;
clear;
close all;

function [rho, theta] = polar_coord(R, C)
  for i=1:R
    for j=1:C
        rho(i,j)= sqrt((i-R/2)^2 + (j-C/2)^2);
        theta(i,j) = atan2((j - (C/2)), (i - (R/2)));
    endfor
  endfor
endfunction

function [new_rho, new_theta] = transform1(R, C, rho, theta)
  new_rho = ((rho.^2)/((sqrt((R^2)+(C^2)))));
  new_theta = theta;
endfunction

function [new_rho, new_theta] = transform2(rho, theta)
  new_rho = rho - mod(rho,5);
  new_theta = (floor(10*theta))/10;
endfunction

function [new_rho, new_theta] = transform3(rho, theta)
  new_rho = 4 + sin(rho/2);
  new_theta = theta;
endfunction

function [new_rho, new_theta] = transform4(rho, theta)
  new_rho = rho;
  new_theta = ((theta.^2)/(2*pi));
endfunction

function [x, y] = cartesian_coord(rho, theta)
  x = (rows(rho)/2) + rho.*cos(theta);
  y = (columns(rho)/2) + rho.*sin(theta);
endfunction

function decision = check_bounds(img, x, y)
  if((x<=rows(img)) && (y<=columns(img)) && (x>=1) && (y>=1))
    decision = 1;
  else
    decision = 0;
  endif
endfunction

function img_out = image_special_effect(img, rho, theta)
  img_out = zeros(rows(img), columns(img));
  [x, y] = cartesian_coord(rho, theta);
  for i=1:rows(img)
    for j=1:columns(img)
      if(check_bounds(img, round(x(i,j)), round(y(i,j))))
        img_out(i,j) = img(round(x(i,j)), round(y(i,j)));
      endif
    endfor
  endfor
endfunction

img = mat2gray(imread("lena512.jpg"));
printf("Converting to Polar Coordinates... ");
[rho,theta] = polar_coord(rows(img), columns(img));
printf(" OK\n");

printf("Calculating rho', theta' for trasformation 1...");
[r1, theta1] = transform1(rows(img), columns(img), rho, theta);
printf(" OK\n");

printf("Calculating rho', theta' for trasformation 2...");
[r2, theta2] = transform2(rho, theta);
printf(" OK\n");

printf("Calculating rho', theta' for trasformation 3...");
[r3, theta3] = transform3(rho, theta);
printf(" OK\n");

printf("Calculating rho', theta' for trasformation 4...");
[r4, theta4] = transform4(rho, theta);
printf(" OK\n");

printf("Applying transformation 1...");
img1 = image_special_effect(img, r1, theta1);
printf(" OK\n");

printf("Applying transformation 2...");
img2 = image_special_effect(img, r2, theta2);
printf(" OK\n");

printf("Applying transformation 3...");
img3 = image_special_effect(img, r3, theta3);
printf(" OK\n");

printf("Applying transformation 4...");
img4 = image_special_effect(img, r4, theta4);
printf(" OK\n");


figure(1);
imshow(img, []);
title("Original");

figure(2);
imshow(img1, []);
title("Transformation 1 (Fisheye)");

figure(3);
imshow(img2, []);
title("Transformation 2");

figure(4);
imshow(img3, []);
title("Transformation 3 (Ripples on a pond)");

figure(5);
imshow(img4, []);
title("Transformation 4");



