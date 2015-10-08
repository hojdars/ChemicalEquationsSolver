unit U_GaussianElimination;

interface
uses U_typeset, U_MatrixFunctions;

function RowReduce(var react_matrix : matrix_array; var solution : dynamic_array_LInt; m,n : longint) : byte;
// What : Reduces the matrix in almost-RREF by using integer operations. The matrix
//        is in it's base form (rows are reduced but not always 1)
// How  : Gauss-Jordan elimination.
//        While the matrix is not reduced (checked every time)
//        - it finds a pivot (partial pivotization is useless but can be turned on)
//        - it reduces the matrix
//        - and repeats.
//        ----
//        When it is done it checks if the equations have a solution
//        then reduces the rows (through the GreatCommDivisor)
//        counts the LCM of the pivots (used for back-substitution)
//        and substitutes back calculating the solution of the equations.

function GreatCommDivisor(a,b : longint) : longint;
// What : Finds the Greates Common Divisor of a and b. Used for integer operations with the matrix.
// How  : Euklidian algorithm.

implementation

function RowReduce(var react_matrix : matrix_array; var solution : dynamic_array_LInt; m,n : longint) : byte;
var NonBasicCol,                // which column is non-basic
    NonBasicColsNumber,         // how many non-basic columns are there
    coef_a, coef_b,             // coeficients used when eliminating
    gcd, lcm,                   // greatest common divisor and least common multiple
    i,j,k,l,                    // iteration variables, i and j being iteration for the whole
                                // elimination and k and l for sub-cycles
    swap_row,                   // which row do we swap
    swp_i,                      // iteration variable for swaping
    tmp,                        // temporary variable for switching
    swap_val : longint;         // Partial Pivotization only variable
    
    reduced,                    // Martix IS/IS NOT reduced
    search,                     // We FOUND/DID NOT FIND a pivot yet
    swap,                       // We ARE/ARE NOT swaping rows this time
    zero_sol : boolean;         // All the solutions ARE/ARE NOT zeros
    
    pivotsColIn,                       // Array of pivots, index is column, returns rows
    pivotsRowIn : array of integer;    // Array of pivots, index is rows, returns columns
