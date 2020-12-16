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

procedure TFrmMain.BtnSendClick(Sender: TObject);
begin
  SetTabText();
  InitClient();
  WriteLn(Client.Get(TxtUrlBar.Text));
end;

procedure TFrmMain.BtnAddHeaderClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := GrdRequestHeaders.RowCount;
  GrdRequestHeaders.InsertColRow(false, Idx);
  GrdRequestHeaders.Cells[0, Idx] := '✅';
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
  GrdRequestHeaders.Cells[0, GrdRequestHeaders.Row] := '✅';
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
begin
  if Client = nil then begin
    Client := TFpHttpClient.Create(Self);
    Client.AllowRedirect := true;
  end;
end;

procedure TFrmMain.SetTabText();
begin
  PgMain.ActivePage.Caption := CmbMethod.Text + ' ' + RightStr(TxtUrlBar.Text, 20);
end;

end.

