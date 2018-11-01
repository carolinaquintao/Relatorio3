% % % % Z:\MylenaReis\Dados\S11D\Benchmark_3metrics_15i15f_permin\Resultados_conn
clear; clc
addpath('.\VetoresIniFim\','.\VetoresIniFimBanda\')
myDir = dir('.\VetoresIniFimBanda\Anova_15*.mat');
load('171pairchannels.mat')
load('7individuosNomes.mat')%carrega os nomes (names)

for i=1:length(myDir)
    load(myDir(i).name);
    anovaIF(anovaIF>0.05) = 0;
    anovaIF(anovaIF~=0) = 1;
    pos = sum(anovaIF,1);
    lengPos = sum(pos>0);
    
    b = split(myDir(i).name,{'Anova_15I15F_7subj_BenchMarco_Banda_','.mat'});
    banda = b{2};
    for t=1:length(name)
        ['VetoresIniFim_' banda '_subj_' name{t} '.mat']
        load(['VetoresIniFim_' banda '_subj_' name{t} '.mat'])
%%%%%%%%%%%%%%%%%%%%acho que tah salvando vecIni e vecFim igual pra
%%%%%%%%%%%%%%%%%%%%todos!!!!
        Ini171 = vecIni171(:,pos>0);
        Fim171 = vecFim171(:,pos>0);

        maxBoth = max(max([Ini171; Fim171]));
        minBoth = min(min([Ini171; Fim171]));

        vecIni171 = normalize(Ini171,'range',[minBoth,maxBoth]);
        vecFim171 = normalize(Fim171,'range',[minBoth,maxBoth]);

        labels = table_label(pos>0);
        % Create figure
        figure1 = figure;

        % Create axes
        axes1 = axes('Parent',figure1,'Position',[0 1 1 1],'Tag','suptitle');
        axis off

        text('Parent',axes1,'HorizontalAlignment','center','FontSize',14,...
        'String',['Banda ' banda],...
        'Position',[0.500520833333333 -0.0243589743589744 0],...
        'Visible','on');

        if ismember(lengPos,1:5)
            colunas = lengPos;
            linhas = 1;
        elseif lengPos==6
            colunas = 3;
            linhas = 2;
        else
            colunas = 5;%round(lengPos/2);
            linhas = ceil(lengPos/5);
    %     else%odd number
    %         colunas = round(lengPos/3);
    %         linhas = 3;
        end


        for j=1:lengPos
            subplot(linhas,colunas,j)
            bar([vecIni171(:,j), vecFim171(:,j)])

            p = polyfit(1:15,vecIni171(:,j)',1); 
            f = polyval(p,1:15); 
            hold on
            plot(1:15,f)

            p = polyfit(1:15,vecFim171(:,j)',1); 
            f = polyval(p,1:15); 
            plot(1:15,f)

            title(labels{j})
            legend('Conn. Begining','Conn. Ending','L. Fit Begining','L. Fit Ending','Location','best')
            legend('boxoff')
            xlabel('Minutes')
            ylabel('Coonectivity')
            hold off
        end
%          saveas(gca,['Subj_' name{t} 'Banda_' banda '_Conectividade_LinearFitting.fig'])
        clear vecIni171 vecFim171
    end
end