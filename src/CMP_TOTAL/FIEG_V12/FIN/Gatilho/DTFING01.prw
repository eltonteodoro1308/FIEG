#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/================================================================================================================================/*/
/*/{Protheus.doc} DTFING01
Gatilho responsável pelo tratamento da numeracao automatica dos titulos a receber.

@type function
@author Fábrica DOIT SP
@since 24/06/2014
@version P12.1.23

@obs Desenvolvimento FIEG – Contas a Receber

@history 20/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return cNum, Numero do Titulo.
/*/
/*/================================================================================================================================/*/

User Function DTFING01()

Private cNum := Space(TamSX3("E1_NUM")[1])

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF !lF040Auto
	IF Alltrim(M->E1_TIPO) == "NF"
		//cNum := Space(TamSX3("E1_NUM")[1])				// Permanece com conteúdo vazio
	
		DEFINE MSDIALOG oDlgA FROM 001,000 TO 010,050 TITLE "Contas a Receber" OF oMainWnd
		
		@ 005,002 TO 35,195 LABEL "Numero" OF oDlgA PIXEL
		@ 015,005 GET oNum VAR cNum  Valid(fNumero()) OF oDlgA SIZE 185,10 PIXEL
		
		DEFINE SBUTTON FROM 40,130 TYPE 1 ACTION IIf( !Empty(cNum), oDlgA:End(), ApMsgStop("Informe o Número do Título", "ATENÇÃO"))  ENABLE OF oDlgA
		DEFINE SBUTTON FROM 40,160 TYPE 2 ACTION oDlgA:End() ENABLE OF oDlgA
		
		ACTIVATE MSDIALOG oDlgA CENTER
	ELSE
		cNum  :=  GetSX8Num("SE1","E1_NUM")
	ENDIF     
ELSE
	cNum := M->E1_NUM
ENDIF	
	
Return(cNum)

	
/*/================================================================================================================================/*/
/*/{Protheus.doc} fNumero
Gatilho responsável pelo tratamento da numeracao automatica dos titulos a pagar.

@type function
@author Fábrica DOIT SP
@since 24/06/2014
@version P12.1.23

@obs Desenvolvimento FIEG – Contas a Pagar

@history 20/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return lRet, retorna verdadeiro se validação for OK.
/*/
/*/================================================================================================================================/*/

Static Function fNumero()

Local aAlias := GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
lRet := .T.

SE1->(DbSetOrder(1))
If SE1->(DbSeek(xFilial("SE1")+M->E1_PREFIXO + cNum + M->E1_PARCELA + M->E1_TIPO,.F.))
	MsgAlert("Existe título com este número para esta filial, favor selecione outro número de título","Alerta")
	cNum := Space(TamSX3("E1_NUM")[1])  
	oNum:Refresh()
	lRet := .F.
Endif

RestArea(aAlias)

Return lRet		


/*/================================================================================================================================/*/
/*/{Protheus.doc} DTFIG01V
Funcao para controle de versao.

@type function
@author Doit Sistemas
@since 02/09/2014
@version P12.1.23

@obs Desenvolvimento FIEG – Contas a Pagar

@history 20/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return cRet, Versão da rotina.
/*/
/*/================================================================================================================================/*/

User Function DTFIG01V() 

Local cRet  := ""                         

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cRet := "20140902001" 
        
Return (cRet)