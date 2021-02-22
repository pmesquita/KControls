unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF FPC}
    LCLIntf, LResources, MaskEdit,
  {$ELSE}
    Windows, Messages, Mask,
  {$ENDIF}
    SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, ActnList, ExtCtrls, ComCtrls, StrUtils,
    KGrids, KControls, KDialogs, KGraphics, KFunctions;

type

  { TForm2 }

  { TMyTextCell }

  TMyTextCell = class(TKGridAttrTextCell)
  private
    FAsNumeric: Integer;
    FBoolToInt: Boolean;
    FAsString: String;
    procedure SetBoolToInt(AValue: Boolean);
  protected
    procedure Initialize; override;
  public
    procedure Assign(Source: TKGridCell); override;
    Property BoolToInt: Boolean          Read FBoolToInt  Write SetBoolToInt;
    Property AsString : String  read FAsString  Write FAsString;
    Property AsNumeric: Integer read FAsNumeric write FAsNumeric;

  end;


  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    KGrid1: TKGrid;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KGrid1Click(Sender: TObject);
    procedure KGrid1EditorCreate(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TWinControl);
    procedure KGrid1EditorDataFromGrid(Sender: TObject; AEditor: TWinControl;
      ACol, ARow: Integer; var AssignText: Boolean);
    procedure KGrid1EditorDataToGrid(Sender: TObject; AEditor: TWinControl;
      ACol, ARow: Integer; var AssignText: Boolean);
  private
    Procedure LoadGrid(ARows: Integer);
    procedure OnTComboBoxClick(Sender: TObject);

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TMyTextCell }

procedure TMyTextCell.SetBoolToInt(AValue: Boolean);
begin
  //if FBoolToInt= AValue then Exit;
   FBoolToInt:= AValue;

   If (AValue = True) Then
     AsNumeric:= 1
   Else
     AsNumeric:= 0;
end;

procedure TMyTextCell.Initialize;
 begin
   inherited;
   FAsNumeric := 0;
   FAsString:= '';
 end;

procedure TMyTextCell.Assign(Source: TKGridCell);
begin
  inherited;
  if Source is TMyTextCell then
  begin
    FAsNumeric := TMyTextCell(Source).AsNumeric;
    FAsString := TMyTextCell(Source).AsString;
  end;
end;

{ TForm2 }

procedure TForm2.KGrid1Click(Sender: TObject);
begin
 Label1.Caption:= Format('Selected Row : %d', [KGrid1.SelectedRow]);
 Label2.Caption:= Format('Selected Text: %s', [KGrid1.Cells[2, KGrid1.SelectedRow]]);
end;

Procedure TForm2.KGrid1EditorCreate(Sender: TObject; ACol, ARow: Integer; var AEditor: TWinControl);
 Begin
  Case ACol Of
    2: Begin
        AEditor:= TComboBox.Create(Nil);
        TComboBox(AEditor).OnClick:= @OnTComboBoxClick;
        TComboBox(AEditor).Items.Add('Não');
        TComboBox(AEditor).Items.Add('Sim');
        TComboBox(AEditor).Items.Add('Talvez');
        TComboBox(AEditor).Items.Add('Quem Sabe');
        TComboBox(AEditor).Items.Add('Acho que não');
        TComboBox(AEditor).Items.Add('Acho que sim');
        TComboBox(AEditor).Style := csDropDown; // cannot set height on Win!
       End;
  End;
 End;

procedure TForm2.KGrid1EditorDataFromGrid(Sender: TObject;
  AEditor: TWinControl; ACol, ARow: Integer; var AssignText: Boolean);
begin
  If (ACol = 2) Then
   //Begin
   //   ShowMessage('DataFromGrid: ' + KGrid1.Cells[2, ARow] );
   // TComboBox(AEditor).ItemIndex:= TComboBox(AEditor).Items.IndexOf( KGrid1.Cells[2, ARow] );
   //
   //End;
end;

procedure TForm2.KGrid1EditorDataToGrid(Sender: TObject; AEditor: TWinControl; ACol, ARow: Integer; var AssignText: Boolean);
Var
  Cell: TMyTextCell;
  Texto: String;
begin
  // If (ACol = 2) Then
  // Begin
  //Cell := TMyTextCell(KGrid1.Cell[2, ARow]);
  //Texto:= GetControlText(AEditor);
  //
  //  ShowMessage('DataToGrid: ' + Texto);
  //  Cell.AsNumeric:= AnsiIndexStr(Texto, ['Não', 'Sim', 'Talvez', 'Quem Sabe', 'Acho que não', 'Acho que sim']);
  //
  // End;

end;

procedure TForm2.FormCreate(Sender: TObject);
begin
 //KGrid1.CellClass := TMyTextCell;
 //KGrid1.RealizeCellClass; // in fact this is not necessary here because all cells are still nil

 KGrid1.Cells[0, 0]:= 'Coluna 00';
 KGrid1.Cells[1, 0]:= 'Coluna 01';
 KGrid1.Cells[2, 0]:= 'TComboBox';
 KGrid1.Cells[3, 0]:= 'Coluna 03';
 KGrid1.Cells[4, 0]:= 'Coluna 04';
 KGrid1.Cells[5, 0]:= 'Coluna 05';

 KGrid1.ClearRows;
 //Grid1Click(Sender);
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
  Form2.LoadGrid(3);
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  KGrid1.DeleteRow(KGrid1.SelectedRow);
end;

procedure TForm2.Button5Click(Sender: TObject);
begin
 //TMyTextCell(KGrid1.Cell[2, 2]).BoolToInt:= True;
 KGrid1.Cells[2, 2]:= 'Sim';
end;

procedure TForm2.Button6Click(Sender: TObject);
begin
  ShowMessage(KGrid1.Cells[2, 2]  );
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


     //TMyTextCell(KGrid1.Cell[4, Pred(KGrid1.RowCount)]).AsBoolean:= True;
     KGrid1.Cells[0, LRowIndex]:= DateToStr(Now);
     KGrid1.Cells[1, LRowIndex]:= Random(200).ToString;
     KGrid1.Cells[2, LRowIndex]:= 'Não';
    End;
  Finally
   KGrid1.UnlockUpdate;
  End;
 End;

procedure TForm2.OnTComboBoxClick(Sender: TObject);
begin

end;

end.

