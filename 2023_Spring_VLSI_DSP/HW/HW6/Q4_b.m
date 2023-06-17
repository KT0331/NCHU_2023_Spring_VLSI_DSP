clear
close all
clc

floading_order = [0 1; 1 0];
vaild = 0;
min_Df = 0;

for sa1 = 1 : 2
    SA1 = floading_order(sa1, :);
    for sa2 = 1 : 2
        SA2 = floading_order(sa2, :);
        for sm1 = 1 : 2
            SM1 = floading_order(sm1, :);
            for sm2 = 1 : 2
                SM2 = floading_order(sm2, :);
                for sm3 = 1 : 2
                    SM3 = floading_order(sm3, :);
                    Df = zeros(12, 1);
                    Df(1) = 2*2 - 1 + SA1(2) - SA1(1);
                    Df(2) = 2*2 - 1 + SM1(1) - SA1(1);
                    Df(3) = 2*0 - 1 + SM1(2) - SA1(1);
                    Df(4) = 2*1 - 1 + SM2(2) - SA1(1);
                    Df(5) = 2*0 - 1 + SM3(2) - SA1(1);
                    Df(6) = 2*0 - 1 + SM2(2) - SA1(2);
                    Df(7) = 2*0 - 1 + SA2(1) - SA2(1);
                    Df(8) = 2*0 - 2 + SA1(1) - SM1(1);
                    Df(9) = 2*0 - 2 + SA1(2) - SM1(2);
                    Df(10)= 2*0 - 2 + SA2(2) - SM2(1);
                    Df(11)= 2*0 - 2 + SA2(1) - SM1(2);
                    Df(12)= 2*0 - 2 + SA2(2) - SM3(2);
                    min_Df = min(Df);
                    if min_Df >= 0
                        vaild = 1;
                        fprintf('There are valid floading design\n');
                        break;
                    end
                end
            end
        end
    end
end

if vaild == 0
    fprintf('There are no valid floading design\n');
end