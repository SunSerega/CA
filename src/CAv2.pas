unit CAv2;

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
  enemy = char(1);
  
  scale: byte = 1;
  rnd: byte = 3;
  
  l1: single = 10;
  l2: single = 15;
  WR: single = 22.5;
  MR: single = WR * power(2, 1.5);

type
  Cave = record
    x, y: real;
    r: real;
    
    constructor create(nX, nY, nR: real);
    begin
      x := nX;
      y := nY;
      r := nR;
    end;
  end;
  
  Mob = record
    x, y: real;
  end;

var
  Map := new Cave[1](new Cave(0, 0, WR * sqrt(2)));
  Steps: int64 := 0;
  Mobs := new Mob[0];

function IsOpen(X, Y: single): boolean;
begin
  for i: integer := 0 to Map.Length - 1 do
    if sqr(X - Map[i].x) + sqr(Y - Map[i].y) < sqr(Map[i].r) then
    begin
      Result := true;
      break;
    end;
end;

function MTBA: array[,] of byte;
var
  Width := Trunc(WR) * 2 + 1;
begin
  Result := new byte[Width, Width];
  for x: byte := 0 to Width - 1 do
    for y: byte := 0 to Width - 1 do
      Result[x, y] := IsOpen(x - Width div 2, y - Width div 2) ? 1 : 0;
  
  for i: integer := 0 to Mobs.Length - 1 do
    with Mobs[i] do
      try
        Result[Round(x) + Width div 2, Round(y) + Width div 2] := 2;
      except
  end;
end;

procedure Draw;
var
  s: string;
  h: byte;
  Width := Trunc(WR) * 2 + 1;

begin
  var a := MTBA;
  for dy: byte := 0 to Width * scale - 1 do
  begin
    var y: byte := dy div scale;
    for dx: byte := 0 to Width * scale - 1 do
    begin
      var x: byte := dx div scale;
      if sqr(x - Width div 2) + sqr(y - Width div 2) > sqr(l2) then s += fill2 else
      if a[x, y] = 2 then s += enemy else
      if sqr(x - Width div 2) + sqr(y - Width div 2) > sqr(l1) then s += a[x, y] = 1 ? fill3 : fill1 else
      if (x = Width div 2) and (y = Width div 2) then s += you else
        s += a[x, y] = 1 ? fill4 : fill0;
    end;
    if UseConsole then
    begin
      System.Console.SetCursorPosition(0, h);
      System.Console.Write(s);
    end else
      Writeln(s);
    s := '';
    h += 1;
  end;
  
  if UseConsole then
  begin
    System.Console.SetCursorPosition(0, h);
    System.Console.Write(Steps);
  end else
    Write(s);
end;

begin
  try
    System.Console.SetWindowSize(Trunc(WR) * 2 + 1, Trunc(WR) * 2 + 2);
    System.Console.SetWindowPosition(0, 0);
    writeln('Press arrows to start');
    
    while true do
    begin
      var dx: shortint := 0;
      var dy: shortint := 0;
      if GetKeyState(37) div 128 = 1 then dx -= 1;
      if GetKeyState(38) div 128 = 1 then dy -= 1;
      if GetKeyState(39) div 128 = 1 then dx += 1;
      if GetKeyState(40) div 128 = 1 then dy += 1;
      
      if (dx <> 0) or (dy <> 0) then
        if IsOpen(dx, dy) then
        begin
          for i: integer := Map.Length - 1 downto 0 do
          begin
            Map[i].x -= dx;
            Map[i].y -= dy;
            
            if sqr(Map[i].x) + sqr(Map[i].y) > sqr(MR) then
            begin
              Map[i] := Map[Map.Length - 1];
              SetLength(Map, Map.Length - 1);
            end;
          end;
          
          for n: byte := 1 to rnd do
          begin
            Map := Map + new Cave[1](new Cave(Random * MR * 2 - MR, Random * MR * 2 - MR, Random * MR / 2));
            with Map[Map.Length - 1] do
              if sqrt(sqr(x) + sqr(y)) < r + MR / 2 then
                SetLength(Map, Map.Length - 1);
          end;
          
          var nMob := Trunc(sqrt(Steps) / 10);
          if Random < sqrt(Steps) / 10 - nMob then
            nMob += 1;
          
          for i: integer := Mobs.Length - 1 downto 0 do
            with Mobs[i] do
            begin
              Mobs[i].x -= dx;
              Mobs[i].y -= dy;
              
              var r := sqrt(sqr(x) + sqr(y));
              var dr: real;
              if IsOpen(x, y) then
                dr := power(0.5, 100 / Steps) * 0.95 else
                dr := power(0.1, 100 / Steps) * 0.95;
              
              dr *= sqrt(abs(dx) + abs(dy));
              
              for i2: integer := i + 1 to Mobs.Length - 1 do
                if sqr(Mobs[i2].x - x) + sqr(Mobs[i2].x - x) < 1 then
                  dr -= 0.5;
              
              x *= (r - dr) / r;
              y *= (r - dr) / r;
              
              if sqr(x) + sqr(y) < 2.25 then
              begin
                if UseConsole then
                  System.Console.Clear;
                var a := new byte[9, 8](
                (0, 1, 1, 1, 1, 1, 1, 0),
                (1, 1, 0, 0, 0, 0, 1, 1),
                (1, 0, 0, 0, 0, 0, 0, 1),
                (1, 0, 1, 0, 0, 1, 0, 1),
                (1, 0, 0, 0, 0, 0, 0, 1),
                (1, 0, 0, 1, 1, 0, 0, 1),
                (1, 0, 1, 1, 1, 1, 0, 1),
                (1, 1, 0, 0, 0, 0, 1, 1),
                (0, 1, 1, 1, 1, 1, 1, 0));
                for nx: integer := 0 to 8 do
                begin
                  for ny: integer := 0 to 7 do
                  begin
                    write(a[nx, ny] = 1 ? fill0 : fill3);
                    sleep(10);
                  end;
                  writeln;
                end;
                Writeln($'You died with {Steps} steps');
                Writeln('Press Enter to restart');
                Writeln('Press Ecs to exit');
                while true do
                begin
                  if GetKeyState(13) div 128 = 1 then
                  begin
                    Map := new Cave[1](new Cave(0, 0, WR * sqrt(2)));
                    Steps := -1;
                    nMob := 0;
                    Mobs := new Mob[0];
                    break;
                  end else
                  if GetKeyState(27) div 128 = 1 then
                    exit;
                end;
                break;
              end;
              
              if sqr(x) + sqr(y) > sqr(MR) then
              begin
                Mobs[i] := Mobs[Mobs.Length - 1];
                SetLength(Mobs, Mobs.Length - 1)
              end;
            end;
          
          for n: integer := 1 to nMob - Mobs.Length do
            with Mobs[Mobs.Length] do
            begin
              Mobs := Mobs + new Mob[1];
              while (sqr(x) + sqr(y) < sqr(MR / 2)) or (sqr(x) + sqr(y) > sqr(MR)) do
              begin
                x := (Random * 2 - 1) * MR;
                y := (Random * 2 - 1) * MR;
              end;
            end;
          
          Steps += 1;
          Draw;
          Sleep(Round(40 * sqrt(sqr(dx) + sqr(dy))));
        end;
    end;
  except
    on e: Exception do
    begin
      try System.Console.Clear except end;
      writeln(e);
      readln;
      halt;
    end;
  end;
end.