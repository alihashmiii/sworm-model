function [] = plotWoidlinoPhasePortraitCorrelationAnalysisSteadyState
% plot phase portrait of g(r) vs time to show quasi steady state

% issues/to-do:
clear
close all

exportOptions = struct('Format','eps2',...
    'Color','rgb',...
    'Width',17,...
    'Resolution',300,...
    'FontMode','fixed',...
    'FontSize',6,...
    'LineWidth',1,...
    'Renderer','opengl');

N = 40;
M = 18;
L = 7.5;
attractionStrength = 0;
numRepeats = 4;
% revRatesClusterEdge = [0, 0.1, 0.2, 0.4, 0.8, 1.6];
revRatesClusterEdge = [0, 0.2, 0.4, 0.8, 1.6, 3.2];
speeds = [0.33];
% slowspeeds = fliplr([0.33, 0.1, 0.05, 0.025, 0.0125]);
slowspeeds = [0.018];
trackedNodes = 1:max(round(M/10),1);
distBinwidth = 0.05; % in units of mm, sensibly to be chosen similar worm width or radius
maxDist = 2;
slowingMode = 'stochastic';
k_dwell = 0.0036;
k_undwell = 1.1;
dkdN_dwell_values = fliplr([0 1./[8 4 2 1 0.5]]);
% num_nbr_max_per_nodes = 2;

for speed = speeds
    poscorrFig = figure;
    plotCtr = 1;
    poscorrFig.Name = ['v_0 = ' num2str(speed)];
    for slowspeed = slowspeeds
        for dkdN_dwell = dkdN_dwell_values
            for revRateClusterEdge = revRatesClusterEdge
                for repCtr = 1:numRepeats
                    filename = ['../results/woidlinos/wlM' num2str(M) '_N_' num2str(N) '_L_' num2str(L) ...
                        '_noVolExcl' ...'_angleNoise' ...
                        '_v0_' num2str(speed,'%1.0e') '_vs_' num2str(slowspeed,'%1.0e') ...
                        '_' slowingMode 'SlowDown' '_dwell_' num2str(k_dwell) '_' num2str(k_undwell)...
                        '_dkdN_' num2str(dkdN_dwell) ...num2str(num_nbr_max_per_nodes)...
                        '_epsLJ_' num2str(attractionStrength,'%1.0e') ...
                        '_revRateClusterEdge_' num2str(revRateClusterEdge,'%1.0e') ...
                        '_run' num2str(repCtr) '.mat'];
                    if exist(filename,'file')
                        thisFile = load(filename);
                        maxNumFrames = size(thisFile.xyarray,4);
                        burnIn = round(0.5*maxNumFrames); % used for visualizing cut-off
                        numFrames =  0.1*maxNumFrames; % sample some percentage of frames
                        framesAnalyzed = round(linspace(1,maxNumFrames,numFrames)); % regularly sample frames without replacement
         
                        %% calculate stats
                        [~,~, ~,~, ~,~,...
                            gr,distBins,~,~] = ...
                            correlationanalysisSimulations(thisFile,trackedNodes,distBinwidth,framesAnalyzed,maxDist);
                        % get maximum of gr
                        [grmax, ~] = max(smoothdata(gr,2,'movmean',3));
                        % plot lines for this file
                        % speed v distance
                        subplot(length(dkdN_dwell_values),length(revRatesClusterEdge),plotCtr)
                        plot(framesAnalyzed,smoothdata(grmax,'SmoothingFactor',0.4))
                        if repCtr==1, hold on, end
                        plot(burnIn*[1 1],[0 max(grmax)],'k--')
                    end
                end
                %% format plots
                formatAxes(revRateClusterEdge,dkdN_dwell);
                % advance to next subplot
                plotCtr = plotCtr + 1;
            end
        end
    end
    %% export figures
    % radial distribution / pair correlation
    poscorrFig.PaperUnits = 'centimeters';
    fignameprefix = ['figures/diagnostics/grmaxOverTime'];
    fignamesuffix = ['_M' num2str(M)...
        'N_' num2str(thisFile.N) '_L_' num2str(thisFile.L(1)) ...
        '_noVolExcl' ...'_angleNoise'...
        '_speed_' num2str(speed,'%1.0e') ...
        '_slowing_' slowingMode '_dwell_' num2str(k_dwell) '_' num2str(k_undwell)...num2str(num_nbr_max_per_nodes) ...
        '_epsLJ_' num2str(attractionStrength,'%1.0e')...
        '.eps'];
    filename = [fignameprefix 'Radialdistribution' fignamesuffix];
    exportfig(poscorrFig,filename, exportOptions)
    system(['epstopdf ' filename]);
    system(['rm ' filename]);
end
end

function ax = formatAxes(revRateClusterEdge,var2)
title(['r=' num2str(revRateClusterEdge) ', dk/dN =' num2str(var2)],...
    'FontWeight','normal')
ax = gca;
ax.Position = ax.Position.*[1 1 1.2 1.2] - [0.0 0.0 0 0]; % stretch panel
% ax.XLim = [0 2];
% ax.XTick = 0:2;
ax.XTickLabel = [];
% ax.YTickLabel = [];
ax.Box = 'on';
grid on
end