#Include "Protheus.CH"
#Include "Topconn.CH"

#DEFINE COLUNA_1 745
#DEFINE COLUNA_2 1100
#DEFINE COLUNA_3 1200

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO2     บAutor  ณrenato.neves        บ Data ณ01/09/2011   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio Recibo de Pagamento                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SIFINR02()

Local _cPerg	:= PadR("SIFINR02",len(SX1->X1_GRUPO))

AjustaSX1(_cPerg)

IF Pergunte(_cPerg,.T.)
	Processa({|| CursorWait(),FPrint(),CursorArrow() })
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfPrint    บAutor  ณrenato.neves        บ Data ณ02/09/2011   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para impressao do relatorio                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fPrint()
Local _lPrimeiro   := .T.
Local _nLin		   := 0
Local _oPrint	   := TMSPrinter():New("Recibo de Pagamentos")
Local _cQuery	   := ""
Local _nCt         := 0
Private _oFont10N  := TFont():New( "Arial",, 10,,.t.,,,,,.f. )
Private _oFont10   := TFont():New( "Arial",, 10,,.f.,,,,,.f. )
Private _oFont09N  := TFont():New( "Arial",, 09,,.t.,,,,,.f. )
Private _oFont09   := TFont():New( "Arial",, 09,,.f.,,,,,.f. )     
Private cNome	   := ""

_oPrint:SetPortrait()

_cQuery := " select E5_FILIAL, E5_XBCOPAG, E5_XAGEPAG, E5_XCTAPAG, E5_BENEF, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, E5_LOJA, "
_cQuery += " E2_VENCREA, E2_VALOR, E5_XDOCBCO, E5_DATA, E5_VALOR, E5_AUTBCO, E5_SEQ, E5_DTDISPO "
_cQuery += " from "+RetSQLName("SE5")+" SE5 "
//_cQuery += " Inner Join "+RetSQLName("SE2")+" SE2 on (E2_FILIAL='"+xFilial("SE2")+"' and E2_PREFIXO=E5_PREFIXO and E2_NUM=E5_NUMERO and " 
_cQuery += " Inner Join "+RetSQLName("SE2")+" SE2 on (E2_FILIAL between '"+MV_PAR14+"' and '"+MV_PAR15+"' and E2_PREFIXO=E5_PREFIXO and E2_NUM=E5_NUMERO and "
_cQuery += "             E2_PARCELA=E5_PARCELA and E2_TIPO=E5_TIPO and E2_FORNECE=E5_CLIFOR and E2_LOJA=E5_LOJA "
_cQuery += "             and SE2.D_E_L_E_T_='' and E2_VENCREA between '"+dToS(MV_PAR12)+"' and '"+dToS(MV_PAR13)+"') "
_cQuery += " where E5_CLIFOR <> '' and E5_AUTBCO <>'' and E5_BANCO= '"+MV_PAR01+"' and SE5.D_E_L_E_T_=''  and E5_TIPODOC <> 'ES' "
_cQuery += " and E5_AGENCIA = '"+MV_PAR02+"' and E5_CONTA= '"+MV_PAR03+"' and E5_FILIAL between '"+MV_PAR14+"' and '"+MV_PAR15+"' "
_cQuery += " and E5_PREFIXO between '"+MV_PAR04+"' and '"+MV_PAR05+"' "
_cQuery += " and E5_PARCELA between '"+MV_PAR06+"' and '"+MV_PAR07+"' "
_cQuery += " and E5_CLIFOR between '"+MV_PAR08+"' and '"+MV_PAR10+"' "
_cQuery += " and E5_LOJA between '"+MV_PAR09+"' and '"+MV_PAR11+"' "
_cQuery += " Order by E5_DATA "
_cQuery := changequery(_cQuery)

dBUseArea( .T., 'TOPCONN', TCGENQRY( ,, _cQuery ), 'QRY1', .F., .T. )

QRY1->( dbEval( { || _nCt++ },,{ || !EOF() } ) )
QRY1->( dbGoTop() )
ProcRegua( _nCt )

