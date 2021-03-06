%hdebug.m
%%
% 功能：数据集做转换
% 输入文件txt格式：文件路径 x1,y1,x2,y2,类别 x1,y1,x2,y2,类别 ...
% 输入文件txt格式：文件路径 目标(类别为0)的个数 x1 y1 x2 y2 x1 y1 x2 y2 ...
% 得到训练正样本.txt
PosImageFile='/media/han/E/mWork/data-dpm/nwpu-10/NWPU_train.txt'
fin = fopen(PosImageFile,'r');%打开正样本文件

fout=fopen('/media/han/E/mWork/data-dpm/nwpu-10/airplane.txt','w')
while ~feof(fin)
    line = fgetl(fin);
    num=0;
    line_save=[];
    S = regexp(line,' ','split');
    for k=2:size(S,2)
        boxinfo=str2num(S{k});
        if boxinfo(5)==0
            num=num+1;
            line_save=[num2str(boxinfo(1)) ' ' num2str(boxinfo(2)) ' ' num2str(boxinfo(3)) ' ' num2str(boxinfo(4)) ' ' line_save];
        end
    end
    if num>1
        line_save=[S{1} ' ' num2str(num) ' ' line_save];
        %         fwrite(fout,line_save);
        fprintf(fout,'%s\n',line_save);
        [S{1} ' ' num2str(num)]
    end
    
end
fclose(fin)
fclose(fout)

%% train
%训练
pascal('nwpu_airplane',3)

%训练bbox_pred
% bboxpred_train('nwpu_airplane')

%% detect
load('AerialImages/nwpu_airplane_final.mat');        % car model trained on the PASCAL 2007 dataset
figure(1),visualizemodel(model)

im = imread('cachedir/nwpu-10/pos/002.jpg');        % test image
bbox = process(im, model, -0.2);  % detect objects
figure(2),showboxes(im, bbox);              % display results

%% detect batch
load('/media/han/E/mWork/mCode/voc-dpm/cachedir/voc-dpm/2007/nwpu_final.mat');        % car model trained on the PASCAL 2007 dataset
% visualizemodel(model)

basename='/media/han/E/mWork/mCode/voc-dpm/cachedir/nwpu-10/pos/'
Files = dir(fullfile(basename,'*.jpg'));
for i=1:70
    im = imread(strcat(basename,Files(i).name));        % test image
    bbox = process(im, model, -0.3);  % detect objects
    figure(1),showboxes(im, bbox);
end

%% mat2opencvxml

fname_in = 'cachedir/voc-dpm/2007/nwpu_final.mat';
% fname_in = 'VOC2007/aeroplane_final.mat';
fname_out = ['mat2opencvxml/nwpu_airplane' '.xml'];
mat2opencvxml(fname_in, fname_out);
% mat2opencvxml_401(fname_in,fname_out);
