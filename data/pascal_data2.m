function [pos, neg, impos] = pascal_data(cls, year)%这里为了保持一致没有改变，读者也可以自己修改
% Get training data from my own dataset
%   [pos, neg, impos] = pascal_data(cls, year)
%
% Return values
%   pos     Each positive example on its own
%   neg     Each negative image on its own
%   impos   Each positive image with a list of foreground boxes

%基地址路径
%added by yihanglou  using my own img and txtinfo
PosImageFile = '/media/han/E/mWork/data-dpm/nwpu-10/airplane.txt';
NegImageFile = '/media/han/E/mWork/data-dpm/nwpu-10/neg.txt';
BasePath = '/media/han/E/mWork/data-dpm/nwpu-10';

pos      = [];
impos    = [];
numpos   = 0;
numimpos = 0;
dataid   = 0;

fin = fopen(PosImageFile,'r');%打开正样本文件

now = 1;

while ~feof(fin)
    line = fgetl(fin);
    S = regexp(line,' ','split');
    count = str2num(S{2});
    fprintf('%s: parsing positives (%s): %d\n', ...
             cls, S{1}, now);
    now = now + 1;
    for i = 1:count;%挨个读取正样本
        numpos = numpos + 1;
        dataid = dataid + 1;
        bbox = [str2num(S{i*4-1}),str2num(S{i*4}),str2num(S{i*4+1}),str2num(S{i*4+2})];
        
        pos(numpos).im      = [BasePath '/' S{1}]; %拼接地址
        pos(numpos).x1      = bbox(1);
        pos(numpos).y1      = bbox(2);
        pos(numpos).x2      = bbox(3);
        pos(numpos).y2      = bbox(4);
        pos(numpos).boxes   = bbox;
        pos(numpos).flip    = false;
        pos(numpos).trunc   = 0;%1 represent incomplete objects, 0 is complete
        pos(numpos).dataids = dataid;
        pos(numpos).sizes   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
        
        img = imread([BasePath '/' S{1}]);
        [height, width, depth] = size(img);%由于我的样本里没有标定大小所以我要读取以下图像尺寸才能翻转
        
        % Create flipped example 创建翻转的正样本
        numpos  = numpos + 1;
        dataid  = dataid + 1;
        oldx1   = bbox(1);
        oldx2   = bbox(3);
        bbox(1) = width - oldx2 + 1;
        bbox(3) = width - oldx1 + 1;
        
        pos(numpos).im      = [BasePath '/' S{1}];
        pos(numpos).x1      = bbox(1);
        pos(numpos).y1      = bbox(2);
        pos(numpos).x2      = bbox(3);
        pos(numpos).y2      = bbox(4);
        pos(numpos).boxes   = bbox;
        pos(numpos).flip    = true;
        pos(numpos).trunc   = 0;% to make operation simple
        pos(numpos).dataids = dataid;
        pos(numpos).sizes   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);%获得图像面积大小   
        
    end
    
    % Create one entry per foreground image in the impos array，这里跟pos是一样的，相当于副本
    numimpos                = numimpos + 1;
    impos(numimpos).im      = [BasePath '/' S{1}];
    impos(numimpos).boxes   = zeros(count, 4);
    impos(numimpos).dataids = zeros(count, 1);
    impos(numimpos).sizes   = zeros(count, 1);
    impos(numimpos).flip    = false;
    
    for j = 1:count
        dataid = dataid + 1;
        bbox   = [str2num(S{j*4-1}),str2num(S{j*4}),str2num(S{j*4+1}),str2num(S{j*4+2})];
        
        impos(numimpos).boxes(j,:) = bbox;
        impos(numimpos).dataids(j) = dataid;
        impos(numimpos).sizes(j)   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
    end     
    
    img = imread([BasePath '/' S{1}]);
    [height, width, depth] = size(img);
    
     % Create flipped example
    numimpos                = numimpos + 1;
    impos(numimpos).im      = [BasePath '/' S{1}];
    impos(numimpos).boxes   = zeros(count, 4);
    impos(numimpos).dataids = zeros(count, 1);
    impos(numimpos).sizes   = zeros(count, 1);
    impos(numimpos).flip    = true;
    unflipped_boxes         = impos(numimpos-1).boxes;
    
    
    for j = 1:count
    dataid  = dataid + 1;
    bbox    = unflipped_boxes(j,:);
    oldx1   = bbox(1);
    oldx2   = bbox(3);
    bbox(1) = width - oldx2 + 1;
    bbox(3) = width - oldx1 + 1;

    impos(numimpos).boxes(j,:) = bbox;
    impos(numimpos).dataids(j) = dataid;
    impos(numimpos).sizes(j)   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
    end
end

fclose(fin);
% Negative examples from the background dataset

fin2 = fopen(NegImageFile,'r');
neg    = [];
numneg = 0;
negnow = 0;
while ~feof(fin2)%这里是循环读取副样本
     line = fgetl(fin2);
     fprintf('%s: parsing Negtives (%s): %d\n', ...
                   cls, line, negnow);
     
     negnow             = negnow +1;
     dataid             = dataid + 1;
     numneg             = numneg+1;
     neg(numneg).im     = [BasePath '/' line];
     disp(neg(numneg).im);
     neg(numneg).flip   = false;
     neg(numneg).dataid = dataid;
 end
 
 fclose(fin2);%存储为mat文件 包含训练样本的信息
%  save([cachedir cls '_' dataset_fg '_' year], 'pos', 'neg', 'impos');