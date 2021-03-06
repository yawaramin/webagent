unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, PairSplitter, Grids, Buttons,
  FpHttpClient,
  LCLIntf,
  LCLType,
  OpenSslSockets,
  OpenSsl,
  strutils;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    BtnDelHeader: TButton;
    BtnEnableHeader: TButton;
    BtnDisableHeader: TButton;
    BtnSend: TButton;
    BtnAddHeader: TButton;
    BtnCancel: TButton;
    CmbMethod: TComboBox;
    GrpResponse: TGroupBox;
    GrpRequest: TGroupBox;
    MmoResponseBody: TMemo;
    MmoRequestBody: TMemo;
    PgResponse: TPageControl;
    PgRequest: TPageControl;
    SplReqResp: TPairSplitter;
    SpsReq: TPairSplitterSide;
    SpsResp: TPairSplitterSide;
    PgMain: TPageControl;
    GrdRequestHeaders: TStringGrid;
    GrdResponseHeaders: TStringGrid;
    SttResponseInfo: TStaticText;
    TabNew: TTabSheet;
    TabAuthorization: TTabSheet;
    TabRequestHeaders: TTabSheet;
    TabRequestBody: TTabSheet;
    TabParameters: TTabSheet;
    TabResponseBody: TTabSheet;
    TabResponseHeaders: TTabSheet;
    TxtUrlBar: TEdit;
    procedure BtnAddHeaderClick(Sender: TObject);
    procedure BtnDelHeaderClick(Sender: TObject);
    procedure BtnDisableHeaderClick(Sender: TObject);
    procedure BtnEnableHeaderClick(Sender: TObject);
    procedure BtnSendClick(Sender: TObject);
    procedure CmbMethodExit(Sender: TObject);
    procedure GrdRequestHeadersExit(Sender: TObject);
    procedure TxtUrlBarExit(Sender: TObject);
    procedure TxtUrlBarKeyPress(Sender: TObject; var Key: char);
  private
    procedure InitClient;
    procedure SetTabText;
    procedure SetResHeaders(Headers: TStrings);
  public

  end;

const
  StatusColumnIdx = 0;
  NameColumnIdx = 1;
  ValueColumnIdx = 2;

var
  FrmMain: TFrmMain;
  Client: TFpHttpClient;

implementation

{$R *.lfm}

{ TFrmMain }

procedure TFrmMain.CmbMethodExit(Sender: TObject);
begin
  SetTabText;
end;

function ValidKV(K, V: String): Boolean;
begin
  Result := (K <> '') and (V <> '');
end;

function CountValidKV(Grd: TStringGrid): Integer;
var
  Idx: Integer;
begin
  Result := 0;

  for Idx := 0 to Grd.RowCount - 1 do
    if ValidKV(Grd.Cells[NameColumnIdx, Idx], Grd.Cells[ValueColumnIdx, Idx]) then
      Result := Result + 1;
end;

procedure TFrmMain.GrdRequestHeadersExit(Sender: TObject);
begin
  TabRequestHeaders.Caption := 'Headers · ' + CountValidKV(GrdRequestHeaders).ToString;
end;

procedure TFrmMain.BtnSendClick(Sender: TObject);
const
  ResInfoFmt: String = 'Status: %d %s · Time: %dms · Size: %dB';
var
  ReqStart: DWord;
  ReqEnd: DWord;
  ResBody: String;
begin
  ResBody := '';
  SetTabText;
  InitClient;

  try
    Client.RequestBody := TRawByteStringStream.Create(MmoRequestBody.Lines.Text);
    ReqStart := GetTickCount;

    try
      ResBody := Client.Get(TxtUrlBar.Text);
      ReqEnd := GetTickCount;

      SttResponseInfo.Caption := Format(
        ResInfoFmt,
        [
          Client.ResponseStatusCode,
          Client.ResponseStatusText,
          ReqEnd - ReqStart,
          ResBody.Length
        ]);

      SetResHeaders(Client.ResponseHeaders);
    except
      on E: Exception do SttResponseInfo.Caption := E.Message;
    end;
  finally
    MmoResponseBody.Lines.Text := ResBody;
    Client.RequestBody.Free;
  end;
end;

procedure TFrmMain.SetResHeaders(Headers: TStrings);
var
  StringsIdx, HeadersIdx: Integer;
  HName, HValue: String;
begin
  for HeadersIdx := 1 to GrdResponseHeaders.RowCount - 1 do
    GrdResponseHeaders.DeleteRow(HeadersIdx);

  HeadersIdx := 1;

  for StringsIdx := 0 to Headers.Count - 1 do begin
    Headers.GetNameValue(StringsIdx, HName, HValue);

    if ValidKV(HName, HValue) then begin
      GrdResponseHeaders.InsertRowWithValues(HeadersIdx, [HName, HValue]);
      HeadersIdx := HeadersIdx + 1;
    end;
  end;

  TabResponseHeaders.Caption := Format(
    'Headers · %d',
    { Subtract one for the title row }
    [GrdResponseHeaders.RowCount - 1]);
end;

procedure TFrmMain.BtnAddHeaderClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := GrdRequestHeaders.RowCount;
  GrdRequestHeaders.InsertColRow(false, Idx);
  GrdRequestHeaders.Cells[StatusColumnIdx, Idx] := '☑';
end;

procedure TFrmMain.BtnDelHeaderClick(Sender: TObject);
begin
  try
     GrdRequestHeaders.DeleteRow(GrdRequestHeaders.Row);
  except
    WriteLn('[WARN] no more rows left to delete');
  end;
end;

procedure TFrmMain.BtnDisableHeaderClick(Sender: TObject);
begin
  GrdRequestHeaders.Cells[StatusColumnIdx, GrdRequestHeaders.Row] := '';
end;

procedure TFrmMain.BtnEnableHeaderClick(Sender: TObject);
begin
  GrdRequestHeaders.Cells[StatusColumnIdx, GrdRequestHeaders.Row] := '☑';
end;

procedure TFrmMain.TxtUrlBarExit(Sender: TObject);
begin
  SetTabText;
end;

procedure TFrmMain.TxtUrlBarKeyPress(Sender: TObject; var Key: char);
begin
  if Ord(Key) = VK_RETURN then BtnSendClick(Sender);
end;

procedure TFrmMain.InitClient;
var
  Idx: LongInt;
  HName: String;
  HValue: String;
begin
  if Client = nil then begin
    Client := TFpHttpClient.Create(Self);
    Client.AllowRedirect := true;
  end;

  Client.RequestHeaders.Clear;
  for Idx := 0 to GrdRequestHeaders.RowCount - 1 do begin
    HName := GrdRequestHeaders.Cells[NameColumnIdx, Idx];
    HValue := GrdRequestHeaders.Cells[ValueColumnIdx, Idx];

    if ValidKV(HName, HValue) then Client.RequestHeaders.AddPair(HName, HValue);
  end;
end;

procedure TFrmMain.SetTabText;
begin
  PgMain.ActivePage.Caption := CmbMethod.Text + ' ' + RightStr(TxtUrlBar.Text, 20);
end;

end.

