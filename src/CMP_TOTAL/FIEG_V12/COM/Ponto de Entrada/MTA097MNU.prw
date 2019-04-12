#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTA097MNU
Ponto de entrada para chamada de funcoes de liberacao de documentos do tipo Solicitacao de compras.

@type function
@author Adriano Luis Brandao - TOTVS
@since 19/07/2011
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MTA097MNU()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Consulta >--------------------------------------------
IF (_nPos := aScan(aRotina,{|x| Upper(AllTrim(x[2])) == Upper("A097Visual")})) > 0
	aRotina[_nPos,2] := "U_SICOMA04(1)"
ENDIF
//--< Liberação >-------------------------------------------
IF (_nPos := aScan(aRotina,{|x| Upper(AllTrim(x[2])) == Upper("A097Libera")})) > 0
	aRotina[_nPos,2] := "U_SICOMA04(2)"
ENDIF
//--< Estornar >--------------------------------------------
IF (_nPos := aScan(aRotina,{|x| Upper(AllTrim(x[2])) == Upper("A097Estorna")})) > 0
	aRotina[_nPos,2] := "U_SICOMA04(3)"
ENDIF

Return()
