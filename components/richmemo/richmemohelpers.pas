{
 richmemohelpers.pas

 Author: Dmitry 'skalogryz' Boyarintsev

 *****************************************************************************
 *                                                                           *
 *  This file is part of the Lazarus Component Library (LCL)                 *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}
unit RichMemoHelpers;

interface

uses
  RichMemo, Graphics;

{$IFDEF FPC_FULLVERSION >= 20600}

type
  TRichEditFromRichMemo = class(TObject);
  TTextAttributes = class(TRichEditFromRichMemo);
  TParaAttributes = class(TRichEditFromRichMemo);

  TRichEditAlignment = (taLeftJustify, taRightJustify, taCenter, taFullJustify);

  { TRichEditTextAttributes }

  TRichEditTextAttributes = class helper for TTextAttributes
  private
    function GetColor: TColor;
    function GetStyles: TFontStyles;
    procedure SetColor(AValue: TColor);
    function GetName: string;
    procedure SetName(const AValue: string);
    function GetSize: Integer;
    procedure SetSize(const ASize: Integer);
    procedure SetStyles(AValue: TFontStyles);
  public
    property Color: TColor read GetColor write SetColor;
    property Name: string read GetName write SetName;
    property Size: Integer read GetSize write SetSize;
    property Style: TFontStyles read GetStyles write SetStyles;
  end;

  { TRichEditParaAttributes }

  TRichEditParaAttributes = class helper for TParaAttributes
  private
    function GetFirstIndent: Integer;
    function GetLeftIndent: Integer;
    function GetRightIndent: Integer;
    function GetTab(Index: Byte): Integer;
    function GetTabCount: Integer;
    procedure SetFirstIndent(AValue: Integer);
    procedure SetLeftIndent(AValue: Integer);
    procedure SetRightIndent(AValue: Integer);
    procedure SetTab(Index: Byte; AValue: Integer);
    procedure SetTabCount(AValue: Integer);
  protected
    function GetAlignment: TRichEditAlignment;
    procedure SetAlignment(const AAlignment: TRichEditAlignment);
  public
    property Alignment: TRichEditAlignment read GetAlignment write SetAlignment;
    property FirstIndent: Integer read GetFirstIndent write SetFirstIndent;
    property LeftIndent: Integer read GetLeftIndent write SetLeftIndent;
    property RightIndent: Integer read GetRightIndent write SetRightIndent;
    property Tab[Index: Byte]: Integer read GetTab write SetTab;
    property TabCount: Integer read GetTabCount write SetTabCount;
  end;

  { TRichEditForMemo }

  TRichEditForMemo = class helper for TCustomRichMemo
  public
    function SelAttributes: TTextAttributes;
    function Paragraph: TParaAttributes;
  end;
{$ELSE}
  {$WARNING Class Helpers require FPC 2.6.0 or later, RichEdit compatible methods will not be available }
{$ENDIF}

implementation

{$IFDEF FPC_FULLVERSION >= 20600}

{ TRichEditTextAttributes }

function TRichEditTextAttributes.GetColor: TColor;
var
  prm : TFontParams;
  m   : TCustomRichMemo;
begin
  m := TCustomRichMemo(TObject(Self));
  m.GetTextAttributes(m.SelStart, prm);
  Result:=prm.Color;
end;

function TRichEditTextAttributes.GetStyles: TFontStyles;
var
  prm : TFontParams;
  m   : TCustomRichMemo;
begin
  m := TCustomRichMemo(TObject(Self));
  m.GetTextAttributes(m.SelStart, prm);
  Result:=prm.Style;
end;

function TRichEditTextAttributes.GetName: string;
var
  m : TCustomRichMemo;
  prm: TFontParams;
begin
  m := TCustomRichMemo(TObject(Self));
  m.GetTextAttributes(m.SelStart, prm);
  Result:=prm.Name;
end;

procedure TRichEditTextAttributes.SetColor(AValue: TColor);
var
  m : TCustomRichMemo;
begin
  m := TCustomRichMemo(TObject(Self));
  m.SetRangeParams( m.SelStart, m.SelLength, [tmm_Color], '', 0, AValue, [], []);
end;

procedure TRichEditTextAttributes.SetName(const AValue: string);
var
  m : TCustomRichMemo;
begin
  m := TCustomRichMemo(TObject(Self));
  m.SetRangeParams( m.SelStart, m.SelLength, [tmm_Name], AValue, 0, 0, [], []);
end;

function TRichEditTextAttributes.GetSize: Integer;
var
  m  : TCustomRichMemo;
  prm: TFontParams;
begin
  m := TCustomRichMemo(TObject(Self));
  m.GetTextAttributes(m.SelStart, prm);
  Result:=prm.Size;
end;

