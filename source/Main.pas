{   *****************************   }
{   Vyèíslování chemických rovnic   }
{   Štìpán Hojdar                   }
{   Zimní semestr 2014/2015         }
{   Programování NPRG030            }
{   *****************************   }

Program Rovnice;

uses  U_Typeset,               // types declared
      U_ListFunctions,         // List, Stack functions (and IsNumber, IsLower and IsUpper)
      U_Association,           // functions for associating elements and tokenizing
      U_MatrixFunctions,       // functions that make a matrix out of tokens
      U_GaussianElimination;   // finding the matrix solutions
  
var 
  zero_sols,                // how many zeros are there in the solution
  i,                        // iteration for basic main cycles
  number_elem,              // the guessed number of elements (is maximum)
  exact_el,                 // the exact number of elements
  exact_react,              // the exact number of reactatns (both right and left side)
  ReactOnLeft : longint;    // reactants on the left - products
  
  FillListReturnValue,      // return value of the function FillList
  result : byte;            // return value of row-reducing procedure 
  
  associate : dynamic_array_str;      // dynamicaly sized array of associations
  matrix : matrix_array;              // the matrix of the equation
  solution : dynamic_array_LInt;      // dynamicaly sized array of the solution
  
  PList_Dispose,       // iteration pointer for disposing the list 
  PList_Iter,         // iteration pointer for printing the list
  listS,              // pointer at the start of the list (for printing)
  listL : PItem;      // pointer at the end of the list (for pushing)
  
  stackS,             // pointer at the start of the stack (for printing)
  stackL : PStack;    // pointer at the end of the stack (for pushing)

begin
  { Initiate string list }
  new(ListS);
  ListS^.val := 'nop';
  ListS^.next := nil;
  ListL := ListS;
  
  { Initiate stack }
  new(StackS);
  StackS^.val := -31000;
  StackS^.last := nil;
  StackS^.next := nil;
  StackL := StackS;
  
  { Unknown number of reactatns, elements, zeros}  
  exact_el := 0;
  exact_react := 0;
  number_elem := 0;
  zero_sols := 0;
  
  { Write instructions on screen }
  Writeln;
  Writeln('Chemical equations');
  Writeln('------------------');
  Writeln('Please write a chemical equation to solve.');
  Writeln('End the equation with a period.');
  Writeln('Example of an equation: H2S + H2SO3 = S + H2O.');
  Writeln;Write(' >> ');  
    
  { Load list with chemicals, in unity ListFunctions }
  FillListReturnValue := FillList(exact_react, number_elem, ListL,ReactOnLeft);
  
  { Format }
  Writeln;
  Writeln('===============================================');
  
  { Check for all kinds of errors, if none occured then }
  { print out the result, max of elements }
  if(FillListReturnValue = 20) then begin
    Writeln;
    write('OK _ INPUT :: ');
    PrintOut(ListS);
    writeln('     Maximum number of elements: ', number_elem);
  end
  else if(FillListReturnValue = 10) then begin
    Writeln;
    WriteLn(' >> You did not provide reactants! Ending.');
    exit;
  end
  else if(FillListReturnValue = 12) then begin
    Writeln;
    WriteLn(' >> You did not provide any products! Ending.');
    exit;
  end
  else if(FillListReturnValue = 14) then begin
    Writeln;
    WriteLn(' >> You did not provide any (no reactant starts with a capital letter)! Ending.');
    exit;
  end;

  { Field of associations, dynamicly set   }
  { lenght to estimated number of elements }
  { in unity Associations } 
  InitAssocField(associate, number_elem);
                                              
  { Associating numbers to elements }
  { in unity Associations } 
  AssociateElements(ListS, associate, exact_el, number_elem);
  Write('OK _ ASSOC :: ');
  for i := 0 to length(associate) do Write(associate[i], ' ');  
  Writeln;
  Writeln('     Exact elements  : ',exact_el);
  Writeln('     Exact reactants : ',exact_react);
  
  { Initialize matrix and solution table }
  { in unity MatrixFunctions } 
  InitializeMatrix(matrix, exact_el, exact_react);
  setlength(solution,exact_react);
  
  { Tokenize each reactant, make a stack, then fill the matrix }
  { in unity MatrixFunctions }
  FillMatrix(matrix, associate, exact_el, exact_react, StackL, ListS,ReactOnLeft);
  
  { Row Reduce and Back Substitute }
  { in unity GaussianElimination }
  result := RowReduce(matrix, solution, exact_el, exact_react);
  writeln('OK _ Elimination successful');
  PrintMatrix(matrix,exact_el, exact_react);
  Writeln;
  
  { Print-out the result }
  i := 0;
  PList_Iter := ListS^.next;
  Writeln('===============================================');

  Writeln; Write(' >> ');
  
  if(result = 255) then begin
    for i := 0 to exact_react-1 do begin
      Write(solution[i],' ',PList_Iter^.val);
      PList_Iter := PList_Iter^.next;
      if ((i <> ReactOnLeft-1) and (i <> exact_react-1)) then write(' + ');   // printing the '+' between
      if (i = ReactOnLeft-1) then write(' = ');       // printing the '=' in the correct place
    end;
   end
   else if (result = 5) then Write('This equation does not have a unique solution')
   else if (result = 4) then Write('This equation does not have a non-zero solution')   
  else if (result = 6) then begin
    for i := 0 to exact_react-1 do begin
      Write(solution[i],' ',PList_Iter^.val);
      if(solution[i] = 0) then Inc(zero_sols); 
      PList_Iter := PList_Iter^.next;
      if ((i <> ReactOnLeft-1) and (i <> exact_react-1)) then write(' + ');   // printing the '+' between
      if (i = ReactOnLeft-1) then write(' = ');       // printing the '=' in the correct place
    end;
    Writeln;  Write(' >> ');
    
    Write('Warning: ',zero_sols,' coeficients are zeros.');
  end;
  WriteLn;WriteLn;
  
  { Dispose allocated memory }
  { the stack }
  dispose(StackS); // Stack is empty, so the only element is the start
  
  { the list }
  PList_Iter := ListS;
  while(PList_Iter <> nil) do begin
    PList_Dispose := PList_Iter;
    PList_Iter := PList_Iter^.next;
    dispose(PList_Dispose); 
  end;
  
end.