While QRY1->(!Eof())	
	
	//Controle da regua de processamento
	IncProc("Imprimindo. Aguarde...")

	//A6_COD+A6+AGENCIA+A6_NUMCON   
	SA6->(DbSetOrder(1))                                                      
	If SubStr(QRY1->E5_FILIAL,3,2)=="BA"
		SA6->(dbSeek(SubStr(QRY1->E5_FILIAL,1,4)+"    "+mv_par01+mv_par02+mv_par03))    //Estแ posicionando na empresa do SE5    
	Else
		SA6->(dbSeek(xFilial("SA6")+mv_par01+mv_par02+mv_par03))	
	Endif	
	        
	cNomeBanco := SA6->A6_NOME
	
	
	//Imprime o cabecalho
	Cabecalho(@_oPrint,_lPrimeiro)
	
	
	//Detalhes do relatorio
	_nLin := iif(_lPrimeiro , 350, 1950)
	           
	//A2_FILIAL+A2_COD_A2_LOJA
	 SA2->(dbSeek(xFilial("SA2")+QRY1->E5_CLIFOR+QRY1->E5_LOJA)) 
	 
	_oPrint:Say(_nLin,COLUNA_1,"Banco:",_oFont10)
	_oPrint:Say(_nLin,COLUNA_3,AllTrim(SA2->A2_BANCO) ,_oFont10)
	_nLin += 35
	_oPrint:Say(_nLin,COLUNA_1,OemToAnsi("Ag๊ncia cr้dito:"),_oFont10)
	_oPrint:Say(_nLin,COLUNA_3,AllTrim(SA2->A2_AGENCIA) ,_oFont10)
	_nLin += 35
	_oPrint:Say(_nLin,COLUNA_1,"Conta cr้dito:",_oFont10)
	_oPrint:Say(_nLin,COLUNA_3,AllTrim(SA2->A2_NUMCON) ,_oFont10)
	_nLin += 35
	_oPrint:Say(_nLin,COLUNA_1,"Favorecido:",_oFont10)
	_oPrint:Say(_nLin,COLUNA_3,AllTrim(QRY1->E5_BENEF) ,_oFont10)
	_nLin += 35
	_oPrint:Say(_nLin,COLUNA_1,"Documento empresa:",_oFont10)
	_oPrint:Say(_nLin,COLUNA_3,AllTrim(QRY1->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_CLIFOR+E5_LOJA)) ,_oFont10)
	_nLin += 35
	_oPrint:Say(_nLin,COLUNA_1,"Data Vencimento:",_oFont10)
	_oPrint:Say(_nLin,COLUNA_3,Dtoc(Stod(QRY1->E2_VENCREA)) ,_oFont10)
	_nLin += 35
	_oPrint:Say(_nLin,COLUNA_1,"Valor pagamento:",_oFont10)
	_oPrint:Say(_nLin,COLUNA_3,Alltrim(Transform(QRY1->E2_VALOR,"@E 999,999,999.99")),_oFont10)
	_nLin += 35
	_oPrint:Say(_nLin,COLUNA_1,"Documento Banco:",_oFont10)
	_oPrint:Say(_nLin,COLUNA_3,AllTrim(QRY1->E5_XDOCBCO) ,_oFont10)
	_nLin += 35
	_oPrint:Say(_nLin,COLUNA_1,"Data real pagamento:",_oFont10)
	_oPrint:Say(_nLin,COLUNA_3,Dtoc(Stod(QRY1->E5_DTDISPO)),_oFont10)
	_nLin += 35
	_oPrint:Say(_nLin,COLUNA_1,"Valor real pagamento:",_oFont10)
	_oPrint:Say(_nLin,COLUNA_3,Alltrim(Transform(QRY1->E5_VALOR,"@E 999,999,999.99")),_oFont10)
	_nLin += 35
	_oPrint:Say(_nLin,COLUNA_1,"Autentica็ใo:",_oFont10)
	_oPrint:Say(_nLin,COLUNA_3,AllTrim(QRY1->E5_AUTBCO) ,_oFont10)
	_nLin += 80
	//_oPrint:Line(_nLin,40,_nLin,2400)
	_oPrint:Line(_nLin,700,_nLin,1700)
	
	
	
	//Imprime o picote da folha
	If _lPrimeiro
		QuebraPag(@_oPrint)
	EndIf
	
	
	//Tratamento para impressao do primeiro recibo da pagina
	If !(_lPrimeiro)
		_oPrint:EndPage()
	EndIf
	_lPrimeiro := !_lPrimeiro
	
	
	QRY1->(DbSkip())
EndDo

_oPrint:Preview()

QRY1->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQuebraPag บAutor  ณrenato.neves        บ Data ณ02/09/2011   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao do picote de quebra de pagina                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QuebraPag(_oPrint)

Local _nI := 0

While _nI < 2450
	_oPrint:Line(1600,_nI,1600,_nI+15)
	_nI+= 30
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCabecalho บAutor  ณrenato.neves        บ Data ณ01/09/2011   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o cabecalho do relatorio                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Cabecalho(_oPrint,_lPrimeiro)

Local _nLin := 0


//Controle de quantidade de recibos impressos por pagina (maximo 2)
If _lPrimeiro
	_oPrint:StartPage()
	_nLin := 0
Else
	_nLin := 1600
EndIF
/*
If _nQtdPrint > 2
_oPrint:EndPage()
_oPrint:StartPage()
_nQtd := 1
Else
_nLin := 1600
EndIf
*/

//Impressao do cabecalho da pagina
//_oPrint:Line(30+_nLin,40,30+_nLin,2400)      


