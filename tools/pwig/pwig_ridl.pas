﻿{ @abstract(This unit contains PWIG RIDL file generator (usable by Delphi COM tools).)
  @author(Tomas Krysl)

  Copyright (c) Tomas Krysl <BR><BR>

  Generated outputs tested in:
  -Delphi XE, Win32 (callee)

  <B>License:</B><BR>
  This code is distributed as a freeware. You are free to use it as part
  of your application for any purpose including freeware, commercial and
  shareware applications. The origin of this source code must not be
  misrepresented; you must not claim your authorship. All redistributions
  of the original or modified source code must retain the original copyright
  notice. The Author accepts no liability for any damage that may result
  from using this code.
}

unit pwig_ridl;

{$mode delphi}

interface

uses
  Classes, SysUtils, PWIGGen;

type

  { TPWIGGenRIDL }

  TPWIGGenRIDL = class(TPWIGGenerator)
  private
    FFlags: string;
    FIndent: string;
    procedure IncIndent;
    procedure DecIndent;
    procedure ClearFlags;
    procedure AddFlag(AFlag: Boolean; const AFlagText: string);
    procedure WriteBracketBegin;
    procedure WriteBracketEnd;
    procedure WriteCurlyBegin;
    procedure WriteCurlyEnd;
    procedure WriteSpace;
    property Flags: string read FFlags;
    property Indent: string read FIndent;
  protected
    F: TextFile;
    function GetDescription: string; override;
    function GetName: string; override;
    function InterfaceToString(AIntf: TPWIGInterface): string; virtual;
    function TypeToString(AType: TPWIGType; AUseEnums: Boolean = True): string; virtual;
    procedure WriteElementProps(AElement: TPWIGElement); virtual;
    procedure WriteAliasProps(AAlias: TPWIGAlias); virtual;
    procedure WriteEnumProps(AEnum: TPWIGEnum); virtual;
    procedure WriteMethod(AMethod: TPWIGMethod; AGetter, ACallingConv: Boolean); virtual;
    procedure WriteInterfaceProps(AIntf: TPWIGInterface); virtual;
    procedure WriteClassProps(AClass: TPWIGClass); virtual;
  public
    constructor Create(AOwner: TPWIG); override;
    procedure SaveCalleeFiles(const AFileName: string); override;
    procedure SaveCallerFiles(const AFileName: string); override;
  end;

implementation

uses
  KFunctions;

{ TPWIGGenRIDL }

constructor TPWIGGenRIDL.Create(AOwner: TPWIG);
begin
  inherited Create(AOwner);
  FIndent := '';
end;

procedure TPWIGGenRIDL.IncIndent;
begin
  FIndent := FIndent + '  ';
end;

procedure TPWIGGenRIDL.DecIndent;
begin
  Delete(FIndent, 1, 2);
end;

procedure TPWIGGenRIDL.ClearFlags;
begin
  FFlags := '';
end;

procedure TPWIGGenRIDL.AddFlag(AFlag: Boolean; const AFlagText: string);
begin
  if AFlag then
  begin
    if FFlags <> '' then
      FFlags := FFlags + ', ';
    FFlags := FFlags + AFlagText;
  end;
end;

function TPWIGGenRIDL.InterfaceToString(AIntf: TPWIGInterface): string;
begin
  if AIntf.FlagDispEvents then
    Result := 'dispinterface'
  else
    Result := 'interface';
end;

function TPWIGGenRIDL.TypeToString(AType: TPWIGType; AUseEnums: Boolean): string;
begin
  Result := '';
  case AType.BaseType of
    btLongInt: Result := 'long';
    btLongWord: Result := 'unsigned long';
    btSmallInt: Result := 'short';
    btWord: Result := 'unsigned short';
    btInt64: Result := '__int64';
    btUInt64: Result := 'unsigned __int64';
    btSingle: Result := 'single';
    btDouble: Result := 'double';
    btUnicodeString: Result := 'BSTR';
    btRawByteString: Result := 'LPSTR'; // memory management not supported by COM!
    btCurrency: Result := 'CURRENCY';
    btDateTime: Result := 'DATE';
    btEnum:
      if AUseEnums then
        Result := 'enum ' + FPWIG.Enums.FindName(AType.CustomTypeGUID, AType.CustomTypeName)
      else
        Result := 'unsigned long';
    btAlias: Result := FPWIG.Aliases.FindName(AType.CustomTypeGUID, AType.CustomTypeName);
    btInterface: Result := FPWIG.Interfaces.FindName(AType.CustomTypeGUID, AType.CustomTypeName) + '*';
  end;
end;

procedure TPWIGGenRIDL.WriteBracketBegin;
begin
  Writeln(F, Indent, '[');
  IncIndent;
end;

