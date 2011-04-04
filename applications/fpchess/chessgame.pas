unit chessgame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpimage, dateutils,
  Forms, Controls, Graphics, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls, Buttons, Spin;

const
  colA = 1;
  colB = 2;
  colC = 3;
  colD = 4;
  colE = 5;
  colF = 6;
  colG = 7;
  colH = 8;

  INT_CHESSTILE_SIZE = 40;
  INT_CHESSBOARD_SIZE = 40 * 8;

  FPCOLOR_TRANSPARENT_TILE: TFPColor = (Red: $0000; Green: $8100; Blue: $8100; Alpha: alphaOpaque); //+/-colTeal

type

  TPacketKind = (pkConnect, pkStartGameClientAsWhite, pkStartGameClientAsBlack, pkMove);
  BitBoard = array[1..8] of array [1..8] of boolean;

  { TPacket }

  TPacket = class
  public
    // Packet Data
    ID: Cardinal;
    Kind: TPacketKind;
    MoveStartX, MoveStartY, MoveEndX, MoveEndY: Byte;
    Next: TPacket; // To build a linked list
  end;

  TChessTile = (ctEmpty,
    ctWPawn, ctWKnight, ctWBishop, ctWRook, ctWQueen, ctWKing,
    ctBPawn, ctBKnight, ctBBishop, ctBRook, ctBQueen, ctBKing
    );

const
  WhitePieces = [ctWPawn, ctWKnight, ctWBishop, ctWRook, ctWQueen, ctWKing];
  BlackPieces = [ctBPawn, ctBKnight, ctBBishop, ctBRook, ctBQueen, ctBKing];

type
  {@@
    The index [1][1] refers to the left-bottom corner of the table,
    also known as A1.
    The first index is the column, to follow the same standard used to
    say coordinates, for example: C7 = [3][7]
  }
  TChessBoard = array[1..8] of array[1..8] of TChessTile;

  { TChessGame }

  TChessGame = class
  public
    Board: TChessBoard;
    msg : String;
    CurrentPlayerIsWhite: Boolean;
    Dragging: Boolean;
    DragStart, MouseMovePos: TPoint;
    UseTimer: Boolean;
    WhitePlayerTime: Integer; // milisseconds
    BlackPlayerTime: Integer; // milisseconds
    MoveStartTime: TDateTime;
    constructor Create;
    procedure StartNewGame(APlayAsWhite: Boolean; AUseTimer: Boolean; APlayerTime: Integer); overload;
    procedure StartNewGame(APlayAsWhite: Integer; AUseTimer: Boolean; APlayerTime: Integer); overload;
    function ClientToBoardCoords(AClientCoords: TPoint): TPoint;
    function CheckStartMove(AFrom: TPoint): Boolean;
    function MovePiece(AFrom, ATo: TPoint): Boolean;
    function ValidateRookMove(AFrom, ATo: TPoint) : boolean;
    function ValidateKnightMove(AFrom, ATo: TPoint) : boolean;
    function ValidateBishopMove(AFrom, ATo: TPoint) : boolean;
    function ValidateQueenMove(AFrom, ATo: TPoint) : boolean;
    function ValidateKingMove(AFrom, ATo: TPoint) : boolean;
    function ValidatePawnMove(AFrom, ATo: TPoint) : boolean;
    function IsSquareOccupied(ASquare: TPoint): Boolean;

    procedure UpdateTimes();
  end;

var
  vChessGame: TChessGame;

implementation

{ TChessGame }

constructor TChessGame.Create;
begin
  inherited Create;


end;

procedure TChessGame.StartNewGame(APlayAsWhite: Boolean; AUseTimer: Boolean; APlayerTime: Integer);
var
  lWPawnRow, lWMainRow, lBPawnRow, lBMainRow: Byte;
  i: Integer;
  j: Integer;
