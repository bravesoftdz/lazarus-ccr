unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, memds, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, DbCtrls, Buttons, jdbintegeredit, jdbdateedit,
  jdbcurrencyedit, jdblabeledcurrencyedit;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    Datasource1: TDatasource;
    DBNavigator1: TDBNavigator;
    JDBCurrencyEdit1: TJDBCurrencyEdit;
    JDBDateEdit1: TJDBDateEdit;
    JDBIntegerEdit1: TJDBIntegerEdit;
    JDBIntegerEdit2: TJDBIntegerEdit;
    JDBLabeledCurrencyEdit1: TJDBLabeledCurrencyEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    MemDataset1: TMemDataset;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
begin
  // populate the memDataset
  for i := 1 to 10 do
  begin
    MemDataset1.Append;
    MemDataset1.FieldByName('ID').AsInteger := i;
    MemDataset1.FieldByName('DATE').AsDateTime := Now;
    MemDataset1.FieldByName('ID2').AsInteger := i * i;
    MemDataset1.FieldByName('TOTAL').AsFloat := i * i * i;
    MemDataset1.Post;
  end;
  MemDataset1.First;
end;

end.
