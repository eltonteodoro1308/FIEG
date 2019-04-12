#Include "Protheus.ch"
#include "report.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} DTAT100
Relatório de Contagem de Transferência de Ativo Por Entidade (fieg).

@type function
@author José Fernando C.Vilela
@since 02/12/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function DTAT100()

	Local osection1
	Local oSection2
	Local oSsecion3
	Local oSection4
	Local oSection5
	Local osection6
	Local oSection7
	Local oSsecion8
	Local oSection9
	Local oSection10

	Local cTitulo := "QTDE TRANSFERIDA/FIEG"
	Private oReport

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	CriaSX1("DTAT100")
	//Pergunte("DTAT100",.F.)

	DEFINE REPORT oReport NAME "DTAT100" TITLE cTitulo PARAMETER "DTAT100" ACTION {|oReport| PrintReport(oReport)}

	DEFINE SECTION oSection1 OF oReport TITLE "Qtde Transferida" TABLES "SN4" LEFT MARGIN 2

	DEFINE CELL NAME "FIEG        " OF oSection1 ALIAS "SN4" TITLE "ENTIDADE"  //Legenda Horizontal
	DEFINE CELL NAME "01GO - FIEG "	OF oSection1 ALIAS "SN4"
	DEFINE CELL NAME "CONTADOR1   "	OF oSection1 ALIAS "SN4" TITLE " TOTAL ENTIDADE"	//quantidade


	DEFINE SECTION oSection2 OF oReport TITLE "Qtde Transferida" TABLES "SN4" LEFT MARGIN 2

	DEFINE CELL NAME "SESI        " OF oSection2 ALIAS "SN4" TITLE "ENTIDADE"  //Legenda Horizontal
	DEFINE CELL NAME "02GO - SESI " OF oSection2 ALIAS "SN4"
	DEFINE CELL NAME "CONTADOR2   " OF oSection2 ALIAS "SN4" TITLE "TOTAL ENTIDADE"	//quantidade

	DEFINE SECTION oSection3 OF oReport TITLE "Qtde Transferida" TABLES "SN4" LEFT MARGIN 2

	DEFINE CELL NAME "SENAI"    	OF oSection3 ALIAS "SN4" TITLE "ENTIDADE"  //Legenda Horizontal
	DEFINE CELL NAME "03GO  SENAI" OF oSection3 ALIAS "SN4"
	DEFINE CELL NAME "CONTADOR3" 	OF oSection3 ALIAS "SN4" TITLE "TOTAL ENTIDADE"  //quantidade

	DEFINE SECTION oSection4 OF oReport TITLE "Qtde Transferida" TABLES "SN4" LEFT MARGIN 2

	DEFINE CELL NAME "IEL         "	OF oSection4 ALIAS "SN4" TITLE "ENTIDADE"   //Legenda Horizontal
	DEFINE CELL NAME "04GO  - IEL  "	OF oSection4 ALIAS "SN4"
	DEFINE CELL NAME "CONTADOR4   "	OF oSection4 ALIAS "SN4" TITLE "  TOTAL ENTIDADE"	//quantidade

	DEFINE SECTION oSection5 OF oReport TITLE "Qtde Transferida" TABLES "SN4" LEFT MARGIN 2

	DEFINE CELL NAME "ICQ BRASIL  "	OF oSection5 ALIAS "SN4" TITLE "ENTIDADE"  //Legenda Horizontal
	DEFINE CELL NAME "05GO  - ICQ  "	OF oSection5 ALIAS "SN4"
	DEFINE CELL NAME "CONTADOR5   "	OF oSection5 ALIAS "SN4" TITLE "  TOTAL ENTIDADE"	//quantidade


	DEFINE SECTION oSection6 OF oReport TITLE "Qtde Transferida" TABLES "SN4" LEFT MARGIN 2

	DEFINE CELL NAME "FIEG        " OF oSection6 ALIAS "SN4" TITLE "01GO FIEG -  "  //Legenda Horizontal
	DEFINE CELL NAME "N4_FILIAL   " OF oSection6 ALIAS "SN4"
	DEFINE CELL NAME "CONTADOR6   " OF oSection6 ALIAS "SN4" TITLE "__________QTDE"	//quantidade


	DEFINE SECTION oSection7 OF oReport TITLE "Qtde Transferida" TABLES "SN4" LEFT MARGIN 2

	DEFINE CELL NAME "SESI        " OF oSection7 ALIAS "SN4" TITLE "02GO SESI -  "    //Legenda Horizontal
	DEFINE CELL NAME "N4_FILIAL   " OF oSection7 ALIAS "SN4"
	DEFINE CELL NAME "CONTADOR7   " OF oSection7 ALIAS "SN4" TITLE "__________QTDE"	//quantidade

	DEFINE SECTION oSection8 OF oReport TITLE "Qtde Transferida" TABLES "SN4" LEFT MARGIN 2

	DEFINE CELL NAME "SENAI       "	OF oSection8 ALIAS "SN4" TITLE "03GO SENAI - " //Legenda Horizontal
	DEFINE CELL NAME "N4_FILIAL   " OF oSection8 ALIAS "SN4"
	DEFINE CELL NAME "CONTADOR8   " OF oSection8 ALIAS "SN4" TITLE "_________QTDE"	//quantidade

	DEFINE SECTION oSection9 OF oReport TITLE "Qtde Transferida" TABLES "SN4" LEFT MARGIN 2

	DEFINE CELL NAME "IEL         " OF oSection9 ALIAS "SN4" TITLE "04GO IEL   - "   //Legenda Horizontal
	DEFINE CELL NAME "N4_FILIAL   " OF oSection9 ALIAS "SN4"
	DEFINE CELL NAME "CONTADOR9   " OF oSection9 ALIAS "SN4" TITLE "_________QTDE"	//quantidade

	DEFINE SECTION oSection10 OF oReport TITLE "Qtde Transferida" TABLES "SN4" LEFT MARGIN 2

	DEFINE CELL NAME "ICQ BRASIL  " OF oSection10 ALIAS "SN4" TITLE "05GO ICQ   - "   //Legenda Horizontal
	DEFINE CELL NAME "N4_FILIAL   " OF oSection10 ALIAS "SN4"
	DEFINE CELL NAME "CONTADOR10  " OF oSection10 ALIAS "SN4" TITLE "_________QTDE"	//quantidade


	oReport:PrintDialog()
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} PrintReport
Busca dados do relatorio.