begin
  UseTimer := AUseTimer;
  CurrentPlayerIsWhite := True;
  WhitePlayerTime := APlayerTime * 60 * 1000; // minutes to milisseconds
  BlackPlayerTime := APlayerTime * 60 * 1000; // minutes to milisseconds
  MoveStartTime := Now;

  //
  if APlayAsWhite then
  begin
    lWPawnRow := 2;
    lWMainRow := 1;
    lBPawnRow := 7;
    lBMainRow := 8;
  end
  else
  begin
    lWPawnRow := 7;
    lWMainRow := 8;
    lBPawnRow := 2;
    lBMainRow := 1;
  end;

  // First, clear the board
  for i := 1 to 8 do
   for j := 1 to 8 do
    Board[i][j] := ctEmpty;

  // White pawns
  for i := 1 to 8 do
   Board[i][lWPawnRow] := ctWPawn;

  // White main row
  Board[1][lWMainRow] := ctWRook;
  Board[2][lWMainRow] := ctWKnight;
  Board[3][lWMainRow] := ctWBishop;
  Board[4][lWMainRow] := ctWQueen;
  Board[5][lWMainRow] := ctWKing;
  Board[6][lWMainRow] := ctWBishop;
  Board[7][lWMainRow] := ctWKnight;
  Board[8][lWMainRow] := ctWRook;

  // White pawns
  for i := 1 to 8 do
   Board[i][lBPawnRow] := ctBPawn;

  // Black main row
  Board[1][lBMainRow] := ctBRook;
  Board[2][lBMainRow] := ctBKnight;
  Board[3][lBMainRow] := ctBBishop;
  Board[4][lBMainRow] := ctBQueen;
  Board[5][lBMainRow] := ctBKing;
  Board[6][lBMainRow] := ctBBishop;
  Board[7][lBMainRow] := ctBKnight;
  Board[8][lBMainRow] := ctBRook;
end;

procedure TChessGame.StartNewGame(APlayAsWhite: Integer; AUseTimer: Boolean; APlayerTime: Integer);
begin
  StartNewGame(APlayAsWhite = 0, AUseTimer, APlayerTime);
end;

{
  Returns: If the move is valid and was executed
}
function TChessGame.MovePiece(AFrom, ATo: TPoint): Boolean;
begin
  result := false;
  //AFrom.x:=AFrom.x;
  //AFrom.y:=AFrom.y+2;
  //if not CheckStartMove(AFrom) then Exit;

  if ( (Board[AFrom.X][AFrom.Y]) in WhitePieces ) then begin
  	if Board[AFrom.X][AFrom.Y] = ctWRook then result:=(ValidateRookMove(AFrom,ATo));;
    if Board[AFrom.X][AFrom.Y] = ctWKnight then result :=(ValidateKnightMove(AFrom,ATo));
    if Board[AFrom.X][AFrom.Y] = ctWBishop then result :=(ValidateBishopMove(AFrom,ATo));
    if Board[AFrom.X][AFrom.Y] = ctWQueen then result :=(ValidateQueenMove(AFrom,ATo));
    if Board[AFrom.X][AFrom.Y] = ctWKing then result :=(ValidateKingMove(AFrom,ATo));
    if Board[AFrom.X][AFrom.Y] = ctWPawn then result :=(ValidatePawnMove(AFrom,ATo));
  end
  else begin
    if Board[AFrom.X][AFrom.Y] = ctBRook then result :=(ValidateRookMove(AFrom,ATo));
    if Board[AFrom.X][AFrom.Y] = ctBKnight then result :=(ValidateKnightMove(AFrom,ATo));
    if Board[AFrom.X][AFrom.Y] = ctBBishop then result :=(ValidateBishopMove(AFrom,ATo));
    if Board[AFrom.X][AFrom.Y] = ctBQueen then result :=(ValidateQueenMove(AFrom,ATo));
    if Board[AFrom.X][AFrom.Y] = ctBKing then result :=(ValidateKingMove(AFrom,ATo));
    if Board[AFrom.X][AFrom.Y] = ctBPawn then result :=(ValidatePawnMove(AFrom,ATo));
  end;
//  ShowMessage('Resultado := ' + BoolToStr(result,true));
  if (result) then begin
	  // col, row
	  Board[ATo.X][ATo.Y] := Board[AFrom.X][AFrom.Y];
	  Board[AFrom.X][AFrom.Y] := ctEmpty;

	  UpdateTimes();
	  CurrentPlayerIsWhite := not CurrentPlayerIsWhite;
  end;
end;

//return true if the move of a Rook is valid.
function TChessGame.ValidateRookMove(AFrom, ATo: TPoint): boolean;
var AttackedSquares : BitBoard;
    i,j : Integer;
    l : integer = 0;
    haveCaptured: boolean = false; //already have captured a piece
    willBeACapture : boolean = false;// the movement will be a capture
    validMove : boolean = false; //if the piece in the 'to' square is not of the same color of the player
