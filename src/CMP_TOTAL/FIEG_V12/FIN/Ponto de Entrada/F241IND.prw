#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} F241IND
P.E. para manipular a ordem dos registros na tela de seleção de titulos para gerar o bordero.

@type function
@author Lucas Riva Tsuda - TOTVS
@since 12/20/2011
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Índice específico.
/*/
/*/================================================================================================================================/*/

User Function F241IND()

Local aArea      := GetArea()
Local aAreaSE2   := SE2->(GetArea())
Local cAliasSE2  := Alias()

Private cPerg    := "XFI240"  								//Especifico CNI

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
AjustaSX1()

Pergunte(cPerg)

DbSelectArea("SE2")

If MV_PAR01 == 1
	
	SE2->(DbOrderNickName("SISE201")) 						//Especifico CNI
	aIndTemp := {CriaTrab(,.F.)}
	IndRegua(cAliasSE2,aIndTemp[1],SE2->(IndexKey()),,,"Indexando arquivo...")
	
ElseIf MV_PAR01 == 2
	
	SE2->(DbSetOrder(3))
	aIndTemp := {CriaTrab(,.F.)}
	IndRegua(cAliasSE2,aIndTemp[1],SE2->(IndexKey()),,,"Indexando arquivo...")
	
Else
	Return Nil
EndIf

RestArea(aArea)
SE2->(RestArea(aAreaSE2))

Return aIndTemp


/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustaSX1
Cria as perguntas necessarias a impressao do RPS.

@type function
@author Mary C. Hergert - TOTVS
@since 05/07/2006
@version P12.1.23

@obs Projeto ELO

@deprecated Função mantida apenas para documentação. A função PutSx1 foi descontinuada no Protheus 12, conforme documentação oficial.
@link http://tdn.totvs.com/pages/releaseview.action?pageId=244740739

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorno verdadeiro.
/*/
/*/================================================================================================================================/*/

Static Function AjustaSX1()

Local aHelpPor	:= {}
Local aARea		:= GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
OpenSxs(,,,,cEmpAnt,"SX1TMP","SX1",,.F.,.T.)
SX1TMP->(dbSetOrder(1))

Aadd (aHelpPor, "Seleciona a ordem da apresentação dos ")
Aadd (aHelpPor, "titulos a serem marcados para a geração ")
Aadd (aHelpPor, "do bordero.")
PutSx1(cPerg,"01","Ordem ?","Ordem ?","Ordem ?","mv_ch1","C",1,0,3,"C","","","","","MV_PAR01","Nome Fornecedor","","","","Vencto. Real","","","Padrão","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

RestArea(aArea)

Return(.T.)
