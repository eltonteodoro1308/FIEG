#Include "Protheus.ch"
#include "Topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT140TOK
Valida todos itens da pré-nota.

@type function
@author Thiago Rasmussen
@since 03/05/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function MT140TOK()

	Local I                  := 1
	Local sAUX               := ""
	Local lRETORNO           := .T.
	Local _MV_XINSREC        := SuperGetMV("MV_XINSREC", .F., "", Substr(cFilAnt,1,4))
	Local _MV_XESEFOR        := SuperGetMV("MV_XESEFOR", .F.)
	Local _MV_XESEUSU        := SuperGetMV("MV_XESEUSU", .F.)
	Local _ALIAS             := GETNEXTALIAS()
	Local _C7_NUM            := ""
	Local _ARRAY             := {}
	Local _REGISTRO_DE_PRECO := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< 01/10/2016 - Thiago Rasmussen - Consistir o pedido passou pela inspeção >--
	If cFilAnt $(_MV_XINSREC)
		If !(cA100For$(_MV_XESEFOR) .AND. RetCodUsr()$(_MV_XESEUSU))
			For I := 1 TO LEN(aCols)
				If aCols[I][Len(aHeader)+1] == .F.
					If aCols[I][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_PEDIDO" })] != _C7_NUM
						_C7_FILIAL := XFILIAL("SC7")
						_C7_NUM    := aCols[I][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_PEDIDO" })]
						_C7_ITEM   := aCols[I][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_ITEMPC" })]

						If aCols[I][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_ITEMMED" })] == '1'
							_ARRAY := GetAdvFVal("SC7", { "C7_FILIAL", "C7_XFILCOM", "C7_CONTRA", "C7_CONTREV" }, XFILIAL("SC7")+_C7_NUM, 1, { "", "", "", "" })
							_REGISTRO_DE_PRECO := POSICIONE("CN9", 1,IIF(EMPTY(_ARRAY[2]), _ARRAY[1], _ARRAY[2]) + _ARRAY[3] + _ARRAY[4], "CN9_XREGP") == "1"
						EndIf

						If aCols[I][ASCAN(aHeader,{|x| TRIM(x[2])=="D1_ITEMMED" })] != '1' .OR. _REGISTRO_DE_PRECO
							_SQL := "EXEC LK_SESUITE.SE_SUITE.dbo.SP_VALIDACAO_PRE_NOTA '" + _C7_FILIAL + "', '" + _C7_NUM + "', '" + ALLTRIM(STR(VAL(CNFISCAL))) + "', '" + DTOS(dDEmissao) + "'"

							If Select( _ALIAS ) # 0

								(_ALIAS)->(DbCloseArea())

							End If
							TcQuery _SQL NEW ALIAS (_ALIAS)
							dbSelectArea(_ALIAS)

							If (_ALIAS)->(EOF())
								lRETORNO := .F.
								MsgAlert("Pedido de compra " + _C7_FILIAL + " / " + _C7_NUM + " / " + _C7_ITEM + " não passou pela inspeção de recebimento do SE Suíte.","MT140TOK")
								EXIT
							EndIf
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	EndIf



	//--< Validar número da nota fiscal >--
	If lRETORNO
		For I := 1 TO LEN(ALLTRIM(CNFISCAL))
			If Substr(CNFISCAL, I, 1)$'123456789'
				sAUX := sAUX + Substr(CNFISCAL, I, 1)
			ElseIf Substr(CNFISCAL, I, 1)$'0' .AND. !EMPTY(sAUX)
				sAUX := sAUX + Substr(CNFISCAL, I, 1)
			ElseIf lRETORNO
				lRETORNO := .F.
				MsgAlert("O número da nota fiscal não deve conter zeros a esquerda ou caracteres diferentes de número! A informação vai ser ajustada automaticamente e caso esteja de acordo pode dar continuidade ao lançamento da pré-nota.","MT140TOK")
			EndIf
		Next

		If SUBS(CSERIE,1,1) == "S" .AND. LEN(sAUX) < 9
			sAUX := '0' + sAUX
		EndIf

		CNFISCAL := sAUX + SPACE(9 - LEN(sAUX))
	EndIf

	// Validar série da nota fiscal
	If lRETORNO
		I := 1
		sAUX := ""

		For I := 1 TO LEN(ALLTRIM(CSERIE))
			If Substr(CSERIE, I, 1)$'123456789'
				sAUX := sAUX + Substr(CSERIE, I, 1)
			ElseIf Substr(CSERIE, I, 1)$'0' .AND. (Substr(sAUX, 1, 1)$'123456789' .OR. Substr(sAUX, 2, 1)$'123456789')
				sAUX := sAUX + Substr(CSERIE, I, 1)
			ElseIf Substr(CSERIE, I, 1)$'SD'
				sAUX := sAUX + Substr(CSERIE, I, 1)

				If ALLTRIM(CSERIE) == 'S' .OR. ALLTRIM(CSERIE) == 'D'
					lRETORNO := .F.
					MsgAlert("A série da nota fiscal não deve conter zeros a esquerda ou caracteres diferentes de número! A informação vai ser ajustada automaticamente e caso esteja de acordo pode dar continuidade ao lançamento da pré-nota.","MT140TOK")
				EndIf
			ElseIf lRETORNO
				lRETORNO := .F.
				MsgAlert("A série da nota fiscal não deve conter zeros a esquerda ou caracteres diferentes de número! A informação vai ser ajustada automaticamente e caso esteja de acordo pode dar continuidade ao lançamento da pré-nota.","MT140TOK")
			EndIf
		Next

		CSERIE := sAUX + SPACE(3 - LEN(sAUX))
	EndIf

RETURN lRETORNO
