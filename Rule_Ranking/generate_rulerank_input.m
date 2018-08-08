% Script that reads in the rules generated for classes 1 and 0, and 
% prepares the input file used for ranking by initializing all of the
% parameters and variables.

clear all;
dataset_name = sprintf('tictactoe_binary_train12');

filename_suffix = sprintf('');

Dataset = load(sprintf('../Datasets/processed/%s.txt', dataset_name));
one_rules = load(sprintf('../Rule_Generation/rules/%s_rules_one%s.txt', dataset_name,filename_suffix));
zero_rules = load(sprintf('../Rule_Generation/rules/%s_rules_zero%s.txt', dataset_name,filename_suffix));

out_filename = sprintf('rules/%s_rank_input%s.dat',dataset_name,filename_suffix);
out_filename2 = sprintf('../Rule_Generation/rules/%s_rules_all%s.txt', dataset_name, filename_suffix);

initialize_vars = 1;

Labels = Dataset(:,end);
Dataset = Dataset(:,1:end-1);

m = size(Dataset,1);
N = size(Dataset,2);

num_one_rules = size(one_rules, 1);
num_zero_rules = size(zero_rules, 1);

% Combine the one and zero rules. Put the default rules (->1 and ->0) at top.
Rules_X = [zeros(1,N); zeros(1,N); one_rules; zero_rules];
Rules_Y = [1 0 ones(1,num_one_rules) zeros(1,num_zero_rules)]';
R = length(Rules_Y);

TmpDataset = Dataset;
TmpLabels = Labels;
num_ranked_rules = 0;
rule_ranks = 10000.*ones(R,1);
while(1)
   prob_vec = zeros(R,1);
   support_vec = zeros(R,1);
   % Find the conditional probability and support of all rules.
   for rule_ind=1:R
     nonzero_ind = find(Rules_X(rule_ind,:));
     if isempty(nonzero_ind)
       rule_apply_ind = 1:length(TmpLabels);
     else
       rule_apply_ind = find(prod(TmpDataset(:,nonzero_ind),2));
     end
     
     num_label_match = length(find(TmpLabels(rule_apply_ind) == Rules_Y(rule_ind)));

     if isempty(rule_apply_ind)
       prob_vec(rule_ind) = 0;
     else
       prob_vec(rule_ind) = num_label_match/length(rule_apply_ind);
     end

     support_vec(rule_ind) = num_label_match; %length(rule_apply_ind);
   end
   
   [~,sorted_rule_ind] = sortrows([prob_vec,support_vec],[-1 -2]);
   best_rule_ind = -1;
   for i=1:length(sorted_rule_ind)
     if rule_ranks(sorted_rule_ind(i)) == 10000
       best_rule_ind = sorted_rule_ind(i);
       break;
     end
   end
   num_ranked_rules = num_ranked_rules + 1;
   rule_ranks(best_rule_ind) = num_ranked_rules;
   
   % Remove these examples from the dataset
   nonzero_ind = find(Rules_X(best_rule_ind,:));
   if isempty(nonzero_ind)
     rule_apply_ind = find(TmpLabels == Rules_Y(best_rule_ind));
   else
     rule_apply_ind = find(prod(TmpDataset(:,nonzero_ind),2) & TmpLabels == Rules_Y(best_rule_ind));
   end

   TmpDataset(rule_apply_ind,:)=[];
   TmpLabels(rule_apply_ind)=[];
   if isempty(TmpLabels) || num_ranked_rules == R || isempty(rule_apply_ind)
     break;
   end
end

if num_ranked_rules < R
  unranked_rule_ind = find(rule_ranks == 10000);
  rule_ranks(unranked_rule_ind) = num_ranked_rules+1:R;
end

if initialize_vars
  [~,val] = sort(rule_ranks);
  Rules_X = Rules_X(val,:);
  Rules_Y = Rules_Y(val);
end

