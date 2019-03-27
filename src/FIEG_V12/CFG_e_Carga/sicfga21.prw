#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICFGA21
Cadastro de Cargas.

@type function
@author Thiago Rasmussen
@since 25/06/2012
@version P12.1.23

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICFGA21()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	AxCadastro("SZD","Integracao")
Return()