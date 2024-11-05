----------------------------------
r          0 :   0
r          1 :   6
r          2 :   2
r          3 : 128
r          4 :   7
r          5 :  16
r          6 :   0
r          7 :   0
----------------------------------
r1 = 6
r2 = 2
r3 = 1
r4 = 1
do{
    r3 *= r2;
    r4++;
}while(r1 < r4);
r5 = PC + 2 = 14 + 2

memo:
while(r1 < r4)
blt, r1, r4, 4
jal, r5, -6

if r4 = 6, then r1 < r4 => 6 < 6 => falue
until r4 = 7, then r1 < r4 => 6 < 7 => true

