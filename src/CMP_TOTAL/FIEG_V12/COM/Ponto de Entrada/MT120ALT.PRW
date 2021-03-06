#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120ALT
Valida o registro do PC e retorna andamento do processo.

@type function
@author TOTVS
@since 30/11/2017
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Nil, Fun��o sem retorno.
/*/
/*/================================================================================================================================/*/

USER FUNCTION MT120ALT()                   

Local _lRet       := .T.
Local aArea       := GetArea()      
Local _MV_RESTPED := NIL  
Local _MV_XADMPED := NIL 
Local _OPERACAO   := ParamIxb[1]

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< 11/12/2013 - Thiago Rasmussen - Pedido de compra n�o pode ser alterado diretamente >--
IF _OPERACAO == 4
	_lRet := .F. 
	MsgStop("Pedido de compra selecionado n�o pode ser alterado diretamente!","MT120ALT") 
ENDIF    

IF _lRet .AND. _OPERACAO == 5 .AND. UPPER(ALLTRIM(FUNNAME())) == "MATA121"
	//--< 11/12/2013 - Thiago Rasmussen - Consistir exclus�o de pedidos com status diferente de "Pedido Bloqueado (Legenda: Azul)" >--
	IF !(SC7->C7_CONAPRO=="B" .AND. SC7->C7_QUJE<SC7->C7_QUANT .AND. Empty(SC7->C7_RESIDUO))                
		_lRet := .F. 
		MsgStop("O pedido de compra selecionado n�o pode ser exclu�do! Somente pedidos com status bloqueado podem ser exclu�dos diretamente atrav�s dessa rotina.","MT120ALT") 
	ENDIF 
	             
	//--< 11/12/2013 - Thiago Rasmussen - Alguns usu�rios espec�ficos v�o ter permiss�o de excluir qualquer pedido de compra >--
	_MV_RESTPED := SuperGetMV("MV_RESTPED", .F.)  
	_MV_XADMPED := SuperGetMV("MV_XADMPED", .F.)         
	_MV_XADMPED := _MV_XADMPED + ";" + SC7->C7_USER
	IF _lRet .AND. _MV_RESTPED <> "S" .AND. !(RetCodUsr() $(_MV_XADMPED))
		_lRet := .F. 
		MsgStop("Usu�rio n�o possui permissao para excluir o pedido de compra selecionado!" + CRLF + CRLF + "Respons�vel pelo pedido de compra: " + UsrFullName(SC7->C7_USER),"MT120ALT") 
	ENDIF 
ENDIF	

//--< Tratamento para passar na valida��o >--
//IF _lRet .AND. IsInCallStack("U_CNIEstMe")  
//	RECLOCK("SC7",.F.) 
//		SC7->C7_CONTRA := ""
//		SC7->C7_CODED  := ""
//	MSUNLOCK()
//ENDIF

RestArea(aArea)

RETURN(_lRet)