procedure TPWIGGenRIDL.WriteBracketEnd;
begin
  DecIndent;
  Writeln(F, Indent, ']');
end;

procedure TPWIGGenRIDL.WriteCurlyBegin;
begin
  Writeln(F, Indent, '{');
  IncIndent;
end;

procedure TPWIGGenRIDL.WriteCurlyEnd;
begin
  DecIndent;
  Writeln(F, Indent, '};');
end;

procedure TPWIGGenRIDL.WriteSpace;
begin
  Writeln(F);
end;

function TPWIGGenRIDL.GetDescription: string;
begin
  Result := 'RIDL (Delphi version of COM IDL). Usable in Delphi.';
end;

function TPWIGGenRIDL.GetName: string;
begin
  Result := 'RIDL';
end;

procedure TPWIGGenRIDL.SaveCalleeFiles(const AFileName: string);
var
  LIntf: TPWIGInterface;
  LCls: TPWIGClass;
  LAlias: TPWIGAlias;
  LEnum: TPWIGEnum;
begin
  AssignFile(F, AFileName);
  try
    try
      Rewrite(F);

      // write file header (warning etc.)
      Writeln(F, Indent, '// ************************************************************************ //');
      Writeln(F, Indent, '// WARNING');
      Writeln(F, Indent, '// -------');
      Writeln(F, Indent, '// This file was generated by PWIG. Do not edit.');
      Writeln(F, Indent, '// File generated on ', DateTimeToStr(Now));
      WriteSpace;

      // write library props
      WriteElementProps(FPWIG);

      // begin to write library
      Writeln(F, Indent, 'library ', FPWIG.Name);
      WriteCurlyBegin;
      WriteSpace;

      // write library imports
      // now hardcoded, later might be automated when needed
      Writeln(F, Indent, 'importlib("stdole2.tlb");');
      WriteSpace;

      // write interface and class forward declarations
      for LIntf in FPWIG.Interfaces do
        Writeln(F, Indent, InterfaceToString(LIntf), ' ', LIntf.Name, ';');
      for LCls in FPWIG.Classes do
        Writeln(F, Indent, 'coclass ', LCls.Name, ';');
      WriteSpace;

      // write enums
      for LEnum in FPWIG.Enums do
        WriteEnumProps(LEnum);

      // write aliases
      for LAlias in FPWIG.Aliases do
        WriteAliasProps(LAlias);

      // write interfaces
      for LIntf in FPWIG.Interfaces do
        WriteInterfaceProps(LIntf);

      // write classes
      for LCls in FPWIG.Classes do
        WriteClassProps(LCls);

      // finish
      WriteCurlyEnd;

      Writeln('RIDL file generated: ', AFileName);
    except
      Writeln('Could not generate RIDL file: ', AFileName);
    end;
  finally
    CloseFile(F);
  end;
end;

procedure TPWIGGenRIDL.SaveCallerFiles(const AFileName: string);
begin
  // nothing to do, caller must import type library from registry, write notice
  Writeln('RIDL generator cannot output caller wrappers, register and import type library instead!');
end;

procedure TPWIGGenRIDL.WriteElementProps(AElement: TPWIGElement);
begin
  WriteBracketBegin;
  if AElement.GUID <> '' then
    Writeln(F, Indent, 'uuid(', XMLGUIDToGUIDNoCurlyBraces(AElement.GUID), '),');
  if AElement.Description <> '' then
    Writeln(F, Indent, 'helpstring("', AElement.Description, '"),');
  if AElement.Version <> '' then
    Writeln(F, Indent, 'version(', AElement.Version, '),');
  if (AElement is TPWIGInterface) and TPWIGInterface(AElement).FlagDual then
    Writeln(F, Indent, 'dual,');
  if (AElement is TPWIGInterface) and TPWIGInterface(AElement).FlagOleAutomation then
    Writeln(F, Indent, 'oleautomation,');
  WriteBracketEnd;
end;

procedure TPWIGGenRIDL.WriteAliasProps(AAlias: TPWIGAlias);
begin
  WriteElementProps(AAlias);
  Writeln(F, Indent, 'typedef ', TypeToString(AAlias.AliasedType), ' ', AAlias.Name, ';');
  WriteSpace;
end;

procedure TPWIGGenRIDL.WriteEnumProps(AEnum: TPWIGEnum);
var
  I: Integer;
  Elem: TPWIGEnumElement;
begin
  WriteElementProps(AEnum);
  Writeln(F, Indent, 'enum ', AEnum.Name);
  WriteCurlyBegin;
  for I := 0 to AEnum.Elements.Count - 1 do
  begin
    Elem := AEnum.Elements[I];
    Write(F, Indent, Elem.Name, ' = ', Elem.Value);
    if I < AEnum.Elements.Count - 1 then
      Writeln(F, ',')
    else
      Writeln(F);
  end;
  WriteCurlyEnd;
  WriteSpace;
