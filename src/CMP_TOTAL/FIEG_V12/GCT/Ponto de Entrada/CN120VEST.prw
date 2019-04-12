#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120VEST
Função executada antes do processo de estorno da medição.

@type function
@author Thiago Rasmussen
@since 11/12/2013
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 11/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se todas as validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function CN120VEST

Local lRet	   := .T.
Local _C7_USER := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
// PARAMIXB[1] // Indica se usuário tem ou não direitos sobre o contrato.

If Upper(ALLTRIM(FunName())) == "CNTA120"
	//--< 10/03/2016 - Thiago Rasmussen - Não permitir estornar uma medição de um contrato com situação dIferente de vigente. >--
	If POSICIONE("CN9", 1, CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA, "CN9_SITUAC") <> "05"
		MsgStop("Medição não pode ser estornada, porque o contrato que deu origem a mesma está com a situação dIferente de vigente!","CN120VEST")
		lRet := .F.
	EndIf 

	//--< 10/03/2016 - Thiago Rasmussen - Não permitir estornar uma medição de um contrato fora do período de vigência. >--------
	If lRet .and. POSICIONE("CN9", 1, CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA, "CN9_DTFIM") < DDATABASE
		MsgStop("Medição não pode ser estornada, porque o contrato que deu origem a mesma está fora do período de vigência!","CN120VEST") 
		lRet := .F.
	EndIf 

	//--< 01/12/2014 - Thiago Rasmussen - Não permitir estornar uma medição gerada por um contrato de registro de preço. >-------
	If lRet .and. POSICIONE("CN9", 1, CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA, "CN9_XREGP") == "1"
		MsgStop("Medição não pode ser estornada manualmente, porque foi gerada apartir de um contrato de registro de preço!","CN120VEST") 
		lRet := .F.
	EndIf 
	
	//--< 11/12/2013 - Thiago Rasmussen - Alguns usuários específicos vão ter permissão de excluir qualquer pedido de compra, para estorno da medição. >--
	If lRet
		_MV_RESTPED := SuperGetMV("MV_RESTPED", .F.)  
		_MV_XADMPED := SuperGetMV("MV_XADMPED", .F.)                    
		
		_C7_USER := POSICIONE("SC7", 1, IIf(!EMPTY(CND->CND_PEDFIL),CND->CND_PEDFIL,CND->CND_FILIAL) + CND->CND_PEDIDO, "C7_USER")	
		_MV_XADMPED := _MV_XADMPED + ";" + _C7_USER
				 
		If _MV_RESTPED <> "S" .AND. !(RetCodUsr() $(_MV_XADMPED))
			MsgStop("Medição não pode ser estornada porque usuário não possui permissao para excluir o pedido de compra gerado por essa medição!" + CRLF + CRLF + "Responsável pelo pedido de compra: " + UsrFullName(_C7_USER),"CN120VEST") 
			lRet := .F.
		EndIf 
	EndIf
EndIf
          
Return lRet
