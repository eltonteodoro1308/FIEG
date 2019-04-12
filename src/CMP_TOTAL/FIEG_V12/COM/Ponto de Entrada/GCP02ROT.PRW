#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} GCP02Rot
Ponto de Entrada para inclusao de funcionalidade no aRotina do Edital.

@type function
@author Thiago Rasmussen
@since 03/11/2011
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com a lista de funcionalidades a serem incluidas no aRotina.

/*/
/*/================================================================================================================================/*/

User Function GCP02Rot()

	Local aArea     := GetArea()
	Local aRet      := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aAdd(aRet,{"Amarrar Doctos","U_SICOMA13",0,4})
	aAdd(aRet,{"Consulta Aprovação", "U_SICOMA03(4)",0,2 })
	aAdd(aRet,{"Estorno"  ,"u_SICOMA20" ,0,4})//"Estorno"

	RestArea(aArea)
Return(aRet)