@type function
@author José Fernando Vilela
@since 02/12/2015
@version P12.1.23

@param oReport, Objeto, Objeto que representa o relatório.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function PrintReport(oReport)
	#IFDEF TOP
	Local cAlias1  		:= GetNextAlias()
	Local cAlias2  		:= GetNextAlias()
	Local cAlias3  		:= GetNextAlias()
	Local cAlias4  		:= GetNextAlias()
	Local cAlias5  		:= GetNextAlias()
	Local cAlias6  		:= GetNextAlias()
	Local cAlias7  		:= GetNextAlias()
	Local cAlias8  		:= GetNextAlias()
	Local cAlias9  		:= GetNextAlias()
	Local cAlias10 		:= GetNextAlias()

	local cStatus       := mv_par03

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	/*If cStatus = 1
	oReport:Section(6):Disable()
	oReport:Section(7):Disable()
	oReport:Section(8):Disable()
	oReport:Section(9):Disable()
	oReport:Section(10):Disable()
	else
	oReport:Section(1):Disable()
	oReport:Section(2):Disable()
	oReport:Section(3):Disable()
	oReport:Section(4):Disable()
	oReport:Section(5):Disable()
	Endif */

	if cStatus = 1
		/*	If Select(cAlias1) > 0
		dbSelectArea(cAlias6)
		dbCloseArea()
		dbSelectArea(cAlias7)
		dbCloseArea()
		dbSelectArea(cAlias8)
		dbCloseArea()
		dbSelectArea(cAlias9)
		dbCloseArea()
		dbSelectArea(cAlias10)
		dbCloseArea()
		Endif */

		BEGIN REPORT QUERY oReport:Section(1)
			BeginSql alias cAlias1
				SELECT N4_OCORR,
				COUNT (N4_OCORR) AS CONTADOR1
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "01GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_OCORR
				ORDER BY N4_OCORR

			EndSql

		END REPORT QUERY oReport:Section(1)


		BEGIN REPORT QUERY oReport:Section(2)

			BeginSql alias cAlias2
				SELECT N4_OCORR,
				COUNT (N4_OCORR) AS CONTADOR2
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "02GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_OCORR
				ORDER BY N4_OCORR

			EndSql

		END REPORT QUERY oReport:Section(2)


		BEGIN REPORT QUERY oReport:Section(3)

			BeginSql alias cAlias3
				SELECT N4_OCORR,
				COUNT (N4_OCORR) AS CONTADOR3
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "03GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_OCORR
				ORDER BY N4_OCORR

			EndSql

		END REPORT QUERY oReport:Section(3)


		BEGIN REPORT QUERY oReport:Section(4)

			BeginSql alias cAlias4
				SELECT N4_OCORR,
				COUNT (N4_OCORR) AS CONTADOR4
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "04GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_OCORR
				ORDER BY N4_OCORR

			EndSql

		END REPORT QUERY oReport:Section(4)


		BEGIN REPORT QUERY oReport:Section(5)

			BeginSql alias cAlias5
				SELECT N4_OCORR,
				COUNT (N4_OCORR) AS CONTADOR5
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "05GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_OCORR
				ORDER BY N4_OCORR

			EndSql

		END REPORT QUERY oReport:Section(5)
		oReport:Section(1):Print()
		oReport:Section(2):Print()
		oReport:Section(3):Print()
		oReport:Section(4):Print()
		oReport:Section(5):Print()

	elseif cStatus = 2
		/*	If Select(cAlias1) > 0
		dbSelectArea(cAlias1)
		dbCloseArea()
		dbSelectArea(cAlias2)
		dbCloseArea()
		dbSelectArea(cAlias3)
		dbCloseArea()
		dbSelectArea(cAlias4)
		dbCloseArea()
		dbSelectArea(cAlias5)
		dbCloseArea()
		Endif */

		BEGIN REPORT QUERY oReport:Section(1)
			BeginSql alias cAlias1
				SELECT N4_OCORR,
				COUNT (N4_OCORR) AS CONTADOR1
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "01GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_OCORR
				ORDER BY N4_OCORR

			EndSql

		END REPORT QUERY oReport:Section(1)


		BEGIN REPORT QUERY oReport:Section(2)

			BeginSql alias cAlias2
				SELECT N4_OCORR,
				COUNT (N4_OCORR) AS CONTADOR2
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "02GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_OCORR
				ORDER BY N4_OCORR

			EndSql

		END REPORT QUERY oReport:Section(2)


		BEGIN REPORT QUERY oReport:Section(3)

			BeginSql alias cAlias3
				SELECT N4_OCORR,
				COUNT (N4_OCORR) AS CONTADOR3
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "03GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_OCORR
				ORDER BY N4_OCORR

			EndSql

		END REPORT QUERY oReport:Section(3)


		BEGIN REPORT QUERY oReport:Section(4)

			BeginSql alias cAlias4
				SELECT N4_OCORR,
				COUNT (N4_OCORR) AS CONTADOR4
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "04GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_OCORR
				ORDER BY N4_OCORR

			EndSql

		END REPORT QUERY oReport:Section(4)


		BEGIN REPORT QUERY oReport:Section(5)

			BeginSql alias cAlias5
				SELECT N4_OCORR,
				COUNT (N4_OCORR) AS CONTADOR5
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "05GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_OCORR
				ORDER BY N4_OCORR

			EndSql

		END REPORT QUERY oReport:Section(5)




		BEGIN REPORT QUERY oReport:Section(6)
			BeginSql alias cAlias6
				SELECT N4_FILIAL,
				COUNT (N4_FILIAL) AS CONTADOR6
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "01GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_FILIAL
				ORDER BY N4_FILIAL

			EndSql

		END REPORT QUERY oReport:Section(6)


		BEGIN REPORT QUERY oReport:Section(7)

			BeginSql alias cAlias7
				SELECT N4_FILIAL,
				COUNT (N4_FILIAL) AS CONTADOR7
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "02GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_FILIAL
				ORDER BY N4_FILIAL

			EndSql

		END REPORT QUERY oReport:Section(7)


		BEGIN REPORT QUERY oReport:Section(8)

			BeginSql alias cAlias8
				SELECT N4_FILIAL,
				COUNT (N4_FILIAL) AS CONTADOR8
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "03GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_FILIAL
				ORDER BY N4_FILIAL

			EndSql

		END REPORT QUERY oReport:Section(8)


		BEGIN REPORT QUERY oReport:Section(9)

			BeginSql alias cAlias9
				SELECT N4_FILIAL,
				COUNT (N4_FILIAL) AS CONTADOR9
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "04GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_FILIAL
				ORDER BY N4_FILIAL

			EndSql

		END REPORT QUERY oReport:Section(9)


		BEGIN REPORT QUERY oReport:Section(10)

			BeginSql alias cAlias10
				SELECT N4_FILIAL,
				COUNT (N4_FILIAL) AS CONTADOR10
				FROM %table:SN4% SN4

				WHERE SN4.%notDel%
				AND SUBSTRING(N4_FILIAL, 1, 4) = "05GO"
				AND N4_OCORR = "04"
				AND N4_DATA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
				AND N4_TIPOCNT = "1"

				GROUP BY N4_FILIAL
				ORDER BY N4_FILIAL

			EndSql

		END REPORT QUERY oReport:Section(10)

		oReport:Section(6):Print()
		oReport:Section(1):Print()
		oReport:ThinLine()
		oReport:Section(7):Print()
		oReport:Section(2):Print()
		oReport:ThinLine()
		oReport:Section(8):Print()
		oReport:Section(3):Print()
		oReport:ThinLine()
		oReport:Section(9):Print()
		oReport:Section(4):Print()
		oReport:ThinLine()
		oReport:Section(10):Print()
		oReport:Section(5):Print()
		oReport:ThinLine()



	endif

	#ENDIF
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} CriaSx1
Cria grupo de perguntas para o relatório.

