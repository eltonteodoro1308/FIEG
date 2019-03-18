#include "protheus.ch"

// Autor....: Thiago Rasmussen
// Data.....: 21/07/2014
// Modulo...: 01 - Ativo
// Descrição: Validações ao realizar uma transferência de ativo.
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

	Local _cEmpOri    := SubStr(PARAMIXB[2],1,2)
	Local _cEmpDest   := SubStr(PARAMIXB[1],1,2)
	Local _MV_ATFBLQM := SuperGetMV("MV_ATFBLQM")
	Local lRet        := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF _cEmpOri <> _cEmpDest
		MsgAlert("Não é permitido transferência entre empresas diferentes." + CRLF + CRLF +;
		"Empresa Origem: " + FWCompanyName('01',PARAMIXB[2]) + CRLF +;
		"Empresa Destino: " + FWCompanyName('01',PARAMIXB[1]),"AF060TOK")
		lRet := .F. //RETURN .F.
	ENDIF

	IF lRet .And. dDataBase <= _MV_ATFBLQM
		MsgAlert("Não é permitido transferência com database menor ou igual a data de bloqueio para movimentação de ativos " + DTOC(_MV_ATFBLQM) + ".","AF060TOK")
		lRet := .F. //RETURN .F.
	ENDIF

RETURN lRet