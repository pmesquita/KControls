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
    KGrids, KControls, KDialogs, KGraphics, KFunctions, Types;

type

  { TForm2 }

  { TMyTextCell }

  TMyTextCell = class(TKGridAttrTextCell)
  private
    FAsNumeric: Integer;
    FAsBoolean: Boolean;
    FAsString: String;
  protected
    procedure Initialize; override;
  public
    procedure Assign(Source: TKGridCell); override;
    Property AsBoolean : Boolean Read FAsBoolean  Write FAsBoolean;
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
    procedure KGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; R: TRect;
      State: TKGridDrawState);
    procedure KGrid1EditorCreate(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TWinControl);
    procedure KGrid1EditorDataFromGrid(Sender: TObject; AEditor: TWinControl;
      ACol, ARow: Integer; var AssignText: Boolean);
    procedure KGrid1EditorDataToGrid(Sender: TObject; AEditor: TWinControl;
      ACol, ARow: Integer; var AssignText: Boolean);
    procedure KGrid1EditorResize(Sender: TObject; AEditor: TWinControl; ACol,
      ARow: Integer; var ARect: TRect);
    procedure KGrid1EditorSelect(Sender: TObject; AEditor: TWinControl; ACol,
      ARow: Integer; SelectAll, CaretToLeft, SelectedByMouse: Boolean);
    procedure KGrid1MeasureCell(Sender: TObject; ACol, ARow: Integer; R: TRect;
      State: TKGridDrawState; Priority: TKGridMeasureCellPriority;
      var Extent: TPoint);
    procedure KGrid1MouseClickCell(Sender: TObject; ACol, ARow: Integer);
  private
    Procedure LoadGrid(ARows: Integer);
    procedure OnTComboBoxClick(Sender: TObject);
    Procedure PrepareCellPainter(ACol, ARow: Integer; R: TRect; State: TKGridDrawState);
  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TMyTextCell }

procedure TMyTextCell.Initialize;
 begin
   inherited;
   FAsNumeric := 0;
   FAsString:= '';
   FAsBoolean:= False;
 end;

procedure TMyTextCell.Assign(Source: TKGridCell);
begin
  inherited;
  //if Source is TMyTextCell then
  begin
    FAsNumeric := TMyTextCell(Source).AsNumeric;
    FAsString := TMyTextCell(Source).AsString;
    FAsBoolean:= TMyTextCell(Source).AsBoolean;
  end;
end;

{ TForm2 }

procedure TForm2.KGrid1Click(Sender: TObject);
begin
 Label1.Caption:= Format('Selected Row : %d', [KGrid1.SelectedRow]);
 //Label2.Caption:= Format('Selected Text: %s', [KGrid1.Cells[2, KGrid1.SelectedRow]]);
end;

procedure TForm2.KGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; R: TRect;
  State: TKGridDrawState);
begin
    // To enable full autosize feature, following function is needed
  PrepareCellPainter(ACol, ARow, R, State);
  { Calling CellPainter.DefaultDraw ensures standard cell painting with
    modified attributes like Brush or Font. You can still use
    DefaultDrawCell as in KGrid 1.0. but it is deprecated. }
  KGrid1.CellPainter.DefaultDraw;
end;

procedure TForm2.KGrid1EditorCreate(Sender: TObject; ACol, ARow: Integer;
  var AEditor: TWinControl);
 Begin
  Case ACol Of
    2: Begin
        AEditor:= TCheckBox.Create(Nil);
        TCheckBox(AEditor).Checked:= False;
        //TCheckBox(AEditor).Caption:= 'Habilitar';

        //AEditor:= TComboBox.Create(Nil);
        //TComboBox(AEditor).OnClick:= @OnTComboBoxClick;
        //TComboBox(AEditor).Items.Add('Não');
        //TComboBox(AEditor).Items.Add('Sim');
        //TComboBox(AEditor).Items.Add('Talvez');
        //TComboBox(AEditor).Items.Add('Quem Sabe');
        //TComboBox(AEditor).Items.Add('Acho que não');
        //TComboBox(AEditor).Items.Add('Acho que sim');
        //TComboBox(AEditor).Style := csDropDown; // cannot set height on Win!
       End;
  End;
 End;

