#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120VEST
Fun��o executada antes do processo de estorno da medi��o.

@type function
@author Thiago Rasmussen
@since 11/12/2013
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 11/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna verdadeiro se todas as valida��es estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function CN120VEST

Local lRet	   := .T.
Local _C7_USER := ""

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
// PARAMIXB[1] // Indica se usu�rio tem ou n�o direitos sobre o contrato.

If Upper(ALLTRIM(FunName())) == "CNTA120"
	//--< 10/03/2016 - Thiago Rasmussen - N�o permitir estornar uma medi��o de um contrato com situa��o dIferente de vigente. >--
	If POSICIONE("CN9", 1, CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA, "CN9_SITUAC") <> "05"
		MsgStop("Medi��o n�o pode ser estornada, porque o contrato que deu origem a mesma est� com a situa��o dIferente de vigente!","CN120VEST")
		lRet := .F.
	EndIf 

	//--< 10/03/2016 - Thiago Rasmussen - N�o permitir estornar uma medi��o de um contrato fora do per�odo de vig�ncia. >--------
	If lRet .and. POSICIONE("CN9", 1, CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA, "CN9_DTFIM") < DDATABASE
		MsgStop("Medi��o n�o pode ser estornada, porque o contrato que deu origem a mesma est� fora do per�odo de vig�ncia!","CN120VEST") 
		lRet := .F.
	EndIf 

	//--< 01/12/2014 - Thiago Rasmussen - N�o permitir estornar uma medi��o gerada por um contrato de registro de pre�o. >-------
	If lRet .and. POSICIONE("CN9", 1, CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA, "CN9_XREGP") == "1"
		MsgStop("Medi��o n�o pode ser estornada manualmente, porque foi gerada apartir de um contrato de registro de pre�o!","CN120VEST") 
		lRet := .F.
	EndIf 
	
	//--< 11/12/2013 - Thiago Rasmussen - Alguns usu�rios espec�ficos v�o ter permiss�o de excluir qualquer pedido de compra, para estorno da medi��o. >--
	If lRet
		_MV_RESTPED := SuperGetMV("MV_RESTPED", .F.)  
		_MV_XADMPED := SuperGetMV("MV_XADMPED", .F.)                    
		
		_C7_USER := POSICIONE("SC7", 1, IIf(!EMPTY(CND->CND_PEDFIL),CND->CND_PEDFIL,CND->CND_FILIAL) + CND->CND_PEDIDO, "C7_USER")	
		_MV_XADMPED := _MV_XADMPED + ";" + _C7_USER
				 
		If _MV_RESTPED <> "S" .AND. !(RetCodUsr() $(_MV_XADMPED))
			MsgStop("Medi��o n�o pode ser estornada porque usu�rio n�o possui permissao para excluir o pedido de compra gerado por essa medi��o!" + CRLF + CRLF + "Respons�vel pelo pedido de compra: " + UsrFullName(_C7_USER),"CN120VEST") 
			lRet := .F.
		EndIf 
	EndIf
EndIf
          
Return lRet
