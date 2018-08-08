#!/bin/bash  
# Shell script to run the sequence of codes to generate and rank rules for the Haberman's Survival dataset.

cd Rule_Generation
# Generate rules for the one class for the specified dataset in the code (haberman by default)
ampl GenerateRules.sa

# In-place modify the files so that it generates rules for zero class and updates output filenames.
sed -i.bak 's/_one/_zero/g' GenerateRules.sa
sed -i.bak 's/Sone/Szero/g' GenerateRules.sa
sed -i.bak 's/_one/_zero/g' AddRule.sa

ampl GenerateRules.sa

# Undo the changes to .sa files.
sed -i.bak 's/_zero/_one/g' GenerateRules.sa
sed -i.bak 's/Szero/Sone/g' GenerateRules.sa
sed -i.bak 's/_zero/_one/g' AddRule.sa

# Here, one and zero class rules are generated. Combine them and generate the input ampl data for ranking.
cd ../Rule_Ranking
sed -i.bak 's/tictactoe/haberman/g' generate_rulerank_input.m # change all references to haberman.
sed -i.bak 's/initialize_vars = .*/initialize_vars = 1;/g' generate_rulerank_input.m # initialize for efficiency.
matlab -nodisplay -nodesktop -r "run generate_rulerank_input.m;quit;" # run code.

# Set the C param (and the filename suffixes) in rule ranking script to 1/4
sed -i.bak 's/tictactoe/haberman/g' RankRules.sa # change all references to haberman
sed -i.bak 's/let C := .*/let C := 1\/4;/g' RankRules.sa # set C=1/4
sed -i.bak 's/_1divR_C1/_1div4_C1/g' RankRules.sa # set log filename
# Run rule ranking algorithm
ampl RankRules.sa

# Set the vars to Haberman's settings and check the ranking of the rules.
sed -i.bak "s/dataset_name = .*/dataset_name = 'haberman_binary';/" print_ranked_rules.m # set dataset
sed -i.bak "s/suffix = .*/suffix = '1div4_C1_1divR_';/" print_ranked_rules.m # set filename suffix
sed -i.bak "s/^rule_names = .*/rule_names = haberman_rule_names;/" print_ranked_rules.m # set rule names for display

matlab -nodisplay -nodesktop -r "run print_ranked_rules.m;quit;" # run code.