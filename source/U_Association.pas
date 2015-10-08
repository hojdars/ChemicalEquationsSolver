unit U_Association;

interface
uses U_Typeset, U_ListFunctions;

procedure InitAssocField(var assoc_field : dynamic_array_str; len : longint);
// What : Initiates the association field with '-', sets it's length
//        to the estimated number of elements.

procedure AssocOne(buffer : string; var assoc_field : dynamic_array_str;
                    var exact_elem : longint; num_elem : longint);
// What : Finds the element in the association array if it is already associated 
//        else associates it into the first blank space.
// How  : Goes the the array, checking if we are searching in the valid
//        range and if we reach the end of valid range (indicated by length/'-' signs)
//        we associate a new element (add it at first blank spot) and increment
//        the exact number of elements
                    
procedure AssociateElements(start : PItem; var assoc_field : dynamic_array_str;
                    var exact_elem : longint; num_elem : longint); 
// What : fills the whole association field, finds all the elements and through
//        AssocOne it counts how many elements there exactly are (exact_el)
// How  : Goes through the list, each reactant char by char. When it finds 
//        a whole elemenet (whole element ends with a number, an uppercase letter
//        or parentheses, it calls AssocOne thus associates it.
                                          
function FindAssoc(assoc_field : dynamic_array_str; exact_elem : longint; elem : string) : longint;
// What : Finds the association of an element, returns the positionin the array
//        if found and -1 if not found

procedure TokenizeString(S : string; assoc_field : dynamic_array_str;
                          exact_elem : longint; var StackL : PStack);
// What : Tokenizes given string into the stack, for complete details see documentation on tokenizing.
// How  : Goes through the string char by char, looking for UpperCases, parentheses
//        numbers, makes the appropriate pushes into the stack. 
                     
implementation

{ initialization of assoc field}
procedure InitAssocField(var assoc_field : dynamic_array_str; len : longint);
var i : longint;
begin
  setlength(assoc_field,len); 
  for i := 0 to len-1 do begin
    assoc_field[i] := '-';
  end;
  writeln('OK _ ASSOC INIT');
end;

procedure AssocOne(buffer : string; var assoc_field : dynamic_array_str;
                    var exact_elem : longint; num_elem : longint);
var i_f : longint;
begin
  i_f := 0;
  while( (assoc_field[i_f] <> buffer) and     // while we are searching in some data (and not '-'s)
      (assoc_field[i_f] <> '-')) do  begin
        if i_f < num_elem then Inc(i_f)
        else begin i_f := -1; break; end;
  end;
  if ( (i_f <> -1) and (assoc_field[i_f] = '-') ) then begin  // if we didnt find it, associate it at the end
    assoc_field[i_f] := buffer;
    Inc(exact_elem);  // and we found a new element!
  end;
end;

procedure AssociateElements(start : PItem; var assoc_field : dynamic_array_str;
                    var exact_elem : longint; num_elem : longint);
var 
   S,buffer : String;
   i : longint;
   i_lst : PItem;
begin
  i_lst := start^.next;
  while i_lst <> nil do begin
    S := i_lst^.val;
    buffer := S[1];
    if(IsUpper(S[1]) = false) then begin
      WriteLn('Reactant > ',S,' < does not begin with capital letter!');
      WriteLn('Ending');
      halt;
    end;
    for i := 2 to length(S) do begin
      if ((IsLower(S[i])) and (buffer <> '')) then begin
        buffer := buffer + S[i];
      end
      else if ((IsUpper(S[i])) or (IsNumber(S[i])) or (S[i] = '(') or (S[i] = ')')) then begin
        if(buffer <> '') then begin
          AssocOne(buffer, assoc_field, exact_elem, num_elem);
          buffer := '';
        end;
        if (IsUpper(S[i])) then buffer := S[i];
      end;
    end;
    if (buffer <> '') then AssocOne(buffer, assoc_field, exact_elem, num_elem);;
    i_lst := i_lst^.next;
  end;
end;

{ returns what number is assigned to 'elem', -1 if none }
function FindAssoc(assoc_field : dynamic_array_str; exact_elem : longint; elem : string) : longint;
var i : longint;

