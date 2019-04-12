#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIFISA09
Rotina "tudook" para validar as linhas do Getdados.

@type function
@author Antonio Marcos Andriani
@since 04/06/2010
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando o resultado na validação das linhas do Getdados.

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
					Alert( "Código de Serviço já informado para esta prefeitura!" )
				Endif
			Endif
		Next

		If Altera
			If SZ9->( DBSeek( xFilial( "SZ9" ) + M->(Z8_ESTADO+M->Z8_COD_MUN) + aCols[ n, nPosCodServ ] ) )
				lRet := .F.
				Alert( "O campo 'Codigo Servi' não pode ser alterado. Excluir a linha e incluir novamente!!!" )
			Endif
		Endif

	Elseif cCpo == "M->Z9_ALIQ"

		If xVal == 0
			lRet := .F.
			Alert( "Favor informar o percentual de aliquota do servico!" )
		Endif

	Endif

Return( lRet )
