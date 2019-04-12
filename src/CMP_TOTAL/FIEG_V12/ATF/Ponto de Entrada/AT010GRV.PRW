#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} AT010GRV
Ponto de Entrada de complemento de gravacao do ativo.

@type function
@author Thiago Rasmussen
@since 04/07/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function AT010GRV()
//	Local _cArea    := GetArea()
//	Local _cAreaSX6 := SX6->(GetArea())
//	Local clCodBase	:= ""
//
//	//--< Log das Personalizações >-----------------------------
//	U_LogCustom()
//
//	//--< Processamento da Rotina >-----------------------------
//
//	IF ALLTRIM(SN1->N1_CBASE) == "00000000"
//		clCodBase := SuperGetMv()
//		clCodBase := &(SuperGetMv("MV_CBASEAF",.F.,,LEFT(CFILANT,4)))
//
//		dbSelectArea("SX6")
//		SX6->(dbSetOrder(1))
//		IF SX6->(dbSeek(LEFT(CFILANT,4)+Space(4)+"MV_CBASEAF"))
//			RecLock("SX6",.F.)
//			FieldPut( FieldPos('X6_CONTEUD'), '"'+Soma1(Alltrim(clCodBase))+'"' )
//			SX6->(MsUnLock())
//		ENDIF
//
//		IF RecLock("SN1", .F.)
//			SN1->N1_CBASE := clCodBase
//			SN1->( MsUnLock() )
//		ENDIF
//
//		IF RecLock("SN3", .F.)
//			SN3->N3_CBASE := clCodBase
//			SN3->( MsUnLock() )
//		ENDIF
//
//		IF RecLock("SN4", .F.)
//			SN4->N4_CBASE := clCodBase
//			SN4->( MsUnLock() )
//		ENDIF
//	ENDIF
//
//	IF INCLUI
//		IF RecLock("SN1", .F.)
//			SN1->N1_VLAQUIS := SN3->N3_VORIG1
//			SN1->( MsUnLock() )
//		ENDIF
//
//		IF RecLock("SN3", .F.)
//			SN3->N3_SUBCCON := ""
//			SN3->N3_CUSTBEM := SN3->N3_CCUSTO
//			SN3->( MsUnLock() )
//		ENDIF
//	ENDIF
//
//	IF INCLUI .AND. (!EMPTY(SN3->N3_CUSTBEM) .OR. !EMPTY(SN3->N3_CCUSTO))
//		IF !EMPTY(SN3->N3_CUSTBEM)
//			GRAVARESP(SN3->N3_CUSTBEM)
//		ELSE
//			GRAVARESP(SN3->N3_CCUSTO)
//		ENDIF
//	ENDIF
//
//	RestArea(_cAreaSX6)
//	RestArea(_cArea)

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} GRAVARESP
Grava código do responsável do centro de custo no cadastro do bem.

@type function
@author Thiago Rasmussen
@since 04/07/2012
@version P12.1.23

@param _cCC, Caractere, Centro de Custo.

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GRAVARESP(_cCC)
	Local cQry      := ""
	Local _cKeySND  := ""
	Local _cAreaSND := GetArea()
	Local lSegue    := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cQry := " SELECT CTT_XRESP FROM "+RETSQLNAME("CTT")
	cQry += " WHERE D_E_L_E_T_ = '' AND CTT_CUSTO = '"+_cCC+"' AND CTT_FILIAL = '"+xFilial("CTT")+"'"

	IF Select("QRY") > 0
		DbSelectArea("QRY")
		QRY->(DbCloseArea())
	ENDIF

	cQry := ChangeQuery(cQry)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), 'QRY', .F., .T.)

	DbSelectArea("QRY")
	QRY->(DbGotop())

	IF QRY->(EOF()) .OR. Empty(QRY->CTT_XRESP)
		DbSelectArea("QRY")
		QRY->(DbCloseArea())
		Restarea(_cAreaSND)
		lSegue := .F.
	ENDIF

	If lSegue

		WHILE QRY->(!EOF())
			dbSelectArea("SND")
			SND->(dbSetOrder(1))

			_cKeySND := xFilial("SND")+QRY->CTT_XRESP+SN1->N1_CBASE+SN1->N1_ITEM

			IF INCLUI .OR. ALTERA
				IF SND->(MsSeek(_cKeySND+"1",.F.))
					RecLock("SND",.F.)
				ELSE
					RecLock("SND",.T.)
				ENDIF

				Field->ND_FILIAL  := xFilial("SND")
				Field->ND_CODRESP := QRY->CTT_XRESP
				Field->ND_CBASE   := SN1->N1_CBASE
				Field->ND_ITEM    := SN1->N1_ITEM
				Field->ND_STATUS  := "1"
				Field->ND_DTINI   := dDataBase
				Field->ND_SEQUENC := NextSNDSEQ(SN1->N1_CBASE,SN1->N1_ITEM)

				SND->(MsUnlock())
			ENDIF

			DbSelectArea("QRY")
			QRY->(dbSkip())
		END

	EndIf

	DbSelectArea("QRY")
	QRY->(DbCloseArea())

	Restarea(_cAreaSND)

Return