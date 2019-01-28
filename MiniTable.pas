{------------------------------------------------------------------------------
TMiniTable component
Developed by Rodrigo Depin� Dalpiaz (dig�o dalpiaz)
To use as a small dinamic table stored as text file

https://github.com/digao-dalpiaz/MiniTable

Please, read the documentation at GitHub link.

File estructure example:
  ID=1,Nome=Jhon
  ID=2,Nome=Mary
------------------------------------------------------------------------------}

unit MiniTable;

interface

uses System.Classes;

type
  TMiniTable = class(TComponent)
  private
    FAbout: String;

    FFileName: String;
    FJumpOpen: Boolean; //JumpOpen - if file not exists, bypass open method (loads blank table)
    FAutoSave: Boolean;

    FSelIndex: Integer;

    Tb, S: TStringList;

    function GetField(const FieldName: String): Variant;
    procedure SetField(const FieldName: String; const Value: Variant);

    function GetCount: Integer;

    procedure Reset;

    procedure CheckAutoSave;
    function GetMemString: String;
    procedure SetMemString(const Value: String);
    procedure CheckInRecord;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Lines: TStringList read Tb;

    property MemString: String read GetMemString write SetMemString;
    property SelIndex: Integer read FSelIndex;
    property Count: Integer read GetCount;
    property F[const FieldName: String]: Variant read GetField write SetField;

    procedure SelReset;
    function InRecord: Boolean;

    procedure Open;
    procedure Save;
    procedure EmptyTable;
    procedure EmptyRecord;
    function IsEmpty: Boolean;
    procedure Select(Index: Integer);
    procedure First;
    procedure Last;
    function Next: Boolean;
    procedure New;
    procedure Insert(Index: Integer);
    procedure Post;
    procedure Delete;
    procedure MoveDown;
    procedure MoveUp;
    function Find(const FieldName: String; const Value: Variant; KeepIndex: Boolean = False): Boolean;
    function FieldExists(const FieldName: String): Boolean;
    function ReadDef(const FieldName: String; const Default: Variant): Variant;
  published
    property About: String read FAbout;

    property FileName: String read FFileName write FFileName;
    property AutoSave: Boolean read FAutoSave write FAutoSave default False;
    property JumpOpen: Boolean read FJumpOpen write FJumpOpen default True;
  end;

procedure Register;

implementation

uses System.SysUtils;

procedure Register;
begin
  RegisterComponents('Digao', [TMiniTable]);
end;

//

constructor TMiniTable.Create(AOwner: TComponent);
begin
  inherited;

  FAbout := 'Dig�o Dalpiaz / Version 1.0';

  FJumpOpen := True; //default

  Tb := TStringList.Create; //full table
  S := TStringList.Create; //selected record

  FSelIndex := -1;
end;

destructor TMiniTable.Destroy;
begin
  Tb.Free;
  S.Free;

  inherited;
end;

function TMiniTable.InRecord: Boolean;
begin
  Result := FSelIndex<>-1;
end;

procedure TMiniTable.CheckInRecord;
begin
  if not InRecord then
    raise Exception.Create('No record selected');
end;

procedure TMiniTable.SelReset;
begin
  if FSelIndex=-1 then Exit;

  S.Clear; //clear selected record
  FSelIndex := -1;
end;

procedure TMiniTable.Reset;
begin
  Tb.Clear;
  SelReset;
end;

procedure TMiniTable.Open;
begin
  Reset; //clear stringlist's and selection set

  if FJumpOpen then
    if not FileExists(FFileName) then Exit;

  Tb.LoadFromFile(FFileName);
end;

procedure TMiniTable.Save;
begin
  Tb.SaveToFile(FFileName);
end;

function TMiniTable.GetMemString: String;
begin
  Result := Tb.Text;
end;

procedure TMiniTable.SetMemString(const Value: String);
begin
  Reset;

  Tb.Text := Value;
end;


function TMiniTable.GetCount: Integer;
begin
  Result := Tb.Count;
end;

function TMiniTable.IsEmpty: Boolean;
begin
  Result := ( Count = 0 );
end;

function TMiniTable.GetField(const FieldName: String): Variant;
begin
  CheckInRecord;

  Result := S.Values[FieldName];
end;

procedure TMiniTable.SetField(const FieldName: String; const Value: Variant);
begin
  CheckInRecord;

  S.Values[FieldName] := Value;
end;

procedure TMiniTable.Select(Index: Integer);
begin
  if Index>Count-1 then raise Exception.CreateFmt('Record of index %d does not exist', [Index]);

  S.CommaText := Tb[Index];
  FSelIndex := Index;
end;

function TMiniTable.Next: Boolean;
begin
  Result := ( FSelIndex < Count-1 );

  if Result then
    Select(FSelIndex+1)
  else
    SelReset;
end;

procedure TMiniTable.First;
begin
  if IsEmpty then raise Exception.Create('There is no record to select');

  Select(0);
end;

procedure TMiniTable.Last;
begin
  if IsEmpty then raise Exception.Create('There is no record to select');

  Select(Count-1);
end;

procedure TMiniTable.New;
begin
  Tb.Add('');
  Last;
end;

procedure TMiniTable.Insert(Index: Integer);
begin
  Tb.Insert(Index, '');
  Select(Index);
end;

procedure TMiniTable.EmptyRecord;
begin
  CheckInRecord;

  S.Clear;
end;

procedure TMiniTable.Post;
begin
  CheckInRecord;

  Tb[FSelIndex] := S.CommaText;

  CheckAutoSave;
end;

procedure TMiniTable.Delete;
begin
  CheckInRecord;

  Tb.Delete(FSelIndex);
  SelReset;

  CheckAutoSave;
end;

procedure TMiniTable.MoveUp;
begin
  CheckInRecord;

  if FSelIndex=0 then raise Exception.Create('Already at first record');

  Tb.Exchange(FSelIndex, FSelIndex-1);
  Dec(FSelIndex);

  CheckAutoSave;
end;

procedure TMiniTable.MoveDown;
begin
  CheckInRecord;

  if FSelIndex=Count-1 then raise Exception.Create('Already at last record');

  Tb.Exchange(FSelIndex, FSelIndex+1);
  Inc(FSelIndex);

  CheckAutoSave;
end;

procedure TMiniTable.EmptyTable;
begin
  Reset; //clear stringlist's and selection set

  CheckAutoSave;
end;

procedure TMiniTable.CheckAutoSave;
begin
  if FAutoSave then Save;
end;

function TMiniTable.Find(const FieldName: String; const Value: Variant; KeepIndex: Boolean = False): Boolean;
var Idx: Integer;
begin
  Result := False;

  Idx := FSelIndex;
  try
    SelReset;
    while Next do
      if F[FieldName] = Value then Exit(True);
  finally
    if KeepIndex then
      if Idx<>-1 then
        Select(Idx)
      else
        SelReset;
  end;
end;

function TMiniTable.FieldExists(const FieldName: String): Boolean;
begin
  CheckInRecord;

  Result := ( S.IndexOfName(FieldName) <> -1 );
end;

function TMiniTable.ReadDef(const FieldName: String; const Default: Variant): Variant;
begin
  if FieldExists(FieldName) then
    Result := F[FieldName]
  else
    Result := Default;
end;

end.
