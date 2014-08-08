% Script for testing the MEX file for the Binaural renderer

clear all
close all

test_startup;

%% input signals
[input] = ...
  audioread(dbGetFile('stimuli/anechoic/instruments/anechoic_cello.wav'));

input = single(input(:,1)./max(abs(input(:,1))));

%% processing parameters

theNode = dbOpenXML('test.xml');

sim = SimulatorConvexRoom();  % simulator object

sim.XML(theNode);

%% initialization
% note that all the parameters including objects' positions have to be
% defined BEFORE initialization in order to init properly
sim.set('Init',true);

sim.draw();

%% static scene

[sig, actualTime] = sim.getSignal(3);  % get 3 seconds signal
display(actualTime);  % display length of sig in seconds
sim.rotateHead(180);  % rotate the head 90 degrees to the left
[sig] = [sig; sim.getSignal(3)];  % get 3 seconds signal

sig = sig/max(abs(sig(:))); % normalize
audiowrite('out_robot.wav',sig,sim.SampleRate);

%% clean up
sim.set('ShutDown',true);