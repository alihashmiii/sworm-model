function [] = extendSimulation(filename,Textend)
% load and resume a simulation
load(filename)
[xyarray2, currentState] = runWoids(Textend,N,M,L,param,'resumeState',currentState);
xyarray = cat(4,xyarray,xyarray2(:,:,:,2:end));
filename = [strrep(filename,'.mat',''),'_extended.mat'];
T = T + Textend;
clear xyarray2
save(filename)
end

