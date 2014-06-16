clear all;
close all;

test_startup;

%%

theDoc = xmlread('test.xml');
theNode = theDoc.getDocumentElement;

source = AudioSource(AudioSourceType.POINT,buffer.Noise());
source.XMLsetProperties(theNode);


%%


