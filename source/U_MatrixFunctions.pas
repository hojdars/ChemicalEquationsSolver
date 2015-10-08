unit U_MatrixFunctions;

interface
uses U_Typeset,U_ListFunctions,U_Association;

procedure InitializeMatrix(var mat : matrix_array; w,l : longint);
// What : Initializes the matrix, sets it's length, all it's elements sets to zero

procedure PrintMatrix(const mat : matrix_array; w,l : longint);
// What : Prints the matrix.

procedure FillCol(var mat : matrix_array; w,l : longint; 
                  var StackL : PStack; col_num : longint;ReactOrProduct : integer);
// What : Fills one column (which means one variable = reactant) of the matrix
//        with appropriate numbers.
// How  : Goes through the stack popping, if it finds a positive or a negative number
//        (positive are elements, negative are "numbers") and makes the appropriate
//        changes to the matrix. For more see documentation on tokenizing.
//        ReactOrProduct determines if the string is on the left or on the right
//        side of the equation.

procedure FillMatrix(var mat : matrix_array; var assoc_field : dynamic_array_str;
          e_elem,e_react : longint; StackL : PStack; ListS : PItem; ReactOnLeft : longint );
// What : Fills the whole matrix with numbers coresponging to the equation.
// How  : Goes through the list of reactatns, calls for tokenization then immediately
//        calls for FillCol. Repeats for the whole list.          
implementation

procedure InitializeMatrix(var mat : matrix_array; w,l : longint);
var m,n : longint;
begin
  setlength(mat,w,l);
  m := 0;
  n := 0;
  for m := 0 to (w-1) do begin
    for n := 0 to (l-1) do begin
      mat[m][n] := 0;
    end;
  end;
  writeln('OK _ Matrix intialized') 
end;

procedure PrintMatrix(const mat : matrix_array; w,l : longint);
var m,n : longint;
begin
  m := 0;
  n := 0;
  WriteLn;
  for m := 0 to (w-1) do begin
    for n := 0 to (l-1) do begin
      Write(mat[m][n],' ');
    end;
    Writeln;
  end;
end;


procedure FillCol(var mat : matrix_array; w,l : longint; 
                    var StackL : PStack; col_num : longint; ReactOrProduct : integer);
var tmp, mul, next, current : longint;
    TmpStackL : PStack;
begin
  mul := 1;  { multiplying by one, not zero! }
  next := 1;
  current := 0;
  new(TmpStackL);
  TmpStackL^.val := -31000;
  TmpStackL^.last := nil;
  TmpStackL^.next := nil;
  
  current := PopEnd(StackL);
  while(current <> -31000) do begin
    if(current < 0) then begin
      if current = -32000 then begin 
        tmp := PopEnd(TmpStackL);
        mul := mul div tmp;
        tmp := 0;
      end
      else next := (-1)*current;
    end
    
    else if(current >= 0) then begin
      if current = 32000 then begin
        tmp := PopEnd(StackL);
        mul := mul*(-1)*tmp;
        PushEnd((-1*tmp),TmpStackL);
        tmp := 0;
      end
      else begin 
        mat[current][col_num] := mat[current][col_num] + mul*next*ReactOrProduct;
        next := 1;
      end; 
    end;
    
    current := PopEnd(StackL);
  end;
  dispose(TmpStackL);
end;


procedure FillMatrix(var mat : matrix_array; var assoc_field : dynamic_array_str;
                           e_elem,e_react : longint; StackL : PStack; 
                            ListS : PItem; ReactOnLeft : longint);
var react : PItem;
        i,LeftOrRight : longint;

begin
  react := ListS^.next;
  i := 0;  
  while react <> nil do begin
    TokenizeString(react^.val, assoc_field, e_elem, StackL);
    
    if(i < ReactOnLeft) then LeftOrRight := 1
                        else LeftOrRight := -1;
    
    FillCol(mat,e_elem, e_react, StackL, i,LeftOrRight);
    
    react := react^.next;
    i := i+1;
  end;
  
  WriteLn('OK _ Matrix fill completed');
end;                           

end.