//    mensagem : String;
begin

  for i:=1 to 8 do  // initialize the bitboard of attacked pieces.
    for j:=1 to 8 do
      AttackedSquares[i][j]:= false;
//  ShowMessage('vai passar pelo up');

//////////////////////////////////////UP////////////////////////////////////////
  l := AFrom.y+1;
  if (l<=8) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[AFrom.x][l] in BlackPieces);
      validMove:= not (Board[AFrom.x][l] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[AFrom.x][l] in WhitePieces);
      validMove:=not (Board[AFrom.x][l] in BlackPieces)
    end;
  end
  else
    l :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (l <= 8) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[AFrom.x][l] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    l := l+1;
    if (l<=8) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[AFrom.x][l] in BlackPieces);
        validMove:= not (Board[AFrom.x][l] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[AFrom.x][l] in WhitePieces);
        validMove:=not (Board[AFrom.x][l] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END UP///////////////////////////////////////
///////////////////////////////////DOWN/////////////////////////////////////////
  haveCaptured:=false;
  l := AFrom.y-1;
  if (l>=1) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[AFrom.x][l] in BlackPieces);
      validMove:= not (Board[AFrom.x][l] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[AFrom.x][l] in WhitePieces);
      validMove:=not (Board[AFrom.x][l] in BlackPieces)
    end;
  end
  else
    l :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (l >= 1) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[AFrom.x][l] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    l := l-1;
    if (l>=1) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[AFrom.x][l] in BlackPieces);
        validMove:= not (Board[AFrom.x][l] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[AFrom.x][l] in WhitePieces);
        validMove:=not (Board[AFrom.x][l] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END DOWN/////////////////////////////////////
////////////////////////////////////RIGHT////////////////////////////////////////
  haveCaptured:=false;
  l := AFrom.x+1;
  if (l<=8) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[l][AFrom.y] in BlackPieces);
      validMove:= not (Board[l][AFrom.y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[l][AFrom.y] in WhitePieces);
      validMove:=not (Board[l][AFrom.y] in BlackPieces)
    end;
  end
  else
    l :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (l <= 8) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[l][AFrom.y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    l := l+1;
    if (l<=8) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[l][AFrom.y] in BlackPieces);
        validMove:= not (Board[l][AFrom.y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[l][AFrom.y] in WhitePieces);
        validMove:=not (Board[l][AFrom.y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END RIGHT////////////////////////////////////
///////////////////////////////////LEFT/////////////////////////////////////////
  haveCaptured:=false;
  l := AFrom.x-1;
  if (l>=1) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[l][AFrom.y] in BlackPieces);
      validMove:= not (Board[l][AFrom.y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[l][AFrom.y] in WhitePieces);
      validMove:=not (Board[l][AFrom.y] in BlackPieces)
    end;
  end
  else
    l :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (l >= 1) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[l][AFrom.y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    l := l-1;
    if (l>=1) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[l][AFrom.y] in BlackPieces);
        validMove:= not (Board[l][AFrom.y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[l][AFrom.y] in WhitePieces);
        validMove:=not (Board[l][AFrom.y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END LEFT/////////////////////////////////////


{  for i:=1 to 8 do begin //To show the bitboard
    for j:=1 to 8 do
      mensagem := mensagem + BoolToStr(AttackedSquares[i][j],'1','0') + ' ';
  	mensagem := mensagem + #13;
  end;

ShowMessage(mensagem);}
//result:=true;
  	result := (AttackedSquares[Ato.X][Ato.y]);
end;
function TChessGame.ValidateKnightMove(AFrom, ATo: TPoint): Boolean;
begin
result:=true;
end;
function TChessGame.ValidateBishopMove(AFrom, ATo: TPoint): Boolean;
var AttackedSquares : BitBoard;
    i,j : Integer;
    x,y : integer;
    haveCaptured: boolean = false; //already have captured a piece
    willBeACapture : boolean = false;// the movement will be a capture
    validMove : boolean = false; //if the piece in the 'to' square is not of the same color of the player
    mensagem : String;
begin
  for i:=1 to 8 do  // initialize the bitboard of attacked pieces.
    for j:=1 to 8 do
      AttackedSquares[i][j]:= false;
//  ShowMessage('vai passar pelo up left');
//////////////////////////////////////UP LEFT///////////////////////////////////
  y := AFrom.y+1;
  x := AFrom.x-1;
  if (x>=1) and (y<=8) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[x][y] in BlackPieces);
      validMove:= not (Board[x][y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[x][y] in WhitePieces);
      validMove:=not (Board[x][y] in BlackPieces)
    end;
  end
  else
    y :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (x>=1) and (y <= 8) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[x][y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    y := y+1;
    x := x-1;
    if (x>=1) and (y<=8) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[x][y] in BlackPieces);
        validMove:= not (Board[x][y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[x][y] in WhitePieces);
        validMove:=not (Board[x][y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END UP LEFT//////////////////////////////////

//////////////////////////////////////UP RIGHT//////////////////////////////////
  y := AFrom.y+1;
  x := AFrom.x+1;
  willBeACapture:=false;
  if (x<=8) and (y<=8) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[x][y] in BlackPieces);
      validMove:= not (Board[x][y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[x][y] in WhitePieces);
      validMove:=not (Board[x][y] in BlackPieces)
    end;
  end
  else
    y :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (x<=8) and (y <= 8) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[x][y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    y := y+1;
    x := x+1;
    if (x<=8) and (y<=8) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[x][y] in BlackPieces);
        validMove:= not (Board[x][y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[x][y] in WhitePieces);
        validMove:=not (Board[x][y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END UP RIGHT/////////////////////////////////
//////////////////////////////////////DOWN LEFT/////////////////////////////////
  y := AFrom.y-1;
  x := AFrom.x-1;
  willBeACapture:=false;
  if (x>=1) and (y>=1) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[x][y] in BlackPieces);
      validMove:= not (Board[x][y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[x][y] in WhitePieces);
      validMove:=not (Board[x][y] in BlackPieces)
    end;
  end
  else
    y :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (x>=1) and (y >= 1) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[x][y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    y := y-1;
    x := x-1;
    if (x>=1) and (y>=1) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[x][y] in BlackPieces);
        validMove:= not (Board[x][y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[x][y] in WhitePieces);
        validMove:=not (Board[x][y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END DOWN LEFT////////////////////////////////
//////////////////////////////////////DOWN RIGHT////////////////////////////////
  y := AFrom.y-1;
  x := AFrom.x+1;
  willBeACapture:=false;
  if (x<=8) and (y>=1) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[x][y] in BlackPieces);
      validMove:= not (Board[x][y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[x][y] in WhitePieces);
      validMove:=not (Board[x][y] in BlackPieces)
    end;
  end
  else
    y :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (x<=8) and (y >= 1) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[x][y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    y := y-1;
    x := x+1;
    if (x<=8) and (y>=1) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[x][y] in BlackPieces);
        validMove:= not (Board[x][y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[x][y] in WhitePieces);
        validMove:=not (Board[x][y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END DOWN RIGHT///////////////////////////////

  {for i:=1 to 8 do begin //To show the bitboard
    for j:=1 to 8 do
      mensagem := mensagem + BoolToStr(AttackedSquares[i][j],'1','0') + ' ';
  	mensagem := mensagem + #13;
  end;

ShowMessage(mensagem);}

result := (AttackedSquares[Ato.X][Ato.y]);

end;
function TChessGame.ValidateQueenMove(AFrom, ATo: TPoint): Boolean;
var AttackedSquares : BitBoard;
    i,j : Integer;
    x,y,l : integer; //l it's the same of the y or x, just an index.
    haveCaptured: boolean = false; //already have captured a piece
    willBeACapture : boolean = false;// the movement will be a capture
    validMove : boolean = false; //if the piece in the 'to' square is not of the same color of the player
    mensagem : String;
begin

  for i:=1 to 8 do  // initialize the bitboard of attacked pieces.
    for j:=1 to 8 do
      AttackedSquares[i][j]:= false;
//  ShowMessage('vai passar pelo up');

//////////////////////////////////////UP////////////////////////////////////////
  l := AFrom.y+1;
  if (l<=8) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[AFrom.x][l] in BlackPieces);
      validMove:= not (Board[AFrom.x][l] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[AFrom.x][l] in WhitePieces);
      validMove:=not (Board[AFrom.x][l] in BlackPieces)
    end;
  end
  else
    l :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (l <= 8) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[AFrom.x][l] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    l := l+1;
    if (l<=8) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[AFrom.x][l] in BlackPieces);
        validMove:= not (Board[AFrom.x][l] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[AFrom.x][l] in WhitePieces);
        validMove:=not (Board[AFrom.x][l] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END UP///////////////////////////////////////
///////////////////////////////////DOWN/////////////////////////////////////////
  haveCaptured:=false;
  l := AFrom.y-1;
  if (l>=1) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[AFrom.x][l] in BlackPieces);
      validMove:= not (Board[AFrom.x][l] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[AFrom.x][l] in WhitePieces);
      validMove:=not (Board[AFrom.x][l] in BlackPieces)
    end;
  end
  else
    l :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (l >= 1) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[AFrom.x][l] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    l := l-1;
    if (l>=1) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[AFrom.x][l] in BlackPieces);
        validMove:= not (Board[AFrom.x][l] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[AFrom.x][l] in WhitePieces);
        validMove:=not (Board[AFrom.x][l] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////DOWN/////////////////////////////////////////

////////////////////////////////////RIGHT////////////////////////////////////////
  haveCaptured:=false;
  l := AFrom.x+1;
  if (l<=8) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[l][AFrom.y] in BlackPieces);
      validMove:= not (Board[l][AFrom.y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[l][AFrom.y] in WhitePieces);
      validMove:=not (Board[l][AFrom.y] in BlackPieces)
    end;
  end
  else
    l :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (l <= 8) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[l][AFrom.y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    l := l+1;
    if (l<=8) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[l][AFrom.y] in BlackPieces);
        validMove:= not (Board[l][AFrom.y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[l][AFrom.y] in WhitePieces);
        validMove:=not (Board[l][AFrom.y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END RIGHT////////////////////////////////////
///////////////////////////////////LEFT/////////////////////////////////////////
  haveCaptured:=false;
  l := AFrom.x-1;
  if (l>=1) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[l][AFrom.y] in BlackPieces);
      validMove:= not (Board[l][AFrom.y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[l][AFrom.y] in WhitePieces);
      validMove:=not (Board[l][AFrom.y] in BlackPieces)
    end;
  end
  else
    l :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (l >= 1) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[l][AFrom.y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    l := l-1;
    if (l>=1) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[l][AFrom.y] in BlackPieces);
        validMove:= not (Board[l][AFrom.y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[l][AFrom.y] in WhitePieces);
        validMove:=not (Board[l][AFrom.y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END LEFT/////////////////////////////////////
//////////////////////////////////////UP LEFT///////////////////////////////////
  y := AFrom.y+1;
  x := AFrom.x-1;
  if (x>=1) and (y<=8) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[x][y] in BlackPieces);
      validMove:= not (Board[x][y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[x][y] in WhitePieces);
      validMove:=not (Board[x][y] in BlackPieces)
    end;
  end
  else
    y :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (x>=1) and (y <= 8) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[x][y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    y := y+1;
    x := x-1;
    if (x>=1) and (y<=8) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[x][y] in BlackPieces);
        validMove:= not (Board[x][y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[x][y] in WhitePieces);
        validMove:=not (Board[x][y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END UP LEFT//////////////////////////////////

//////////////////////////////////////UP RIGHT//////////////////////////////////
  y := AFrom.y+1;
  x := AFrom.x+1;
  willBeACapture:=false;
  if (x<=8) and (y<=8) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[x][y] in BlackPieces);
      validMove:= not (Board[x][y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[x][y] in WhitePieces);
      validMove:=not (Board[x][y] in BlackPieces)
    end;
  end
  else
    y :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (x<=8) and (y <= 8) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[x][y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    y := y+1;
    x := x+1;
    if (x<=8) and (y<=8) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[x][y] in BlackPieces);
        validMove:= not (Board[x][y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[x][y] in WhitePieces);
        validMove:=not (Board[x][y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END UP RIGHT/////////////////////////////////
//////////////////////////////////////DOWN LEFT/////////////////////////////////
  y := AFrom.y-1;
  x := AFrom.x-1;
  willBeACapture:=false;
  if (x>=1) and (y>=1) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[x][y] in BlackPieces);
      validMove:= not (Board[x][y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[x][y] in WhitePieces);
      validMove:=not (Board[x][y] in BlackPieces)
    end;
  end
  else
    y :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (x>=1) and (y >= 1) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[x][y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    y := y-1;
    x := x-1;
    if (x>=1) and (y>=1) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[x][y] in BlackPieces);
        validMove:= not (Board[x][y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[x][y] in WhitePieces);
        validMove:=not (Board[x][y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END DOWN LEFT////////////////////////////////
//////////////////////////////////////DOWN RIGHT////////////////////////////////
  y := AFrom.y-1;
  x := AFrom.x+1;
  willBeACapture:=false;
  if (x<=8) and (y>=1) then begin
  	if (CurrentPlayerIsWhite) then begin
      willBeACapture:= (Board[x][y] in BlackPieces);
      validMove:= not (Board[x][y] in WhitePieces);
    end
    else begin
      willBeACapture:=(Board[x][y] in WhitePieces);
      validMove:=not (Board[x][y] in BlackPieces)
    end;
  end
  else
    y :=0; // if it is in the border of the board, put 0 in l to skip the while below.
  haveCaptured:=false;
  while ( (x<=8) and (y >= 1) and (validMove) and (not haveCaptured)) do begin
    AttackedSquares[x][y] := true;
    if (willBeACapture) then
      haveCaptured:=true;
    y := y-1;
    x := x+1;
    if (x<=8) and (y>=1) then begin //again to not have an 'out of bounds' error
  	  if (CurrentPlayerIsWhite) then begin
        willBeACapture:= (Board[x][y] in BlackPieces);
        validMove:= not (Board[x][y] in WhitePieces);
      end
      else begin
        willBeACapture:=(Board[x][y] in WhitePieces);
        validMove:=not (Board[x][y] in BlackPieces)
      end;
    end;
  end;
///////////////////////////////////END DOWN RIGHT///////////////////////////////

  for i:=1 to 8 do begin //To show the bitboard
    for j:=1 to 8 do
      mensagem := mensagem + BoolToStr(AttackedSquares[i][j],'1','0') + ' ';
  	mensagem := mensagem + #13;
  end;

//ShowMessage(mensagem);
  result:= (AttackedSquares[Ato.X][Ato.y]);
end;

function TChessGame.ValidateKingMove(AFrom, ATo: TPoint): Boolean;
begin
  Result := True;
end;

{
  The white is always in the bottom at the moment,
  which means the smallest x,y values
}
function TChessGame.ValidatePawnMove(AFrom, ATo: TPoint): Boolean;
begin
  // ToDo: Verify if the kind will be in check

  Result := False;

  if CurrentPlayerIsWhite then
  begin
    // Normal move forward
    if (AFrom.X = ATo.X) and (AFrom.Y = ATo.Y - 1) then
    begin
      Result := not IsSquareOccupied(ATo);
    end
    // Initial double move forward
    else if (AFrom.X = ATo.X) and (AFrom.Y = 2) and (AFrom.Y = ATo.Y - 2) then
    begin
      Result := not IsSquareOccupied(ATo);
    end;
  end
  else
  begin
    // Normal move forward
    if (AFrom.X = ATo.X) and (AFrom.Y = ATo.Y + 1) then
    begin
      Result := not IsSquareOccupied(ATo);
    end
    // Initial double move forward
    else if (AFrom.X = ATo.X) and (AFrom.Y = 7) and (AFrom.Y = ATo.Y + 2) then
    begin
      Result := not IsSquareOccupied(ATo);
    end;
  end;
end;

function TChessGame.IsSquareOccupied(ASquare: TPoint): Boolean;
begin
  Result := Board[ASquare.X][ASquare.Y] <> ctEmpty;
end;

procedure TChessGame.UpdateTimes();
var
  lNow: TDateTime;
  lTimeDelta: Integer;
begin
  lNow := Now;

  lTimeDelta := MilliSecondsBetween(lNow, MoveStartTime);
  MoveStartTime := lNow;

  if CurrentPlayerIsWhite then WhitePlayerTime := WhitePlayerTime - lTimeDelta
  else BlackPlayerTime := BlackPlayerTime - lTimeDelta;
end;

function TChessGame.ClientToBoardCoords(AClientCoords: TPoint): TPoint;
begin
  Result.X := 1 + AClientCoords.X div INT_CHESSTILE_SIZE;
  Result.Y := 1 + (INT_CHESSBOARD_SIZE - AClientCoords.Y) div INT_CHESSTILE_SIZE;
end;

{@@
  AFrom - The start move position in board coordinates
}
function TChessGame.CheckStartMove(AFrom: TPoint): Boolean;
begin
  if CurrentPlayerIsWhite then
    Result := Board[AFrom.X][AFrom.Y] in WhitePieces
  else
    Result := Board[AFrom.X][AFrom.Y] in BlackPieces;
end;

initialization

vChessGame := TChessGame.Create;

finalization

vChessGame.Free;

end.

