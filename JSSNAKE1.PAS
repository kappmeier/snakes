program JSSnake;

uses Crt, Dos;

type
    Nahrung = record
        XPos : Word;
        YPos : Word
    end;

    HimmelsRichtung = (NORD, OST, SUED, WEST);
    Position = record
        XPos : array[1..255] of Shortint;
        YPos : array[1..255] of Shortint;
        Laenge : Byte;
        BlickRichtung : HimmelsRichtung
      end; {type Position = record}

    TKoordinaten = array[1..50, 1..25] of Boolean;

    Time = record
        Hour, Minute, Second, Sec100 : Word
    end; {type Time = record}

var
    ch : Char;
    fFehlschlag : Boolean;
    fKoordinaten : TKoordinaten;
    i, j : Integer;
    ilDelayTime : Longint;
    isLevel, isLevelAnzeige, isSnakeLaenge, isOldLen : Shortint;
    nahSnake : Nahrung;
    posSnake : Position;
    s, sNochMal : String;

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

procedure Pause(ilTimes : Longint);
    var
        iDelay : Longint;
        timeZW : Time;
    begin
        iDelay := 0;
        repeat
            iDelay :=  iDelay + 1;
            Delay(1);
            GetTime(timeZW.Hour, timeZW.Minute, timeZW.Second, timeZW.Sec100)
        until iDelay = ilTimes
    end;

procedure SetHindernis(var Koordinaten : TKoordinaten;
                       SnakePos : Position;
                       SnakeNahrung : Nahrung);
    begin
        for i := 2 TO 49 do
            for j := 2 TO 24 do
                Koordinaten[i, j] := false;
        for i := 2 to SnakePos.Laenge do
            Koordinaten[SnakePos.XPos[i], SnakePos.YPos[i]] := true;
        Koordinaten[SnakeNahrung.XPos, SnakeNahrung.YPos] := TRUE
    end;

procedure SetNahrung(var Koordinaten : TKoordinaten;
                     SnakePos : Position;
                     var SnakeNahrung : Nahrung
                     );
    var
        fErlaubt : Boolean;

    function Control(xPos, yPos : Shortint;
                     SnakePos : Position) : Boolean;
    var
        fTemp : Boolean;
    begin
        fTemp := FALSE;
        i := 1;
        repeat
            if (SnakePos.XPos[i] = xPos) and (SnakePos.YPos[i] = yPos) then begin
                fTemp := FALSE;
                GoToXY(60,10);
                Write('X'); end
            else begin
                fTemp := TRUE;
                GoToXY(60, 10);
                Write(' ');
            end;
            i := i + 1
        until (i = SnakePos.Laenge) or (fTemp = FALSE);
        Control := fTemp
    end;

