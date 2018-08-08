#!/bin/bash
# Shell script to run the sequence of codes to rank the toy ruleset for the TicTacToe dataset.

cd ./Rule_Ranking
# One and zero class rules are generated. Combine them and generate the input ampl data for ranking.
sed -i.bak 's/haberman/tictactoe/g' generate_rulerank_input.m # change all references to tictactoe. 
sed -i.bak 's/initialize_vars = .*/initialize_vars = 0;/g' generate_rulerank_input.m  # initialization not necessary for toy ruleset.
matlab -nodisplay -nodesktop -r "run generate_rulerank_input.m;quit;"

# Set the C param (and the filename suffixes) in rule ranking script to 1/R
sed -i.bak 's/haberman/tictactoe/g' RankRules.sa # change all references to tictactoe.
sed -i.bak 's/let C := .*/let C := 1\/R;/g' RankRules.sa  # set C=1/R 
sed -i.bak 's/_1div4_C1/_1divR_C1/g' RankRules.sa # set log filename
# Run rule ranking algorithm
ampl RankRules.sa

# Set the vars to TicTacToe's settings and check the ranking of the rules.
sed -i.bak "s/dataset_name = .*/dataset_name = 'tictactoe_binary';/" print_ranked_rules.m # set dataset   
sed -i.bak "s/suffix = .*/suffix = '1divR_C1_1divR_';/" print_ranked_rules.m # set filename suffix 
sed -i.bak "s/^rule_names = .*/rule_names = tictactoe_rule_names;/" print_ranked_rules.m # set rule names for display
matlab -nodisplay -nodesktop -r "run print_ranked_rules.m;quit;" # run code.
