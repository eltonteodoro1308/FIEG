#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTA10
Ponto de entrada tratamento de exclusao de inventario.

@type function
@author Leonardo Soncin
@since 06/12/2011
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIESTA10

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If SB7->B7_XORIGEM $ 'SIESTA01'
		MsgStop("Este registro n�o pode ser exclu�do por esta rotina. Utilize a op��o Estornar em Cadastro de Invent�rio.","Opera��o Inv�lida")

	Else
		A270Deleta("SB7",RecNo(),5)
	Endif

Return
