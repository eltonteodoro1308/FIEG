#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTA094RO
O Ponto de Entrada MTA094RO, localizado na rotina de Liberação de Documento, permite adicionar opções no item Outras Ações.
Alterando os programas nas rotinas de liberação, visualização e estorno.

@type function
@author Elton Alves
@since 26/04/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array aRotina com as modificações.

/*/
/*/================================================================================================================================/*/


User Function MTA094RO()

	Local aRotina := PARAMIXB[1]
	Local _nPos1  := 0
	Local _nPos2  := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Consulta >--------------------------------------------
	If (_nPos1 := aScan(aRotina,{|x| Upper(AllTrim(x[1])) == Upper("VIsualizar")})) > 0

		_nPos2 := aScan(aRotina[_nPos1,2],{|x| Upper(AllTrim(x[2])) == Upper("A94Visual")})

		aRotina[_nPos1,2,_nPos2,2] := "U_SICOMA04(1)"

	End If
	//--< Liberação >-------------------------------------------
	IF (_nPos1 := aScan(aRotina,{|x| Upper(AllTrim(x[2])) == Upper("A94ExLiber")})) > 0
		aRotina[_nPos1,2] := "U_SICOMA04(2)"
	End If
	//--< Estornar >--------------------------------------------
	IF (_nPos1 := aScan(aRotina,{|x| Upper(AllTrim(x[2])) == Upper("A094VldEst")})) > 0
		aRotina[_nPos1,2] := "U_SICOMA04(3)"
	End If

Return (aRotina)