unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  kgrids, Types;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    KGrid1: TKGrid;
    Label1: TLabel;
    Memo1: TMemo;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KGrid1Click(Sender: TObject);
    procedure KGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; R: TRect;
      State: TKGridDrawState);
  private
    Procedure LoadGrid(ARows: Integer);

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.KGrid1Click(Sender: TObject);
begin
 Label1.Caption:= Format('Selected Row: %d', [KGrid1.SelectedRow]);
end;

procedure TForm2.KGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; R: TRect;
  State: TKGridDrawState);
begin
  //
end;

procedure TForm2.FormCreate(Sender: TObject);
begin

 KGrid1.Cells[0, 0]:= 'Coluna 00';
 KGrid1.Cells[1, 0]:= 'Coluna 01';
 KGrid1.Cells[2, 0]:= 'Coluna 02';
 KGrid1.Cells[3, 0]:= 'Coluna 03';
 KGrid1.Cells[4, 0]:= 'Coluna 04';
 KGrid1.Cells[5, 0]:= 'Coluna 05';

 KGrid1.ClearRows;
 KGrid1Click(Sender);
 Form2.Button3Click(Sender);
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  KGrid1.Row:= 0;
  KGrid1Click(Sender);
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  KGrid1.ClearRows;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  Form2.LoadGrid(5000);
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  KGrid1.DeleteRow(KGrid1.SelectedRow);
end;

procedure TForm2.LoadGrid(ARows: Integer);
Var
  I: Integer;
  LRowIndex: Integer;
 Begin
  KGrid1.LockUpdate;
  Try
   For I:= 1 To ARows Do
    Begin
     LRowIndex:= KGrid1.AddRows();

     //TMyTextCell(KGrid1.Cell[3, Pred(KGrid1.RowCount)]).AsString:= DateToStr(Now);
     //TMyTextCell(KGrid1.Cell[4, Pred(KGrid1.RowCount)]).AsBoolean:= True;
     KGrid1.Cells[0, LRowIndex]:= DateToStr(Now);
     KGrid1.Cells[1, LRowIndex]:= Random(200).ToString;
    End;
  Finally
   KGrid1.UnlockUpdate;
  End;
 End;

end.

