#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} function_method_class_name
Cadastro de Finalidade de Compra x Conta Contabil..

@type function
@author Alexandre Cadubtski
@since 02/01/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIcoma18()

	Local cVldExc := "U_coma18Exc()"// Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	Local cVldAlt := ".T." 			// Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.


	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	AxCadastro("SZO","Cadastro de Finalidade de Compra x Conta Contabil.",cVldExc,cVldAlt)

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} coma18Exc
Verifica se o registro pode ser excluido.

@type function
@author Alexandre Cadubtski
@since 02/01/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso indicando se registro pode ser exclu�do.

/*/
/*/================================================================================================================================/*/

User Function coma18Exc()

	Local lRet  		:= .T.
	Local cCont 		:= SZO->ZO_FINCOM //Conteudo do registro posicionado
	Local cARQPROD	:= Upper(Alltrim(GetMv("MV_ARQPROD"))) //Configura se os dados de indicadores de produto serao considerados pela tabela "SB1" ou "SBZ"


	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cAli := GetNextAlias()//Carrega o proximo alias disponivel

	//Verifica se a finalidade da compra esta em uso no SB1 ou SBZ
	If cARQPROD == "SB1"
		BeginSQL Alias cAli
			SELECT B1_FINCOM AS FINCOM
			FROM %table:SB1%
			WHERE B1_FILIAL = %xFilial:SB1%
			AND %NotDel%
			AND B1_FINCOM = %Exp:cCont%
		EndSQL
	Else
		BeginSQL Alias cAli
			SELECT BZ_FINCOM AS FINCOM
			FROM %table:SBZ%
			WHERE BZ_FILIAL = %xFilial:SBZ%
			AND %NotDel%
			AND BZ_FINCOM = %Exp:cCont%
		EndSQL
	EndIf

	DbSelectArea((cAli))

	If Select((cAli)) > 0
		If !Empty((cAli)->FINCOM)
			lRet := .F.
		EndIf
	EndIf

	cAli->(DbCloseArea())

	cAli := GetNextAlias()//Carrega o proximo alias disponivel

	//Verifica se a finalidade da compra esta em uso no SC1
	BeginSQL Alias cAli
		SELECT C1_FINCOM AS FINCOM
		FROM %table:SC1%
		WHERE C1_FILIAL = %xFilial:SC1%
		AND %NotDel%
		AND C1_FINCOM = %Exp:cCont%
	EndSQL

	DbSelectArea((cAli))

	If Select((cAli)) > 0
		If !Empty((cAli)->FINCOM)
			lRet := .F.
		EndIf
	EndIf

	cAli->(DbCloseArea())

	If !lRet
		Aviso("Atencao !","N�o � poss�vel excluir o registro, pois ele est� em uso.",{"Ok"})
	EndIf

Return(lRet)