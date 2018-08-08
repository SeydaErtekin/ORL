
param m;  # Number of observations.
param R;  # Total number of rules available.

param C; # Regularization Parameter.
param C1; # Regularization parameter 2.
param null1 >=0; # Height of the default rule {} => +1
param null0 >=0; # Height of the default rule {} => -1

# Matrix of size m x R. M[i,r] is:
#  1 if rule r applies to observation i and RHS agrees with y_i,
# -1 if rule r applies to observation i and RHS disagrees with y_i,
#  0 if rule r does not apply to observation i.
param M{i in 1..m, r in 1..R};

# Applies matrix of size  m x R. 
# A[i,r] is 1 if rule r applies to observation i.
param A{i in 1..m, r in 1..R};

# Size of each rule. R x 1 
param S{1..R};

# Permutation of rules of length R. The entry pi[r] is the 
# position (height) of rule r in the list.
var pi{r in 1..R} in {1..R}; 

# For each observation, stores the height of the rule that makes
# the decision. h[i] is the height of the rule that makes the
# prediction for observation i.
var h{1..m} >=1, <=R;

# Deciding rule matrix of size m x R. d[i,r] is 1 if rule r is 
# the first rule that makes the prediction for observation i.
var d{i in 1..m, r in 1..R} binary;  
   
# Indicator matrix that encodes which rule is assigned to which 
# position in pi vector. 
var delta{r in 1..R, j in 1..R} binary;
                
# Height of the highest default rule.
var pi_tilde in {1..R};

var gamma_plus >=0, <= 1;
var gamma_minus binary;

# indicates if pi[r] > pi_tilde (if the rule is in the list)
var l{1..R} binary;

# Objective and constraints on page 6.
maximize Objective : (1/2)*(m + (sum {i in 1..m, r in 1..R} M[i,r]*d[i,r])) + C*pi_tilde - C1*sum {r in 1..R} S[r]*l[r];

subject to height1{i in 1..m, r in 1..R}:
    h[i] >= A[i,r]*pi[r];

subject to height2{i in 1..m, r in 1..R}:
    h[i] <= A[i,r]*pi[r] + R*(1 - d[i,r]);

subject to decisionrule1{i in 1..m}:
    sum{r in 1..R} d[i,r] = 1;

subject to decisionrule2{i in 1..m, r in 1..R}:
    d[i,r] >= 1 - h[i] + A[i,r]*pi[r];

subject to decisionrule3{i in 1..m, r in 1..R}:
    d[i,r] <= A[i,r];

subject to pi1{r in 1..R}:
    pi[r] = (sum{j in 1..R} j*delta[r,j]);

subject to piconstr1:
    pi_tilde - pi[null1] <= (R - 1)*gamma_plus;

subject to piconstr2: 
    pi[null1] - pi_tilde <= (R - 1)*gamma_plus;

subject to piconstr3: 
    pi_tilde - pi[null0] <= (R - 1)*gamma_minus;

subject to piconstr4: 
    pi[null0] - pi_tilde <= (R - 1)*gamma_minus; 

subject to gamma1:
    gamma_plus + gamma_minus = 1;

subject to pitilde1: 
    pi_tilde >= pi[null1];

subject to pitilde2:
    pi_tilde >= pi[null0];

subject to decisionrule4{i in 1..m, r in 1..R}:
    d[i,r] <= 1 - (pi_tilde - pi[r])/(R - 1);

subject to delta1{r in 1..R}:
    sum{j in 1..R} delta[r,j] = 1;

subject to delta2{j in 1..R}:
    sum{r in 1..R} delta[r,j] = 1;

subject to pi2{r in 1..R}: 
    pi[r] - pi_tilde <= (R - 1)*l[r];

