#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} AF060TOK
Validações ao realizar uma transferência de ativo.

@type function
@author Thiago Rasmussen
@since 21/07/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

/*/
/*/================================================================================================================================/*/

User Function AF060TOK()

	Local oGridFNR    := PARAMIXB[1]:GetDependency()[1,4,1,3]
	Local _cEmpOri    := SubStr(oGridFNR:GetValue('FNR_FILORI'),1,2)
	Local _cEmpDest   := SubStr(oGridFNR:GetValue('FNR_FILDES'),1,2)
	Local _MV_ATFBLQM := SuperGetMV("MV_ATFBLQM")
	Local lRet        := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF _cEmpOri <> _cEmpDest
		MsgAlert("Não é permitido transferência entre empresas diferentes." + CRLF + CRLF +;
		"Empresa Origem: " + FWCompanyName('01',oGridFNR:GetValue('FNR_FILORI')) + CRLF +;
		"Empresa Destino: " + FWCompanyName('01',oGridFNR:GetValue('FNR_FILDES')),"AF060TOK")
		lRet := .F. //RETURN .F.
	ENDIF

	IF lRet .And. dDataBase <= _MV_ATFBLQM
		MsgAlert("Não é permitido transferência com database menor ou igual a data de bloqueio para movimentação de ativos " + DTOC(_MV_ATFBLQM) + ".","AF060TOK")
		lRet := .F. //RETURN .F.
	ENDIF

RETURN lRet