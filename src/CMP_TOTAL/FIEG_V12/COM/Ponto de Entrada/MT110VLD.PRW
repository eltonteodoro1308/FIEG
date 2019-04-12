#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110VLD
Bloqueia alteracao de SC's com processo orcamentario iniciado.

@type function
@author TOTVS
@since 27/04/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, retorna verdadeiro se validações OK.
/*/
/*/================================================================================================================================/*/

User Function MT110VLD()

Local _lRet       := .T.
//Local _lBlqSC     := SuperGetMV("SI_XBLQORC", .T.) 			// Habilita bloqueio de SC por orçamento
Local _cAreaAKD   := AKD->(GetArea()) 
Local _MV_RESTCOM := SuperGetMV("MV_RESTCOM", .F.,)  
Local _MV_XADMSOL := SuperGetMV("MV_XADMSOL", .F.,)
Local _MENSAGEM   := ""     
LOCAL _MV_XUSU999 := SuperGetMV("MV_XUSU999", .F.)
LOCAL _MV_XSOL999 := SuperGetMV("MV_XSOL999", .F., "", SUBSTR(cFilAnt,1,4))

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF IsInCallStack("A110Deleta") .OR. IsInCallStack("A110Altera")
	IF SC1->C1_APROV == "O"
		MsgAlert("A solicitação de compra selecionada foi bloqueada por orçamento e não poderá ser alterada ou excluída!","MT110VLD")
		_lRet := .F.
	ELSEIF SC1->C1_APROV == "C"
		MsgAlert("A solicitação de compra selecionada está em processo de contingência e não poderá ser alterada ou excluída!","MT110VLD")
		_lRet := .F.
	ELSEIF SC1->C1_APROV == "F"
		MsgAlert("A solicitação de compra selecionada foi bloqueada pelo PCO e não poderá ser alterada ou excluída!","MT110VLD")
		_lRet := .F.
	ELSEIF SC1->C1_APROV == "L"
		AKD->(dbSetOrder(10))
		IF AKD->(dbSeek(XFilial("AKD")+"SC1"+SC1->(C1_FILIAL+C1_NUM)))
			MsgAlert("A solicitação de compra selecionada possui movimentos orçamentários gerados e não pode ser alterada ou excluída!","MT110VLD")
			_lRet := .F.
		ENDIF
	ENDIF
	
	//--< Verifica se existe mutuo cadastrado >--
	IF _lRet .AND. AliasIndic("SZW")
		SZW->(dbSetOrder(1))
		IF SZW->(dbSeek(XFilial("SZW")+SC1->C1_NUM))
			MsgAlert("A solicitação de compra selecionada está com regra de mútuo cadastrada!","MT110VLD")
			_lRet := .F.
		ENDIF
	ENDIF
	       
	//--< 29/07/2013 - Thiago Rasmussen - Alguns usuários específicos vão ter permissão de alterar/excluir qualquer solicitação de compra >--
	IF _lRet                             
		_MV_XADMSOL := _MV_XADMSOL + ";" + SC1->C1_USER
		IF (_MV_RESTCOM <> "S") .AND. !(RetCodUsr() $(_MV_XADMSOL))
			MsgAlert("O senhor(a) " + UsrFullName(RetCodUsr()) + ", logado atualmente não possui permissão para alterar ou excluir a solicitação de compra selecionada!" + CRLF + CRLF + "Responsável pela solicitação de compra: " + UsrFullName(SC1->C1_USER),"MT110VLD") 
			_lRet := .F. 
		ENDIF 
	ENDIF
ENDIF

DO CASE
	CASE xFILIAL("SC1") == '01GO0001'
		_MENSAGEM := "da FIEG"
	CASE xFILIAL("SC1") == '02GO0001'
		_MENSAGEM := "do SESI"
	CASE xFILIAL("SC1") == '03GO0001'
		_MENSAGEM := "do SENAI"
	CASE xFILIAL("SC1") == '04GO0001'
		_MENSAGEM := "do IEL"
	CASE xFILIAL("SC1") == '05GO0001'
		_MENSAGEM := "do ICQ-BRASIL"
ENDCASE

IF _lRet .AND. IsInCallStack("A110Inclui")
	//--< 25/07/2017 - Thiago Rasmussen - Validar solicitações que devem ser encaminhadas para a GEMAT >--
	IF xFILIAL("SC1")$'01GO0001;02GO0001;03GO0001;04GO0001;05GO0001'    
		IF POSICIONE("SY1",1,xFILIAL("SY1") + '999',"Y1_MSBLQL") == "1" .AND. !RetCodUsr()$(_MV_XUSU999)
			MsgAlert("As solicitações de compra da matriz " + _MENSAGEM + " devem ser encaminhadas para a gerência de materiais realizar a compra, só que no momento a GEMAT está bloqueada para receber solicitações de compra. Portanto não pode ocorrer a inclusão de uma solicitação!" + CRLF + CRLF + "Qualquer dúvida, entre em contato com a GEMAT.","MT110VLD")
			_lRet := .F.
		ENDIF
	ENDIF	
ENDIF
           
IF _lRet .AND. IsInCallStack("A110Altera")        
	IF _lRet .AND. SC1->C1_APROV == "R"
		MsgAlert("A solicitação de compra selecionada foi reprovada por algum dos níveis da alçada de aprovação e não poderá ser alterada! Para alterar a solicitação, a alçada de aprovação da mesma deve ser estornada.","MT110VLD")
		_lRet := .F.
	ENDIF	

	IF _lRet .AND. POSICIONE("SCR",1,SC1->C1_FILIAL + 'SC' + SC1->C1_NUM,"CR_STATUS") != '02'
		MsgAlert("A solicitação de compra selecionada foi aprovada por algum dos níveis da alçada de aprovação e não poderá ser alterada! Para alterar a solicitação, a alçada de aprovação da mesma deve ser estornada.","MT110VLD")
		_lRet := .F.
	ENDIF

	//--< 25/07/2017 - Thiago Rasmussen - Validar solicitações que devem ser encaminhadas para a GEMAT >--
	IF _lRet .AND. xFILIAL("SC1")$'01GO0001;02GO0001;03GO0001;04GO0001;05GO0001'    
		IF POSICIONE("SY1",1,xFILIAL("SY1") + '999',"Y1_MSBLQL") == "1" .AND. SC1->C1_XCODCOM != "999" .AND. (!RetCodUsr()$(_MV_XUSU999) .OR. !SC1->C1_CC$(_MV_XSOL999))
			MsgAlert("As solicitações de compra da matriz " + _MENSAGEM + " devem ser encaminhadas para a gerência de materiais realizar a compra, só que no momento a GEMAT está bloqueada para receber solicitações de compra. Portanto a solicitação selecionada não pode ser alterada!" + CRLF + CRLF + "Qualquer dúvida, entre em contato com a GEMAT.","MT110VLD")
			_lRet := .F.
		ENDIF
	ENDIF	
ENDIF

/*
IF _lRet .AND. IsInCallStack("A110Copia")
	IF SC1->C1_APROV != "L"
		MsgAlert("Somente solicitações de compra sem pendências podem ser copiadas!" + CRLF + CRLF + "Qualquer dúvida, entre em contato com a GEMAT.","MT110VLD")
		_lRet := .F.
	ENDIF
ENDIF
*/
	
AKD->(RestArea(_cAreaAKD))

Return(_lRet)