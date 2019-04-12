#Include "Protheus.ch"
#Include "Topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMR02
Relatório de Mapa de Preços.

@type function
@author Juliana Ribeiro
@since 20/12/2011
@version P12.1.23

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMR02()
	Local oDlg
	Local cDirArq		:= "C:\"
	Local nOpca 		:= 2
	Local cPerg			:= "SCOR02"
	Local aSays			:= {}
	Local aButtons		:= {}
	Local cCadastro 	:= OemToAnsi("Relatorio de Mapa de Precos")
	//Private cTitulo		:= OemToAnsi("Relatório Gerencial")

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	ValidPerg(cPerg)
	Pergunte(cPerg,.F.)
	aadd(aSays,"Este programa tem como objetivo gerar em")
	aadd(aSays,"Excel o Relatorio de Mapa de Precos.")

	aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	aadd(aButtons, { 1,.T.,{|| nOpcA:= 1, FechaBatch() }} )
	aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )

	FormBatch( cCadastro, aSays, aButtons )

	If nOpca == 1
		cDirArq := cGetFile("","Local para gravac-o...",1,,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY ) //"Local para gravação..."
		Processa({|lEnd| RunQuery(cDirArq+"SICOMR02.XlS")},"Processando Mapa de Precos",OemToAnsi("Aguarde..."),.F.)
	EndIf

Return NIL

