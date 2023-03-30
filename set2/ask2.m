pkg load image;
pkg load signal;
clear;
close all;

function [result] = calculate_coef(image, template)
  % image(r, c) (f) ,template(m,n) (w)
  r = rows(image);
  c = columns(image);
  m = rows(template);
  n = columns(template);

  coefficient = zeros((r+m-1), (c+n-1));

  x1 = (m-1)/2+1;
  y1 = (n-1)/2+1;

  x2 = r+(m-1)/2;
  y2 = c+(n-1)/2;
  % Padding
  img_temp = zeros((r+m-1), (c+n-1));
  img_temp(x1:x2, y1:y2) = image;
  % for x,y -> g(x,y)
  for i=x1:x2
    for j=y1:y2
      r1 = (i-(m-1)/2);
      r2 = (i+(m-1)/2);
      c1 = (j-(n-1)/2);
      c2 = (j+(n-1)/2);

      W = mean2(template); % Mean W (w(s,t))
      F = mean2(img_temp(r1:r2, c1:c2));  % Mean F (Fxy)
      % SS[w(s,t)-W][f(x+s, y+t)-Fxy]
      numerator_1 = (template-W).*(img_temp(r1:r2,c1:c2)-F);
      numerator = sum(sum(numerator_1));

      %SS[w(s,t)-W]^2   -1
      denominator_1 = (template-W).^2;
      denominator_1 = sum(sum(denominator_1));
      %SS[f(x+s, y+t)-Fxy]^2    -2
      denominator_2 = (img_temp(r1:r2, c1:c2)-F).^2;
      denominator_2 = sum(sum(denominator_2));
      % 1*2^(1/2)
      denominator = sqrt(denominator_1*denominator_2);
      % g(x,y) Correlation coefficient
      coefficient(i,j) = numerator/denominator;
    endfor
  endfor

  result = coefficient(x1:x2, y1:y2);
endfunction

function [max_x, max_y] = find_max(coef)
  r = rows(coef);
  c = columns(coef);
  tmp_x = 1;
  tmp_y = 1;
  tmp_value = coef(1, 1);
  for i=2:r
    for j=2:c
      if(coef(i, j)>= tmp_value)
        tmp_x = i;
        tmp_y = j;
        tmp_value = coef(i,j);
      endif
    endfor
  endfor
  max_x = tmp_x;
  max_y = tmp_y;
endfunction

function [result] = calculate_mosaic(image1, image2, diff)
  R = rows(image1);
  C = columns(image1);

  mosaic(1:R,1:C)= image2;
  mosaic(1:R,(diff+1):(diff+C))= image1;
  result = mosaic;
endfunction

% Main
image_1 = double(imread('Image1.tif'));
image_2 = double(imread('Image2.tif'));
template = double(imread('Template.tif'));
template = template(:,:,1);


printf("Calculating correlation coefficient for Image1, Template...\n");
coef_1 = calculate_coef(image_1, template);
printf("  OK!\n")
printf(" Finding coordinates of max value...\n");
[max1_x, max1_y] = find_max(coef_1);
printf("  OK!\n")

printf("Calculating correlation coefficient for Image2, Template...\n");
coef_2 = calculate_coef(image_2, template);
printf("  OK!\n")
printf(" Finding coordinates of max value...\n");
[max2_x, max2_y] = find_max(coef_2);
printf("  OK!\n")

printf("Calculating mosaic...\n");
dy = abs(max1_y-max2_y);
mosaic = calculate_mosaic(image_1, image_2, dy);
printf("  OK!\n")

% Figure to pdf
figure;

subplot(3,2,1);
imshow(image_1, []);
title('Image 1:');

subplot(3,2,2);
imshow(coef_1, []);
title_coef_1 = sprintf("Coef 1:\n    max at (%d, %d)",max1_x, max1_y);
title(title_coef_1)

subplot(3,2,3);
imshow(image_2, []);
title('Image 2:');

subplot(3,2,4);
imshow(coef_2, []);
title_coef_2 = sprintf("Coef 2:\n    max at (%d, %.d)",max2_x, max2_y);
title(title_coef_2);

subplot(3,2,[5,6]);
imshow(mosaic, []);
title('Mosaic of Image1, Image2:');
