unit CAv3;

function GetKeyState(nVirtKey: byte): byte;
external 'User32.dll' name 'GetKeyState';

var
  UseConsole := System.Reflection.Assembly.GetExecutingAssembly.GetType('__RedirectIOMode.__RedirectIOMode') = nil;

const
  fill0 = char(9608);
  fill1 = char(9619);
  fill2 = char(9618);
  fill3 = char(9617);
  fill4 = ' ';
  
  you = char(2);
  
  l1: single = 2.25;
  l2: single = 5;

type
  Turn = class
    X, Y: integer;
    Up, Down, Left, Rigth: boolean;
    tU, tD, tL, tR: Turn;
    PlayerIn: boolean;
  end;

var
  Map: array[1..5] of array[1..5] of byte;
  Turns := new Turn[1](new Turn);
  PTurn:Turn;
  Steps: int64 := 0;

procedure Draw;
var
  s := '';
begin ;
  for y: byte := 1 to 5 do
  begin
    for x: byte := 1 to 5 do
    begin
      if sqr(x - 3) + sqr(y - 3) > sqr(l2) then s += fill2 else
      //if Map[x, y] = 2 then s += enemy else
      if sqr(x - 3) + sqr(y - 3) > sqr(l1) then s += Map[x, y] = 1 ? fill3 : fill1 else
      if (x = 3) and (y = 3) then s += you else
        s += Map[x, y] = 1 ? fill4 : fill0;
    end;
    s += char(10);
  end;
  
  s += Steps;
  
  if UseConsole then
  begin
    system.Console.Clear;
    system.Console.Write(s);
  end else
    Write(s);
end;

function IsOpen(X, Y: integer): boolean;
begin
  for i: integer := 0 to Turns.Length - 1 do
    if 
    (Turns[i].Left and (X - Turns[i].X <= 0) and (X - Turns[i].X >= -2) and (Y = Turns[i].Y)) or 
    (Turns[i].Rigth and (X - Turns[i].X >= 0) and (X - Turns[i].X <= 2) and (Y = Turns[i].Y)) or 
    (Turns[i].Up and (Y - Turns[i].Y <= 0) and (Y - Turns[i].Y >= -2) and (X = Turns[i].X)) or 
    (Turns[i].Down and (Y - Turns[i].Y >= 0) and (Y - Turns[i].Y <= 2) and (X = Turns[i].X))
    then
    begin
      Result := true;
      exit;
    end;
end;

