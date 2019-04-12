#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} XSLA
Relatório de SLA.

@type function
@author Thiago Rasmussen
@since 02/06/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function XSLA()

	Local lSegue := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	IF PERGUNTE("XGSTCOM", .T.) == .F.
		lSegue := .F.
	ENDIF

	If lSegue

		MsgRun("Favor Aguardar.....","Exportando os Registros para o Excel",{||GERAR_ARQUIVO()})

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} GERAR_ARQUIVO
Função que Exporta os Registros para o Excel.

@type function
@author Thiago Rasmussen
@since 02/06/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GERAR_ARQUIVO()
	Local _SQL       := ""
	Local _ALIAS     := GetNextAlias()
	Local _CABECALHO := {}
	Local _DADOS     := {}
	Local _TEMP      := {}
	Local I          := 10
	Local _MODALIDADE
	Local lSegue := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	_SQL := "EXEC XSLA '" + MV_PAR01 + "','" + MV_PAR02 + "','" + DTOS(MV_PAR03) + "','" + DTOS(MV_PAR04) + "'"

	IF SELECT(_ALIAS) > 0
		dbSelectArea(_ALIAS)
		(_ALIAS)->(dbCloseArea())
	ENDIF

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)

	DbSelectArea(_ALIAS)
	(_ALIAS)->(dbGotop())

	IF (_ALIAS)->(EOF())
		MsgAlert("Verifique os parâmetros informados, nenhum registro foi encontrado!")
		lSegue := .T.
	ENDIF

	If lSegue

		AAdd(_DADOS, {"Modalidade", "Filial SC", "Solicitação", "Item SC", "Produto", "Data Solicitação", "Data Aprovação", "Cotação", "Data Cotação", "Contrato", "Data Assinatura", "Medição", "Filial PC", "Pedido", "Item PC", "Data Pedido", "Data NF", "Modalidade", "SC->AP", "AP->PC", "PC->NF", "Dispensa Licitação (15)", "Convite (25)", "Inexibilidade (20)", "Leilão (30)", "Pregão (20)", "Concorrência (45)", "Consulta", "Comprador"})

		While !(_ALIAS)->(EOF())
			I += 1

			//ConOut(STR(I))

			// Modalidade
			IF     ALLTRIM((_ALIAS)->MODALIDADE) == 'COMPRA DIRETA' .OR. ALLTRIM((_ALIAS)->MODALIDADE) == 'DISPENSA LICITAÇÃO' .OR. ALLTRIM((_ALIAS)->MODALIDADE) == 'LICITAÇÃO'
				_MODALIDADE := "DL"
			ELSEIF ALLTRIM((_ALIAS)->MODALIDADE) == 'CONVITE'
				_MODALIDADE := "CV"
			ELSEIF ALLTRIM((_ALIAS)->MODALIDADE) == 'INEXIGIBILIDADE'
				_MODALIDADE := "IN"
			ELSEIF ALLTRIM((_ALIAS)->MODALIDADE) == 'PREGÃO'
				_MODALIDADE := "PG"
			ELSEIF ALLTRIM((_ALIAS)->MODALIDADE) == 'CONCORRÊNCIA'
				_MODALIDADE := "CC"
			ELSE
				_MODALIDADE := ""
			ENDIF

			AAdd(_DADOS, {;
			(_ALIAS)->MODALIDADE,;
			(_ALIAS)->FILIAL_SC,;
			(_ALIAS)->NUMERO_SC,;
			(_ALIAS)->ITEM_SC,;
			(_ALIAS)->PRODUTO_SC,;
			STOD((_ALIAS)->DATA_SC),;
			STOD((_ALIAS)->DATA_APROVACAO),;
			(_ALIAS)->NUMERO_COTACAO,;
			STOD((_ALIAS)->DATA_COTACAO),;
			(_ALIAS)->CONTRATO,;
			STOD((_ALIAS)->DATA_CONTRATO),;
			(_ALIAS)->MEDICAO,;
			(_ALIAS)->FILIAL_PC,;
			(_ALIAS)->NUMERO_PC,;
			(_ALIAS)->ITEM_PC,;
			STOD((_ALIAS)->DATA_PC),;
			STOD((_ALIAS)->DATA_NF),;
			_MODALIDADE,;
			'=DIATRABALHOTOTAL(F'+ALLTRIM(STR(I))+';G'+ALLTRIM(STR(I))+')',;
			'=DIATRABALHOTOTAL(G'+ALLTRIM(STR(I))+';SE(AB'+ALLTRIM(STR(I))+'=3;K'+ALLTRIM(STR(I))+';P'+ALLTRIM(STR(I))+'))',;
			'=DIATRABALHOTOTAL(P'+ALLTRIM(STR(I))+';Q'+ALLTRIM(STR(I))+')',;
			'=SE(R'+ALLTRIM(STR(I))+'="DL";SE(T'+ALLTRIM(STR(I))+'<=15;1;0);"")',;
			'=SE(R'+ALLTRIM(STR(I))+'="CV";SE(T'+ALLTRIM(STR(I))+'<=25;1;0);"")',;
			'=SE(R'+ALLTRIM(STR(I))+'="IN";SE(T'+ALLTRIM(STR(I))+'<=20;1;0);"")',;
			'=SE(R'+ALLTRIM(STR(I))+'="LL";SE(T'+ALLTRIM(STR(I))+'<=30;1;0);"")',;
			'=SE(R'+ALLTRIM(STR(I))+'="PG";SE(T'+ALLTRIM(STR(I))+'<=20;1;0);"")',;
			'=SE(R'+ALLTRIM(STR(I))+'="CC";SE(T'+ALLTRIM(STR(I))+'<=45;1;0);"")',;
			(_ALIAS)->CONSULTA,;
			(_ALIAS)->COMPRADOR })

			(_ALIAS)->(dbSkip())
		END

		AAdd(_TEMP, {"Filtros"})
		AAdd(_TEMP, {"Filial: " + MV_PAR01 + " à " + MV_PAR02})
		AAdd(_TEMP, {"Emissão: " + DTOC(MV_PAR03) + " à " + DTOC(MV_PAR04)})

		AAdd(_TEMP, {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",;
		'=TEXTO(SE(CONT.NÚM(V11:V'+ALLTRIM(STR(I))+')>0;SOMA(V11:V'+ALLTRIM(STR(I))+')/CONT.NÚM(V11:V'+ALLTRIM(STR(I))+');1);"#.##0,00%")',;
		'=TEXTO(SE(CONT.NÚM(W11:W'+ALLTRIM(STR(I))+')>0;SOMA(W11:W'+ALLTRIM(STR(I))+')/CONT.NÚM(W11:W'+ALLTRIM(STR(I))+');1);"#.##0,00%")',;
		'=TEXTO(SE(CONT.NÚM(X11:X'+ALLTRIM(STR(I))+')>0;SOMA(X11:X'+ALLTRIM(STR(I))+')/CONT.NÚM(X11:X'+ALLTRIM(STR(I))+');1);"#.##0,00%")',;
		'=TEXTO(SE(CONT.NÚM(Y11:Y'+ALLTRIM(STR(I))+')>0;SOMA(Y11:Y'+ALLTRIM(STR(I))+')/CONT.NÚM(Y11:Y'+ALLTRIM(STR(I))+');1);"#.##0,00%")',;
		'=TEXTO(SE(CONT.NÚM(Z11:Z'+ALLTRIM(STR(I))+')>0;SOMA(Z11:Z'+ALLTRIM(STR(I))+')/CONT.NÚM(Z11:Z'+ALLTRIM(STR(I))+');1);"#.##0,00%")',;
		'=TEXTO(SE(CONT.NÚM(AA11:AA'+ALLTRIM(STR(I))+')>0;SOMA(AA11:AA'+ALLTRIM(STR(I))+')/CONT.NÚM(AA11:AA'+ALLTRIM(STR(I))+');1);"#.##0,00%")'})

		FOR J := 1 TO LEN(_DADOS)
			AAdd(_TEMP, {_DADOS[J][1], _DADOS[J][2], _DADOS[J][3], _DADOS[J][4], _DADOS[J][5], _DADOS[J][6], _DADOS[J][7], _DADOS[J][8], _DADOS[J][9], _DADOS[J][10], _DADOS[J][11], _DADOS[J][12], _DADOS[J][13], _DADOS[J][14], _DADOS[J][15], _DADOS[J][16], _DADOS[J][17], _DADOS[J][18], _DADOS[J][19], _DADOS[J][20], _DADOS[J][21], _DADOS[J][22], _DADOS[J][23], _DADOS[J][24], _DADOS[J][25], _DADOS[J][26], _DADOS[J][27], _DADOS[J][28], _DADOS[J][29]})
		NEXT

		DlgToExcel({{"ARRAY","Nível de Atendimento", _CABECALHO, _TEMP}})

		(_ALIAS)->(dbCloseArea())

		ASize(_CABECALHO,0)
		_CABECALHO := Nil

		ASize(_DADOS,0)
		_DADOS := Nil

		ASize(_TEMP,0)
		_TEMP := Nil

	EndIf

Return