begin
    {Nahrung wird solange gesetzt, bis ein Punkt getroffen wird,
     der nicht von der Schlange belegt wird.}
    repeat
        SnakeNahrung.XPos := Random(49) + 2;
        SnakeNahrung.YPos := Random(23) + 2;
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
        {Kontrolle, ob ein Hindernis berhrt wird.}
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
        GoToXY(55, 5);
        Write('Kopf   :    /    ');
        GoToXY(55, 5);
        Write('Kopf   : ', (SnakePos.XPos[1] - 1));
        GoToXY(66,5);
        Write(' / ', (SnakePos.YPos[1] - 1));
        GoToXY(55, 4);
        Write('L„nge: ', SnakePos.Laenge);
        GoToXY(55, 6);
        Write('Nahrung:    /    ');
        GoToXY(55, 6);
        Write('Nahrung: ', (SnakeNahrung.XPos - 1));
        GoToXY(66,6);
        Write(' / ', (SnakeNahrung.YPos - 1));
        {Zuerst den Schlangenkopf anzeigen}
        GoToXY(SnakePos.XPos[1], SnakePos.YPos[1]);
        case SnakePos.BlickRichtung of
            NORD : write('^');
            OST : Write('>');
            SUED : Write('|');
            WEST : Write('<')
        end;
        for i := 2 TO SnakePos.Laenge do begin
            GoToXY(SnakePos.XPos[i], SnakePos.YPos[i]);
            Write('*')
        end;
        Pause(ilDelayTime div 1000 * isLevel);
        {Kontrolle, ob eine Taste gedrckt wurde.Die letze gedrckte Taste z„hlt.}
        GoToXY(SnakePos.XPos[SnakePos.Laenge], SnakePos.YPos[SnakePos.Laenge]);
        Write(' ');
        while KeyPressed do ch := ReadKey;
        case Ord(ch) of
            72 : begin
                for i := SnakePos.Laenge downto 2 do begin
                    SnakePos.YPos[i] := SnakePos.YPos[i - 1];
                    SnakePos.XPos[i] := SnakePos.XPos[i - 1]
                end;
                SnakePos.BlickRichtung := NORD;
                SnakePos.YPos[1] := SnakePos.YPos[1] - 1
            end;
            75 : begin
                for i := SnakePos.Laenge downto 2 do begin
                    SnakePos.YPos[i] := SnakePos.YPos[i - 1];
                    SnakePos.XPos[i] := SnakePos.XPos[i - 1]
                end;
                SnakePos.BlickRichtung := WEST;
                SnakePos.XPos[1] := SnakePos.XPos[1] - 1
            end;
            77 : begin
                for i := SnakePos.Laenge downto 2 do begin
                    SnakePos.YPos[i] := SnakePos.YPos[i - 1];
                    SnakePos.XPos[i] := SnakePos.XPos[i - 1]
                end;
                SnakePos.BlickRichtung := OST;
                SnakePos.XPos[1] := SnakePos.XPos[1] + 1
            end;
            80 : begin
                for i := SnakePos.Laenge downto 2 do begin
                    SnakePos.YPos[i] := SnakePos.YPos[i - 1];
                    SnakePos.XPos[i] := SnakePos.XPos[i - 1]
                end;
                SnakePos.BlickRichtung := SUED;
                SnakePos.YPos[1] := SnakePos.YPos[1] + 1
            end
        end;
        SetHindernis(Koordinaten, SnakePos, SnakeNahrung);
        Hindernis(Koordinaten, SnakePos, SnakeNahrung, Fehlschlag)
    end;

procedure SpielEinrichten;
    begin
        {Den Rahmen als Hindernis eintragen}
        for i := 1 to 50 do begin
            fKoordinaten[i, 1] := true;
        end;
        for i := 1 to 25 do begin
            fKoordinaten[1, i] := true;
        end;
        for i := 1 to 50 do begin
            fKoordinaten[i, 25] := true;
        end;
        for i := 1 to 25 do begin
            fKoordinaten[50, i] := true;
        end;
        {Level bestimmen}
        repeat {(s = 0) or (s = 1) or (s = 2) or (s = 3) or (s = 4) or (s = 5) or (s = 6) or (s = 7) or (s = 8) or (s = 9)}
            GoToXY(55, 3);
            Write('Level (0-9)');
            s := ReadKey;
        until (s = '0') or (s = '1') or (s = '2') or (s = '3') or (s = '4')
            or (s = '5') or (s = '6') or (s = '7') or (s = '8') or (s = '9');
        Val(s, isLevelAnzeige, i);
        GoToXY(55, 3);
        Write('Level: ', isLevelAnzeige, '    ');
        GoToXY(55, 4);
        Write('L„nge: ', posSnake.Laenge);
        {Aus isLevel die Spielgeschwindigkeit errechnen.}
        case isLevelAnzeige of
            0 : isLevel := 13;
            1 : isLevel := 12;
            2 : isLevel := 11;
            3 : isLevel := 10;
            4 : isLevel := 9;
            6 : isLevel := 8;
            7 : isLevel := 7;
            8 : isLevel := 6;
            9 : isLevel := 5
        end
    end;

