#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/================================================================================================================================/*/
/*/{Protheus.doc} DTFING02
Gatilho respons�vel pelo tratamento da numeracao automatica dos titulos a pagar.

@type function
@author F�brica DOIT SP
@since 24/06/2014
@version P12.1.23

@obs Desenvolvimento FIEG � Contas a Pagar

@history 21/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return cNum, N�mero do T�tulo do Contas a Pagar.
/*/
/*/================================================================================================================================/*/

User Function DTFING02()

Private	cNum := Space(TamSX3("E2_NUM")[1])

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If AllTrim(M->E2_TIPO)$"NF;AB-" .AND. !lF050Auto

	DEFINE MSDIALOG oDlgA FROM 001,000 TO 010,050 TITLE "Contas a Pagar" OF oMainWnd
	
	@ 005,002 TO 35,195 LABEL "Numero" OF oDlgA PIXEL
	@ 015,005 GET oNum VAR cNum  Valid(fNumero()) OF oDlgA SIZE 185,10 PIXEL
	
	DEFINE SBUTTON FROM 40,130 TYPE 1 ACTION IIf( !Empty(cNum), oDlgA:End(), ApMsgStop("Informe o N�mero do T�tulo", "ATEN��O"))  ENABLE OF oDlgA
	DEFINE SBUTTON FROM 40,160 TYPE 2 ACTION oDlgA:End() ENABLE OF oDlgA
	
	ACTIVATE MSDIALOG oDlgA CENTER
Else
	If Upper(AllTrim(FunName()))$"FINA050;FINA750" .AND. (AllTrim(M->E2_TIPO) <> "INS" .OR. (AllTrim(M->E2_TIPO) == "INS" .AND. !lF050Auto)) // Faz o tratamento somente quando for inclusao manual, quando for via ExecAuto mantem o numero do titulo original
		cNum  := GetSX8Num("SE2","E2_NUM") 
	Else
		cNum  := M->E2_NUM
	Endif	
Endif

Return(cNum)

	
/*/================================================================================================================================/*/
/*/{Protheus.doc} fNumero
Fun��o utilizada no Gatilho DTFING02, respons�vel pelo tratamento da numeracao automatica dos titulos a pagar.

@type function
@author F�brica DOIT SP
@since 24/06/2014
@version P12.1.23

@obs Desenvolvimento FIEG � Contas a Pagar

@history 21/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return lRet, Retorna True se j� existir t�tulo com o mesmo n�mero.
/*/
/*/================================================================================================================================/*/

Static Function fNumero()

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
aAlias := GetArea()
lRet := .T.

If SE2->(DbSeek(xFilial("SE2")+M->E2_PREFIXO + cNum + M->E2_PARCELA + M->E2_TIPO + M->E2_FORNECE + M->E2_LOJA,.F.))
	MsgAlert("Existe t�tulo com este n�mero para esta filial, favor selecione outro n�mero de t�tulo","Alerta")
	cNum := Space(TamSX3("E2_NUM")[1])  
	oNum:Refresh()
	lRet := .F.
Endif

RestArea(aAlias)

Return lRet		


/*/================================================================================================================================/*/
/*/{Protheus.doc} DTFIG02V
Fun��o utilizada no Gatilho DTFING02, para controle de versao.

@type function
@author F�brica DOIT SP
@since 02/09/2014
@version P12.1.23

@obs Desenvolvimento FIEG � Contas a Pagar

@history 21/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return cRet, vers�o da rotina.
/*/
/*/================================================================================================================================/*/

User Function DTFIG02V() 

Local cRet  := ""                         

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cRet := "20140902001" 
        
Return (cRet)