begin
  for i := 0 to exact_elem do begin
    if(assoc_field[i] = elem) then begin
      FindAssoc := i;
      exit;
    end;
  end;
  FindAssoc := -1;
end;

{ Tokenizes parameter s (string) into a stack at StackS (PStack)
  making it able to be counted into a matrix }
procedure TokenizeString(S : string; assoc_field : dynamic_array_str;
                          exact_elem : longint; var StackL : PStack);
var tmp,NumOrStr,i,num_buf : longint;
    str_buf : string;
    {NumOrStr :: 0 - nothing, 1 - int, 2 - str, 3 - cislo za zavorkou}
    
begin
  if(IsUpper(S[1])) then begin str_buf := S[1]; NumOrStr := 2 end
                    else begin
                      Writeln;Writeln('===============================================');Writeln;
                      writeln('  Error? > ',S ,' < does not start with a capital letter!');
                      Writeln('  Ending.');
                      halt;
                    end;
  num_buf := 0;                 
  for i:=2 to length(S) do begin
    {found lowercase and needed lowercase}
    if ( (IsLower(S[i])) and (NumOrStr = 2) ) then begin
      str_buf := str_buf + S[i];
    end
    
    {found lowercase and needed number or bracket number!}
    else if ( (IsLower(S[i])) and (NumOrStr <> 2) ) then begin
      writeln('Element didnt start with capital!');
      halt;
    end
    
    {found number and needed number}
    else if ( (IsNumber(S[i])) and ( (NumOrStr = 0) or  (NumOrStr = 1) or (NumOrStr = 3) )) then begin
      num_buf := num_buf*10 + ord(S[i]) - ord('0');
    end
    
    {found number, was reading string}
    {dump the string! and read number, and set reading}
    else if ( (IsNumber(S[i])) and (NumOrStr = 2)) then begin
      tmp := FindAssoc(assoc_field, exact_elem, str_buf);
      if(tmp <> -1) then PushEnd(tmp,StackL)
                    else begin Write('I found element I havent previously, ERROR at ',S[i]); halt; end; 
      NumOrStr := 1;
      str_buf := '';
      num_buf := ord(S[i]) - ord('0');
    end
      
    {found UpperCase, was doing nothing}
    {start reading string, set what I am doing}
    else if (IsUpper(S[i]) and (NumOrStr = 0)) then begin
      str_buf := S[i];
      NumOrStr := 2;
    end
    
    {found UpperCase, was reading number}
    {set reding str, do buffer}
    {dump number, clear numbuf}
    else if (IsUpper(S[i]) and (NumOrStr = 1)) then begin
      NumOrStr := 2;
      str_buf := S[i];
      num_buf := num_buf*(-1);
      PushEnd(num_buf,StackL);
      num_buf := 0;  
    end
    
    {found Upper Case, was reading string }
    {dump the string, start new string}
    else if (IsUpper(S[i]) and (NumOrStr = 2)) then begin
      tmp := FindAssoc(assoc_field, exact_elem, str_buf);
      if(tmp <> -1) then PushEnd(tmp,StackL)
                    else begin Write('I found element I havent previously, ERROR'); halt; end;
      str_buf := S[i];
    end
    
    {found UpperCase, was reading BRACKET number}
    {dump number, DUMP FLAG, set mode, start string}
    else if (IsUpper(S[i]) and (NumOrStr = 3)) then begin
      if(num_buf = 0) then begin 
        num_buf := -1;
        PushEnd(num_buf,StackL);
      end
      else begin
        num_buf := num_buf*(-1);
        PushEnd(num_buf,StackL);       
      end;
      PushEnd(32000,StackL);
      NumOrStr := 2;
      num_buf := 0;
      str_buf := S[i];
    end
    
    {found opening bracket, was doing nothing}
    {dump OPENFLAG, do nothing}
    else if ( (S[i] = '(') and (NumOrStr = 0) )then begin  
      PushEnd(-32000,StackL);
      NumOrStr := 0;
    end
    
    {found opening bracket, was reading number}
    {dump numbuf and OPENFLAG, clear numbuf, do nothing}
    else if ( (S[i] = '(') and (NumOrStr = 1) )then begin
      num_buf := num_buf*(-1);
      PushEnd(num_buf,StackL);
      num_buf := 0; 
      PushEnd(-32000,StackL);
      NumOrStr := 0;
    end
    
    {found opening bracket, was reading string}
    {dump string and OPENFLAG, clear strbuf, do nothing}
    else if ( (S[i] = '(') and (NumOrStr = 2) )then begin
      tmp := FindAssoc(assoc_field, exact_elem, str_buf);
      if(tmp <> -1) then PushEnd(tmp,StackL)
                    else begin Write('I found element I havent previously, ERROR'); halt; end;
      PushEnd(-32000,StackL);
      NumOrStr := 0;
      str_buf := '';
    end
    
    {found opening bracket, was reading BRACKET number}
    {dump number, DUMP FLAG, set mode}
    else if ((S[i] = '(') and (NumOrStr = 3)) then begin
      if(num_buf = 0) then begin 
        num_buf := -1;
        PushEnd(num_buf,StackL);
      end
      else begin
        num_buf := num_buf*(-1);
        PushEnd(num_buf,StackL);       
      end;
      PushEnd(32000,StackL);
      NumOrStr := 0;
      num_buf := 0;
    end

    {found close braket, was doing nothing}
    {enter mode 3 - reading number, then printing flag}
    else if ( (S[i] = ')') and (NumOrStr = 0) )then begin
      NumOrStr := 3;
      num_buf := 0;
    end
    
    {found closing bracket, was reading number}
    {dump number, clear numbuf, enter mode 3}
    else if ( (S[i] = ')') and (NumOrStr = 1) )then begin
      num_buf := num_buf*(-1);
      PushEnd(num_buf,StackL);
      num_buf := 0;
      NumOrStr := 3;     
    end
    
    {found closing bracket, was reading string}
    {dump string, clear strbuf, enter mode 3}
    else if ( (S[i] = ')') and (NumOrStr = 2) )then begin
      tmp := FindAssoc(assoc_field, exact_elem, str_buf);
      if(tmp <> -1) then PushEnd(tmp,StackL)
                    else begin Write('I found element I havent previously, ERROR'); halt; end;
      NumOrStr := 3;
      str_buf := '';
    end
    
    {found closing bracket, was reading BRACKET number}
    {dump number, FLAG, then clear number and set mode 3}
    else if ( (S[i] = ')') and (NumOrStr = 3) )then begin
      if(num_buf = 0) then begin 
        num_buf := -1;
        PushEnd(num_buf,StackL);
      end
      else begin
        num_buf := num_buf*(-1);
        PushEnd(num_buf,StackL);       
      end;
      NumOrStr := 3;
      num_buf := 0;
      PushEnd(32000,StackL);            
    end
  end;
  
  if(num_buf <> 0) then begin { some number left over} 
    num_buf := num_buf*(-1);
    PushEnd(num_buf,StackL);
    num_buf := 0;
    if(NumOrStr = 3) then begin  { is the number after brackets check}
      PushEnd(32000,StackL);
    end;
    NumOrStr := 0;
  end
  else if ((num_buf = 0) and (NumOrStr = 3)) then begin  { -1 after brackets left over } 
    PushEnd(-1,StackL);
    PushEnd(32000,StackL);
    NumOrStr := 0;
  end
  else if (str_buf <> '') then begin { string left over }
    tmp := FindAssoc(assoc_field, exact_elem, str_buf);
    if(tmp <> -1) then PushEnd(tmp,StackL)
                  else begin
                    Write('I found element at the end that I havent previously found, ERROR');
                    halt;
                  end;
    str_buf := '';
    NumOrStr := 0;  
  end;
  
{  End of procedure, checks if num_buf, str_buf and NumOrStr
   are all as should - 0, empty and 0.

  Writeln('NumBuf je : ', num_buf);
  Writeln('StrBuf je : ,', str_buf,',');
  Writeln('NumOrStr je : ', NumOrStr);
}  
end;

end.