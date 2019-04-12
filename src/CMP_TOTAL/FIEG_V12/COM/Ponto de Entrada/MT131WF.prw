#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT130WF
P.E. executado ao gerar a cotação, no qual possibilita selecionar a modalidade do processo de compra e gerar uma numeração de identificação do processo.

@type function
@author TOTVS
@since 25/05/2012
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT130WF()

	Local _cGet := ""
	Local lNewTpGrv	:= SuperGetMv("SI_XGNPROC",.F.,.T.)
	
//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
	If lNewTpGrv
		If (Empty(MV_PAR59) .OR. Alltrim(MV_PAR59) # Alltrim(SC8->(C8_FILIAL+C8_NUM)))
			If IsInCallStack("U_MTA130C8")
				_cGet := xTelaCoTa()
				U_SICOMA28(_cGet,"C")
			Else
				If (Empty(MV_PAR60) .OR. Empty(SC8->C8_NPROC))
					_cGet := xTelaCoTa()
					U_SICOMA28(_cGet,"C")				
				Else
					MV_PAR59 := ''
					MV_PAR60 := ''
				EndIf
			EndIf
		EndIf
	Else
		_cGet := xTelaCoTa()
		U_SICOMA28(_cGet,"C")
	EndIf

Return Nil


/*/================================================================================================================================/*/
/*/{Protheus.doc} xTelaCoTa
Função utilizada pelo P.E. MT130WF para informar o Tipo na geração da Cotação.

@type function
@author TOTVS
@since 07/10/2012
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Tipo escolhido pelo usuário.
/*/
/*/================================================================================================================================/*/

Static Function xTelaCoTa()

Local oGet1               := Nil
Local oSay1               := Nil
Local oSButton1           := Nil
Local oDlg                := Nil   
Local cQuery              := ''

Private cGet1             := Space(2)
Private bContratoParceria := .F.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< 29/11/2016 - Thiago Rasmussen - Verificar se trata-se de uma solicitação de compra do tipo contrato de parceria >--
cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName('SC1') + " WITH (NOLOCK) " + CRLF +;
          "WHERE C1_FILIAL = '" + SC8->C8_FILIAL + "' AND " + CRLF +;
          "      C1_COTACAO = '" + SC8->C8_NUM + "' AND " + CRLF +;
          "      C1_XTIPOSC = '006' AND " + CRLF +;
          "      D_E_L_E_T_ = ' ' "

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .T.)
	                                                                         				
bContratoParceria := !QRY->(EOF())   
dbCloseArea()

DEFINE MSDIALOG oDlg TITLE "Informe" FROM 000, 000  TO 090, 200 COLORS 0, 16777215 PIXEL Style DS_MODALFRAME

oDlg:lEscClose := .F.

@ 012, 012 SAY oSay1 PROMPT "Tipo de Modalidade:" SIZE 053, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 010, 065 MSGET oGet1 VAR cGet1 SIZE 022, 010 OF oDlg COLORS 0, 16777215 F3 "TP" VALID Empty(cGet1) .OR. ExistCPO("SX5","TP"+cGet1) WHEN !bContratoParceria PIXEL
cGet1 := IIF(bContratoParceria, 'CP', '  ')
DEFINE SBUTTON oSButton1 FROM 030, 040 TYPE 1 OF oDlg ENABLE ACTION(IIF(!ValidarBotao(),'',oDlg:End()))
ACTIVATE MSDIALOG oDlg CENTERED

Return(cGet1)       
          

/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidarBotao
Função utilizada pelo P.E. MT130WF para validação do botão ao informar o Tipo na geração da Cotação.

@type function
@author TOTVS
@since 07/10/2012
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function ValidarBotao()

Local lRet := .T.
//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If Empty(cGet1)
	MsgAlert("Por gentileza informe o tipo de modalidade.","MT130WF")
	lRet := .F.
EndIf

If lRet .and. bContratoParceria .AND. ALLTRIM(cGet1) != 'CP'
	cGet1 := 'CP'
	MsgAlert("Como trata-se de uma solicitação de contrato de parceria, o tipo de modalidade deve ser contrato de parceria.","MT130WF")
	lRet := .F.
EndIf

If lRet .and. !bContratoParceria .AND. ALLTRIM(cGet1) == 'CP'
	cGet1 := '  '
	MsgAlert("Tipo de modalidade contrato de parceria só pode ser utilizado para solicitações de contrato de parceria.","MT130WF")
	lRet := .F.
EndIf

Return lRet