begin
  Turns[0].X := 3;
  Turns[0].Y := 3;
  Turns[0].Down := Random(3) = 0;
  Turns[0].Left := Random(3) - (Turns[0].Down ? 0 : 1) <= 0;
  Turns[0].Rigth := Random(3) - (Turns[0].Down ? 0 : 1) - (Turns[0].Left ? 0 : 1) <= 0;
  Turns[0].Up := Random(3) - (Turns[0].Down ? 0 : 1) - (Turns[0].Left ? 0 : 1) - (Turns[0].Rigth ? 0 : 1) <= 0;
  Turns[0].PlayerIn := true;
  PTurn := Turns[0];
  
  for x: byte := 1 to 5 do
    for y: byte := 1 to 5 do
      Map[x][y] := IsOpen(x, y) ? 1 : 0;
  
  Draw;
  
  while true do
  begin
    var dx: shortint := 0;
    var dy: shortint := 0;
    if GetKeyState(37) div 128 = 1 then dx -= 1;
    if GetKeyState(38) div 128 = 1 then dy -= 1;
    if GetKeyState(39) div 128 = 1 then dx += 1;
    if GetKeyState(40) div 128 = 1 then dy += 1;
    
    if (dx <> 0) or (dy <> 0) then
      if Map[3 + dx][3 + dy] > 0 then
      begin
        for i: integer := Turns.Length - 1 downto 0 do
          if (abs(Turns[i].X - 3) > 3) or (abs(Turns[i].Y - 3) > 3) then
          begin
            if Turns[i].tD <> nil then Turns[i].tD.tU := nil;
            if Turns[i].tU <> nil then Turns[i].tU.tD := nil;
            if Turns[i].tR <> nil then Turns[i].tR.tL := nil;
            if Turns[i].tL <> nil then Turns[i].tL.tR := nil;
            Turns[i] := Turns[Turns.Length - 1];
            SetLength(Turns, Turns.Length - 1);
          end;
        
        if dx > 0 then begin
          
          for i: integer := 0 to Turns.Length - 1 do
            if Turns[i].Rigth then
              if Turns[i].X = 3 then
                if Random(3) > 0 then
                begin
                  var a := new Turn;
                  a.X := 7;
                  a.Y := Turns[i].Y;
                  a.Left := true;
                  a.Rigth := Random(2) - (a.Left ? 0 : 1) <= 0;
                  a.Down := Random(2) - (a.Left ? 0 : 1) - (a.Left ? 0 : 1) <= 0;
                  a.Up := Random(2) - (a.Left ? 0 : 1) - (a.Left ? 0 : 1) - (a.Down ? 0 : 1) <= 0;
                  a.PlayerIn := false;
                  a.tL := Turns[i];
                  Turns[i].tR := a;
                  Turns := Turns + new Turn[1](a);
                end;
          
        end else if dx < 0 then begin
          
          for i: integer := 0 to Turns.Length - 1 do
            if Turns[i].Left then
              if Turns[i].X = 3 then
                if Random(3) > 0 then
                begin
                  var a := new Turn;
                  a.X := -1;
                  a.Y := Turns[i].Y;
                  a.Rigth := true;
                  a.Down := Random(2) - (a.Rigth ? 0 : 1) <= 0;
                  a.Left := Random(2) - (a.Rigth ? 0 : 1) - (a.Down ? 0 : 1) <= 0;
                  a.Up := Random(2) - (a.Rigth ? 0 : 1) - (a.Down ? 0 : 1) - (a.Rigth ? 0 : 1) <= 0;
                  a.PlayerIn := false;
                  a.tL := Turns[i];
                  Turns[i].tL := a;
                  Turns := Turns + new Turn[1](a);
                end;
          
        end;
        if dy > 0 then begin
          
          for i: integer := 0 to Turns.Length - 1 do
            if Turns[i].Down then
              if Turns[i].Y = 3 then
                if Random(3) > 0 then
                begin
                  var a := new Turn;
                  a.X := Turns[i].X;
                  a.Y := 7;
                  a.Up := true;
                  a.Left := Random(2) - (a.Up ? 0 : 1) <= 0;
                  a.Rigth := Random(2) - (a.Up ? 0 : 1) - (a.Left ? 0 : 1) <= 0;
                  a.Down := Random(2) - (a.Up ? 0 : 1) - (a.Left ? 0 : 1) - (a.Rigth ? 0 : 1) <= 0;
                  a.PlayerIn := false;
                  a.tU := Turns[i];
                  Turns[i].tD := a;
                  Turns := Turns + new Turn[1](a);
                end;
          
        end else if dy < 0 then begin
          
          for i: integer := 0 to Turns.Length - 1 do
            if Turns[i].Up then
              if Turns[i].Y = 3 then
                if Random(3) > 0 then
                begin
                  var a := new Turn;
                  a.X := Turns[i].X;
                  a.Y := -1;
                  a.Down := true;
                  a.Left := Random(2) - (a.Down ? 0 : 1) <= 0;
                  a.Rigth := Random(2) - (a.Down ? 0 : 1) - (a.Left ? 0 : 1) <= 0;
                  a.Up := Random(2) - (a.Down ? 0 : 1) - (a.Left ? 0 : 1) - (a.Rigth ? 0 : 1) <= 0;
                  a.PlayerIn := false;
                  a.tD := Turns[i];
                  Turns[i].tU := a;
                  Turns := Turns + new Turn[1](a);
                end;
          
        end;
        
        for i: integer := 0 to Turns.Length - 1 do
        begin
          Turns[i].X -= dx;
          Turns[i].Y -= dy;
        end;
        
        begin
          var nMap: array[1..5] of array[1..5] of byte;
          for x: byte := 1 to 5 do
            for y: byte := 1 to 5 do
              try
                nMap[x, y] := Map[x + dx, y + dy];
              except
              end;
          
          if dx < 0 then
            for y: byte := 1 to 5 do nMap[1, y] := IsOpen(1, y) ? 1 : 0
          else if dx > 0 then
            for y: byte := 1 to 5 do nMap[5, y] := IsOpen(5, y) ? 1 : 0;
          
          if dy < 0 then
            for x: byte := 1 to 5 do nMap[x, 1] := IsOpen(x, 1) ? 1 : 0
          else if dy > 0 then
            for x: byte := 1 to 5 do nMap[x, 5] := IsOpen(x, 5) ? 1 : 0;
          
          for x: byte := 1 to 5 do
            for y: byte := 1 to 5 do
              Map[x, y] := nMap[x, y];
        end;
        
        Steps += 1;
        Draw;
        
        Sleep(Round(100 * sqrt(sqr(dx) + sqr(dy))));
      end;
  end;
end.