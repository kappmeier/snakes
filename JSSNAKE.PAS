program JSSnake2;

uses Crt, Dos;

type
    Nahrung = record
        XPos: Word;
        YPos: Word
    end;

    HimmelsRichtung = (NORD, OST, SUED, WEST);
    Position = record
        XPos: array[1..255] of Shortint;
        YPos: array[1..255] of Shortint;
        Laenge: Byte;
        BlickRichtung: HimmelsRichtung
    end; {type Position = record}

    TKoordinaten = array[1..50, 2..50] of Boolean;

    Time = record
        Hour, Minute, Second, Sec100: Word
    end; {type Time = record}

var
    ch, chNochMal: Char;
    fFehlschlag: Boolean;
    kKoordinaten: TKoordinaten;
    i, j, iOrigMode: Integer;
    lDelayTime: Longint;
    shLevel, shLevelAnzeige, shSnakeLaenge, shOldLen: Shortint;
    nahSnake: Nahrung;
    posSnake: Position;
    s: String;

function GetDelay : Longint;
    var
        ilDelayTime : Longint;
        now : Time;
        timestampStart : Longint;
        timestampEnd : Longint;
    begin
        {GetTime(var Hour, Minute, Second, Sec100: Word);}
        GetTime(now.Hour, now.Minute, now.Second, now.Sec100);
        timestampStart := now.Hour * 60 * 60 + now.Minute * 60 + now.Second;
        ilDelayTime := 0;
        repeat
            Delay(1);
            GetTime(now.Hour, now.Minute, now.Second, now.Sec100);
            timestampEnd := now.Hour * 60 * 60 + now.Minute * 60 + now.Second;
            ilDelayTime := ilDelayTime + 1
        until timestampEnd - timestampStart >= 10;
        GetDelay := ilDelayTime;
    end;

procedure Pause(lTimes : Longint);
    var
        lDelay : Longint;
        timeZW : Time;
    begin
        lDelay := 0;
        repeat
            lDelay :=  lDelay + 1;
               Delay(1);
            GetTime(timeZW.Hour, timeZW.Minute, timeZW.Second, timeZW.Sec100)
        until lDelay = lTimes
    end;

procedure SetHindernis(var Koordinaten : TKoordinaten;
                       SnakePos : Position;
                       SnakeNahrung : Nahrung);
    begin
        for i := 2 TO 39 do
            for j := 3 TO 48 do
                Koordinaten[i, j] := false;
        for i := 2 to SnakePos.Laenge do
            Koordinaten[SnakePos.XPos[i], SnakePos.YPos[i]] := true;
        Koordinaten[SnakeNahrung.XPos, SnakeNahrung.YPos] := TRUE
    end;

procedure SetNahrung(var Koordinaten : TKoordinaten;
                     SnakePos : Position;
                     var SnakeNahrung : Nahrung
                     );
    var fErlaubt : Boolean;

    function Control(xPos, yPos : Shortint;
                     SnakePos : Position) : Boolean;
    var fTemp : Boolean;
    begin
        fTemp := FALSE;
        i := 1;
        repeat
            if (SnakePos.XPos[i] = xPos) and (SnakePos.YPos[i] = yPos) then begin
                fTemp := FALSE;
                GoToXY(1,1);
                Write('X'); end
            else begin
                fTemp := TRUE;
                GoToXY(1, 1);
                Write(' ');
            end;
            i := i + 1
        until (i = SnakePos.Laenge) or (fTemp = FALSE);
        Control := fTemp
    end;

begin
    { Nahrung wird solange gesetzt, bis ein Punkt getroffen wird,
      der nicht von der Schlange belegt wird. }
    repeat
        SnakeNahrung.XPos := Random(37) + 2;
        SnakeNahrung.YPos := Random(45) + 3;
        fErlaubt := Control(SnakeNahrung.XPos, SnakeNahrung.YPos, SnakePos);
    until fErlaubt = true;
    GoToXY(SnakeNahrung.XPos, SnakeNahrung.YPos);
    Write('*');
    Koordinaten[SnakeNahrung.XPos, SnakeNahrung.YPos] := true
end;

procedure Hindernis(var Koordinaten : TKoordinaten;
                    var SnakePos : Position;
                    var SnakeNahrung : Nahrung;
                    var Fehlschlag : Boolean);

    begin
        {Kontrolle, ob ein Hindernis berÅhrt wird.}
        if Koordinaten[SnakePos.XPos[1], SnakePos.YPos[1]] = true then
            Fehlschlag := true;
        if (SnakePos.XPos[1] = SnakeNahrung.XPos) and (SnakePos.YPos[1] = SnakeNahrung.YPos) then begin
            Fehlschlag := false;
            SnakePos.Laenge := SnakePos.Laenge + 1;
            SnakePos.XPos[SnakePos.Laenge] := SnakePos.XPos[2];
            SnakePos.YPos[SnakePos.Laenge] := SnakePos.YPos[2];
            SetNahrung(Koordinaten, SnakePos, SnakeNahrung);
            Koordinaten[SnakePos.XPos[1], SnakePos.YPos[1]] := false
        end
    end;

