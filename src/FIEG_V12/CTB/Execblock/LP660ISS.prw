#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LP660ISS
Rotina tem a finalidade de buscar t�tulo a pagar de reten��o de ISSQN.

@type function
@author Allan da Silva Faria
@since 28/08/2015
@version P12.1.23

@obs Desenvolvimento FIEG
Essa fonte � tempor�rio porque a rotina de MATA103 deveria preencher o campo E2_VRETISS no casso de reten��o de ISSQN.
Foi aberto chamado na totvs para corrigir.

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Num�rico, Valor do ISSQN Retido.

/*/
/*/================================================================================================================================/*/

User Function LP660ISS()

	Local _aArea	:=  SaveArea1({"SE2"})
	Local _nRet 	:= 0
	Local _cAlias	:= GetNextAlias()

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	
	//------------------------------------
	//-- Checa se Alias est� aberto e
	//-- encerra.
	//------------------------------------
	If Select(_cAlias)>0
		dbSelectArea(_cAlias)
		(_cAlias)->(dbCloseArea())
	EndIf

	//------------------------------------
	//-- Query filtra t�tulo ISSQN
	//------------------------------------
	BeginSQL Alias _cAlias

		Column E2_VALOR as Numeric(14,2)

		SELECT E2_VALOR AS VALOR
		FROM %table:SE2%
		WHERE %notDel%
		AND E2_FILIAL 	= %exp:SF1->F1_FILIAL%
		AND E2_PREFIXO 	= %exp:SF1->F1_PREFIXO%
		AND E2_NUM 		= %exp:SF1->F1_DOC%
		AND E2_TIPO 	= 'ISS'
		AND E2_EMISSAO 	= %exp:SF1->F1_EMISSAO%

	EndSql

	dbSelectArea(_cAlias)
	(_cAlias)->(dbGoTop())

	//------------------------------------
	//-- checa se existe t�tulo ISSQN
	//------------------------------------
	If (_cAlias)->(!EOF()) .AND. (_cAlias)->(!BOF())
		_nRet := (_cAlias)->VALOR
	EndIf

	//------------------------------------
	//-- Restaura Area
	//------------------------------------
	(_cAlias)->(dbCloseArea())
	RestArea1(_aArea)
Return(_nRet)

