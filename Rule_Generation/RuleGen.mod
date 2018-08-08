# Objective and constraints for Rule Generation.
set S;
set Szero;
set Sone;

param Acurrent;
param SparsityThreshold;
param m;
param N; 

param RuleSupThreshold;

param U {i in 1..m, j in 1..N};

param num_infeasible_rules;
param ir {i in 1..num_infeasible_rules, j in 1..N};
param C {i in 1..num_infeasible_rules};

var alpha {i in 1..N} binary;
var a {i in 1..m} >=0, <=1;

maximize objective:
    (sum {i in S} a[i]);
	
subject to Constraint1:
    sum {i in 1..m} a[i] <= Acurrent;
	
subject to Constraint2:
    sum {j in 1..N} alpha[j] <= SparsityThreshold;

subject to Constraint3:
    sum {i in S} a[i] >= RuleSupThreshold;

subject to Constraint4 {i in 1..m, j in 1..N}:
    a[i] <= 1 + (U[i,j]-1)*alpha[j];
	
subject to Constraint5 {i in 1..m}:
    a[i] >= 1 + (sum {j in 1..N} (U[i,j]-1)*alpha[j]);
	
subject to ExtraConstraints {i in 1..num_infeasible_rules}:
    (sum {j in 1..N} ir[i,j]*alpha[j]) + C[i] >= 1;