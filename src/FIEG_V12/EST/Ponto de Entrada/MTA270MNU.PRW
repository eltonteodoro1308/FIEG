#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTA270MNU
Ponto de entrada para manipular a aRotina do inventário.

@type function
@author Thiago Rasmussen
@since 16/12/2011
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function MTA270MNU()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Exclusao
	If (_nPos := aScan(aRotina,{|x| Upper(AllTrim(x[2])) == Upper("A270Deleta")})) > 0
		aRotina[_nPos,2] := "U_SIESTA10()"
	EndIf

Return()