end;

procedure TPWIGGenRIDL.WriteMethod(AMethod: TPWIGMethod; AGetter, ACallingConv: Boolean);
var
  I: Integer;
  Param: TPWIGParam;
  S: string;
begin
  // always HRESULT and stdcall
  if ACallingConv then
    S := '_stdcall'
  else
    S := '';
  Write(F, Indent, 'HRESULT', ' ', S, ' ', AMethod.Name, '(');
  if AMethod.Params.Count = 0 then
    Writeln(F, 'void);')
  else
  begin
    for I := 0 to AMethod.Params.Count - 1 do
    begin
      Param := AMethod.Params[I];
      if AMethod is TPWIGProperty then
      begin
        // all params are [in] except last one which is [out, retval] for a getter
        if not AGetter or (I < AMethod.Params.Count - 1) then
          Write(F, '[in] ', TypeToString(Param.ParamType, TPWIGProperty(AMethod).PropertyType = ptWriteOnly), ' ', Param.Name)
        else
          Write(F, '[out, retval] ', TypeToString(Param.ParamType, TPWIGProperty(AMethod).PropertyType = ptWriteOnly), '* ', Param.Name);
      end else
      begin
        // write param flags as specified
        ClearFlags;
        AddFlag(Param.FlagInput, 'in');
        AddFlag(Param.FlagOutput, 'out');
        AddFlag(Param.FlagRetVal, 'retval');
        if Param.FlagOutput then
          S := '*'
        else
          S := '';
        if Flags = '' then
          AddFlag(True, 'in');
        Write(F, '[', Flags, '] ', TypeToString(Param.ParamType), S, ' ', Param.Name)
      end;
      if I < AMethod.Params.Count - 1 then
        Write(F, ', ')
      else
        Writeln(F, ');');
    end;
  end;
end;

procedure TPWIGGenRIDL.WriteInterfaceProps(AIntf: TPWIGInterface);

  procedure WriteMethods;
  var
    Method: TPWIGMethod;
    Id: string;
  begin
    if AIntf.FlagDispEvents then
      Writeln(F, Indent, 'methods:');
    for Method in AIntf.Methods do
    begin
      Id := IntToHexStr(Method.Id, 8, '0x', '', False);
      Writeln(F, Indent, '[id(', Id, ')]');
      WriteMethod(Method, False, not AIntf.FlagDispEvents);
    end;
  end;

  procedure WriteProperties;
  var
    Prop: TPWIGProperty;
    Id: string;
  begin
    if AIntf.FlagDispEvents then
      Writeln(F, Indent, 'properties:');
    for Prop in AIntf.Properties do
    begin
      Id := IntToHexStr(Prop.Id, 8, '0x', '', False);
      if Prop.PropertyType in [ptReadOnly, ptReadWrite] then
      begin
        // write getter
        Writeln(F, Indent, '[propget, id(', Id, ')]');
        WriteMethod(Prop, True, not AIntf.FlagDispEvents);
      end;
      if Prop.PropertyType in [ptWriteOnly, ptReadWrite] then
      begin
        // write setter
        Writeln(F, Indent, '[propput, id(', Id, ')]');
        WriteMethod(Prop, False, not AIntf.FlagDispEvents);
      end;
    end;
  end;

begin
  WriteElementProps(AIntf);
  Write(F, Indent, InterfaceToString(AIntf), ' ', AIntf.Name);
  if AIntf.FlagDispEvents or (AIntf.BaseInterface = '') then
    Writeln(F)
  else
    Writeln(F, ': ', AIntf.BaseInterface);
  WriteCurlyBegin;
  if AIntf.FlagDispEvents then
  begin
    WriteProperties;
    WriteMethods;
  end else
  begin
    WriteMethods;
    WriteProperties;
  end;
  WriteCurlyEnd;
  WriteSpace;
end;

procedure TPWIGGenRIDL.WriteClassProps(AClass: TPWIGClass);
var
  Ref: TPWIGInterfaceRef;
  LIntf: TPWIGInterface;
begin
  WriteElementProps(AClass);
  Writeln(F, Indent, 'coclass', ' ', AClass.Name);
  WriteCurlyBegin;
  for Ref in AClass.InterfaceRefs do
  begin
    LIntf := FPWIG.Interfaces.Find(Ref.RefGUID, Ref.RefName);
    if LIntf <> nil then
    begin
      ClearFlags;
      AddFlag(Ref.FlagDefault, 'default');
      AddFlag(Ref.FlagSource, 'source');
      Writeln(F, Indent, '[', Flags, '] ', InterfaceToString(LIntf), ' ', LIntf.Name, ';');
    end;
  end;
  WriteCurlyEnd;
  WriteSpace;
end;

end.

