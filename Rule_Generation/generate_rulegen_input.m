clear all;

RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

dataset_name = sprintf('haberman');
Dataset = load(sprintf('../Datasets/%s.csv', dataset_name));

% Randomly shuffle examples (Since in some datasets, the examples are
% ordered; ones first, zeros second.

num_examples = size(Dataset,1);

r = randperm(num_examples);
Dataset = Dataset(r,:);

Labels = Dataset(:,end);
Dataset = Dataset(:,1:end-1);

fold_size = floor(num_examples/3);

for i=1:3
  if i == 1
    test_examples = 1:fold_size;
    train_filename = sprintf('../Datasets/processed/%s_train23.dat',dataset_name);
    train_filename_noampl = sprintf('../Datasets/processed/%s_train23.txt',dataset_name);
    test_filename = sprintf('../Datasets/processed/%s_test_for_23.txt',dataset_name);
  elseif i == 2
    test_examples = fold_size+1:2*fold_size;
    train_filename = sprintf('../Datasets/processed/%s_train13.dat',dataset_name);
    train_filename_noampl = sprintf('../Datasets/processed/%s_train13.txt',dataset_name);
    test_filename = sprintf('../Datasets/processed/%s_test_for_13.txt',dataset_name);
  else
    test_examples = (2*fold_size + 1):num_examples;    
    train_filename = sprintf('../Datasets/processed/%s_train12.dat',dataset_name);
    train_filename_noampl = sprintf('../Datasets/processed/%s_train12.txt',dataset_name);
    test_filename = sprintf('../Datasets/processed/%s_test_for_12.txt',dataset_name);
  end
  
  train_examples = setdiff(1:num_examples, test_examples);
  TrainX = Dataset(train_examples,:);
  TrainY = Labels(train_examples);
  TestX = Dataset(test_examples,:);
  TestY = Labels(test_examples);
  
  Sone  = find(TrainY == 1);
  Szero = find(TrainY == 0);
  
  fid = fopen(train_filename,'w');

  % Write Sone
  fprintf(fid,'set Sone := ');
  fprintf(fid,'%d ', Sone');
  fprintf(fid,';\n\n');

  % Write Szero
  fprintf(fid,'set Szero := ');
  fprintf(fid,'%d ', Szero');
  fprintf(fid,';\n\n');

  fprintf(fid,'param m := %d;\n\n', length(TrainY)); % Num examples
  fprintf(fid,'param N := %d;\n\n', size(TrainX, 2)); % Num features

  fprintf(fid,'param U : ');
  fprintf(fid, '%d ', 1:size(TrainX, 2)); % Column Header 1..N
  fprintf(fid, ':= \n');

  fclose(fid);
  first_col = 1:length(TrainY);
  TrainX_with_row_numbers = [first_col' TrainX]; % Set row header

  dlmwrite(train_filename, TrainX_with_row_numbers, '-append', 'delimiter', ' ');

  % Append ";" to the file
  fid = fopen(train_filename,'a');
  fprintf(fid,';');
  fclose(fid);

  % Write test file to output
  Test = [TestX TestY];
  dlmwrite(test_filename, Test, 'delimiter', ' ');  

  % Write regular (non-ampl format) train file to output. We'll use it for
  % generating the input files for ranking.
  Train = [TrainX TrainY];
  dlmwrite(train_filename_noampl, Train, 'delimiter', ' ');  
end
