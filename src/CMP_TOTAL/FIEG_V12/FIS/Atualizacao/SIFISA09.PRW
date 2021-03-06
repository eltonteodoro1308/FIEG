#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIFISA09
Rotina "tudook" para validar as linhas do Getdados.

@type function
@author Antonio Marcos Andriani
@since 04/06/2010
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso indicando o resultado na valida��o das linhas do Getdados.

/*/
/*/================================================================================================================================/*/

User Function SIFISA09()
	Local cCpo 			:= ReadVar()
	Local xVal 			:= &(ReadVar())
	Local lRet			:= .T.
	Local nPosCodServ	:= aScan( aHeader, { |x| Alltrim( Upper( x[2] ) ) == "Z9_CODSERV" } )

	If cCpo == "M->Z9_CODSERV"

		For nx := 1 to Len( aCols )
			If nx <> n
				If xVal == aCols[ nx, nPosCodServ ]
					lRet := .F.
					Alert( "C�digo de Servi�o j� informado para esta prefeitura!" )
				Endif
			Endif
		Next

		If Altera
			If SZ9->( DBSeek( xFilial( "SZ9" ) + M->(Z8_ESTADO+M->Z8_COD_MUN) + aCols[ n, nPosCodServ ] ) )
				lRet := .F.
				Alert( "O campo 'Codigo Servi' n�o pode ser alterado. Excluir a linha e incluir novamente!!!" )
			Endif
		Endif

	Elseif cCpo == "M->Z9_ALIQ"

		If xVal == 0
			lRet := .F.
			Alert( "Favor informar o percentual de aliquota do servico!" )
		Endif

	Endif

Return( lRet )