procedure TForm2.KGrid1EditorDataFromGrid(Sender: TObject;
  AEditor: TWinControl; ACol, ARow: Integer; var AssignText: Boolean);
var
  Cell: TMyTextCell;
 Begin
  If (ACol = 2) Then
   Begin
    Cell:= TMyTextCell(KGrid1.Cell[ACol, ARow]);
    TCheckBox(AEditor).Checked:= Cell.AsBoolean;
   End;
 End;

procedure TForm2.KGrid1EditorDataToGrid(Sender: TObject; AEditor: TWinControl; ACol, ARow: Integer; var AssignText: Boolean);
Var
  Cell: TMyTextCell;
 Begin
   If (ACol = 2) Then
   Begin
    Cell:= TMyTextCell(KGrid1.Cell[2, ARow]);
    Cell.AsBoolean:= TCheckBox(AEditor).Checked;
   End;
   AssignText := False;
 End;

procedure TForm2.KGrid1EditorResize(Sender: TObject; AEditor: TWinControl;
  ACol, ARow: Integer; var ARect: TRect);
var
  InitialCol: Integer;
begin
  InitialCol := KGrid1.InitialCol(ACol); // map column indexes
  // you can change the position and size of your editor within the cell here
  case InitialCol of
    2: Inc(ARect.Left, KGrid1.CellPainter.CheckBoxHPadding);
  end;

end;

procedure TForm2.KGrid1EditorSelect(Sender: TObject; AEditor: TWinControl;
  ACol, ARow: Integer; SelectAll, CaretToLeft, SelectedByMouse: Boolean);
begin
    if SelectedByMouse and (KGrid1.InitialCol(ACol) in [2]) then
    KGrid1.ThroughClick := True;
  KGrid1.DefaultEditorSelect(AEditor, ACol, ARow, SelectAll, CaretToLeft, SelectedByMouse);
end;

procedure TForm2.KGrid1MeasureCell(Sender: TObject; ACol, ARow: Integer;
  R: TRect; State: TKGridDrawState; Priority: TKGridMeasureCellPriority;
  var Extent: TPoint);
begin
    { To enable full autosize feature, we must call exactly the same code
    affecting the cellpainter settings as in OnDrawCell. This code cannot paint anything! }
  PrepareCellPainter(ACol, ARow, R, State);
  { Calling CellPainter.DefaultMeasure obtains the cell contents from default
    implementation }
  Extent := KGrid1.CellPainter.DefaultMeasure(Priority);
end;

procedure TForm2.KGrid1MouseClickCell(Sender: TObject; ACol, ARow: Integer);
begin
   { Example for new multiple selections. Add new selection when clicking on fixed cell. }
  if (ACol = 0) and (ARow >= KGrid1.FixedRows) then
    Kgrid1.AddSelection(GridRect(KGrid1.FixedCols, ARow, KGrid1.ColCount - 1, ARow));
  if (ARow = 0) and (ACol >= KGrid1.FixedCols) then
    Kgrid1.AddSelection(GridRect(ACol, KGrid1.FixedRows, ACol, KGrid1.RowCount - 1));
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
 KGrid1.CellClass := TMyTextCell;
 KGrid1.RealizeCellClass; // in fact this is not necessary here because all cells are still nil

 KGrid1.Cells[0, 0]:= 'Coluna 00';
 KGrid1.Cells[1, 0]:= 'Coluna 01';
 KGrid1.Cells[2, 0]:= 'TCheckBox';
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
  TMyTextCell(KGrid1.Cell[2, 2]).AsBoolean:= True;
end;

