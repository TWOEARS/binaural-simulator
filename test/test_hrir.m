close all;
clear all;

test_startup;

filename = fullfile('../../twoears-data/impulse_responses/qu_kemar_anechoic/QU_KEMAR_anechoic_3m.wav');
azimuth = 90;  % this should be left

hrtf = simulator.DirectionalIR(filename);

plot(hrtf.getImpulseResponses(azimuth).left,'r');
hold on;
plot(hrtf.getImpulseResponses(azimuth).right,'b');
title(['Directional Transfer Function (azimuth=', num2str(azimuth), ')']);
legend('left','right');
hold off;