#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
Validar os poss�veis compradores, das solicita��es de compra.

@type function
@author Thiago Rasmussen
@since 01/10/2013
@version P12.1.23

@obs Desenvolvimento FIEG - Compras

@history 21/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return lRet, retorno verdadeiro se valida��es OK.
/*/
/*/================================================================================================================================/*/

User Function XVALCOM()

Local lRet		 := .T.
Local _Y1_MSBLQL := POSICIONE("SY1",1,xFILIAL("SY1") + M->C1_XCODCOM,"Y1_MSBLQL")

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF !Empty(_Y1_MSBLQL)
	IF _Y1_MSBLQL == "1"    
		M->C1_XCODCOM := ""
		MsgAlert("Comprador est� bloqueado, consulte os compradores atrav�s da op��o F3.","XVALCOM")
		lRet := .F.
	EndIf
	
	IF !cFILANT$SY1->Y1_XFILCOM
		M->C1_XCODCOM := ""
		MsgAlert("Comprador n�o est� associado a filial " + cFILANT + ", consulte os compradores associados a essa filial atrav�s da op��o F3.","XVALCOM")
		lRet := .F.
	EndIf
Else	
	M->C1_XCODCOM := ""
	MsgAlert("Comprador n�o existe ou n�o est� associado a filial " + cFILANT + ", consulte os compradores associados a essa filial atrav�s da op��o F3.","XVALCOM")
	lRet := .F.
EndIf                    

Return lRet