procedure TForm2.Button6Click(Sender: TObject);
begin
  ShowMessage( TMyTextCell(KGrid1.Cells[2, 2]).AsBoolean.ToString );
end;

Procedure TForm2.LoadGrid(ARows: Integer);
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
     TMyTextCell(KGrid1.Cell[2, LRowIndex]).AsBoolean:= True;
     //TMyTextCell(KGrid1.Cell[2, LRowIndex]).Text:= 'Habilitar';
    End;
  Finally
   KGrid1.UnlockUpdate;
  End;
 End;

procedure TForm2.OnTComboBoxClick(Sender: TObject);
begin

end;

Procedure TForm2.PrepareCellPainter(ACol, ARow: Integer; R: TRect; State: TKGridDrawState);
var
  InitialCol, InitialRow: Integer;
  Cell: TMyTextCell;
begin
  InitialCol := KGrid1.InitialCol(ACol); // map column indexes
  InitialRow := KGrid1.InitialRow(ARow); // map row indexes
  Cell := TMyTextCell(KGrid1.Cell[ACol, ARow]); // we know it is always the case
  { apply specific paint properties first - applies the cell class specific
    settings to the CellPainter. If you write your own cell class make any
    specific drawing adjustments to be accessible through ApplyDrawProperties. }
  Cell.ApplyDrawProperties;

  // get cell text
  if (InitialRow = 1) and (InitialCol > 0) then
    // display initial column positions in the (initially) first row
    KGrid1.CellPainter.Text := IntToStr(KGrid1.Cols[ACol].InitialPos);
  //else if Cell.Number <> 0 then
  //  { Display cell text and cell number. The Text property of CellPainter
  //    is already filled with the Text property of the corresponding TKGridTextCell
  //    cell instance. }
  //  KGrid1.CellPainter.Text := KGrid1.CellPainter.Text + ' ' + IntToStr(Cell.Number);
  // mouse "hover" simulation for default grid colors
  with KGrid1.CellPainter.Canvas do
  begin
    if gdMouseOver in State then
      if gdFocused in State then
        Brush.Color := BrightColor(Brush.Color, 0.2, bsOfTop)
      else if ColorToRGB(Brush.Color) <> clWhite then
        Brush.Color := BrightColor(Brush.Color, 0.4, bsOfTop)
      else
        Brush.Color := $E0F8F8;
  end;
  if InitialRow > 1 then
  begin
    if InitialCol = 3 then
    begin
      { Painting a graphic in a cell. Reworked in version 1.6. Incorporated into DefaultDraw. }
      KGrid1.CellPainter.GraphicHAlign := halLeft;
      KGrid1.CellPainter.GraphicVAlign := valCenter;
      KGrid1.CellPainter.GraphicVPadding := 1;
      KGrid1.CellPainter.GraphicDrawText := True;
