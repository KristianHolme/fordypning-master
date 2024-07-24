clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mpfa mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics nfvm gmsh prosjektOppgave...
    deckformat
%%
deck = readEclipseDeck('pyopmcsp11/testOutput/preprocessing/CSP11A.DATA');
%%
deck = convertDeckUnits(deck);
%%
[state0, model, schedule, nls] = initEclipseProblemAD(deck);