begin
  { initialize variables }
  swap_row := 0;
  swap_val := 0;
  m := m-1; // indexing from zero
  n := n-1;
  search := true;
  reduced := false;
  zero_sol := false;
  swap := false;
  NonBasicColsNumber := 0;
  NonBasicCol := 0;
  
  { table of pivots' positions}
  setlength(pivotsColIn,n+1);
  setlength(pivotsRowIn,m+1);
  for l := 0 to n do begin
    pivotsColIn[l] := -1;
  end;
  for k := 0 to m do begin
    pivotsRowIn[k] := -1;
  end;
  
  { first step}
  i := 0;
  j := 0;
  k := 0; l := 0;
   
  while(reduced = false) do begin
    { second step - check if reduced}
    reduced := true;
    for k := i to m do begin
      for l := j to n do begin
        if(react_matrix[k][l] <> 0) then begin
          reduced := false;
          break;
        end;
      end;
      if(reduced = false) then break;
    end;
    { end the algorithm if finished}
    if(reduced) then break;
    
    { third step - find the pivot, no pivotization, improve with partial }
    k := 1; l := 1; search := true;
    for l := j to n do begin
      for k := i to m do begin
        if(react_matrix[k][l] <> 0) then begin
          j := l;           {this column has at least one pivot}
          search := false;
          swap := true;
          swap_row := k;
          //writeln('pivot is: ',k,j,' ',react_matrix[k][j]);
          break;  // found a pivot
          
        {  choosing which from which row to make a pivot }
        {  turn this on for partial pivotization }
        { if(swap_val < abs(react_matrix[k][l])) then begin
            swap_val := abs(react_matrix[k][l]); 
            swap_row := k;
            swap := true;              
          end; }
          
        end;
      end;
      if (search = false) then break;
    end;

//  Swap rows with chosen pivot
    if(swap) then begin
      swap := false;
      for swp_i := 0 to n do begin
        tmp := react_matrix[swap_row][swp_i];
        react_matrix[swap_row][swp_i] := react_matrix[i][swp_i];
        react_matrix[i][swp_i] := tmp;
      end;
    end;
    k := 0; l := 0;
//    eliminate all below pivot ([i][j] position) in Whole numbers
//    using GCD, LSM
//    Makes almost RREF, only diagonal is not only ones
//    Which avoids precision errors completely 
    pivotsColIn[j] := i;
    pivotsRowIn[i] := j;
    for k := 0 to m do begin
      if(k <> i) then begin
        if(react_matrix[k][j] <> 0) then begin
          gcd := GreatCommDivisor(react_matrix[i][j],react_matrix[k][j]);
          lcm := (abs(react_matrix[i][j] * react_matrix[k][j])) div gcd;
          coef_a := lcm div react_matrix[i][j];
          coef_b := lcm div react_matrix[k][j];
                    
          for l := 0 to n do begin
            react_matrix[k][l] := coef_b*react_matrix[k][l] - coef_a*react_matrix[i][l];  
          end;
        end;
      end;
    end;
    
    i := i + 1;
    j := j + 1;
  end; 
  
  for l := 0 to n do begin
    if(pivotsColIn[l] = -1) then begin
      NonBasicCol := l;
      Inc(NonBasicColsNumber);
    end; 
  end;
  
  { other than one parameter = not solvable }
  { print an error, exit the procedure back to main}
  if ((NonBasicColsNumber > 1)) then begin
    { This equation does not have a unique solution }
    RowReduce := 5;
    exit;
  end;
  
  if ((NonBasicColsNumber < 1)) then begin
    { This equations does not have a non-zero solution }
    RowReduce := 4;
    exit;
  end; 
  
  { reducing the equations by their respective GCD}
  for k := 0 to m do begin
    if(pivotsRowIn[k] <> -1) then begin
      gcd := GreatCommDivisor(react_matrix[k][pivotsRowIn[k]],react_matrix[k][NonBasicCol]);
      if((react_matrix[k][pivotsRowIn[k]] < 0) and (react_matrix[k][NonBasicCol] >= 0)) then begin
        react_matrix[k][pivotsRowIn[k]] := react_matrix[k][pivotsRowIn[k]] * -1;
        react_matrix[k][NonBasicCol] := react_matrix[k][NonBasicCol] * -1;
      end;
      react_matrix[k][pivotsRowIn[k]] := react_matrix[k][pivotsRowIn[k]] div gcd;
      react_matrix[k][NonBasicCol] := react_matrix[k][NonBasicCol] div gcd;
    end;    
  end;
  
  { finding the LCM of pivots for back substitution}
  k := 0;
  lcm := react_matrix[0][pivotsRowIn[0]];
  for k := 1 to (n-NonBasicColsNumber) do begin
    gcd := GreatCommDivisor(lcm, react_matrix[k][pivotsRowIn[k]]);
    lcm := (abs(lcm * react_matrix[k][pivotsRowIn[k]])) div gcd;
  end; 
  
 { Count the back-substitution and save to solutions}  
  k := 0;
  for k := 0 to m do begin
    if(pivotsRowIn[k] <> -1) then begin
      solution[k] := (react_matrix[k][NonBasicCol] * -1 * lcm ) div react_matrix[k][pivotsRowIn[k]] ;
      if(solution[k] = 0) then zero_sol := true;
    end;
  end;
  solution[NonBasicCol] := lcm;
  if(zero_sol = true) then RowReduce := 6   
  else RowReduce := 255;   // all is good
end;


function GreatCommDivisor(a,b : longint) : longint;
var t : longint;
begin
  { Eukleidian algorithm }
  while b <> 0 do
  begin
    t := a;
    a := b;
    b := t mod b;
  end;
  GreatCommDivisor := abs(a);
end;

end.

