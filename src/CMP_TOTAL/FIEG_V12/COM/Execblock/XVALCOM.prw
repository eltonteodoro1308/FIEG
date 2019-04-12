#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
Validar os possíveis compradores, das solicitações de compra.

@type function
@author Thiago Rasmussen
@since 01/10/2013
@version P12.1.23

@obs Desenvolvimento FIEG - Compras

@history 21/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return lRet, retorno verdadeiro se validações OK.
/*/
/*/================================================================================================================================/*/

User Function XVALCOM()

Local lRet		 := .T.
Local _Y1_MSBLQL := POSICIONE("SY1",1,xFILIAL("SY1") + M->C1_XCODCOM,"Y1_MSBLQL")

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF !Empty(_Y1_MSBLQL)
	IF _Y1_MSBLQL == "1"    
		M->C1_XCODCOM := ""
		MsgAlert("Comprador está bloqueado, consulte os compradores através da opção F3.","XVALCOM")
		lRet := .F.
	EndIf
	
	IF !cFILANT$SY1->Y1_XFILCOM
		M->C1_XCODCOM := ""
		MsgAlert("Comprador não está associado a filial " + cFILANT + ", consulte os compradores associados a essa filial através da opção F3.","XVALCOM")
		lRet := .F.
	EndIf
Else	
	M->C1_XCODCOM := ""
	MsgAlert("Comprador não existe ou não está associado a filial " + cFILANT + ", consulte os compradores associados a essa filial através da opção F3.","XVALCOM")
	lRet := .F.
EndIf                    

Return lRet