procedure ShowSnake(var Koordinaten : TKoordinaten;
                    var SnakePos : Position;
                    var SnakeNahrung : Nahrung;
                    var Fehlschlag : Boolean);
    begin
        GoToXY(1, 1);
        Write('     ');
        GoToXY(1, 1);
        Write(SnakePos.XPos[1] - 1);
        GoToXY(3, 1);
        Write('/');
        GoToXY(4, 1);
        Write(SnakePos.YPos[1] - 2);

        GoToXY(30, 1);
        Write('LÑnge: ', SnakePos.Laenge);

        GoToXY(10, 1);
        Write('Nahrung:   /    ');
        GoToXY(19, 1);
        Write(SnakeNahrung.XPos - 1);
        GoToXY(22,1);
        Write(SnakeNahrung.YPos - 2);

        for i := 2 TO SnakePos.Laenge do begin
            GoToXY(SnakePos.XPos[i], SnakePos.YPos[i]);
            Write('*')
        end;
        {Zuletzt den Schlangenkopf anzeigen}

        GotoXY(SnakePos.XPos[1], SnakePos.YPos[1]);
        {case SnakePos.BlickRichtung of
            NORD : write('^');
            OST : Write('>');
            SUED : Write('|');
            WEST : Write('<')
        end;}
        Write(#2);
        GoToXY(SnakePos.XPos[1], SnakePos.YPos[2]);

        Pause(lDelayTime div 1000 * shLevel);
        {Kontrolle, ob eine Taste gedrÅckt wurde.Die letze gedrÅckte Taste zÑhlt.}
        GoToXY(SnakePos.XPos[SnakePos.Laenge], SnakePos.YPos[SnakePos.Laenge]);
        Write(' ');
        while KeyPressed do ch := ReadKey;
        case Ord(ch) of
            72 : begin
                if SnakePos.BlickRichtung <> SUED then
                begin
                    for i := SnakePos.Laenge downto 2 do begin
                        SnakePos.YPos[i] := SnakePos.YPos[i - 1];
                        SnakePos.XPos[i] := SnakePos.XPos[i - 1]
                    end;
                    SnakePos.BlickRichtung := NORD;
                    SnakePos.YPos[1] := SnakePos.YPos[1] - 1
                end
            end;
            75 : begin
                if SnakePos.BlickRichtung <> OST then
                begin
                    for i := SnakePos.Laenge downto 2 do begin
                        SnakePos.YPos[i] := SnakePos.YPos[i - 1];
                        SnakePos.XPos[i] := SnakePos.XPos[i - 1]
                    end;
                    SnakePos.BlickRichtung := WEST;
                    SnakePos.XPos[1] := SnakePos.XPos[1] - 1
                end
            end;
            77 : begin
                if SnakePos.BlickRichtung <> WEST then
                begin
                    for i := SnakePos.Laenge downto 2 do begin
                        SnakePos.YPos[i] := SnakePos.YPos[i - 1];
                        SnakePos.XPos[i] := SnakePos.XPos[i - 1]
                    end;
                    SnakePos.BlickRichtung := OST;
                    SnakePos.XPos[1] := SnakePos.XPos[1] + 1
                end
            end;
            80 : begin
                if SnakePos.BlickRichtung <> NORD then
                begin
                    for i := SnakePos.Laenge downto 2 do begin
                        SnakePos.YPos[i] := SnakePos.YPos[i - 1];
                        SnakePos.XPos[i] := SnakePos.XPos[i - 1]
                    end;
                    SnakePos.BlickRichtung := SUED;
                    SnakePos.YPos[1] := SnakePos.YPos[1] + 1
                end
            end
        end;
        SetHindernis(Koordinaten, SnakePos, SnakeNahrung);
        Hindernis(Koordinaten, SnakePos, SnakeNahrung, Fehlschlag)
    end;

procedure SpielEinrichten;
    begin
        { Den Rahmen als Hindernis eintragen }
        for i := 1 to 40 do
           kKoordinaten[i, 2] := true;

        for i := 3 to 49 do
            kKoordinaten[1, i] := true;

        for i := 3 to 49 do
           kKoordinaten[40, i] := true;

        for i := 2 to 39 do
           kKoordinaten[i, 49] := true;

        { Level bestimmen }
        repeat {(s = 0) or (s = 1) or (s = 2) or (s = 3) or (s = 4) or (s = 5) or (s = 6) or (s = 7) or (s = 8) or (s = 9)}
            GoToXY(55, 3);
            Write('Level (0-9)');
            s := ReadKey;
        until (s = '0') or (s = '1') or (s = '2') or (s = '3') or (s = '4')
            or (s = '5') or (s = '6') or (s = '7') or (s = '8') or (s = '9');
        Val(s, shLevelAnzeige, i);
        GoToXY(55, 3);
        Write('Level: ', shLevelAnzeige, '    ');
        GoToXY(55, 4);
        Write('LÑnge: ', posSnake.Laenge);
        { Aus shLevel die Spielgeschwindigkeit errechnen. }
        case shLevelAnzeige of
            0 : shLevel := 13;
            1 : shLevel := 12;
            2 : shLevel := 11;
            3 : shLevel := 10;
            4 : shLevel := 9;
            6 : shLevel := 8;
            7 : shLevel := 7;
            8 : shLevel := 6;
            9 : shLevel := 5
        end
    end;

procedure SpielFeldDefault;
    begin
        ClrScr;
        GoToXY(1,2);
        Write('…');
        GoToXY(1, 49);
        Write('»');
        GoToXY(40, 2);
        Write('ª');
        GoToXY(40, 49);
        Write('º');
        GoToXY(1, 2);
        for i := 3 to 48 do
        begin
            GoToXY(1,i);
            Write('∫');
            GoToXY(40, i);
            Write('∫');
        end; {i := 2 to 49 do begin}
        GoToXY(2, 2);
        for i := 2 to 39 do
            Write('Õ');
        GoToXY(2, 49);
        for i := 2 to 39 do
            Write('Õ')
    end; { SpielFeldDefault }

begin {of Hauptprogramm}

    { Bildschirmmodus setzen }
    iOrigMode := LastMode;
    TextMode(256); { 256 = Font8x8 }

    { Programm Initialisieren }
    for i := 1 to 255 do begin
        posSnake.XPos[i] := 1;
        posSnake.XPos[i] := 1;
    end;
    Randomize;
    ClrScr;
    Writeln ('SnakeS 2.0');
    Writeln ('        Jan-Philipp Kappmeier 2000');

    { Zeitmesser einrichten }
    GoToXY(1, 5);
    WriteLn('Programm einrichten...');
    WriteLn('Dies dauert ca. 10 sec.');
    lDelayTime := GetDelay;

    { Hauptschleife zum wiederhohlten starten. }
    repeat  {until sNochMal = 'n'}
        { Einrichten }
        fFehlschlag := false;
        for i := 1 to 50 do
            for j := 2 TO 50 do begin
                kKoordinaten[i, j] := false;
                Write('.')
            end;
        posSnake.Laenge := 3;
        posSnake.BlickRichtung := WEST;
        for i := 1 to 3 do begin
            posSnake.XPos[i] := i + 35;
            posSnake.YPos[i] := 48
        end; {i := 1 to 3 do beign}
        kKoordinaten[39, 48] := true;
        kKoordinaten[38, 48] := true;
        kKoordinaten[37, 48] := true;
        SpielEinrichten; { Die RÑnder als hindernisseeintragen }
        SetNahrung(kKoordinaten, posSnake, nahSnake);

        SpielFeldDefault;        { Einrichten der OberflÑche }
        while Keypressed do      { Tastaturspeicher leeren }
            ch := ReadKey;
        ReadLn;

        { Spiel starten }
        ch := ReadKey;
        shSnakeLaenge := 0;
        repeat {until fFehlschlag}
            shOldLen := posSnake.Laenge;
            ShowSnake(kKoordinaten, posSnake, nahSnake, fFehlschlag);

            {Automatisches Erhîhen des Levels bei einigen gefundenen
             Fre·teilchen, Geschwindigkeit quadratisch abfallend.}
            {Erhîhen des ZÑhlers der SchlangenlÑnge seit dem letzen
             Levelerhîhen}
            if posSnake.Laenge > shOldLen then shSnakeLaenge := shSnakeLaenge + 1;
            if shSnakeLaenge = (shLevelAnzeige + 1) * 3 then begin
                shSnakeLaenge := 0;
                shLevel := shLevel - 1;
                if shLevel = 0 then shLevel := 1;
                shLevelAnzeige := shLevelAnzeige + 1;
                if shLevelAnzeige = 10 then shLevelAnzeige := 9;
                GoToXY(1, 50);
                Write('Level: ', shLevelAnzeige, '    ');
            end;


            until fFehlschlag;


        { Abfrage zum wiederhohlten Spielen }
        repeat { until (UpCase(chNochMal) = 'J') or (UpCase(chNochMal) = 'N') }
            ClrScr;
            GoToXY(1, 25);
            Write('bock noch mal zu zocken?(j/n) ');
            chNochMal := ReadKey;
        until (UpCase(chNochMal) = 'J') or (UpCase(chNochMal) = 'N')
    until UpCase(chNochMal) = 'N';

    TextMode(iOrigMode);  { ZurÅcksetzen des Bildschirmmodes}
end. { of main }

{ (c) Jan-Philipp Kappmeier, 1999-2000 }
