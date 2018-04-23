unit CAv1;

function GetKeyState(nVirtKey: byte): byte;
external 'User32.dll' name 'GetKeyState';

const
  fill0 = char(9608);
  fill1 = char(9619);
  fill2 = char(9618);
  fill3 = char(9617);
  fill4 = ' ';
  
  you = char(2);
  
  l1: single = 3.78;
  l2: single = 5.5;
  
  scale: byte = 1;
  rnd: byte = 2;
  
  Width: byte = 15;

begin
  {
  for i: word := 9580 to 9680 do
  begin
    writeln(' ',i,char(i)+';');
    //if i mod 2048 = 0 then
    //  readln;
  end;
  readln;
  {}
  
  var MAP := new boolean[Width, Width];
  for x: byte := 0 to Width - 1 do
    for y: byte := 0 to Width - 1 do
      MAP[x, y] := true;
  
  begin
    var s: string;
    for dy: byte := 0 to Width * scale - 1 do
    begin
      var y: byte := dy div scale;
      for dx: byte := 0 to Width * scale - 1 do
      begin
        var x: byte := dx div scale;
        if sqr(x - Width div 2) + sqr(y - Width div 2) > sqr(l2) then s += fill2 else
        if sqr(x - Width div 2) + sqr(y - Width div 2) > sqr(l1) then s += MAP[x, y] ? fill3 : fill1 else
        if (x = Width div 2) and (y = Width div 2) then s += you else
          s += MAP[x, y] ? fill4 : fill0;
      end;
      if y <> Width then
        s += char(10);
    end;
    write(s);
  end;
  
  while true do
  begin
    var dx: shortint := 0;
    var dy: shortint := 0;
    if GetKeyState(37) div 128 = 1 then dx -= 1;
    if GetKeyState(38) div 128 = 1 then dy -= 1;
    if GetKeyState(39) div 128 = 1 then dx += 1;
    if GetKeyState(40) div 128 = 1 then dy += 1;
    
    if Map[Width div 2 + dx, Width div 2 + dy] then
      if (dx <> 0) or (dy <> 0) then
      begin
        var nMap := new boolean[Width, Width];
        
        for x: integer := 0 to Width - 1 do
          for y: integer := 0 to Width - 1 do
            try
              nMap[x - dx, y - dy] := Map[x, y];
            except
            end;
        Map := nMap;
        
        if dx = -1 then begin
          
          for i: byte := 0 to Width - 1 do
            if Map[1, i] then
              Map[0, i] := Random(rnd) = 0;
          var row := new boolean[Width];
          for i: byte := 0 to Width - 1 do
            if ((i > 0) and Map[0, i - 1]) or ((i < Width - 1) and Map[0, i + 1]) then
              row[i] := Random(rnd) = 0;
          for i: byte := 0 to Width - 1 do
            if row[i] then
              Map[0, i] := true;
          
        end else if dx = 1 then begin
          
          for i: byte := 0 to Width - 1 do
            if Map[Width - 2, i] then
              Map[Width - 1, i] := Random(rnd) = 0;
          var row := new boolean[Width];
          for i: byte := 0 to Width - 1 do
            if ((i > 0) and Map[Width - 1, i - 1]) or ((i < Width - 1) and Map[Width - 1, i + 1]) then
              row[i] := Random(rnd) = 0;
          for i: byte := 0 to Width - 1 do
            if row[i] then
              Map[Width - 1, i] := true;
          
        end;
        
        if dy = -1 then begin
          
          for i: byte := 0 to Width - 1 do
            if Map[i, 1] then
              Map[i, 0] := Random(rnd) = 0;
          var row := new boolean[Width];
          for i: byte := 0 to Width - 1 do
            if ((i > 0) and Map[i - 1, 0]) or ((i < Width - 1) and Map[i + 1, 0]) then
              row[i] := Random(rnd) = 0;
          for i: byte := 0 to Width - 1 do
            if row[i] then
              Map[i, 0] := true;
          
        end else if dy = 1 then begin
          
          for i: byte := 0 to Width - 1 do
            if Map[i, Width - 2] then
              Map[i, Width - 1] := Random(rnd) = 0;
          var row := new boolean[Width];
          for i: byte := 0 to Width - 1 do
            if ((i > 0) and Map[i - 1, Width - 1]) or ((i < Width - 1) and Map[i + 1, Width - 1]) then
              row[i] := Random(rnd) = 0;
          for i: byte := 0 to Width - 1 do
            if row[i] then
              Map[i, Width - 1] := true;
          
        end;
        
        var s: string;
        for dy := 0 to Width * scale - 1 do
        begin
          var y: byte := dy div scale;
          for dx := 0 to Width * scale - 1 do
          begin
            var x: byte := dx div scale;
            if sqr(x - Width div 2) + sqr(y - Width div 2) > sqr(l2) then s += fill2 else
            if sqr(x - Width div 2) + sqr(y - Width div 2) > sqr(l1) then s += MAP[x, y] ? fill3 : fill1 else
            if (x = Width div 2) and (y = Width div 2) then s += you else
              s += MAP[x, y] ? fill4 : fill0;
          end;
          if y <> Width then
            s += char(10);
        end;
        system.Console.Clear;
        write(s);
        Sleep(200);
      end;
  end;
end.