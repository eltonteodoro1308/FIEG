#INCLUDE "PROTHEUS.CH"
#INCLUDE "Topconn.ch"

// Autor....: Thiago Rasmussen
// Data.....: 13/12/2016
// Modulo...: 02 - Compras
// Descri��o: Valida��es Espec�ficas do usu�rio

#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110LOK
Valida��es Espec�ficas do usu�rio nas linhas da solicita��o de compras.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro valida linha ou Falso n�o valida linha.

/*/
/*/================================================================================================================================/*/

User Function  MT110LOK()

	Local _ALIAS      := GETNEXTALIAS()
	Local _SQL        := ""
	Local _FORNECEDOR := ""
	Local _PRODUTO    := ""
	Local _DESCRICAO  := ""
	Local _CONTADOR   := 0
	Local lRet        := .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If aCols[n][Len(aHeader)+1] == .F.
		_PRODUTO   := AllTrim(aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})])
		_DESCRICAO := AllTrim(aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_DESCRI'})])

		// 27/12/2018 - Thiago Rasmussen - Validar produtos inativos
		If ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+_PRODUTO,"B1_COLOR")) == "INATIVO"
			MsgAlert("O seguinte produto " + _PRODUTO + " - " + _DESCRICAO + " encontra-se inativado, qualquer d�vida procurar a GEMAT.","MT110LOK")
			lRet :=  .F.
		EndIf

		_FORNECEDOR := Posicione("ZZ3", 1, xFilial("ZZ3")+_PRODUTO, "ZZ3_FORNEC")

		If !EMPTY(_FORNECEDOR)
			FOR I := 1 TO Len(aCols)
				If _PRODUTO == AllTrim(aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})]) .AND. aCols[I][Len(aHeader)+1] == .F.
					_CONTADOR := _CONTADOR + 1
					If _CONTADOR > 1
						MsgAlert("O seguinte produto " + _PRODUTO + " - " + _DESCRICAO + " n�o pode constar mais de uma vez para a mesma solicita��o de compra.","MT110LOK")
						lRet :=  .F.
					EndIf
				EndIf
			NEXT

			_SQL := "SELECT dbo.FN_GET_SALDO_CONTRATO_LOCACAO("+cValToChar(aCols[n][Len(aHeader)])+",'"+_PRODUTO+"') AS SALDO"

			TcQuery _SQL NEW ALIAS (_ALIAS)
			(_ALIAS)->(dbSelectArea(_ALIAS))

			If (_ALIAS)->SALDO - aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_QUANT'})] < 0
				aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_FORNECE'})] := ""
				aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_LOJA'})]    := ""
				MsgAlert("O saldo dispon�vel do seguinte produto " + _PRODUTO + " - " + _DESCRICAO + " � " + cValToChar((_ALIAS)->SALDO) + " unidades.","MT110LOK")
				(_ALIAS)->(DbCloseArea())
				lRet :=  .F.
			EndIf

			aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_FORNECE'})] := _FORNECEDOR
			aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_LOJA'})]    := "0001"

			(_ALIAS)->(DbCloseArea())

		EndIf

	EndIf

Return lRet