_oPrint:Line(30+_nLin,700,30+_nLin,1700)
_oPrint:Say(045+_nLin,COLUNA_1,"Banco:",_oFont10)
_oPrint:Say(045+_nLin,COLUNA_2, AllTrim(MV_PAR01)+" - "+AllTrim(cNomeBanco),_oFont10)
_oPrint:Say(085+_nLin,COLUNA_1,"Ag๊ncia d้bito:",_oFont10)
_oPrint:Say(085+_nLin,COLUNA_2,AllTrim(MV_PAR02),_oFont10)
_oPrint:Say(115+_nLin,COLUNA_1,"Conta d้bito:",_oFont10)
_oPrint:Say(115+_nLin,COLUNA_2,AllTrim(MV_PAR03),_oFont10)
_oPrint:Say(145+_nLin,COLUNA_1,"CPF/CNPJ:",_oFont10) 
If Substr(cFilAnt,3,2) == "BA"    
	//M0_CODIGO+M0_CODFIL   (0101BA0001)
	SM0->(dbSeek(cEmpAnt+SubStr(QRY1->E5_FILIAL,1,2)))
Endif
_oPrint:Say(145+_nLin,COLUNA_2,AllTrim(SM0->M0_CGC) + " - " + AllTrim(SM0->M0_NOMECOM),_oFont10)

//_oPrint:Line(230+_nLin,40,230+_nLin,2400)
_oPrint:Line(230+_nLin,700,230+_nLin,1700)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSX1 บAutor  ณrenato.neves        บ Data ณ01/09/2011   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o grupo de perguntas no SX1                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(_cPerg)

PutSx1( _cPerg, "01","Banco"	,"Banco","Banco"										,"mv_ch1","C",TamSx3("E5_BANCO")[1]	,0,1,"G","","SA6","007","","mv_par01","","","","",""	,"","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "02","Agencia","Agencia","Agencia"								,"mv_ch2","C",TamSx3("E5_AGENCIA")[1]	,0,1,"G","","   ","008","","mv_par02","","","","",""	,"","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "03","Conta"	,"Conta","Conta"										,"mv_ch3","C",TamSx3("E5_CONTA")[1]	,0,1,"G","","   ","009","","mv_par03","","","","",""	,"","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "04","Prefixo de ?"	,"Prefixo de ?","Prefixo de ?"				,"mv_ch4","C",TamSx3("E2_PREFIXO")[1]	,0,1,"G","","   ","   ","","mv_par04","","","","",""	,"","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "05","Prefixo ate ?","Prefixo ate ?","Prefixo ate ?"			,"mv_ch5","C",TamSx3("E2_PREFIXO")[1]	,0,1,"G","","   ","   ","","mv_par05","","","","",""	,"","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "06","Parcela de?","Parcela de?","Parcela de?"					,"mv_ch6","C",TamSx3("E2_PARCELA")[1]	,0,1,"G","","   ","011","","mv_par06","","","","",""	,"","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "07","Parcela ate?"	,"Parcela ate?","Parcela ate?"				,"mv_ch7","C",TamSx3("E2_PARCELA")[1]	,0,1,"G","","   ","011","","mv_par07","","","","",""	,"","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "08","Fornecedor de ?","Fornecedor de ?","Fornecedor de ?"	,"mv_ch8","C",TamSx3("E2_FORNECE")[1]	,0,0,"G","","SA2","001","","MV_PAR08","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "09","Loja de ?","Loja de ?","Loja de ?"							,"mv_ch9","C",TamSx3("E2_LOJA")[1]		,0,0,"G","","   ","002","","MV_PAR09","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "10","Fornecedor ate ?","Fornecedor ate ?","Fornecedor ate ?","mv_cha","C",TamSx3("E2_FORNECE")[1]	,0,0,"G","","SA2","001","","MV_PAR10","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "11","Loja ate ?","Loja ate ?","Loja ate ?"						,"mv_chb","C",TamSx3("E2_LOJA")[1]		,0,0,"G","","   ","002","","MV_PAR11","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "12","Vencimento de ?","Vencimento de ?","Vencimento de ?"	,"mv_chc","D",8							,0,0,"G","","   ","   ","","MV_PAR12","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "13","Vencimento ate?","Vencimento ate?","Vencimento ate?"	,"mv_chd","D",8							,0,0,"G","","   ","   ","","MV_PAR13","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "14","Filial De?","Filial De","Filial De"	,"mv_che","C",8							,0,0,"G","","   ","   ","","MV_PAR14","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( _cPerg, "15","Filial Ate?","Filial Ate?","Filial Ate"	,"mv_chf","C",8							,0,0,"G","","   ","   ","","MV_PAR15","","","","","","","","","","","","","","","","",{},{},{})


Return
