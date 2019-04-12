#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CTA100MNU
Ponto de entrada para inclusão de nova rotina no menu do pedido de compra.

@type function
@author Alexandre Cadubtski
@since 01/09/2011
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CTA100MNU()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//aAdd(aRotina,{"Imprime Doc","U_SIGCTR01", 0, 6, 0, Nil })
	aAdd(aRotina,{"Compartilhamento","U_SIESTA08", 0, 7, 0, Nil })
	//aAdd(aRotina,{"Gestores do Contrato","U_SIGCTC01", 0, 7, 0, Nil })
	aAdd(aRotina,{"Gestores do Contrato","U_CN100USER", 0, 7, 0, Nil })
	aAdd(aRotina,{"Impressão do Contrato","U_XCOMCT02", 0, 7, 0, Nil })

Return()