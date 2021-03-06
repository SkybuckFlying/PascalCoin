unit UWIZOperationSigner_Select;

{ Copyright (c) 2018 by Sphere 10 Software <http://www.sphere10.com/>

  Distributed under the MIT software license, see the accompanying file LICENSE
  or visit http://www.opensource.org/licenses/mit-license.php.

  This unit is a part of the PascalCoin Project, an infinitely scalable
  cryptocurrency. Find us here:
  Web: https://www.pascalcoin.org
  Source: https://github.com/PascalCoin/PascalCoin

  Acknowledgements:
  - Ugochukwu Mmaduekwe - main developer
  - Herman Schoenfeld - designer

  THIS LICENSE HEADER MUST NOT BE REMOVED.
}

{$mode delphi}
{$modeswitch nestedprocvars}

interface

uses
  SysUtils, Graphics, StdCtrls, ExtCtrls, UWizard, UWIZOperation;

type

  { TWIZOperationSigner_Select }

  TWIZOperationSigner_Select = class(TWizardForm<TWIZOperationsModel>)
    cbSignerAccount: TComboBox;
    gbTransaction: TGroupBox;
    lblNote: TLabel;
    lblBalance: TLabel;
    rbPrimary: TRadioButton;
    rbSecondary: TRadioButton;
    procedure cbSignerAccountChange(Sender: TObject);

  public
    procedure OnPresent; override;
    procedure OnNext; override;
    function Validate(out message: ansistring): boolean; override;
  end;


implementation

{$R *.lfm}

uses
  UAccounts,
  UCoreObjects;

{ TWIZOperationSigner_Select }

procedure TWIZOperationSigner_Select.cbSignerAccountChange(Sender: TObject);
begin
  if cbSignerAccount.ItemIndex < 1 then
  begin
    lblBalance.Font.Color := clRed;
    lblBalance.Caption := 'Please Select Signer Account';
  end
  else
  begin
    lblBalance.Font.Color := clGreen;
    lblBalance.Caption := Format('%s PASC',
      [TAccountComp.FormatMoney(Model.Signer.SignerCandidates[PtrInt(
      cbSignerAccount.Items.Objects[cbSignerAccount.ItemIndex])].Balance)]);
  end;
end;

procedure TWIZOperationSigner_Select.OnPresent;

  function GetAccountNumberWithChecksum(AAccountNumber: cardinal): string;
  begin
    Result := TAccountComp.AccountNumberToAccountTxtNumber(AAccountNumber);
  end;

var
  LAccount: TAccount;
  LAccountNumberWithChecksum: string;
  LIdx: integer;
begin
  cbSignerAccount.Items.BeginUpdate;
  try
    cbSignerAccount.Items.Clear;
    cbSignerAccount.Items.Add('Select Signer Account');
    for LIdx := Low(Model.Signer.SignerCandidates) to High(Model.Signer.SignerCandidates) do
    begin
      LAccount := Model.Signer.SignerCandidates[LIdx];
      LAccountNumberWithChecksum := GetAccountNumberWithChecksum(LAccount.account);
      cbSignerAccount.Items.AddObject(LAccountNumberWithChecksum, TObject(LIdx));
    end;
  finally
    cbSignerAccount.Items.EndUpdate;
  end;
  if Length(Model.Signer.SignerCandidates) = 1 then
    cbSignerAccount.ItemIndex := 1
  else
    cbSignerAccount.ItemIndex := Model.Signer.SelectedIndex;
  cbSignerAccountChange(Self);
  cbSignerAccount.SetFocus;
end;

procedure TWIZOperationSigner_Select.OnNext;
begin
  Model.Signer.SelectedIndex := cbSignerAccount.ItemIndex;
  Model.Signer.SignerAccount := Model.Signer.SignerCandidates[PtrInt(
    cbSignerAccount.Items.Objects[cbSignerAccount.ItemIndex])];
  if rbPrimary.Checked then
    Model.Signer.OperationSigningMode := akaPrimary
  else if rbSecondary.Checked then
    Model.Signer.OperationSigningMode := akaSecondary;
end;

function TWIZOperationSigner_Select.Validate(out message: ansistring): boolean;
begin
  Result := True;
  if cbSignerAccount.ItemIndex < 1 then
  begin
    message := 'A Signer Account Must Be Selected';
    Exit(False);
  end;

end;

end.