//      KGrid1.CellPainter.Graphic := FThumbNail;
      KGrid1.CellPainter.GraphicStretchMode := stmZoomOutOnly;
    end
    else if InitialCol = 2 then
    begin
      { Painting a check box frame in the cell is very likely a common programming
        task. That's why I encapsulated this task into TKGridCellPainter. }
      KGrid1.CellPainter.CheckBox := True;
      Case TMyTextCell(KGrid1.Cell[ACol, ARow]).AsBoolean Of
        True : KGrid1.CellPainter.CheckBoxState := cbChecked;
        False: KGrid1.CellPainter.CheckBoxState := cbUnchecked;
      End;
      KGrid1.CellPainter.CheckBoxHAlign := halCenter;
    {$IFDEF LCLQT}
      // QT workaround: QT cannot draw checkbox transparent here
      if gdEdited in State then
        KGrid1.CellPainter.Canvas.Brush.Color := KGrid1.Color;
    {$ENDIF}
      end;
    end;
  // apply custom text output attributes
  if (InitialRow > 1) and (InitialCol = 6) then
    KGrid1.CellPainter.Attributes := [taEndEllipsis, taLineBreak, taWordBreak]
  else
    KGrid1.CellPainter.Attributes := [taEndEllipsis]; // this is the default
  end;


//
//var
//  InitialCol, InitialRow: Integer;
//  Cell: TMyTextCell;
//begin
//  InitialCol := KGrid1.InitialCol(ACol); // map column indexes
//  InitialRow := KGrid1.InitialRow(ARow); // map row indexes
//
//  Cell := TMyTextCell(KGrid1.Cell[ACol, ARow]); // we know it is always the case
//  { apply specific paint properties first - applies the cell class specific
//    settings to the CellPainter. If you write your own cell class make any
//    specific drawing adjustments to be accessible through ApplyDrawProperties. }
//  Cell.ApplyDrawProperties;
//
//  //// get cell text
//  //if (InitialRow = 1) and (InitialCol > 0) then
//  //  // display initial column positions in the (initially) first row
//  //  KGrid1.CellPainter.Text := IntToStr(KGrid1.Cols[ACol].InitialPos)
//  //else if Cell.Number <> 0 then
//  //  { Display cell text and cell number. The Text property of CellPainter
//  //    is already filled with the Text property of the corresponding TKGridTextCell
//  //    cell instance. }
//  //  KGrid1.CellPainter.Text := KGrid1.CellPainter.Text + ' ' + IntToStr(Cell.Number);
//  //// mouse "hover" simulation for default grid colors
//  with KGrid1.CellPainter.Canvas do
//  begin
//    if gdMouseOver in State then
//      if gdFocused in State then
//        Brush.Color := BrightColor(Brush.Color, 0.2, bsOfTop)
//      else if ColorToRGB(Brush.Color) <> clWhite then
//        Brush.Color := BrightColor(Brush.Color, 0.4, bsOfTop)
//      else
//        Brush.Color := $E0F8F8;
//  end;
//  //if InitialRow > 1 then
//  //begin
//  //  if InitialCol = 3 then
//  //  begin
//  //    { Painting a graphic in a cell. Reworked in version 1.6. Incorporated into DefaultDraw. }
//  //    KGrid1.CellPainter.GraphicHAlign := halLeft;
//  //    KGrid1.CellPainter.GraphicVAlign := valCenter;
//  //    KGrid1.CellPainter.GraphicVPadding := 1;
//  //    KGrid1.CellPainter.GraphicDrawText := True;
//  //    KGrid1.CellPainter.Graphic := FThumbNail;
//  //    KGrid1.CellPainter.GraphicStretchMode := stmZoomOutOnly;
//  //  end
//  If (ARow > 0) Then
//   Begin
//     if ACol = 2 then
//      begin
//        { Painting a check box frame in the cell is very likely a common programming
//          task. That's why I encapsulated this task into TKGridCellPainter. }
//        KGrid1.CellPainter.CheckBox := True;
//        Case TMyTextCell(KGrid1.Cell[ACol, ARow]).AsBoolean Of
//          True : KGrid1.CellPainter.CheckBoxState := cbChecked;
//          False: KGrid1.CellPainter.CheckBoxState := cbUnchecked;
//        End;
//        KGrid1.CellPainter.CheckBoxHAlign := halCenter;
//        KGrid1.CellPainter.CheckBoxVAlign:= valCenter
//      {$IFDEF LCLQT}
//        // QT workaround: QT cannot draw checkbox transparent here
//        if gdEdited in State then
//          KGrid1.CellPainter.Canvas.Brush.Color := KGrid1.Color;
//      {$ENDIF}
//        end;
//      end;
//    // apply custom text output attributes
//  if (InitialRow > 1) and (InitialCol = 6) then
//    KGrid1.CellPainter.Attributes := [taEndEllipsis, taLineBreak, taWordBreak]
//  else
//    KGrid1.CellPainter.Attributes := [taEndEllipsis, taWordBreak]; // this is the default
//  End;



end.

