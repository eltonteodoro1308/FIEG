#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCOAKDCHV
PE para alterar campo AKD_CHAVE nos lancamentos especificos.

@type function
@author TOTVS
@since 19/09/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Retorna a Chave.
/*/
/*/================================================================================================================================/*/

User Function PCOAKDCHV()

Local _cRet := ""
Local _lProcessa := ParamIXB[1] == GetNewPar("SI_XCODPCO","900001")

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF _lProcessa
	_cRet := TMPPCO->AKD_CHAVE
ELSE
	IF ParamIXB[3] 											// validacao
		_cRet := AKA->AKA_CHAVE
	ELSE 													// lancamento
		_cRet := ParamIXB[4]
	ENDIF
ENDIF

Return(_cRet)
