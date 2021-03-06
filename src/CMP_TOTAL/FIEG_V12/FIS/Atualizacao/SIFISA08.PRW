#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIFISA08
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

User Function SIFISA08()
	Local lRet 			:= .T.
	Local nPosCodServ	:= aScan( aHeader, { |x| Alltrim( Upper( x[2] ) ) == "Z9_CODSERV" } )
	Local nPosAliq		:= aScan( aHeader, { |x| Alltrim( Upper( x[2] ) ) == "Z9_ALIQ" } )
	Local nx			:= 0

	For nx := 1 to Len( aCols )

		If aCols[ nx, nPosAliq ] == 0
			cMsg := "Campo ALIQ SERVI�O � de preenchimento obrigat�rio!"
			lRet := .F.
		Endif

		If Empty( aCols[ nx, nPosCodServ ] )
			cMsg := "Campo CODIGO SERVI � de preenchimento obrigat�rio!"
			lRet := .F.
		Endif

		If !lRet
			Help("",1,"","GVGCT04C",cMsg,1,0)
			Exit
		Endif

	Next

Return( lRet )