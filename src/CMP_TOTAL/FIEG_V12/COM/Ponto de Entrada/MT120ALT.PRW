#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120ALT
Valida o registro do PC e retorna andamento do processo.

@type function
@author TOTVS
@since 30/11/2017
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

USER FUNCTION MT120ALT()                   

Local _lRet       := .T.
Local aArea       := GetArea()      
Local _MV_RESTPED := NIL  
Local _MV_XADMPED := NIL 
Local _OPERACAO   := ParamIxb[1]

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< 11/12/2013 - Thiago Rasmussen - Pedido de compra não pode ser alterado diretamente >--
IF _OPERACAO == 4
	_lRet := .F. 
	MsgStop("Pedido de compra selecionado não pode ser alterado diretamente!","MT120ALT") 
ENDIF    

IF _lRet .AND. _OPERACAO == 5 .AND. UPPER(ALLTRIM(FUNNAME())) == "MATA121"
	//--< 11/12/2013 - Thiago Rasmussen - Consistir exclusão de pedidos com status diferente de "Pedido Bloqueado (Legenda: Azul)" >--
	IF !(SC7->C7_CONAPRO=="B" .AND. SC7->C7_QUJE<SC7->C7_QUANT .AND. Empty(SC7->C7_RESIDUO))                
		_lRet := .F. 
		MsgStop("O pedido de compra selecionado não pode ser excluído! Somente pedidos com status bloqueado podem ser excluídos diretamente através dessa rotina.","MT120ALT") 
	ENDIF 
	             
	//--< 11/12/2013 - Thiago Rasmussen - Alguns usuários específicos vão ter permissão de excluir qualquer pedido de compra >--
	_MV_RESTPED := SuperGetMV("MV_RESTPED", .F.)  
	_MV_XADMPED := SuperGetMV("MV_XADMPED", .F.)         
	_MV_XADMPED := _MV_XADMPED + ";" + SC7->C7_USER
	IF _lRet .AND. _MV_RESTPED <> "S" .AND. !(RetCodUsr() $(_MV_XADMPED))
		_lRet := .F. 
		MsgStop("Usuário não possui permissao para excluir o pedido de compra selecionado!" + CRLF + CRLF + "Responsável pelo pedido de compra: " + UsrFullName(SC7->C7_USER),"MT120ALT") 
	ENDIF 
ENDIF	

//--< Tratamento para passar na validação >--
//IF _lRet .AND. IsInCallStack("U_CNIEstMe")  
//	RECLOCK("SC7",.F.) 
//		SC7->C7_CONTRA := ""
//		SC7->C7_CODED  := ""
//	MSUNLOCK()
//ENDIF

RestArea(aArea)

RETURN(_lRet)
