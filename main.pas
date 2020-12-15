unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls,
  FpHttpClient,
  OpenSslSockets,
  OpenSsl,
  strutils;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    BtnSend: TButton;
    CmbMethod: TComboBox;
    PgMain: TPageControl;
    TabNew: TTabSheet;
    TxtUrlBar: TEdit;
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
  writeln(Client.Get(TxtUrlBar.Text));
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
    Client.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  end;
end;

procedure TFrmMain.SetTabText();
begin
  PgMain.ActivePage.Caption := CmbMethod.Text + ' ' + RightStr(TxtUrlBar.Text, 20);
end;

end.

