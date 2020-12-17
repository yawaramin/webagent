unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, PairSplitter, Grids, Buttons,
  FpHttpClient,
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
    MmoBody: TMemo;
    PgRequest: TPageControl;
    SplReqResp: TPairSplitter;
    SpsReq: TPairSplitterSide;
    SpsResp: TPairSplitterSide;
    PgMain: TPageControl;
    GrdRequestHeaders: TStringGrid;
    TabNew: TTabSheet;
    TabAuthorization: TTabSheet;
    TabHeaders: TTabSheet;
    TabBody: TTabSheet;
    TabParameters: TTabSheet;
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
    procedure InitClient();
    procedure SetTabText();
  public

  end;

var
  FrmMain: TFrmMain;
  Client: TFpHttpClient;

implementation

{$R *.lfm}

{ TFrmMain }

procedure TFrmMain.CmbMethodExit(Sender: TObject);
begin
  SetTabText();
end;

procedure TFrmMain.GrdRequestHeadersExit(Sender: TObject);
begin
  TabHeaders.Caption := 'Headers · ' + GrdRequestHeaders.RowCount.ToString;
end;

procedure TFrmMain.BtnSendClick(Sender: TObject);
begin
  SetTabText();
  InitClient();

  try
    WriteLn(Client.Get(TxtUrlBar.Text));
  except
    WriteLn('[ERROR] request failed');
  end;
end;

procedure TFrmMain.BtnAddHeaderClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := GrdRequestHeaders.RowCount;
  GrdRequestHeaders.InsertColRow(false, Idx);
  GrdRequestHeaders.Cells[0, Idx] := '☑';
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
  GrdRequestHeaders.Cells[0, GrdRequestHeaders.Row] := '';
end;

procedure TFrmMain.BtnEnableHeaderClick(Sender: TObject);
begin
  GrdRequestHeaders.Cells[0, GrdRequestHeaders.Row] := '☑';
end;

procedure TFrmMain.TxtUrlBarExit(Sender: TObject);
begin
  SetTabText();
end;

procedure TFrmMain.TxtUrlBarKeyPress(Sender: TObject; var Key: char);
begin
  if Ord(Key) = VK_RETURN then BtnSendClick(Sender);
end;

procedure TFrmMain.InitClient();
var
  Idx: LongInt;
  HName: String;
  HValue: String;
begin
  if Client = nil then begin
    Client := TFpHttpClient.Create(Self);
    Client.AllowRedirect := true;
  end;

  Client.RequestHeaders.Clear();
  for Idx := 0 to GrdRequestHeaders.RowCount - 1 do begin
    HName := GrdRequestHeaders.Cells[1, Idx];
    HValue := GrdRequestHeaders.Cells[2, Idx];

    if (HName <> '') and (HValue <> '') then
       Client.RequestHeaders.AddPair(HName, HValue);
  end;

  WriteLn(Client.RequestHeaders.CommaText);
end;

procedure TFrmMain.SetTabText();
begin
  PgMain.ActivePage.Caption := CmbMethod.Text + ' ' + RightStr(TxtUrlBar.Text, 20);
end;

end.