procedure SpielFeldDefault;
    begin
        ClrScr;
        Write('É');
        GotoXY(1, 25);
        Write('È');
        GoToXY(50, 1);
        Write('Ë');
        GoToXY(50, 25);
        Write('Ê');
        GoToXY(79, 1);
        Write('»');
        GoToXY(79, 25);
        Write('¼');
        GoToXY(1, 2);
        for i := 2 to 24 do begin
            Write('º');
            GoToXY(50, i);
            Write('º');
            GotoXY(79, i);
            WriteLn('º')
        end; {i := 2 to 24 do begin}
        GoToXY(2, 1);
        for i := 2 to 49 do
            Write('Í');
        GoToXY(51, 1);
        for i := 51 to 78 do
            Write('Í');
        GoToXY(2, 25);
        for i := 2 to 49 do
            Write('Í');
        GoToXY(51, 25);
        for i := 51 to 78 do
            Write('Í')
    end; {SpielFeldDefault}

begin {of Hauptprogramm}

    for i := 1 to 255 do begin
        posSnake.XPos[i] := 1;
        posSnake.XPos[i] := 1;
    end;
    Randomize;
    ClrScr;
    Writeln ('SnakeS 1.0');
    Writeln ('        Jan-Philipp Kappmeier 1999');
    {Zeitmesser einrichten}
    GoToXY(1, 5);
    WriteLn('Programm einrichten...');
    WriteLn('Dies dauert ca. 10 sec.');
    ilDelayTime := GetDelay;
    WriteLn('Delay: ', ilDelayTime );
    {Hauptschleife zum wiederhohlten starten.}
    repeat  {until sNochMal = 'n'}
        { Tastaturspeicher leeren }
        while Keypressed do
            ch := ReadKey;
        fFehlschlag := false;
        sNochmal := 'n';
        { Einrichten der Oberfl„che }
        SpielFeldDefault;
        { Spiel starten }
        posSnake.Laenge := 3;
        posSnake.BlickRichtung := WEST;
        for i := 1 to 3 do begin
            posSnake.XPos[i] := i + 46;
            posSnake.YPos[i] := 24
        end; {i := 1 to 3 do begin}
        fKoordinaten[50, 24] := true;
        fKoordinaten[49, 24] := true;
        SpielEinrichten;
        SetNahrung(fKoordinaten, posSnake, nahSnake);
        ch := ReadKey;
        {Spielschleife}
        isSnakeLaenge := 0;
        repeat {until fFehlschlag}
            isOldLen := posSnake.Laenge;
            ShowSnake(fKoordinaten, posSnake, nahSnake, fFehlschlag);
            {Automatisches Erh”hen des Levels bei einigen gefundenen
             Freáteilchen, Geschwindigkeit quadratisch abfallend.}
            {Erh”hen des Z„hlers der Schlangenl„nge seit dem letzen
             Levelerh”hen}
            if posSnake.Laenge > isOldLen then isSnakeLaenge := isSnakeLaenge + 1;
            if isSnakeLaenge = (isLevelAnzeige + 1) * 3 then begin
                isSnakeLaenge := 0;
                isLevel := isLevel - 1;
                if isLevel = 0 then isLevel := 1;
                isLevelAnzeige := isLevelAnzeige + 1;
                if isLevelAnzeige = 10 then isLevelAnzeige := 9;
                GoToXY(55, 3);
                Write('Level: ', isLevelAnzeige, '    ');
            end;
            until fFehlschlag;
        repeat {until (sNochMal = 'j') or (sNochMal = 'n')}
            ClrScr;
            GoToXY(1, 25);
            Write('bock noch mal zu zocken?(j/n) ');
            sNochMal := ReadKey;
        until (sNochMal = 'j') or (sNochMal = 'n')
    until sNochMal = 'n';
    WriteLn
end. { of main }

{ (c) Jan-Philipp Kappmeier, 1999 }
