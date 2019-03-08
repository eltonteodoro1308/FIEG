#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA37
Rotina de exclusao de ativos.

@type function
@author Thiago Rasmussen
@since 25/07/2012
@version P12.1.23

@obs Projeto ELO

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA37()

	Local _cArea   := GetArea()
	Local _cArqTRB := CriaTrab(nil,.f.)
	Private aCIAP  := {}


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQuery  := "SELECT N1_CBASE,N1_ITEM FROM "+RetSqlName("SN1")+" WHERE D_E_L_E_T_ = ' ' AND N1_FILIAL = '"+XFilial("SN1")+"' "
	_cQuery  += "AND N1_FORNEC = '"+SF1->F1_FORNECE+"' AND N1_LOJA = '"+SF1->F1_LOJA+"' AND N1_NSERIE = '"+SF1->F1_SERIE+"' "
	_cQuery  += "AND N1_NFISCAL = '"+SF1->F1_DOC+"' "
	_cQuery  := ChangeQuery(_cQuery)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqTRB,.t.,.t.)

	While (_cArqTRB)->(!Eof())

		SN1->(dbSetOrder(1))
		IF SN1->(dbSeek(XFilial("SN1")+(_cArqTRB)->(N1_CBASE+N1_ITEM)))
			Af010DelAtu("SN3",,,,@aCIAP)
		ENDIF

		(_cArqTRB)->(dbSkip())
	Enddo

	(_cArqTRB)->(dbCloseArea())
	FErase(_cArqTRB+GetDBExtension())
	FErase(_cArqTRB+OrdBagExt())

Return()
