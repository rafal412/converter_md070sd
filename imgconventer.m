clear all; close all;
# This octave script convert image file to RGB565 witdh will be compatible 
# width TFT MD070SD
# Createrd by Rafal Koterba 

bmp_file='pig.bmp';

ig = imread(bmp_file);
dim=size(ig);
dx=dim(1);
dy=dim(2);

RGB565 = uint16(zeros(dx, dy));
redcut = uint16(bitand(ig(:,:,1),248));
greencut = uint16(bitand(ig(:,:,2),252));
bluecut = uint16(bitand(ig(:,:,3),248));
#{
# To see differen between original and deform picture
RGB2 = uint8(zeros(dx, dy, 3));
RGB2(:,:,1) = redcut;
RGB2(:,:,2) = greencut;
RGB2(:,:,3) = bluecut;

imshow(RGB2)
figure
#}

redcut_tab = uint16(zeros(dx*dy,1));
greencut_tab = uint16(zeros(dx*dy,1));
bluecut_tab = uint16(zeros(dx*dy,1));
#transform 2-dim array to 1-dim array...
zm=1;
for i=1:dx
	for j=1:dy
	redcut_tab(zm) = redcut(i,j);
	greencut_tab(zm) = greencut(i,j);
	bluecut_tab(zm) = bluecut(i,j);
	zm++;
	endfor
endfor

#Move bits into right position
RGB565=bitshift(redcut_tab,8);
RGB565 = bitor(RGB565,bitshift(greencut_tab,3));
RGB565 = bitor(RGB565, bitshift(bluecut_tab,-3));

RGB565hex=dec2hex(RGB565);

#Split 16 bit data into 8 bit data
dxy=(dx*dy);
RGB565array = cell(2*dxy,1);
j=1;
for i = [1:dxy]
   RGB565array(j) =strcat(RGB565hex(i,3), RGB565hex(i,4));
   j++;
   RGB565array(j) =strcat(RGB565hex(i,1), RGB565hex(i,2));
   j++;
endfor

#Magic to get ready array to put into uC
FileToSave=cell(dx,dy*2);
zm=1;
for i=1:dx
	for j=1:dy*2
	FileToSave(i,j)=RGB565array(zm);
	zm++;
	endfor
endfor

zm=1
fid = fopen('data4.txt', 'w+');
fprintf(fid,"rom const char image[]={ \n");
for i=1:dx
	for j=1:dy*2
	
	fprintf(fid, "0X%s,", RGB565array{zm});
	zm++;
	endfor
	fprintf(fid, ' \n');
	
endfor
fprintf(fid,"};");
fclose(fid);


# Reverse engineering ...

#M = textread("img_my", "%s");
M = RGB565array;
x = hex2dec(textread("img", "%s")); 
j=1;
rozmiar=60

for i = [1:2:7200]
  M16(j) = strcat(M(i+1),M(i));
   j++;
endfor
red_mask = 'F800';
green_mask = '7E0';
blue_mask = '1F';

red_mask = hex2dec(red_mask)
green_mask = hex2dec(green_mask)
blue_mask = hex2dec(blue_mask)

M16dec = hex2dec(M16);
M16dec=uint16(M16dec);

RED = bitand(M16dec, red_mask);
RED=bitshift(RED,-11);
RED=uint8(bitshift(RED,3));

GREEN = bitand(M16dec, green_mask);
GREEN = bitshift(GREEN,-5);
GREEN=uint8(bitshift(GREEN,2));

BLUE = bitand(M16dec, blue_mask);
BLUE = uint8(bitshift(BLUE,3));

i=1
j=1
REDtab = uint8(zeros(rozmiar, rozmiar));
GREENtab = uint8(zeros(rozmiar,rozmiar));
BLUEtab = uint8(zeros(rozmiar,rozmiar));
zm=1
for i=1:rozmiar
	for j=1:rozmiar
	REDtab(i,j) = RED(zm);
	GREENtab(i,j) = GREEN(zm);
	BLUEtab(i,j) = BLUE(zm);
	zm++;
	endfor
endfor



RGB = uint8(zeros(rozmiar, rozmiar, 3));
RGB(:,:,1) =REDtab;
RGB(:,:,2)= GREENtab;
RGB(:,:,3)= BLUEtab;

imshow(RGB)
