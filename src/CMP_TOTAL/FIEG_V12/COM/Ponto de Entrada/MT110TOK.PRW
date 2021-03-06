#Include "Protheus.ch"
#Include "Topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110TOK
Ponto de Entrada utilizado para validar o preenchimento do campo cJustCom (Justificativa de compra).

@type function
@author Claudinei Ferreira
@since 10/01/2012
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Retorna verdadeiro se valida��es forem OK.
/*/
/*/================================================================================================================================/*/

User Function MT110TOK()

Local aArea       := GetArea()
Local lRet        := .T.
Local nPosCta     := aScan(aHeader, {|x| ALLTRIM(x[2]) == 'C1_CONTA'})
Local _MV_XCONPAR := SuperGetMV("MV_XCONPAR", .F.)
Local _ALIAS      := GETNEXTALIAS()
Local _SQL        := ""
Local _TOTAL_SC   := 0
Local _MV_XSOL999 := SuperGetMV("MV_XSOL999", .F., "", SUBSTR(cFilAnt,1,4))

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< 29/11/2016 - Thiago Rasmussen - Alguns usu�rios espec�ficos v�o ter permiss�o de incluir SC do tipo Contrato de Parceria >--
IF cTpSC == '006' .AND. !(RetCodUsr() $(_MV_XCONPAR))
	MsgAlert("Usu�rio n�o possui permiss�o para inclus�o de solicita��es de compra do tipo Contrato de Parceria!","MT110TOK")
	lRet := .F.
ENDIF

//--< 19/04/2018 - Thiago Rasmussen - Validar filial de entrega >--
IF lRet .AND. SUBSTR(xFILIAL('SC1'),5,4) != '0001'
	IF xFILIAL('SC1') != M->cFilEnt .AND. SUBSTR(M->cFilEnt,5,4) != '0001'
		MsgAlert("As solicita��es realizadas por uma filial s� podem definir como filial de entrega a mesma filial da solicita��o ou a filial da matriz.","MT110TOK")
		lRet := .F.
	ENDIF
ENDIF

IF lRet .AND. EMPTY(M->CJUSTCOM)
	MsgAlert("Informe a justificativa da solicita��o de compra!","MT110TOK")
	lRet := .F.
ENDIF

IF lRet .AND. EMPTY(M->_cItCta) .AND. !cTpSC $ '001/005'
	MsgAlert("Informe o �tem cont�bil!","MT110TOK")
	lRet := .F.
ELSEIF lRet .AND. EMPTY(M->_cItCta) .AND. cTpSC $ '001/005'
	FOR I := 1 TO LEN(aCols)
		IF SUBSTR(aCols[n][nPosCta],1,2) <> "11"
			MsgAlert("Informe o �tem cont�bil!","MT110TOK")
			lRet := .F.
			EXIT
		ENDIF
	NEXT
ENDIF

//--< 10/11/2014 - Thiago Rasmussen - Validar Amarra��o Cont�bil >--
//IF lRet
//	IF EMPTY(POSICIONE("CTA", 11, xFILIAL("CTA") + M->CCCUSTO + M->_CITCTA, "CTA_DESC"))
//		MsgAlert("Verifique a amarra��o cont�bil entre o centro de custo " + ALLTRIM(M->CCUSTO) + " e o item cont�bil " + ALLTRIM(M->_CITCTA) + ".","MT110TOK")
//		lRet := .F.
//	ENDIF
//ENDIF

//--< 25/07/2017 - Thiago Rasmussen - Validar solicita��es que devem ser encaminhadas para a GEMAT >--
IF lRet
	IF !xFILIAL("SC1")$'01GO0001;02GO0001;03GO0001;04GO0001;05GO0001'
		IF POSICIONE("SY1",1,xFILIAL("SY1") + '999',"Y1_MSBLQL") == "1" .AND. SC1->C1_XCODCOM != "999" .AND. !ALLTRIM(SC1->C1_CC)$(_MV_XSOL999)
			FOR I := 1 TO LEN(aCols)
				IF aCols[I][Len(aHeader)+1] == .F.
					_TOTAL_SC := _TOTAL_SC + (aCols[I][aScan(aHeader, {|x| ALLTRIM(x[2]) == 'C1_QUANT'})] * aCols[I][aScan(aHeader, {|x| ALLTRIM(x[2]) == 'C1_VUNIT'})])

					IF SUBSTR(aCols[I][aScan(aHeader, {|x| ALLTRIM(x[2]) == 'C1_CONTA'})],1,2) = '32' .AND. ALLTRIM(aCols[I][aScan(aHeader, {|x| ALLTRIM(x[2]) == 'C1_CONTA'})]) != '32010202'
						MsgAlert("As solicita��es de compra da filial " + xFILIAL("SC1") + ", de produtos patrimoniados devem ser encaminhadas para a ger�ncia de materiais realizar a compra, s� que no momento a GEMAT est� bloqueada para receber solicita��es de compra!" + CRLF + CRLF + "Qualquer d�vida, entre em contato com a GEMAT.","MT110TOK")
						lRet := .F.
						EXIT
					ENDIF
				ENDIF
			NEXT

			IF lRet .AND. _TOTAL_SC > 4000.00
				MsgAlert("As solicita��es de compra da filial " + xFILIAL("SC1") + ", que o valor total seja acima de R$ 4.000,00 devem ser encaminhadas para a ger�ncia de materiais realizar a compra, s� que no momento a GEMAT est� bloqueada para receber solicita��es de compra!" + CRLF + CRLF + "Qualquer d�vida, entre em contato com a GEMAT.","MT110TOK")
				lRet := .F.
			ENDIF
		ENDIF
	ELSE
		IF POSICIONE("SY1",1,xFILIAL("SY1") + IIF(INCLUI,'999',SC1->C1_XCODCOM),"Y1_MSBLQL") == "1" .AND. !ALLTRIM(M->CCUSTO)$(_MV_XSOL999)
			MsgAlert("As solicita��es de compra da matriz " + xFILIAL("SC1") + " devem ser encaminhadas para a ger�ncia de materiais realizar a compra, s� que no momento a GEMAT est� bloqueada para receber solicita��es de compra!" + CRLF + CRLF + "Qualquer d�vida, entre em contato com a GEMAT.","MT110TOK")
			lRet := .F.
		ENDIF
	ENDIF
ENDIF

IF lRet
	FOR I := 1 TO LEN(aCols)
		IF aCols[I][Len(aHeader)+1] == .F.
			IF !xFILIAL("SC1")$'01GO0001;02GO0001;03GO0001;04GO0001;05GO0001'
				//--< 01/06/2017 - Thiago Rasmussen - Validar Comprador N�o Informado >--
				IF EMPTY(aCols[I][aScan(aHeader, {|x| ALLTRIM(x[2]) == 'C1_XCODCOM'})])
					MsgAlert("Informe o comprador para o item " + aCols[I][aScan(aHeader, {|x| ALLTRIM(x[2]) == 'C1_ITEM'})] + " da solicita��o de compra.","MT110TOK")
					lRet := .F.
					EXIT
				ENDIF

				//--< 19/12/2013 - Thiago Rasmussen - Validar Comprador Bloqueado >--
				IF POSICIONE("SY1",1,xFILIAL("SY1") + aCols[I][aScan(aHeader, {|x| ALLTRIM(x[2]) == 'C1_XCODCOM'})],"Y1_MSBLQL") == "1"
					MsgAlert("O comprador " + ALLTRIM(POSICIONE("SY1",1,xFILIAL("SY1") + aCols[I][aScan(aHeader, {|x| ALLTRIM(x[2]) == 'C1_XCODCOM'})],"Y1_NOME")) + " est� bloqueado, consulte os compradores atrav�s da op��o F3.","MT110TOK")
					lRet := .F.
					EXIT
				ENDIF
			ENDIF

			//--< 13/12/2016 - Thiago Rasmussen - Validar Saldo de determinados produtos >--
			IF !EMPTY(Posicione("ZZ3", 1, xFILIAL("ZZ3")+aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})], "ZZ3_FORNEC"))
				_SQL := "SELECT dbo.FN_GET_SALDO_CONTRATO_LOCACAO("+cValToChar(aCols[I][Len(aHeader)])+",'"+aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})]+"') AS SALDO"

				TcQuery _SQL NEW ALIAS (_ALIAS)
				(_ALIAS)->(dbSelectArea(_ALIAS))

				IF (_ALIAS)->SALDO - aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_QUANT'})] < 0
					MsgAlert("O saldo dispon�vel do seguinte produto " + AllTrim(aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})]) + " - " + AllTrim(aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_DESCRI'})]) + " � " + cValToChar((_ALIAS)->SALDO) + " unidades.","MT110TOK")
					(_ALIAS)->(DbCloseArea())
					lRet := .F.
					EXIT
				ENDIF

				(_ALIAS)->(DbCloseArea())
			ENDIF

			//--< 27/12/2018 - Thiago Rasmussen - Validar produtos inativos >--
			IF ALLTRIM(POSICIONE("SB1",1,xFILIAL("SB1")+aCols[I][aScan(aHeader, {|x| ALLTRIM(x[2]) == 'C1_PRODUTO'})],"B1_COLOR")) == "INATIVO"
				MsgAlert("O seguinte produto " + AllTrim(aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})]) + " - " + AllTrim(aCols[I][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_DESCRI'})]) + ", do item " + aCols[I][aScan(aHeader, {|x| ALLTRIM(x[2]) == 'C1_ITEM'})] + ", encontra-se inativado, qualquer d�vida procurar a GEMAT.","MT110TOK")
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
EndIf

RestArea(aArea)

Return(lRet)