/*/================================================================================================================================/*/
/*/{Protheus.doc} RunQuery
Prepara e executa a query que retornará os dados para o relatório.

@type function
@author Thiago Rasmussen
@since 21/11/2011
@version P12.1.23

@param cArq, Caractere, Local de gravação e nome do arquivo a ser gerado.

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function RunQuery(cArq)
	Local cQuery 	:= ""
	Local aDados	:= {}
	Local nCount 	:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cQuery 	:= "SELECT  "
	cQuery 	+= " CO3.CO3_FILIAL, "
	cQuery 	+= " CO3.CO3_CODEDT, "
	cQuery 	+= " CO3.CO3_NUMPRO, "
	cQuery 	+= " CO3.CO3_TIPO, "
	cQuery 	+= " CO3.CO3_CODIGO, "
	cQuery 	+= " CO3.CO3_LOJA, "
	cQuery 	+= " SA2.A2_NOME, "
	cQuery 	+= " CO6.CO6_NOME, "
	cQuery 	+= " CO3.CO3_VLUNIT, "
	cQuery 	+= " CO3.CO3_CODPRO, "
	cQuery 	+= " SB1.B1_DESC, "
	cQuery 	+= " CO1.CO1_MODALI, "
	cQuery 	+= " CO6.CO6_TIPO, "
	cQuery 	+= " SA1.A1_NOME, "
	cQuery 	+= " CO2.CO2_XNUMLO  "

	cQuery 	+= "FROM " +RetSqlName("CO3")+ " CO3 "
	cQuery 	+= "LEFT JOIN " +RetSqlName("SA2")+ " SA2 ON CO3_CODIGO = A2_COD AND CO3_LOJA = A2_LOJA AND CO3.CO3_TIPO = '2'  "
	cQuery 	+= "AND SA2.A2_FILIAL = '" +xFilial("SA2")+ "' "
	cQuery 	+= "AND SA2.D_E_L_E_T_ = ' '  "

	cQuery 	+= "LEFT JOIN " +RetSqlName("SA1")+ " SA1 ON CO3_CODIGO = A1_COD AND CO3_LOJA = A1_LOJA AND CO3.CO3_TIPO = '2'  "
	cQuery 	+= "AND SA1.A1_FILIAL = '" +xFilial("SA1")+ "' "
	cQuery 	+= "AND SA1.D_E_L_E_T_ = ' '  "

	cQuery 	+= "LEFT JOIN " +RetSqlName("CO6")+ " CO6 ON CO6_CODIGO = CO3_CODIGO AND CO3_LOJA = CO6_LOJFOR  AND CO3.CO3_TIPO = '1'  "
	cQuery 	+= "AND CO6.CO6_FILIAL = '" +xFilial("CO6")+ "' "
	cQuery 	+= "AND CO6.D_E_L_E_T_ = ' '  "

	cQuery 	+= "INNER JOIN " +RetSqlName("CO2")+ " CO2 ON CO3_CODEDT = CO2_CODEDT AND CO3_NUMPRO = CO2_NUMPRO AND CO3_CODPRO = CO2_CODPRO    "
	cQuery 	+= "AND CO2.CO2_FILIAL = '" +xFilial("CO2")+ "' "
	cQuery 	+= "AND CO2.D_E_L_E_T_ = ' '  "

	cQuery 	+= "INNER JOIN " +RetSqlName("CO1")+ " CO1 ON CO3_CODEDT = CO1_CODEDT AND CO3_NUMPRO = CO1_NUMPRO   "
	cQuery 	+= "AND CO1.CO1_FILIAL = '" +xFilial("CO1")+ "' "
	cQuery 	+= "AND CO1.D_E_L_E_T_ = ' '  "

	cQuery 	+= "INNER JOIN " +RetSqlName("SB1")+ " SB1 ON CO3_CODPRO = B1_COD  "
	cQuery 	+= "AND SB1.B1_FILIAL = '" +xFilial("SB1")+ "' "
	cQuery 	+= "AND SB1.D_E_L_E_T_ = ' '  "

	cQuery 	+= "WHERE CO3.CO3_FILIAL = '" +xFilial("CO3")+ "' "
	cQuery  += "AND CO3_CODIGO BETWEEN '" + (mv_par01) + "' And '" + (mv_par02) + "' "
	cQuery  += "AND CO3_LOJA BETWEEN '" + (mv_par03) + "' And '" + (mv_par04) + "' "
	cQuery  += "AND CO3_CODPRO BETWEEN '" + (mv_par05) + "' And '" + (mv_par06) + "' "
	cQuery  += "AND CO3_CODEDT BETWEEN '" + (mv_par07) + "' And '" + (mv_par08) + "' "
	cQuery 	+= "AND CO3.D_E_L_E_T_ = ' ' "


	MsAguarde({|| dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TRBTEMP", .F., .T.)},"Selecionando registros...") //"Selecionando registros..."
	Count to nCount
	ProcRegua(nCount)
	//TcSetField("TRBTEMP","A1_ULTCOM"	,"D",08,0)
	//TcSetField("TRBTEMP","A1_DTCHURN"	,"D",08,0)
	//TcSetField("TRBTEMP","A1_PTCLI"		,"N",07,0)

	dbSelectArea("TRBTEMP")
	TRBTEMP->(dbGoTop())
	While TRBTEMP->(!Eof())
		IncProc()
		aAdd(aDados,{;
		TRBTEMP->CO3_FILIAL,;//1
		TRBTEMP->CO3_CODEDT,;//2
		TRBTEMP->CO3_NUMPRO,;//3
		TRBTEMP->CO3_TIPO,; //4
		TRBTEMP->CO3_CODIGO,;//5
		TRBTEMP->CO3_LOJA,;//6
		TRBTEMP->A2_NOME,;//7
		TRBTEMP->CO3_VLUNIT,;//8
		TRBTEMP->CO3_CODPRO,;//9
		TRBTEMP->B1_DESC,;//10
		TRBTEMP->CO2_XNUMLO,;//11
		TRBTEMP->CO6_NOME,;//12
		TRBTEMP->CO1_MODALI,;//13
		TRBTEMP->CO6_TIPO,;//14
		TRBTEMP->A1_NOME})//15
		TRBTEMP->(dbSkip())
	EndDo
	TRBTEMP->(dbClosearea())
	GeraXls(aDados, cArq)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} GeraXls
Grava o arquivo texto para planilha.

@type function
@author Juliana Ribeiro
@since 21/12/2011
@version P12.1.23

@param aDados, Array, Dados do Relatório.
@param cArq, Caractere, Local de gravação e nome do arquivo a ser gerado.

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GeraXls(aDados, cArq)
	Local nX	:= 0
	Local cTabela := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Len(aDados) > 0
		If !Empty(cArq)

			// Verifica se o arquivo existe e exclui.
			If FILE(cArq)
				FERASE(cArq)
			EndIf

			//+----------------------------------------------------------------------------------+
			//|Cria um arquivo do tipo *.xls	                                                 |
			//+----------------------------------------------------------------------------------+
			nHandle := FCREATE(cArq, 0)

			//+----------------------------------------------------------------------------------+
			//|Verifica se o arquivo pode ser criado, caso contrario um alerta sera exibido      |
			//+----------------------------------------------------------------------------------+
			If FERROR() != 0
				Alert("Não foi possível abrir ou criar o arquivo: " + cArq )
			Else


				cTabela:='<html xmlns:o="urn:schemas-microsoft-com:office:office"' + Chr(13) + Chr(10)
				cTabela+='xmlns:x="urn:schemas-microsoft-com:office:excel"' + Chr(13) + Chr(10)
				cTabela+='xmlns="http://www.w3.org/TR/REC-html40">' + Chr(13) + Chr(10)

				cTabela+='<head>' + Chr(13) + Chr(10)
				cTabela+='<meta http-equiv=Content-Type content="text/html; charset=windows-1252">' + Chr(13) + Chr(10)
				cTabela+='<meta name=ProgId content=Excel.Sheet>' + Chr(13) + Chr(10)
				cTabela+='<meta name=Generator content="Microsoft Excel 12">' + Chr(13) + Chr(10)
				cTabela+='<link rel=File-List href="SHER321_arquivos/filelist.xml">' + Chr(13) + Chr(10)
				cTabela+='<style id="SHER321_7679_Styles">' + Chr(13) + Chr(10)
				cTabela+='<!--table' + Chr(13) + Chr(10)
				cTabela+='{mso-displayed-decimal-separator:"\,";' + Chr(13) + Chr(10)
				cTabela+='mso-displayed-thousand-separator:"\.";}' + Chr(13) + Chr(10)

				cTabela+='.xl157679' + Chr(13) + Chr(10)
				cTabela+='{padding-top:1px;' + Chr(13) + Chr(10)
				cTabela+='padding-right:1px;' + Chr(13) + Chr(10)
				cTabela+='padding-left:1px;' + Chr(13) + Chr(10)
				cTabela+='mso-ignore:padding;' + Chr(13) + Chr(10)
				cTabela+='color:black;' + Chr(13) + Chr(10)
				cTabela+='font-size:11.0pt;' + Chr(13) + Chr(10)
				cTabela+='font-weight:400;' + Chr(13) + Chr(10)
				cTabela+='font-style:normal;' + Chr(13) + Chr(10)
				cTabela+='text-decoration:none;' + Chr(13) + Chr(10)
				cTabela+='font-family:Calibri, sans-serif;' + Chr(13) + Chr(10)
				cTabela+='mso-font-charset:0;' + Chr(13) + Chr(10)
				cTabela+='mso-number-format:General;' + Chr(13) + Chr(10)
				cTabela+='text-align:general;' + Chr(13) + Chr(10)
				cTabela+='vertical-align:bottom;' + Chr(13) + Chr(10)
				cTabela+='mso-background-source:auto;' + Chr(13) + Chr(10)
				cTabela+='mso-pattern:auto;' + Chr(13) + Chr(10)
				cTabela+='white-space:nowrap;}' + Chr(13) + Chr(10)

				cTabela+='.xl637679' + Chr(13) + Chr(10)
				cTabela+='{padding-top:1px;' + Chr(13) + Chr(10)
				cTabela+='padding-right:1px;' + Chr(13) + Chr(10)
				cTabela+='padding-left:1px;' + Chr(13) + Chr(10)
				cTabela+='mso-ignore:padding;' + Chr(13) + Chr(10)
				cTabela+='color:black;' + Chr(13) + Chr(10)
				cTabela+='font-size:11.0pt;' + Chr(13) + Chr(10)
				cTabela+='font-weight:400;' + Chr(13) + Chr(10)
				cTabela+='font-style:normal;' + Chr(13) + Chr(10)
				cTabela+='text-decoration:none;' + Chr(13) + Chr(10)
				cTabela+='font-family:Calibri, sans-serif;' + Chr(13) + Chr(10)
				cTabela+='mso-font-charset:0;' + Chr(13) + Chr(10)
				cTabela+='mso-number-format:General;' + Chr(13) + Chr(10)
				cTabela+='text-align:general;' + Chr(13) + Chr(10)
				cTabela+='vertical-align:bottom;' + Chr(13) + Chr(10)
				cTabela+='border:.5pt solid windowtext;' + Chr(13) + Chr(10)
				cTabela+='mso-background-source:auto;' + Chr(13) + Chr(10)
				cTabela+='mso-pattern:auto;' + Chr(13) + Chr(10)
				cTabela+='white-space:nowrap;}' + Chr(13) + Chr(10)

				cTabela+='.xl649930' + Chr(13) + Chr(10)
				cTabela+='{padding-top:1px;' + Chr(13) + Chr(10)
				cTabela+='padding-right:1px;' + Chr(13) + Chr(10)
				cTabela+='padding-left:1px;' + Chr(13) + Chr(10)
				cTabela+='mso-ignore:padding;' + Chr(13) + Chr(10)
				cTabela+='color:black;' + Chr(13) + Chr(10)
				cTabela+='font-size:11.0pt;' + Chr(13) + Chr(10)
				cTabela+='font-weight:400;' + Chr(13) + Chr(10)
				cTabela+='font-style:normal;' + Chr(13) + Chr(10)
				cTabela+='text-decoration:none;' + Chr(13) + Chr(10)
				cTabela+='font-family:Calibri, sans-serif;' + Chr(13) + Chr(10)
				cTabela+='mso-font-charset:0;' + Chr(13) + Chr(10)
				cTabela+='mso-number-format:"Short Date";' + Chr(13) + Chr(10)
				cTabela+='text-align:general;' + Chr(13) + Chr(10)
				cTabela+='vertical-align:bottom;' + Chr(13) + Chr(10)
				cTabela+='border:.5pt solid windowtext;' + Chr(13) + Chr(10)
				cTabela+='mso-background-source:auto;' + Chr(13) + Chr(10)
				cTabela+='mso-pattern:auto;' + Chr(13) + Chr(10)
				cTabela+='white-space:nowrap;}' + Chr(13) + Chr(10)

				cTabela+='.xl659930' + Chr(13) + Chr(10)
				cTabela+='{padding-top:1px;' + Chr(13) + Chr(10)
				cTabela+='padding-right:1px;' + Chr(13) + Chr(10)
				cTabela+='padding-left:1px;' + Chr(13) + Chr(10)
				cTabela+='mso-ignore:padding;' + Chr(13) + Chr(10)
				cTabela+='color:black;' + Chr(13) + Chr(10)
				cTabela+='font-size:11.0pt;' + Chr(13) + Chr(10)
				cTabela+='font-weight:400;' + Chr(13) + Chr(10)
				cTabela+='font-style:normal;' + Chr(13) + Chr(10)
				cTabela+='text-decoration:none;' + Chr(13) + Chr(10)
				cTabela+='font-family:Calibri, sans-serif;' + Chr(13) + Chr(10)
				cTabela+='mso-font-charset:0;' + Chr(13) + Chr(10)
				//cTabela+='mso-number-format:"\#\,\#\#0";' + Chr(13) + Chr(10)
				cTabela+='text-align:general;' + Chr(13) + Chr(10)
				cTabela+='vertical-align:bottom;' + Chr(13) + Chr(10)
				cTabela+='border:.5pt solid windowtext;' + Chr(13) + Chr(10)
				cTabela+='mso-background-source:auto;' + Chr(13) + Chr(10)
				cTabela+='mso-pattern:auto;' + Chr(13) + Chr(10)
				cTabela+='white-space:nowrap;}' + Chr(13) + Chr(10)

				cTabela+='.xl28' + Chr(13)+Chr(10)
				cTabela+='	{mso-style-parent:style21;' + Chr(13)+Chr(10)
				cTabela+='	color:navy;' + Chr(13)+Chr(10)
				cTabela+='	text-align:right;' + Chr(13)+Chr(10)
				cTabela+='	border-top:none;' + Chr(13)+Chr(10)
				cTabela+='	border-right:.5pt solid silver;' + Chr(13)+Chr(10)
				cTabela+='	border-bottom:.5pt solid silver;' + Chr(13)+Chr(10)
				cTabela+='	border-left:none;' + Chr(13)+Chr(10)
				cTabela+='	white-space:normal;}' + Chr(13)+Chr(10)

				cTabela += '.xl32'				 														+ Chr(13)+Chr(10)
				cTabela += '	{mso-style-parent:style16;'				 								+ Chr(13)+Chr(10)
				cTabela += '	mso-number-format:"_\(\0022R$ \0022* \#\,\#\#0\.00_\)\;_\(\0022R$ \0022* \\\(\#\,\#\#0\.00\\\)\;_\(\0022R$ \0022* \0022-\0022??_\)\;_\(\@_\)";'				 + Chr(13)+Chr(10)
				cTabela += '	border-top:none;'				 										+ Chr(13)+Chr(10)
				cTabela += '	border-right:.5pt solid windowtext;'									+ Chr(13)+Chr(10)
				cTabela += '	border-bottom:.5pt solid windowtext;'									+ Chr(13)+Chr(10)
				cTabela += '	border-left:.5pt solid windowtext;}'									+ Chr(13)+Chr(10)
				cTabela += '-->'							 											+ Chr(13)+Chr(10)

				cTabela += '.xl25'				 														+ Chr(13)+Chr(10)
				cTabela += '	{mso-style-parent:style0;'												+ Chr(13)+Chr(10)
				cTabela += '	mso-number-format:"\@";'												+ Chr(13)+Chr(10)
				cTabela += '	text-align:center;'														+ Chr(13)+Chr(10)
				cTabela += '	border-top:none;'														+ Chr(13)+Chr(10)
				cTabela += '	border-right:.5pt solid windowtext;'									+ Chr(13)+Chr(10)
				cTabela += '	border-bottom:.5pt solid windowtext;'									+ Chr(13)+Chr(10)
				cTabela += '	border-left:.5pt solid windowtext;}'									+ Chr(13)+Chr(10)

				cTabela+='-->' + Chr(13) + Chr(10)
				cTabela+='</style>' + Chr(13) + Chr(10)
				cTabela+='</head>' + Chr(13) + Chr(10)

				cTabela+='<body>' + Chr(13) + Chr(10)

				cTabela+='<div id="SHER321_7679" align=center x:publishsource="Excel">' + Chr(13) + Chr(10)

				cTabela+="<table border=0 cellpadding=0 cellspacing=0 width=692 style='border-collapse:collapse;table-layout:fixed;width:520pt'>" + Chr(13) + Chr(10)
				cTabela+="<tr height=20 style='height:15.0pt'>" + Chr(13) + Chr(10)
				cTabela+='<td class=xl637679 >Filial</td>' + Chr(13) + Chr(10)
				cTabela+='<td class=xl637679 >Codigo Edital</td>' + Chr(13) + Chr(10)
				cTabela+='<td class=xl637679 >Numero do Processo</td>' + Chr(13) + Chr(10)
				cTabela+='<td class=xl637679 >Tipo</td>' + Chr(13) + Chr(10)
				cTabela+='<td class=xl637679 >Codigo</td>' + Chr(13) + Chr(10)
				cTabela+='<td class=xl637679 >Loja</td>' + Chr(13) + Chr(10)
				cTabela+='<td class=xl637679 >Nome do Fornecedor</td>' + Chr(13) + Chr(10)
				cTabela+='<td class=xl637679 >Valor Unitario</td>' + Chr(13) + Chr(10)
				cTabela+='<td class=xl637679 >Produto</td>' + Chr(13) + Chr(10)
				cTabela+='<td class=xl637679 >Descricao</td>' + Chr(13) + Chr(10)
				cTabela+='<td class=xl637679 >Lote</td>' + Chr(13) + Chr(10)
				cTabela+='</tr>' + Chr(13) + Chr(10)
				ProcRegua(Len(aDados))
				For nX := 1 To Len(aDados)
					IncProc("Gerando XLS...")
					If(FWRITE(nHandle, cTabela) == 0)
						Alert("Não foi possível gravar o arquivo!")  //"Não foi possível gravar o arquivo!"
					EndIf


					cTabela:="<tr height=20 style='height:15.0pt'>" + Chr(13) + Chr(10)
					cTabela+='<td class=xl637679 >'+AllTrim(aDados[nX,1])+'</td>' + Chr(13) + Chr(10) //FILIAL
					cTabela+='<td class=xl25 >'+AllTrim(aDados[nX,2])+'</td>' + Chr(13) + Chr(10) //COD EDITAL
					cTabela+='<td class=xl25 >'+AllTrim(aDados[nX,3])+'</td>' + Chr(13) + Chr(10) //NUM PROCESSO

					If AllTrim(aDados[nX,4]) == '1' .AND. AllTrim(aDados[nX,13]) == "LL"
						cTabela+='<td class=xl637679 >'+ 'Pré-Cliente' +'</td>' + Chr(13) + Chr(10) //TIPO
					ElseIf AllTrim(aDados[nX,4]) == '2' .AND. AllTrim(aDados[nX,13]) == "LL"
						cTabela+='<td class=xl637679 >'+ 'Cliente' +'</td>' + Chr(13) + Chr(10) //TIPO
					ElseIf AllTrim(aDados[nX,4]) == '1' .AND. AllTrim(aDados[nX,13]) <> "LL"
						cTabela+='<td class=xl637679 >'+ 'Pre-fornecedor' +'</td>' + Chr(13) + Chr(10) //TIPO
					ElseIf AllTrim(aDados[nX,4]) == '2'.AND. AllTrim(aDados[nX,13]) <> "LL"
						cTabela+='<td class=xl637679 >'+ 'Fornecedor' +'</td>' + Chr(13) + Chr(10) //TIPO
					EndIf

					/*	If AllTrim(aDados[nX,4]) == '1' .AND. AllTrim(aDados[nX,13]) == "LL" .AND. AllTrim(aDados[nX,14]) <> "C"
					cTabela+='<td class=xl637679 >'+ 'Cliente' +'</td>' + Chr(13) + Chr(10) //TIPO
					ElseIf AllTrim(aDados[nX,4]) == '1' .AND. AllTrim(aDados[nX,13]) == "LL" .AND. AllTrim(aDados[nX,14]) == "C"
					cTabela+='<td class=xl637679 >'+ 'Pre-cliente' +'</td>' + Chr(13) + Chr(10) //TIPO
					ElseIf AllTrim(aDados[nX,4]) == '1' .AND. AllTrim(aDados[nX,14]) == "F"
					cTabela+='<td class=xl637679 >'+ 'Pre-fornecedor' +'</td>' + Chr(13) + Chr(10) //TIPO
					ElseIf AllTrim(aDados[nX,4]) == '2'
					cTabela+='<td class=xl637679 >'+ 'Fornecedor' +'</td>' + Chr(13) + Chr(10) //TIPO
					EndIf  */
					cTabela+='<td class=xl25 >'+AllTrim(aDados[nX,5])+'</td>' + Chr(13) + Chr(10) //CODIGO
					cTabela+='<td class=xl25 >'+AllTrim(aDados[nX,6])+'</td>' + Chr(13) + Chr(10) //LOJA

					If AllTrim(aDados[nX,4]) == '2' .AND. AllTrim(aDados[nX,13]) == "LL"
						cTabela+='<td class=xl637679 >'+AllTrim(aDados[nX,15])+'</td>' + Chr(13) + Chr(10) //NOME cliente
					ElseIf AllTrim(aDados[nX,4]) == '1'
						cTabela+='<td class=xl637679 >'+AllTrim(aDados[nX,12])+'</td>' + Chr(13) + Chr(10) //NOME pre-fornecedor/pre-cliente
					ElseIf AllTrim(aDados[nX,4]) == '2' .AND. AllTrim(aDados[nX,13]) <> "LL"
						cTabela+='<td class=xl637679 >'+AllTrim(aDados[nX,7])+'</td>' + Chr(13) + Chr(10) //NOME FORNECEDOR
					EndIf
					/*	If AllTrim(aDados[nX,4]) == '1' .AND. AllTrim(aDados[nX,13]) == "LL"
					cTabela+='<td class=xl637679 >'+AllTrim(aDados[nX,15])+'</td>' + Chr(13) + Chr(10) //NOME cliente
					ElseIf AllTrim(aDados[nX,4]) == '1'
					cTabela+='<td class=xl637679 >'+AllTrim(aDados[nX,12])+'</td>' + Chr(13) + Chr(10) //NOME pre-fornecedor/pre-cliente
					ElseIf AllTrim(aDados[nX,4]) == '2'
					cTabela+='<td class=xl637679 >'+AllTrim(aDados[nX,7])+'</td>' + Chr(13) + Chr(10) //NOME FORNECEDOR
					EndIf */
					//cTabela+='<td class=xl659930 >'+AllTrim(Str(aDados[nX,8]))+'</td>' + Chr(13) + Chr(10) //VALOR UNITARIO
					cTabela+='<td class=xl32 >'+Transform(aDados[nX,8],"@E 999,999,999,999.99 ")+'</td>' + Chr(13)+Chr(10)//VALOR UNITARIO
					cTabela+='<td class=xl25 >'+AllTrim(aDados[nX,9])+'</td>' + Chr(13) + Chr(10) //PRODUTO
					cTabela+='<td class=xl637679 >'+AllTrim(aDados[nX,10])+'</td>' + Chr(13) + Chr(10) //DESCRICAO
					cTabela+='<td class=xl25 >'+AllTrim(aDados[nX,11])+'</td>' + Chr(13) + Chr(10) //LOTE
					cTabela+='</tr>' + Chr(13) + Chr(10)
				Next nX
				cTabela+='</table>' + Chr(13) + Chr(10)
				cTabela+='</div>' + Chr(13) + Chr(10)
				cTabela+='</body>' + Chr(13) + Chr(10)
				cTabela+='</html>' + Chr(13) + Chr(10)



				//+----------------------------------------------------------------------------------+
				//|Verifica se foi possivel gravar o arquivo, caso nao seja possivel um mensagem     |
				//|de alerta será exibida na tela   			                                     |
				//+----------------------------------------------------------------------------------+
				If(FWRITE(nHandle, cTabela) == 0)

					Alert("Não foi possível gravar o arquivo!")  //"Não foi possível gravar o arquivo!"

				EndIf

				//+----------------------------------------------------------------------------------+
				//|Fecha o arquivo gravado                                                           |
				//+----------------------------------------------------------------------------------+
				FCLOSE(nHandle)


				cMsg := "Arquivo gerado com sucesso. "+CHR(13)+CHR(10)
				cMsg += "O arquivo foi gravado em:  " +cArq+CHR(13)+CHR(10)
				cMsg += " "+CHR(13)+CHR(10)

				Aviso("Aviso",cMsg,{"Ok"})

				lRet := .T.                                                                  ç
			EndIf
		Else

			Alert("Caminho do arquivo não Informado!!! Não foi possível gravar o arquivo!")  //"Não foi possível gravar o arquivo!"

			lRet := .F.
		EndIf
	Else

		Alert("Não há dados para gerar o arquivo!")

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidPerg
Este programa tem como objetivo ajustar o arquivo de perguntas (SX1).

