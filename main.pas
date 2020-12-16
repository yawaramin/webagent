unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, PairSplitter, Grids, Buttons,
  FpHttpClient,
  OpenSslSockets,
  OpenSsl,
  strutils;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    btnDelHeader: TButton;
    btnEnableHeader: TButton;
    btnDisableHeader: TButton;
    BtnSend: TButton;
    btnAddHeader: TButton;
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
    procedure btnAddHeaderClick(Sender: TObject);
    procedure btnDelHeaderClick(Sender: TObject);
    procedure BtnSendClick(Sender: TObject);
    procedure CmbMethodExit(Sender: TObject);
    procedure TxtUrlBarExit(Sender: TObject);
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

procedure TFrmMain.btnAddHeaderClick(Sender: TObject);
begin
  GrdRequestHeaders.InsertColRow(false, GrdRequestHeaders.RowCount);
end;

procedure TFrmMain.btnDelHeaderClick(Sender: TObject);
begin
  try
     GrdRequestHeaders.DeleteRow(GrdRequestHeaders.Row);
  except
    WriteLn('[WARN] no more rows left to delete');
  end;
end;

procedure TFrmMain.TxtUrlBarExit(Sender: TObject);
begin
  SetTabText();
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

