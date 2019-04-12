#Include "Protheus.ch"
#Include "TBICONN.CH"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} XATFRSD
Relatório de Ativos Customizado.

@type function
@author Thiago Rasmussen
@since 18/12/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function XATFRSD()

	Local _SQL         := ""
	Local _ALIAS       := GetNextAlias()
	Local _CABECALHO   := {}
	Local _DADOS       := {}
	Local _CONT_I      := 18
	Local _CONT_F      := 18
	Local _AGRUPAR_POR := ""
	Local _TOTALIZAR   := "FALSE"
	Local _TOT_A       := ""
	Local _TOT_H       := ""
	Local _TOT_I       := ""
	Local _TOT_J       := ""
	Local _TOT_K       := ""
	Local lSegue       := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não instalado!")
		lSegue := .F.
	ENDIF

	IF lSegue .And. PERGUNTE("XATFRSD", .T.) == .F.
		lSegue := .F.
	ENDIF

	If lSegue

		AAdd(_DADOS, {"Filtros"})
		AAdd(_DADOS, {"Filial: " + MV_PAR01 + " à " + MV_PAR02})
		AAdd(_DADOS, {"Centro de Custo: " + MV_PAR03 + " à " + MV_PAR04})
		AAdd(_DADOS, {"Local: " + MV_PAR05 + " à " + MV_PAR06})
		AAdd(_DADOS, {"Grupo: " + MV_PAR07 + " à " + MV_PAR08})
		AAdd(_DADOS, {"Produto: " + MV_PAR09 + " à " + MV_PAR10})
		AAdd(_DADOS, {"Ativo: " + MV_PAR11 + " à " + MV_PAR12})
		AAdd(_DADOS, {"Aquisição: " + DTOC(MV_PAR13) + " à " + DTOC(MV_PAR14)})

		DO CASE
			CASE MV_PAR15 == 1 // FILIAL
			AAdd(_DADOS, {"Ordenado por: Filial"})
			CASE MV_PAR15 == 2 // GRUPO
			AAdd(_DADOS, {"Ordenado por: Grupo"})
			CASE MV_PAR15 == 3 // CENTRO DE CUSTO
			AAdd(_DADOS, {"Ordenado por: Centro de Custo"})
			CASE MV_PAR15 == 4 // LOCAL
			AAdd(_DADOS, {"Ordenado por: Local"})
		ENDCASE

		AAdd(_DADOS, {""}) // SIMULAÇÃO DE SALTO DE LINHA

		_SQL += " SELECT "
		_SQL += " N1_FILIAL AS COL01, "
		_SQL += " CHAR(13) + N1_CBASE AS COL02, "
		_SQL += " N1_DESCRIC AS COL03, "
		_SQL += " N1_XMODPR AS COL04, "
		_SQL += " CHAR(13) + RTRIM(N1_GRUPO) + ' - ' + NG_DESCRIC AS COL05, "
		_SQL += " CHAR(13) + RTRIM(N3_CUSTBEM) + ' - ' + CTT_DESC01 AS COL06, "
		_SQL += " CHAR(13) + RTRIM(N1_LOCAL) + ' - ' + NL_DESCRIC AS COL07, "
		_SQL += " SUBSTRING(N1_AQUISIC,7,2) + '/' + SUBSTRING(N1_AQUISIC,5,2) + '/' + SUBSTRING(N1_AQUISIC,1,4) AS COL08, "
		_SQL += " 'R$ ' + REPLACE(CAST(N3_VORIG1 AS DECIMAL(12,2)),'.',',') AS COL09, "
		_SQL += " 'R$ ' + REPLACE(CAST(N3_VRDACM1 AS DECIMAL(12,2)),'.',',') AS COL10, "
		_SQL += " 'R$ ' + REPLACE(CAST(ROUND((N3_VORIG1 - N3_VRDACM1), 2) AS DECIMAL(12,2)),'.',',') AS COL11, "
		_SQL += " 'R$ ' + REPLACE(CAST(N3_VRDMES1 AS DECIMAL(12,2)),'.',',') AS COL12 "
		_SQL += " FROM SN1010 WITH (NOLOCK) "
		_SQL += " LEFT JOIN SN3010 WITH (NOLOCK) ON N3_FILIAL = N1_FILIAL AND "
		_SQL += "                                   N3_CBASE = N1_CBASE AND "
		_SQL += "                                   N3_ITEM = N1_ITEM AND "
		_SQL += "                                   SN3010.D_E_L_E_T_ = '' "
		_SQL += " LEFT JOIN SNG010 WITH (NOLOCK) ON NG_FILIAL = SUBSTRING(N1_FILIAL,1,4) AND "
		_SQL += "                                   NG_GRUPO = N1_GRUPO AND "
		_SQL += "                                   SNG010.D_E_L_E_T_ = '' "
		_SQL += " LEFT JOIN CTT010 WITH (NOLOCK) ON CTT_FILIAL = SUBSTRING(N3_FILIAL,1,4) AND "
		_SQL += "                                   CTT_CUSTO = N3_CUSTBEM AND "
		_SQL += "                                   CTT010.D_E_L_E_T_ = '' "
		_SQL += " LEFT JOIN SNL010 WITH (NOLOCK) ON NL_CODIGO = N1_LOCAL AND "
		_SQL += "                                   SNL010.D_E_L_E_T_ = '' "
		_SQL += " WHERE SN1010.D_E_L_E_T_ = '' AND "
		_SQL += "       N1_QUANTD > 0 AND "
		_SQL += "       N1_STATUS <> '0' "

		IF ALLTRIM(MV_PAR01) != ""
			_SQL += "AND N1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
		ENDIF

		IF ALLTRIM(MV_PAR03) != ""
			_SQL += "AND N3_CUSTBEM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
		ENDIF

		IF ALLTRIM(MV_PAR05) != ""
			_SQL += "AND N1_LOCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
		ENDIF

		IF ALLTRIM(MV_PAR07) != ""
			_SQL += "AND N1_GRUPO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
		ENDIF

		IF ALLTRIM(MV_PAR09) != ""
			_SQL += "AND N1_PRODUTO BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
		ENDIF

		IF ALLTRIM(MV_PAR11) != ""
			_SQL += "AND N1_CBASE BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
		ENDIF

		IF !EMPTY(MV_PAR13) .AND. !EMPTY(MV_PAR14)
			_SQL += "AND N1_AQUISIC BETWEEN '" + DTOS(MV_PAR13) + "' AND '" + DTOS(MV_PAR14) + "' "
		ENDIF

		DO CASE
			CASE MV_PAR15 == 1 // FILIAL
			_SQL += "ORDER BY N1_FILIAL, N1_CBASE "
			CASE MV_PAR15 == 2 // GRUPO
			_SQL += "ORDER BY N1_GRUPO, N1_CBASE "
			CASE MV_PAR15 == 3 // CENTRO DE CUSTO
			_SQL += "ORDER BY N3_CUSTBEM, N1_CBASE "
			CASE MV_PAR15 == 4 // LOCAL
			_SQL += "ORDER BY N1_LOCAL, N1_CBASE "
		ENDCASE

		IF SELECT(_ALIAS) > 0
			dbSelectArea(_ALIAS)
			(_ALIAS)->(dbCloseArea())
		ENDIF

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)

		DbSelectArea(_ALIAS)
		(_ALIAS)->(dbGotop())

		While !(_ALIAS)->(EOF())
			IF _CONT_I == _CONT_F
				DO CASE
					CASE MV_PAR15 == 1 // FILIAL
					AAdd(_DADOS, {"Filial: " + (_ALIAS)->COL01})
					AAdd(_DADOS, {"Ativo", "Descrição", "Modelo", "Grupo", "Centro Custo", "Local", "Aquisição", "Valor Aquisição", "Depreciação Acumulada", "Valor Resisual", "Depreciação Mês"})
					_AGRUPAR_POR = (_ALIAS)->COL01
					CASE MV_PAR15 == 2 // GRUPO
					AAdd(_DADOS, {"Grupo: " + (_ALIAS)->COL05})
					AAdd(_DADOS, {"Filial", "Ativo", "Descrição", "Modelo", "Centro Custo", "Local", "Aquisição", "Valor Aquisição", "Depreciação Acumulada", "Valor Resisual", "Depreciação Mês"})
					_AGRUPAR_POR = (_ALIAS)->COL05
					CASE MV_PAR15 == 3 // CENTRO DE CUSTO
					AAdd(_DADOS, {"Centro de Custo: " + (_ALIAS)->COL06})
					AAdd(_DADOS, {"Filial", "Ativo", "Descrição", "Modelo", "Grupo", "Local", "Aquisição", "Valor Aquisição", "Depreciação Acumulada", "Valor Resisual", "Depreciação Mês"})
					_AGRUPAR_POR = (_ALIAS)->COL06
					CASE MV_PAR15 == 4 // LOCAL
					AAdd(_DADOS, {"Local: " + (_ALIAS)->COL07})
					AAdd(_DADOS, {"Filial", "Ativo", "Descrição", "Modelo", "Grupo", "Centro Custo", "Aquisição", "Valor Aquisição", "Depreciação Acumulada", "Valor Resisual", "Depreciação Mês"})
					_AGRUPAR_POR = (_ALIAS)->COL07
				ENDCASE
			ENDIF

			DO CASE
				CASE MV_PAR15 == 1 // FILIAL
				AAdd(_DADOS, { (_ALIAS)->COL02, (_ALIAS)->COL03, (_ALIAS)->COL04, (_ALIAS)->COL05, (_ALIAS)->COL06, (_ALIAS)->COL07, (_ALIAS)->COL08, (_ALIAS)->COL09, (_ALIAS)->COL10, (_ALIAS)->COL11, (_ALIAS)->COL12 })
				CASE MV_PAR15 == 2 // GRUPO
				AAdd(_DADOS, { (_ALIAS)->COL01, (_ALIAS)->COL02, (_ALIAS)->COL03, (_ALIAS)->COL04, (_ALIAS)->COL06, (_ALIAS)->COL07, (_ALIAS)->COL08, (_ALIAS)->COL09, (_ALIAS)->COL10, (_ALIAS)->COL11, (_ALIAS)->COL12 })
				CASE MV_PAR15 == 3 // CENTRO DE CUSTO
				AAdd(_DADOS, { (_ALIAS)->COL01, (_ALIAS)->COL02, (_ALIAS)->COL03, (_ALIAS)->COL04, (_ALIAS)->COL05, (_ALIAS)->COL07, (_ALIAS)->COL08, (_ALIAS)->COL09, (_ALIAS)->COL10, (_ALIAS)->COL11, (_ALIAS)->COL12 })
				CASE MV_PAR15 == 4 // LOCAL
				AAdd(_DADOS, { (_ALIAS)->COL01, (_ALIAS)->COL02, (_ALIAS)->COL03, (_ALIAS)->COL04, (_ALIAS)->COL05, (_ALIAS)->COL06, (_ALIAS)->COL08, (_ALIAS)->COL09, (_ALIAS)->COL10, (_ALIAS)->COL11, (_ALIAS)->COL12 })
			ENDCASE

			_CONT_F += 1

			(_ALIAS)->(dbSkip())

			DO CASE
				CASE MV_PAR15 == 1 // FILIAL
				IF _AGRUPAR_POR != (_ALIAS)->COL01
					_TOTALIZAR = "TRUE"
				ENDIF
				CASE MV_PAR15 == 2 // GRUPO
				IF _AGRUPAR_POR != (_ALIAS)->COL05
					_TOTALIZAR = "TRUE"
				ENDIF
				CASE MV_PAR15 == 3 // CENTRO DE CUSTO
				IF _AGRUPAR_POR != (_ALIAS)->COL06
					_TOTALIZAR = "TRUE"
				ENDIF
				CASE MV_PAR15 == 4 // LOCAL
				IF _AGRUPAR_POR != (_ALIAS)->COL07
					_TOTALIZAR = "TRUE"
				ENDIF
			ENDCASE

			IF _TOTALIZAR == "TRUE"
				AAdd(_DADOS, {"=CONT.VALORES(A"+ALLTRIM(STR(_CONT_I))+":A"+ALLTRIM(STR(_CONT_F - 1))+")", "", "", "", "", "", "", "=MOEDA(SOMA(H"+ALLTRIM(STR(_CONT_I))+":H"+ALLTRIM(STR(_CONT_F - 1))+");2)", "=MOEDA(SOMA(I"+ALLTRIM(STR(_CONT_I))+":I"+ALLTRIM(STR(_CONT_F - 1))+");2)", "=MOEDA(SOMA(J"+ALLTRIM(STR(_CONT_I))+":J"+ALLTRIM(STR(_CONT_F - 1))+");2)", "=MOEDA(SOMA(K"+ALLTRIM(STR(_CONT_I))+":K"+ALLTRIM(STR(_CONT_F - 1))+");2)"})
				IF _TOT_A == ""
					_TOT_A = "A" + ALLTRIM(STR(_CONT_F))
				ELSE
					_TOT_A = _TOT_A + "+A" + ALLTRIM(STR(_CONT_F))
				ENDIF

				IF _TOT_H == ""
					_TOT_H = "H" + ALLTRIM(STR(_CONT_F))
				ELSE
					_TOT_H = _TOT_H + "+H" + ALLTRIM(STR(_CONT_F))
				ENDIF

				IF _TOT_I == ""
					_TOT_I = "I" +ALLTRIM(STR(_CONT_F))
				ELSE
					_TOT_I = _TOT_I + "+I" + ALLTRIM(STR(_CONT_F))
				ENDIF

				IF _TOT_J == ""
					_TOT_J = "J" + ALLTRIM(STR(_CONT_F))
				ELSE
					_TOT_J = _TOT_J + "+J" + ALLTRIM(STR(_CONT_F))
				ENDIF

				IF _TOT_K == ""
					_TOT_K = "K" + ALLTRIM(STR(_CONT_F))
				ELSE
					_TOT_K = _TOT_K + "+K" + ALLTRIM(STR(_CONT_F))
				ENDIF

				_CONT_F += 3
				_CONT_I = _CONT_F

				_TOTALIZAR = "FALSE"
			ENDIF
		END

		AAdd(_DADOS, {""})
		AAdd(_DADOS, {"=("+_TOT_A+")", "", "", "", "", "", "", "=MOEDA("+_TOT_H+";2)", "=MOEDA("+_TOT_I+";2)", "=MOEDA("+_TOT_J+";2)", "=MOEDA("+_TOT_K+";2)"})

		MsgRun("Favor Aguardar.....","Exportando os Registros para o Excel",{||DlgToExcel({{"ARRAY","Relatório de Ativos",_CABECALHO, _DADOS}})})

		(_ALIAS)->(dbCloseArea())

		ASize(_CABECALHO,0)
		_CABECALHO := Nil

		ASize(_DADOS,0)
		_DADOS := Nil

	EndIf

Return