@type function
@author Joao Tavares Junior
@since 03/05/2005
@version P12.1.23

@param cPerg, Caractere, Nome da pergunta.

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ValidPerg(cPerg)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Verifica se existe ou nao o arquivo de pergunta (SX1)
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If SX1->(!dbSeek(cPerg))
		PutSx1Help("P.SCOR0201.",{"Fornecedor/Cliente."})
		PutSx1Help("P.SCOR0202.",{"Fornecedor/Cliente."})
		PutSx1Help("P.SCOR0203.",{"Loja."})
		PutSx1Help("P.SCOR0204.",{"Loja."})
		PutSx1Help("P.SCOR0205.",{"Codigo do Produto."})
		PutSx1Help("P.SCOR0206.",{"Codigo do Produto."})
		PutSx1Help("P.SCOR0207.",{"Edital."})
		PutSx1Help("P.SCOR0208.",{"Edital."})

		//		PutSx1(cPerg, "01", "Forn/Cli. De    	?","","", "mv_ch1", "C", 6,0,0,"G",""				,"SA2"	 	,"","","mv_par01",""	    , "", "", "", ""    , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "", "", "", "")
		//		PutSx1(cPerg, "02", "Forn/Cli. Ate    	?","","", "mv_ch2", "C", 6,0,0,"G",""				,"SA2"	 	,"","","mv_par02",""	    , "", "", "", ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "", "", "", "")
		//		PutSx1(cPerg, "03", "Loja De   			?","","", "mv_ch3", "C", 2,0,0,"G",""				,""	 	 	,"","","mv_par03",""	    , "", "", "", ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "", "", "", "")
		//		PutSx1(cPerg, "04", "Loja Ate  			?","","", "mv_ch4", "C", 2,0,0,"G",""				,""	 	 	,"","","mv_par04",""	    , "", "", "", ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "", "", "")
		//		PutSx1(cPerg, "05", "Produto De  	  	?","","", "mv_ch5", "C", 30,0,0,"G",""				,"SB1"	 	,"030","","mv_par05",""	    , "", "", "", ""    , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "", "", "", "")
		//		PutSx1(cPerg, "06", "Produto Ate 	  	?","","", "mv_ch6", "C", 30,0,0,"G",""				,"SB1"	 	,"030","","mv_par06",""	    , "", "", "", ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "", "", "", "")
		//		PutSx1(cPerg, "07", "Edital De  		?","","", "mv_ch7", "C", 15,0,0,"G",""				,"CO1001"	 ,"","","mv_par07",""	    , "", "", "", ""    , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "", "", "", "")
		//		PutSx1(cPerg, "08", "Edital Ate 		?","","", "mv_ch8", "C", 15,0,0,"G",""				,"CO1001"	 ,"","","mv_par08",""	    , "", "", "", ""	, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "", "", "", "")

	EndIf

Return()