procedure TRichEditTextAttributes.SetSize(const ASize: Integer);
var
  m : TCustomRichMemo;
begin
  m := TCustomRichMemo(TObject(Self));
  m.SetRangeParams( m.SelStart, m.SelLength, [tmm_Size], '', ASize, 0, [], []);
end;

procedure TRichEditTextAttributes.SetStyles(AValue: TFontStyles);
var
  m   : TCustomRichMemo;
begin
  m := TCustomRichMemo(TObject(Self));
  m.SetRangeParams(m.SelStart, m.SelLength, [tmm_Styles], '', 0, 0, AValue, []);
end;

{ TRichEditParaAttributes }

const
  ScreenDPI    = 96;
  EditDPI      = 72;
  PtToPixel    = EditDPI / ScreenDPI;
  PixelToPt    = ScreenDPI / EditDPI;

function TRichEditParaAttributes.GetFirstIndent: Integer;
var
  m   : TCustomRichMemo;
  mt  : TParaMetric;
begin
  m := TCustomRichMemo(TObject(Self));
  m.GetParaMetric( m.SelStart, mt);
  Result := Round((mt.FirstLine - mt.HeadIndent) * PtToPixel);
end;

function TRichEditParaAttributes.GetLeftIndent: Integer;
var
  m   : TCustomRichMemo;
  mt  : TParaMetric;
begin
  m := TCustomRichMemo(TObject(Self));
  m.GetParaMetric( m.SelStart, mt);
  Result := Round(( mt.HeadIndent) * PtToPixel);
end;

function TRichEditParaAttributes.GetRightIndent: Integer;
var
  m   : TCustomRichMemo;
  mt  : TParaMetric;
begin
  m := TCustomRichMemo(TObject(Self));
  m.GetParaMetric( m.SelStart, mt);
  Result := Round(( mt.TailIndent) * PtToPixel);
end;

function TRichEditParaAttributes.GetTab(Index: Byte): Integer;
begin
  Result:=0;
end;

function TRichEditParaAttributes.GetTabCount: Integer;
begin
  Result:=0;
end;

procedure TRichEditParaAttributes.SetFirstIndent(AValue: Integer);
var
  m   : TCustomRichMemo;
  mt  : TParaMetric;
begin
  m := TCustomRichMemo(TObject(Self));
  m.GetParaMetric( m.SelStart, mt);
  mt.FirstLine:=mt.HeadIndent + AValue * PixelToPt;
  m.SetParaMetric( m.SelStart, m.SelLength, mt);
end;

procedure TRichEditParaAttributes.SetLeftIndent(AValue: Integer);
var
  m   : TCustomRichMemo;
  mt  : TParaMetric;
begin
  m := TCustomRichMemo(TObject(Self));
  m.GetParaMetric( m.SelStart, mt);
  mt.HeadIndent:=AValue * PixelToPt;
  m.SetParaMetric( m.SelStart, m.SelLength, mt);
end;

procedure TRichEditParaAttributes.SetRightIndent(AValue: Integer);
var
  m   : TCustomRichMemo;
  mt  : TParaMetric;
begin
  m := TCustomRichMemo(TObject(Self));
  m.GetParaMetric( m.SelStart, mt);
  mt.TailIndent:=AValue * PixelToPt;
  m.SetParaMetric( m.SelStart, m.SelLength, mt);
end;

procedure TRichEditParaAttributes.SetTab(Index: Byte; AValue: Integer);
begin
  //todo
end;

procedure TRichEditParaAttributes.SetTabCount(AValue: Integer);
begin
  //todo
end;

function TRichEditParaAttributes.GetAlignment: TRichEditAlignment;
var
  m  : TCustomRichMemo;
  al :TParaAlignment;
begin
  m:=TCustomRichMemo(TObject(Self));
  m.GetParaAlignment(m.SelStart, al);
  case al of
    paRight:   Result:=taRightJustify;
    paCenter:  Result:=taCenter;
    paJustify: Result:=taFullJustify;
  else
    Result:=taLeftJustify;
  end;
end;

procedure TRichEditParaAttributes.SetAlignment(const AAlignment: TRichEditAlignment);
var
  m  : TCustomRichMemo;
const
  ReToMemA : array [TRichEditAlignment] of TParaAlignment = (paLeft, paRight, paCenter, paJustify);
begin
  m:=TCustomRichMemo(TObject(Self));
  m.SetParaAlignment(m.SelStart, m.SelLength, ReToMemA[AAlignment]);
end;

{ TRichEditForMemo }

function TRichEditForMemo.SelAttributes: TTextAttributes;
begin
  Result:=TTextAttributes(TObject(Self));
end;

function TRichEditForMemo.Paragraph: TParaAttributes;
begin
  Result:=TParaAttributes(TObject(Self));
end;
{$ENDIF}

end.
