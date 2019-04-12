#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA030TOK
Ponto de Entrada no Cadastro de Clientes para Validação da Obrigatoriedade do CNPJ.

@type function
@author Thiago Rasmussen
@since 16/05/2012
@version P12.1.23

@obs Projeto ELO

@history 25/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Logico, Indica Verdadeiro ou Falso para as validacoes adcionais.
/*/
/*/================================================================================================================================/*/

User Function MA030TOK()

	Local lOK:= .F.
	Local lCNPJ := SuperGetMv("SI_xCNPJ",.F.,.F.,Substr(cFilant,1,4))


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If lCNPJ

		If (M->A1_TIPO = "X" .Or. !Empty(M->A1_CEINSS))

			lOk := .T.

		ElseIf Empty(M->A1_CGC)

			lOk := .F.
			MsgStop("Para este cliente deve ser preenchido o campo CGC.")

		ElseIf !Empty(M->A1_CGC)

			lOk := .T.

		Endif

	Else

		lOk:=.T.

	Endif

Return lOk
