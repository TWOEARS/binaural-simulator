clear all;
close all;

test_startup;

%%

theDoc = xmlread('info.xml');
theNode = theDoc.getDocumentElement;

source = AudioSource(AudioSourceType.POINT,buffer.Noise());
source.PropertiesFromXMLNode(theNode);

%%


