% Prints the accuracy on the supplied set. Below, you can change Test matrix to the
% training set or test set. The dataset_name, split and suffix variables need
% to be adjusted based on the experiment settings.

clear all;

dataset_name = sprintf('tictactoe_binary');
split = sprintf('12');
suffix = sprintf('1divR_C1_1divR_');

% Load rules in original order
Rules = load(sprintf('../Rule_Generation/rules/%s_train%s_rules_all.txt', dataset_name,split));

% Load rule ranks
RuleRanks = load(sprintf('rules/%s_train%s_rank_output_%s.dat', dataset_name, split, suffix));

% Load test set
%Test = load(sprintf('../Datasets/processed/%s_train%s.txt', dataset_name, split));
Test = load(sprintf('../Datasets/processed/%s_test_for_%s.txt', dataset_name, split));

Test_X = Test(:,1:end-1);
Test_Y = Test(:,end);

% Reorder the rules according to the computed ranks.
[val,ind] = sort(RuleRanks, 'descend');
Rules = Rules(ind,:);

Rules_X = Rules(:,1:end-1);
Rules_Y = Rules(:,end);

m = size(Test,1);
R = size(Rules,1);

rule_sizes = sum(Rules_X');

num_correct = 0;

for i=1:m
  for r=1:R
    nonzero_ind = find(Rules_X(r,:)); % Find the items in this rule.
    if isempty(nonzero_ind) || prod(Test_X(i,nonzero_ind)) == 1
    % Rule applies to this test example;
      if Test_Y(i) == Rules_Y(r)
        num_correct = num_correct + 1;
      end
      break;
    end
  end
end

Accuracy = num_correct/m

