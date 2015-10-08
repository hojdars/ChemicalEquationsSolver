unit U_ListFunctions;

interface

uses U_Typeset;

function IsNumber(c : char) : boolean;   // checks if c is a number
function IsUpper(c : char) : boolean;    // checks if c is UPPERCASE
function IsLower(c : char) : boolean;    // checks if c is lowercase                          

procedure PrintOut(s : PItem);
// What : prints the list out

procedure InsertEnd(prvek : string; var l : PItem);
// What : inserts a new element at the end

function FillList(var exact_react : longint; var number_elem : longint; var l : PItem; var ReactOnLeft : longint) : byte;
// What : fills list with input
// How : Reads stdin until SeekEoF, builds a string and when it find
//       '=' or '+' it inserts it at the end of the list and starts a new one

procedure PrintStack(s : PStack);
// What : prints stack

procedure PushEnd(item : longint; var l : PStack);
// What : pushes a new element at the end of the stack

function PopEnd(var l : PStack) : longint;
// What : returns the latest element of the stack

implementation

{ Char procedures }
function IsNumber(c : char) : boolean;
begin
  if( (c >= '0') AND (c <= '9') ) then IsNumber := true
  else IsNumber := false; 
end;

function IsUpper(c : char) : boolean;
begin
  if( (c >= 'A') AND (c <= 'Z') ) then IsUpper := true
  else IsUpper := false; 
end;

function IsLower(c : char) : boolean;
begin
  if( (c >= 'a') AND (c <= 'z') ) then IsLower := true
  else IsLower := false; 
end;

{ List procedures }
procedure PrintOut(s : PItem);
var i : PItem;
begin
  i := s^.next;
  while i <> nil do begin
    write(i^.val, ' ');
    i := i^.next;
  end;
  WriteLn;
end;

procedure InsertEnd(prvek : string; var l : PItem);
var i : Pitem;
begin  
  new(i);
  i^.val := prvek;
  i^.next := nil;

  l^.next := i;
  l := i;
end;

{ Start of parsing - makes the list with reactants }
function FillList(var exact_react : longint; var number_elem : longint; var l : PItem; var ReactOnLeft : longint) : byte;
var in_C : char;
    s : string;
    ReachedEnd,Empty,ReachedEquat : boolean;
begin
  s := '';
  ReachedEnd := false;
  Empty := true;
  ReachedEquat := false; 
  { all the reactants }
  while not seekEOF do begin
    read(in_C);
    
    { one reactant }
    While ((in_C <> '+') and (in_C <> '=' ) and (in_C <> '.' )) do begin
      s := s + in_C;
      if(isUpper(in_C)) then Inc(number_elem);
      if seekEOF then begin ReachedEnd := true; break; end
      else read(in_C);
    end;
    
    { found the whole }
    if(s <> '') then begin
      InsertEnd(s,l);
      Empty := false;
    end;
    if(in_C = '.' ) then ReachedEnd := true;
    Inc(exact_react);
    if(in_C = '=') then begin ReactOnLeft := exact_react; ReachedEquat := true; end;
    if(ReachedEnd = true) then break;
    s := '';
  end;
  if(empty) then FillList := 10                                         // empty equation !
  else if((not(empty)) and (ReachedEquat = false)) then FillList := 12  // No '=' found !
  else if(number_elem = 0) then FillList := 14                          // No elements found !
  else if((not(empty)) and (ReachedEquat = true))  then FillList := 20  // All is OK.
end;

{ Stack procedures }
procedure PrintStack(s : PStack);
var i : PStack;
begin
  i := s^.next;
  while i <> nil do begin
    write(i^.val,' ');
    i := i^.next;
  end;
  WriteLn;
end;

procedure PushEnd(item : longint; var l : PStack);
var i : PStack;
begin
  new(i);
  i^.next := nil;
  i^.last := l;
  i^.val := item;
  
  l^.next := i;
  l := i;
end;

function PopEnd(var l : PStack) : longint;
var tmp : PStack;
begin
  PopEnd := l^.val;
  if(l^.val <> -31000) then begin
    tmp := l;
    l^.last^.next := nil;
    l := l^.last;
    dispose(tmp);
  end;
end;

end.