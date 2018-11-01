clear; close all
%-------
files = dir(fullfile('..','DadosConectividade','Conetividade15i15f_Marco'));
dirFlags = [files.isdir]& ~strcmp({files.name},'.') & ~strcmp({files.name},'..');
files = files(dirFlags);
load('12freqBands.mat')
load('171pairchannels.mat')
load('7individuos.mat')
% lobo = unique(separaLobos);
clear dirFlags
for u=1:length(freqBands)
    banda = freqBands{u}%'beta'  %'teta' %'alfa'; %
    for i=1:length(files)
        name1 = split(files(i).name,'_');
        name{i} = name1{1};
        pathMy = fullfile(files(i).folder,files(i).name);
        dirMy = dir(pathMy);
        pathMy = fullfile(dirMy(3).folder,dirMy(3).name);
        dirMy = dir(pathMy);
        pathMy = fullfile(dirMy(3).folder,dirMy(3).name);
        dirMy = dir(pathMy);
        dirFlags = ~[dirMy.isdir];
        dirMy = dirMy(dirFlags);
        %     aux = strcmp([subj{1} ' '],tablelist_name_ind(:,1));
        %     subj = split(dirMy(1).name,{'.'});
        for k = 1:length(dirMy)
            subj = split(dirMy(k).name,{'_','.'});
            if strcmp(subj{2},banda)
                fullfile(dirMy(k).folder,dirMy(k).name)
                load(fullfile(dirMy(k).folder,dirMy(k).name));
                ini15 = eval(['conn_' banda '(1,1:15)']);
                fim15 = eval(['conn_' banda '(1,16:end)']);
                %%preciso vetorizar a matriz
                for j=1:15
                    auxI = reshape(tril(mean(ini15{1,j}{1,1},3)),1,19*19);
                    auxF = reshape(tril(mean(fim15{1,j}{1,1},3)),1,19*19);
                    auxI = auxI(auxI~=0);
                    auxF = auxF(auxF~=0);
                    vecIni171(j,:) = auxI;
                    vecFim171(j,:) = auxF;
                end
                save(['VetoresIniFim_' banda '_subj_' name{i} '.mat'], 'vecIni171', 'vecFim171')
                %calcular o anova            
                for h=1:171
                    anovaIF(i,h) = anova1([vecIni171(:,h) vecFim171(:,h)]);
                    close all
                end
%             end
%         end
     clear vecIni171 vecFim171 ini15 fim15 auxI auxF subj 
    end
    save(['7IndividuosNomes.mat'],'name')
    save(['Anova_15I15F_7subj_BenchMarco_Banda_' banda], 'anovaIF')
    anovaIF(anovaIF>0.05) = 0;
    anovaIF(anovaIF~=0) = 1;

    pos = sum(anovaIF,1);%find(anovaIF==1);
    lengPos = sum(pos>0);
    %%Todos
    figure
    xvalues = table_label(pos>0);
    yvalues = ind';
    h = heatmap(xvalues,yvalues,anovaIF(:,pos>0), 'XLabel', 'Pairs','YLabel', 'Subjects', 'Title', banda);
    savefig([banda '_BenchMarco_ConnectivityAnnova.fig'])
    
    %%within region
    aux = anovaIF(:,pos>0);
    figure
    xvalues = table_label(pos>0);
    a = split(xvalues,'-');%a(1,length(pos),2)
    o=1;
    for p=1:length(xvalues)
        if strcmp(a{1,p,1}(1),a{1,p,2}(1)) && ~strcmp(a{1,p,1}(2),'p') && ~strcmp(a{1,p,2}(2),'p')%se for da mesma regiao AND nao for F com Fp
            newXvalues(o) = xvalues(p);
            newAnovaIF(:,o) = aux(:,p);
            o=o+1;
        elseif strcmp(a{1,p,1}(1),a{1,p,2}(1)) && strcmp(a{1,p,1}(2),'p') && strcmp(a{1,p,2}(2),'p')%se for da mesma regiao AND for Fp com Fp
            newXvalues(o) = xvalues(p);
            newAnovaIF(:,o) = aux(:,p);
            o=o+1;
        end
    end
    
     teste = exist('newXvalues');
    if exist('newXvalues')
        yvalues = ind';
        h = heatmap(newXvalues,yvalues,newAnovaIF, 'XLabel', 'Pairs','YLabel', 'Subjects', 'Title', banda);
        savefig([banda '_BenchMarco_ConnectivityAnnova_WithinRegion.fig'])
        clear newXvalues newAnovaIF anovaIF o p xvalues aux
    end
    
    %between region
    aux = anovaIF(:,pos>0);
    figure
    xvalues = table_label(pos>0);
    a = split(xvalues,'-');%a(1,length(pos),2)
    o=1;
    for p=1:length(xvalues)
        if ~strcmp(a{1,p,1}(1),a{1,p,2}(1))
            newXvalues(o) = xvalues(p);
            newAnovaIF(:,o) = aux(:,p);
            o=o+1;
        end
    end
    teste = exist('newXvalues');
    if exist('newXvalues')
        yvalues = ind';
        h = heatmap(newXvalues,yvalues,newAnovaIF, 'XLabel', 'Pairs','YLabel', 'Subjects', 'Title', banda);
        savefig([banda '_BenchMarco_ConnectivityAnnova_BetweenRegion.fig'])
    
        clear newXvalues newAnovaIF anovaIF o p xvalues aux
    end

end
function lobo = separaLobos
load('19channels.mat');%v3 {1x19}
for i=1:19
    lobo{i,1} = v3{1,i}(1);
end
end