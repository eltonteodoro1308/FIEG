#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ATFA012
Ponto de entrada MVC para tratar a chamada MODELPRE quando é feita a cópia do bem para que o código incrementado seja o Código base do bem.

@type function
@author Elton Alves
@since 04/04/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 04/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Indefinido, Pode retornar um valor lógico, um array ou nulo dependendo do tipo de chamda efetuada ao Ponto de Entrada.

/*/
/*/================================================================================================================================/*/

User Function ATFA012()

	Local xRet       := Nil
	Local oModel     := PARAMIXB[1]
	Local cIdPe      := PARAMIXB[2]
	Local cNextcBase := NextNumero('SN1',1,'N1_CBASE',.T.)
	Local cItem      := StrZero( 1, GetSx3Cache( 'N1_ITEM', 'X3_TAMANHO') )

	// Chamadas que retornam valor lógico.
	If AllTrim(cIdPe) $ 'MODELPRE/MODELPOS/FORMPRE/FORMPOS/FORMLINEPRE/FORMLINEPOS/FORMCANCEL/MODELVLDACTIVE/MODELCANCEL'

		If AllTrim(cIdPe) == 'MODELPRE' .And. oModel:IsCopy();
		.And. SN1->N1_GRUPO # "0104" .AND. SN1->N1_FILIAL # CFILANT

			//--< Log das Personalizações >-----------------------------
			U_LogCustom()

			//--< Processamento da Rotina >-----------------------------

			oModel:GetModel( 'SN1MASTER' ):LoadValue( 'N1_CBASE', cNextcBase )
			oModel:GetModel( 'SN1MASTER' ):LoadValue( 'N1_ITEM' , cItem      )

		EndIf

		xRet := .T.

		// Chamadas que retornam nulo.
	ElseIf AllTrim(cIdPe) $ 'MODELCOMMITTTS/MODELCOMMITNTTS/FORMCOMMITTTSPRE/FORMCOMMITTTSPOS'

		xRet := Nil

		// Chamadas que retornam array.
	ElseIf AllTrim(cIdPe) == 'BUTTONBAR'

		xRet := {}

	EndIf

return xRet