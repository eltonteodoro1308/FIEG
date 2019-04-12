#Include 'Protheus.ch'
#Include 'rwmake.ch'

#Define MAX_TAMANHO 130	//numero maximo de carateres por linha
#Define MAX_LINHA	   74	// numero maximo de linhas por pagina

#Define ESQUERDA 0		//Alinhamento utilizado pelo TMSPrinter:Say()
#Define DIREITA 1			//Alinhamento utilizado pelo TMSPrinter:Say()
#Define CENTRALIZADO 2	//Alinhamento utilizado pelo TMSPrinter:Say()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFINR04  บAutor  ณrenato.neves           บ Data ณ02/09/2011บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio Ordem de Recebimento                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SIFINR04()


Local _cTexto     := ""
Local _nVias		:= 1
Local _nOpc		:= 0
Local _cTitulo		:= "Dados Complementares"
Local _oBrw,_oMemo, _oGet

If SE1->E1_STATUS == "B"  

	Define Msdialog _oBrw Title _cTitulo FROM 05,0 TO 22,50
	
	@ 007,007 Get _cTexto  When .T.  Size 185,100  MEMO Object _oMemo
	@ 115,010 Say "Qtde Vias:"
	@ 115,040 Get _nVias  Size 020,030   Picture "99" Object _oGet
	
	@ 115,140  BMPBUTTON TYPE 6 ACTION (_nOpc := 1, _oBrw:End())
	@ 115,170  BMPBUTTON TYPE 2 ACTION (_nOpc := 0, _oBrw:End())
	
	Activate Msdialog _oBrw Centered
	
	
	If _nOpc = 1 .and. _nVias > 0
		Processa({|| CursorWait(),fPrint(_cTexto,_nVias), CursorArrow() })
	EndIf
	
Else
	Aviso("Aten็ใo","Funcionalidade disponivel somente para titulos liquidados.",{"Ok"})
Endif


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfPrint    บAutor  ณrenato.neves        บ Data ณ02/09/2011   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o Relatorio                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fPrint(_cTexto,_nVias)

Local _aArea		:= GetArea()
Local _nI 			:= 0
Local _nX			:= 0
Local _nPag		:= 0
Local _nTotPag		:= 0
Local _lPrimeiro	:= .T.
Local _nLin		:= 0
Local _oPrint	 	:= TMSPrinter():New("Recibo de Ordem de Recebimento")
Local _nLinMemo	:= 0
Local _l1PorPag	:= .F.
Local _cValor		:= ""
Local _cTxtDefault:= ""
Local _nLinha		:= 0

Private _oFont10N	:= TFont():New( "Arial",, 10,,.t.,,,,,.f. )
Private _oFont10	:= TFont():New( "Arial",, 10,,.f.,,,,,.f. )
Private _oFont14N	:= TFont():New( "Arial",, 14,,.t.,,,,,.f. )
Private _oFont14 	:= TFont():New( "Arial",, 14,,.f.,,,,,.f. )
Private _oFont18N	:= TFont():New( "Arial",, 18,,.t.,,,,,.f. )
Private _oFont12N	:= TFont():New( "Arial",, 12,,.t.,,,,,.f. )
Private _oFont12	:= TFont():New( "Arial",, 12,,.f.,,,,,.f. )

