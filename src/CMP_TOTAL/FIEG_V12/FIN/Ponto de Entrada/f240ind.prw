#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} F240IND
Ponto de Entrada para manipular a ordem dos registros na tela de seleção de titulos para gerar o bordero.

@type function
@author Lucas Riva Tsuda
@since 20/12/2011
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, .

/*/
/*/================================================================================================================================/*/

User Function F240IND()
	Local aArea     := GetArea()
	Local aAreaSE2  := SE2->(GetArea())
	Private cPerg   := "XFI240"  //Especifico CNI

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	AjustaSX1()

	Pergunte(cPerg)

	DbSelectArea("SE2")

	If MV_PAR01 == 1

		SE2->(DBORDERNICKNAME("SISE201")) //Especifico CNI
		aIndTemp := {CriaTrab(,.F.)}
		IndRegua(cAliasSE2,aIndTemp[1],SE2->(IndexKey()),,,"Indexando arquivo...")

	ElseIf MV_PAR01 == 2

		SE2->(DbSetOrder(3))
		aIndTemp := {CriaTrab(,.F.)}
		IndRegua(cAliasSE2,aIndTemp[1],SE2->(IndexKey()),,,"Indexando arquivo...")

	EndIf

	RestArea(aArea)
	RestArea(aAreaSE2)

Return aIndTemp

/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustaSX1
Cria as perguntas necessarias a impressao do RPS.

@type function
@author Mary C. Hergert
@since 05/07/2006
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

Static Function AjustaSX1()

	Local	aHelpPor	:=	{}
	Local	aARea		:=	GetArea()
	Local	aAreaSX1	:=	SX1->(GetArea())

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelecTArea("SX1")
	SX1->(dbSetOrder(1))

	Aadd (aHelpPor, "Seleciona a ordem da apresentação dos ")
	Aadd (aHelpPor, "titulos a serem marcados para a geração ")
	Aadd (aHelpPor, "do bordero.")
	PutSx1(cPerg,"01","Ordem ?","Ordem ?","Ordem ?","mv_ch1","C",1,0,3,"C","","","","","MV_PAR01","Nome Fornecedor","","","","Vencto. Real","","","Padrão","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

	RestArea(aAreaSX1)
	RestArea(aArea)

Return(.T.)