S = sum(Rules_X');

% Find null1 and null0.
default_rule_ind = find(S == 0);
if Rules_Y(default_rule_ind(1)) == 1
  null1 = default_rule_ind(1);
  null0 = default_rule_ind(2);
else
  null0 = default_rule_ind(1);
  null1 = default_rule_ind(2);    
end

C=1/R; % Set to 1/#rules
C1=1/R;


% Populate applies matrix A. A[i,r] is 1 if rule r applies to observation i
A = zeros(m,R);
for i=1:m
  for r=1:R
    nonzero_ind = find(Rules_X(r,:));
    if isempty(nonzero_ind)
      % Default rule... Always applies
      A(i,r) = 1;
    elseif prod(Dataset(i,nonzero_ind)) == 1
      % All of the items in the rule are 1 for this observation (Applies). 
      A(i,r) = 1;
    end
  end
end

% Populate M. M[i,r] is 1 if rule r applies & Label agrees
%                      -1 if rule r applies & Label disagrees
%                       0 if rule r does not apply
M = zeros(m,R);
d = zeros(m,R);
h = zeros(m,1);
for i=1:m
  should_set_d_h = 1;
  for r=1:R
    nonzero_ind = find(Rules_X(r,:));
    if isempty(nonzero_ind) || prod(Dataset(i,nonzero_ind)) == 1
      % Rule applies. Set to 1 or -1 depending on consequent match.
      M(i,r) = 2*(Labels(i) == Rules_Y(r)) - 1;
      if should_set_d_h == 1
        d(i,r) = 1;
        h(i,1) = R-r+1;
        should_set_d_h = 0;
      end
    end
  end
end


fid = fopen(out_filename,'w');
fprintf(fid,sprintf('param m:=%d;\n\n',m));
fprintf(fid,sprintf('param R:=%d;\n\n',R));
fprintf(fid,sprintf('param C:=%g;\n\n',C));
fprintf(fid,sprintf('param C1:=%g;\n\n',C1));
fprintf(fid,sprintf('param null1:=%d;\n\n',null1));
fprintf(fid,sprintf('param null0:=%d;\n\n',null0));

% WRITE A;
fprintf(fid,'param A : ');
fprintf(fid, '%d ', 1:R);
fprintf(fid, ':= \n');
fclose(fid);
first_col = 1:m;
A = [first_col' A];
dlmwrite(out_filename, A, '-append', 'delimiter', ' ');
fid = fopen(out_filename,'a');
fprintf(fid,';\n\n');


% WRITE M;
fprintf(fid,'param M : ');
fprintf(fid, '%d ', 1:R);
fprintf(fid, ':= \n');
fclose(fid);
first_col = 1:m;
M = [first_col' M];
dlmwrite(out_filename, M, '-append', 'delimiter', ' ');
fid = fopen(out_filename,'a');
fprintf(fid,';\n\n');


% WRITE S;
fprintf(fid,'param S := ');
fclose(fid);
first_col = 1:R;
S = [first_col' S'];
dlmwrite(out_filename, S, '-append', 'delimiter', ' ');
fid = fopen(out_filename,'a');
fprintf(fid,';\n\n');

fprintf(fid,'let {i in 1..R} pi[i] := R-i+1;\n');

list_length = min(null0, null1);
pi_tilde = R - list_length + 1;

if initialize_vars
  fprintf(fid,sprintf('let {i in 1..%d} l[i] := 1;\n', list_length));
  fprintf(fid,sprintf('let {i in %d..R} l[i] := 0;\n',list_length+1));
  fprintf(fid,sprintf('let pi_tilde := %d;\n', pi_tilde));

  for i=1:m
    fprintf(fid,sprintf('let h[%g] := %g;\n',i,h(i,1)));
  end

  for i=1:m
    for r=1:R
      fprintf(fid,sprintf('let d[%g,%g] := %g;\n',i,r,d(i,r)));
    end
  end
end

fclose(fid);

% Write Rules (to be used for computing accuracy).
Rules = [Rules_X Rules_Y];
dlmwrite(out_filename2, Rules, ' ');