@type function
@author José Fernando Vilela
@since 02/12/2015
@version P12.1.23

@param cPerg, Caractere, Nome do grupo de perguntas.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@deprecated Função PutSx1foi descontinuada.

/*/
/*/================================================================================================================================/*/

Static Function CriaSx1( cPerg )
	Local aP := {}
	//Local i := 0
	//Local cSeq
	//Local cMvCh
	//Local cMvPar
	Local aHelp := {}
	Local aArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	aAdd(aP,{"Periodo De"		,"D",8 ,0,"G","",""	  	,"","","","",""})   // MV_PAR01
	aAdd(aP,{"Periodo Ate"		,"D",8 ,0,"G","",""	  	,"","","","",""})   // MV_PAR02
	aAdd(aP,{"Tipo Relatorio:"	,"C",1 ,0,"C","",""	  	,"Entidade","Filial","","",""})       // MV_PAR03


	//-----------------------------------------------

	aAdd(aHelp,{"Informe o Período inicial."})
	aAdd(aHelp,{"Informe o Período final."})
	aAdd(aHelp,{"Entidade(Sintético) ou Filial(Analítico)"})


	//	For i:=1 To Len(aP)
	//		cSeq   := StrZero(i,2,0)
	//		cMvPar := "mv_par"+cSeq
	//		cMvCh  := "mv_ch"+IIF(i<=9,Chr(i+48),Chr(i+87))
	//
	//
	//		PutSx1(cPerg,;
	//		cSeq,;
	//		aP[i,1],aP[i,1],aP[i,1],;
	//		cMvCh,;
	//		aP[i,2],;
	//		aP[i,3],;
	//		aP[i,4],;
	//		0,;
	//		aP[i,5],;
	//		aP[i,6],;
	//		aP[i,7],;
	//		"",;
	//		"",;
	//		cMvPar,;
	//		aP[i,8],aP[i,8],aP[i,8],;
	//		"",;
	//		aP[i,9],aP[i,9],aP[i,9],;
	//		aP[i,10],aP[i,10],aP[i,10],;
	//		aP[i,11],aP[i,11],aP[i,11],;
	//		aP[i,12],aP[i,12],aP[i,12],;
	//		aHelp[i],;
	//		{},;
	//		{},;
	//		"")
	//	Next i
	RestArea(aArea)
Return