/*DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA))*/

	ProcRegua(_nVias)
	
	
	//Valor a ser impresso
	_cValor := "Valor R$ "
	_cValor += AllTrim(Transform(E1_VALLIQ, X3Picture("E1_VALLIQ") ))
	
	
	//Texto do campo MEMO a ser impresso
	_cTxtDefault := "Recebi da Entidade "+AllTrim(SE1->E1_NOMCLI)+", a quantia de ("+AllTrim(Extenso(SE1->E1_VALLIQ))+")"
	If Empty(_cTexto)
		_cTexto := _cTxtDefault+"."
	Else
		_cTexto := _cTxtDefault+rTrim(_cTexto)
	EndIF
	
	
	//Quantidades de linhas necessaria para imprimir o campo memo
	_nLinMemo	:= MLCount(_cTexto,MAX_TAMANHO)
	
	
	//indica que deve ser impresso 1 recibo por pagina
	_l1PorPag	:= ( _nLinMemo > (Int(MAX_LINHA/2)-15))
	
	
	//Calcula o total de paginas impressas
	_nTotPag := Int(_nLinMemo/MAX_LINHA)
	If Mod(_nLinMemo,MAX_LINHA) <> 0
		_nTotPag++
	EndIF
	
	
	//Imprimindo as vias do relatorio
	For _nI:=1 to _nVias
		
		_nPag := 1
		_nLinha := 0
		
		//Imprime informacoes do cabecalho
		Cabecalho(@_oPrint,_lPrimeiro,_l1PorPag,_nPag,_nTotPag)
		_nLin := iif(_lPrimeiro, 330, 1930)
		
		_oPrint:Say(_nLin,85,"Nome:",_oFont12N)
		_oPrint:Say(_nLin,205,AllTrim(Upper(SM0->M0_NOMECOM)),_oFont12)
		
		_nLin += 60
		
		_oPrint:Say(_nLin,2300, _cValor , _oFont12N,,,,DIREITA)
		
		_nLin += 55
		
		//Imprime as informacoes do campo MEMO
		For _nX := 1 to _nLinMemo
			_nLinha++
			//Quebra de Pagina
			If _nLinha > MAX_LINHA//_nLin > 3200
				_nLinha := 1
				_oPrint:EndPage()
				_nPag++
				Cabecalho(@_oPrint,_lPrimeiro,_l1PorPag,_nPag,_nTotPag)
				_nLin := 400
			EndIf
			
			_oPrint:Say(_nLin,95,MemoLine(_cTexto,MAX_TAMANHO,_nX),_oFont10)
			_nLin+=35
		Next _nX
		
		//Imprime informacoes do rodape
		RodaPe(@_oPrint,_lPrimeiro,_l1PorPag)
		
		
		
		Do Case
			Case _lPrimeiro .and. !(_l1PorPag)
				_lPrimeiro := .F.
			Case !(_lPrimeiro) .and. !(_l1PorPag)
				_lPrimeiro := .T.
				_oPrint:EndPage()
			Case _l1PorPag
				_oPrint:EndPage()
		EndCase
		
	Next _nI
	
	_oPrint:Preview()

RestArea(_aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCabecalho บAutor  ณrenato.neves        บ Data ณ02/09/2011   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime o cabecalho do relatorio                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Cabecalho(_oPrint,_lPrimeiro,_l1PorPag,_nPag,_nTotPag)

Local _nLin 	:= iif(_lPrimeiro,0,1600)
Local _cLogo	:= GetSrvProfString("Startpath","") + "REC" + cEmpAnt + cFilAnt + ".BMP"
Local _cNumDoc:= "N๚mero: "+AllTrim(SE1->E1_NUM)+"/"+SE1->E1_PARCELA
Local _cPagina:= "Pแgina "+AllTrim(Str(_nPag))+" de "+AllTrim(Str(_nTotPag))

If !File(_cLogo)
	_cLogo	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
EndIf

_oPrint:StartPage()

_oPrint:Box(30+_nLin,45,250+_nLin,2400)
_oPrint:SayBitmap(35+_nLin,50,_cLogo,095,096)
_oPrint:Say(70+_nLin,1200, _oPrint:cDocument, _oFont18N,,,,CENTRALIZADO)
_oPrint:Say(130+_nLin,1200,_cNumDoc ,_oFont12N,,,,CENTRALIZADO)
_oPrint:Say(60+_nLin,2380,_cPagina ,_oFont10,,,,DIREITA)
_oPrint:Say(105+_nLin,2380,dToC(dDataBase) ,_oFont10,,,,DIREITA)
_oPrint:Say(150+_nLin,2380,Time(),_oFont10,,,,DIREITA)


//Imprime o picote da folha
If _lPrimeiro .and. !_l1PorPag
	QuebraPag(@_oPrint)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO2     บAutor  ณrenato.neves        บ Data ณ02/09/2011   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o roda pe do relatorio                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RodaPe(_oPrint,_lPrimeiro,_l1PorPag)

Local _nLin := 0


If  _lPrimeiro .and. !(_l1PorPag)
	_nLin := 1400
Else
	_nLin := 3100
EndIf

_oPrint:Say(_nLin,2300, "_______________________________, ____ de ___________________ de _____",_oFont10,,,,DIREITA)
_nLin+= 65
_oPrint:Say(_nLin,2300, "Assinatura: ________________________________________",_oFont10,,,,DIREITA)
_nLin+=50
_oPrint:Say(_nLin,2300, "CNPJ: ________________________________________",_oFont10,,,,DIREITA)

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
