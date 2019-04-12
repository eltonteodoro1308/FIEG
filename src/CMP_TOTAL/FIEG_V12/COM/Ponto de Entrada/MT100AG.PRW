#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
Ponto de Entrada para validar exclusao da NFE.

@type function
@author TOTVS
@since 06/27/2012
@version P12.1.23

@obs Projeto ELO

@history 26/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT100AG()

Local aArea := GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Exclusão dos lançamentos orçamentários >--------------
If !INCLUI .and. !ALTERA
	MsgRun("Excluindo Movimentos da NF "+SF1->F1_DOC,"",{|| U_SICOMA07({5,1}) })
EndIf

RestArea(aArea)

Return()
