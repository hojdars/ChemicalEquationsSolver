unit U_Typeset;

interface

type
    dynamic_array_str = array of string;
    matrix_array = array of array of integer;
    dynamic_array_LInt = array of longint;
     
    PItem = ^TItem;

    TItem = record
      val : string;
      next : PItem;
    end;
    
    PStack = ^TStack;
    
    TStack = record
      val : longint;
      next : PStack;
      last : PStack;
    end;
    
implementation

end.    