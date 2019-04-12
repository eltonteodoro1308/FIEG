#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOR04
Resumo de Consolidacao.

@type function
@author TOTVS
@since 28/03/2012
@version P12.1.23

@param _nOpc, Numérico, Numero da Opção.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCOR04(_nOpc)

Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := "Resumo de Consolidação"
Local cPict         := ""
Local Cabec1        := ""
Local Cabec2        := ""
Local imprime       := .T.
Local nLin          := 80
Private titulo      := "Consolidação"
Private aOrd        := {"Operação + CR","Operação + Conta"}
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 80
Private tamanho     := "P"
Private nomeprog    := "SIPCOR04" 							// Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "SIPCOR04" 							// Coloque aqui o nome do arquivo usado para impressao em disco
Private cString     := "AK2"
Private cPerg       := "SIPCOR04X1"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------

//--< Monta a interface padrao com o usuario >--------------

ValidPerg(cPerg)
pergunte(cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//--< Processamento. RPTSTATUS monta janela com a regua de processamento. >--

titulo := Alltrim(titulo) + " (Classe "+MV_PAR10+" - Saldo "+MV_PAR09+")"

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,_nOpc) },Titulo)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} RunReport
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.

@type function
@author TOTVS
@since 27/09/2011
@version P12.1.23

@param Cabec1, Caractere, Cabeçalho do Relatório.
@param Cabec2, Caractere, Cabeçalho do Relatório.
@param Titulo, Caractere, Título do Relatório.
@param nLin, Numérico, Numero da Linha.
@param _nOpc, Numérico, Opção da Rotina.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,_nOpc)

Local nOrdem   := aReturn[8]

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Impressao do cabecalho do relatorio >-----------------

If nLin > 55 												// Salto de Página. Neste caso o formulario tem 55 linhas...
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
Endif

IF Len(_aFiles := _fSelFile(_nOpc)) == 0
	MsgInfo("Nenhum arquivo foi selecionado!")
	Return()
ENDIF

@nLin,001 PSAY "Origem do(s) Lançamento(s): "+IIF(_nOpc==1,"Orçamento","Movimento")
nLin += 2

@nLin,001 PSAY "Lista dos arquivo(s) importado(s):"
nLin++
For i := 1 to Len(_aFiles)
	@nLin,005 PSAY _aFiles[i]
	nLin++
Next
@nLin,000 PSAY Replicate("=",limite)
nLin += 2

_cQuery  := ""
_cArqTRB := CriaTrab(nil,.f.)

IF _nOpc == 1 												// Planilha
	IF nOrdem == 1 											// Ordem OPERACAO+CR+CONTA
		_cQuery := "SELECT SUBSTRING(AK2_PERIOD,1,6) MESREF,AK2_OPER OPER,AK2_ITCTB ENT01,AK2_CO ENT02,SUM(AK2_VALOR) VALOR "
	ELSE 													// Ordem OPERCAO+CR+CONTA
		_cQuery := "SELECT SUBSTRING(AK2_PERIOD,1,6) MESREF,AK2_OPER OPER,AK2_CO ENT01,AK2_ITCTB ENT02,SUM(AK2_VALOR) VALOR "
	ENDIF
	_cQuery += "FROM "+RetSqlName("AK2")+" WHERE D_E_L_E_T_ = ' ' AND AK2_FILIAL = '"+xFilial("AK2")+"' "
	_cQuery += "AND AK2_PERIOD BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
	_cQuery += "AND AK2_CO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	_cQuery += "AND AK2_ITCTB BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	_cQuery += "AND AK2_OPER BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	_cQuery += "AND AK2_CLASSE = '"+MV_PAR10+"' "
	_cQuery += "AND AK2_XFILE IN ('"
	For i := 1 to Len(_aFiles)
		_cQuery += IIF(i==1,Alltrim(_aFiles[i]),"','"+Alltrim(_aFiles[i]))
	Next
	_cQuery += "') "
	IF nOrdem == 1 											// Ordem OPERACAO+CR+CONTA
		_cQuery += "GROUP BY SUBSTRING(AK2_PERIOD,1,6),AK2_OPER,AK2_ITCTB,AK2_CO "
		_cQuery += "ORDER BY 1,2,3,4"
	ELSE 													// Ordem OPERACAO+CR+CONTA
		_cQuery += "GROUP BY SUBSTRING(AK2_PERIOD,1,6),AK2_OPER,AK2_CO,AK2_ITCTB "
		_cQuery += "ORDER BY 1,2,3,4"
	ENDIF
ELSE 														// Movimentos
	IF nOrdem == 1 											// Ordem OPERACAO+CR+CONTA
		_cQuery := "SELECT SUBSTRING(AKD_DATA,1,6) MESREF,AKD_OPER OPER,AKD_ITCTB ENT01,AKD_CO ENT02,SUM(AKD_VALOR1) VALOR "
	ELSE 													// Ordem OPERCAO+CR+CONTA
		_cQuery := "SELECT SUBSTRING(AKD_DATA,1,6) MESREF,AKD_OPER OPER,AKD_CO ENT01,AKD_ITCTB ENT02,SUM(AKD_VALOR1) VALOR "
	ENDIF
	_cQuery += "FROM "+RetSqlName("AKD")+" WHERE D_E_L_E_T_ = ' ' AND AKD_FILIAL = '"+xFilial("AKD")+"' AND AKD_STATUS = '1' "
	_cQuery += "AND AKD_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
	_cQuery += "AND AKD_CO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	_cQuery += "AND AKD_ITCTB BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	_cQuery += "AND AKD_OPER BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	_cQuery += "AND AKD_TPSALD = '"+MV_PAR09+"' "
	_cQuery += "AND AKD_CLASSE = '"+MV_PAR10+"' "
	_cQuery += "AND AKD_XFILE IN ('"
	For i := 1 to Len(_aFiles)
		_cQuery += IIF(i==1,Alltrim(_aFiles[i]),"','"+Alltrim(_aFiles[i]))
	Next
	_cQuery += "') "
	IF nOrdem == 1 											// Ordem OPERACAO+CR+CONTA
		_cQuery += "GROUP BY SUBSTRING(AKD_DATA,1,6),AKD_OPER,AKD_ITCTB,AKD_CO "
		_cQuery += "ORDER BY 1,2,3,4"
	ELSE 													// Ordem OPERACAO+CR+CONTA
		_cQuery += "GROUP BY SUBSTRING(AKD_DATA,1,6),AKD_OPER,AKD_CO,AKD_ITCTB "
		_cQuery += "ORDER BY 1,2,3,4"
	ENDIF
ENDIF

_cQuery := ChangeQuery(_cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqTRB,.t.,.t.)

_cPerAnt  := ""
_cOperAnt := ""
_cCRAnt   := ""
_cCtaAnt  := ""

_nSubCTD  := 0
_nSubAKF  := 0
_nSubPER  := 0
_nTotal   := 0

_cChave1 := ""
_cChave2 := ""
_cChave3 := ""

_cLabel1 := IIF(nOrdem==1,"CR : ","CONTA : ")
_cLabel2 := IIF(nOrdem==1,"Contas","CR's")
_cTable  := IIF(nOrdem==1,"CTD","AK5")
_cCampo  := IIF(nOrdem==1,"CTD_DESC01","AK5_DESCRI")

While (_cArqTRB)->(!Eof())
	
	IF Empty(_cPerAnt)
		@nLin,001 PSAY "PERÍODO : "+Transform((_cArqTRB)->MESREF,"@R 9999/99")
		nLin += 2
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		@nLin,003 PSAY "OPERAÇÃO : "+Alltrim((_cArqTRB)->OPER)+" - "+GetAdvFVal("AKF","AKF_DESCRI",xFilial("AKF")+(_cArqTRB)->OPER,1)
		nLin++
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		@nLin,005 PSAY _cLabel1+Alltrim((_cArqTRB)->ENT01)+" - "+IIF(Empty((_cArqTRB)->ENT01),"Sem Informação",GetAdvFVal(_cTable,_cCampo,xFilial(_cTable)+(_cArqTRB)->ENT01,1))
		nLin++
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		@nLin,007 PSAY _cLabel2
		nLin++
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
	ENDIF
	
	// Quebra nos terceiro nivel
	IF !Empty(_cChave1) .and. _cChave1 <> (_cArqTRB)->(MESREF+OPER+ENT01)
		
		nLin++
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		@nLin,007 PSAY "Total do CR ==>"
		@nLin,063 PSAY _nSubCTD Picture "@E 99,999,999,999.99"
		nLin++
		@nLin,000 PSAY Replicate("-",limite)
		nLin += 2
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		IF _cChave2 == (_cArqTRB)->(MESREF+OPER)
			@nLin,005 PSAY _cLabel1+Alltrim((_cArqTRB)->ENT01)+" - "+IIF(Empty((_cArqTRB)->ENT01),"Sem Informação",GetAdvFVal(_cTable,_cCampo,xFilial(_cTable)+(_cArqTRB)->ENT01,1))
			nLin++
			
			// tratamento da linha
			IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
			
			@nLin,007 PSAY _cLabel2
			nLin++
			
			// tratamento da linha
			IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		ENDIF
		
		_nSubCTD := 0
	ENDIF
	
	IF !Empty(_cChave2) .and. _cChave2 <> (_cArqTRB)->(MESREF+OPER)
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		@nLin,007 PSAY "Total da OPERAÇÃO ==>"
		@nLin,063 PSAY _nSubAKF Picture "@E 99,999,999,999.99"
		nLin++
		@nLin,000 PSAY Replicate("=",limite)
		nLin += 2
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		@nLin,003 PSAY "OPERAÇÃO : "+Alltrim((_cArqTRB)->OPER)+" - "+GetAdvFVal("AKF","AKF_DESCRI",xFilial("AKF")+(_cArqTRB)->OPER,1)
		nLin++
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		@nLin,005 PSAY _cLabel1+Alltrim((_cArqTRB)->ENT01)+" - "+IIF(Empty((_cArqTRB)->ENT01),"Sem Informação",GetAdvFVal(_cTable,_cCampo,xFilial(_cTable)+(_cArqTRB)->ENT01,1))
		nLin++
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		@nLin,007 PSAY _cLabel2
		
		nLin++
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		_nSubAKF := 0
	ENDIF
	
	IF !Empty(_cChave3) .and. _cChave3 <> (_cArqTRB)->MESREF
		
		nLin++
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		@nLin,001 PSAY "Total do PERÍODO ==>"
		@nLin,063 PSAY _nSubPER Picture "@E 99,999,999,999.99"
		nLin++
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		@nLin,000 PSAY __PrtThinLine()
		nLin++
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		@nLin,001 PSAY "PERÍODO : "+Transform((_cArqTRB)->MESREF,"@R 9999/99")
		nLin += 2
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		@nLin,003 PSAY "OPERAÇÃO : "+Alltrim((_cArqTRB)->OPER)+" - "+GetAdvFVal("AKF","AKF_DESCRI",xFilial("AKF")+(_cArqTRB)->OPER,1)
		nLin++
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		@nLin,005 PSAY _cLabel1+Alltrim((_cArqTRB)->ENT01)+" - "+IIF(Empty((_cArqTRB)->ENT01),"Sem Informação",GetAdvFVal(_cTable,_cCampo,xFilial(_cTable)+(_cArqTRB)->ENT01,1))
		nLin++
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		@nLin,007 PSAY _cLabel2
		nLin++
		
		// tratamento da linha
		IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
		
		_nSubPER := 0
	ENDIF
	
	_cDescric := Subs(GetAdvFVal(IIF(nOrdem==1,"AK5","CTD"),IIF(nOrdem==1,"AK5_DESCRI","CTD_DESC01"),xFilial(IIF(nOrdem==1,"AK5","CTD"))+(_cArqTRB)->ENT02,1),1,35)
	@nLin,007 PSAY IIF(Empty((_cArqTRB)->ENT02),"Sem Informação",(_cArqTRB)->ENT02)+" "+_cDescric
	@nLin,063 PSAY (_cArqTRB)->VALOR Picture "@E 99,999,999,999.99"
	nLin++
	
	// tratamento da linha
	IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
	
	_cPerAnt  := (_cArqTRB)->MESREF
	_cOperAnt := (_cArqTRB)->OPER
	_cCRAnt   := IIF(Empty((_cArqTRB)->ENT01),"N/A",(_cArqTRB)->ENT01)
	_cCtaAnt  := (_cArqTRB)->ENT02
	
	_nSubCTD  += (_cArqTRB)->VALOR
	_nSubAKF  += (_cArqTRB)->VALOR
	_nSubPER  += (_cArqTRB)->VALOR
	_nTotal   += (_cArqTRB)->VALOR
	
	_cChave1 := (_cArqTRB)->(MESREF+OPER+ENT01)
	_cChave2 := (_cArqTRB)->(MESREF+OPER)
	_cChave3 := (_cArqTRB)->MESREF
	
	(_cArqTRB)->(dbSkip())
Enddo

nLin++
// tratamento da linha
IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)

@nLin,007 PSAY "Total do CR ==>"
@nLin,063 PSAY _nSubCTD Picture "@E 99,999,999,999.99"
nLin += 2

// tratamento da linha
IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)

@nLin,007 PSAY "Total da OPERAÇÃO ==>"
@nLin,063 PSAY _nSubAKF Picture "@E 99,999,999,999.99"
nLin += 2

// tratamento da linha
IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)

@nLin,001 PSAY "Total do PERÍODO ==>"
@nLin,063 PSAY _nSubPER Picture "@E 99,999,999,999.99"
nLin++

// tratamento da linha
IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)

@nLin,000 PSAY __PrtThinLine()
nLin++

// tratamento da linha
IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)

@nLin,001 PSAY "Total GERAL ==>"
@nLin,063 PSAY _nTotal Picture "@E 99,999,999,999.99"
nLin++

(_cArqTRB)->(dbCloseArea())
FErase( _cArqTRB + GetDBExtension() )

//--< Finaliza a execucao do relatorio >--------------------
SET DEVICE TO SCREEN

//--< Se impressao em disco, chama o gerenciador de impressao >--
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidPerg
Valida as Perguntas do Relatório.

@type function
@author TOTVS
@since 29/03/2012
@version P12.1.23

@param cPerg, Grupo de Perguntas.

@obs Projeto ELO
@deprecated Função mantida apenas para documentação. A função PutSx1 foi descontinuada no Protheus 12, conforme documentação oficial.
@link http://tdn.totvs.com/pages/releaseview.action?pageId=244740739

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function ValidPerg(cPerg)

Local _sAlias := Alias()
Local aRegs := {}
Local i

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
OpenSxs(,,,,cEmpAnt,"SX1TMP","SX1",,.F.,.T.)
SX1TMP->(dbSetOrder(1))
cPerg := PADR(cPerg,10)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Periodo de:  "	,"mv_ch1","D",08,0,0,"G","naovazio()","mv_par01","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Periodo até: "	,"mv_ch2","D",08,0,0,"G","naovazio() .and. mv_par02>=mv_par01","mv_par02","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Conta de: "		,"mv_ch3","C",20,0,0,"G","","mv_par03","","","","","","","","","","","","","","","CT1","003"})
aAdd(aRegs,{cPerg,"04","Conta até: "	,"mv_ch4","C",20,0,0,"G","","mv_par04","","","","","","","","","","","","","","","CT1","003"})
aAdd(aRegs,{cPerg,"05","CR de: "		,"mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","CTD","004"})
aAdd(aRegs,{cPerg,"06","CR até: "	    ,"mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","CTD","004"})
aAdd(aRegs,{cPerg,"07","Operação de: "	,"mv_ch7","C",10,0,0,"G","","mv_par05","","","","","","","","","","","","","","","AKF","004"})
aAdd(aRegs,{cPerg,"08","Operação até: "	,"mv_ch8","C",10,0,0,"G","","mv_par06","","","","","","","","","","","","","","","AKF",""})
aAdd(aRegs,{cPerg,"09","Saldo : "		,"mv_ch9","C",02,0,0,"G","ExistCpo('AL2').and.NaoVazio()","mv_par09","","","","","","","","","","","","","","","AL2A",""})
aAdd(aRegs,{cPerg,"10","Classe :"		,"mv_cha","C",06,0,0,"G","ExistCpo('AK6').and.NaoVazio()","mv_par10","","","","","","","","","","","","","","","AK6",""})

For i := 1 to Len(aRegs)
	PutSX1(aRegs[i,1] ,aRegs[i,2] ,aRegs[i,3] ,aRegs[i,3] ,aRegs[i,3] ,aRegs[i,4] ,aRegs[i,5] ,aRegs[i,6] ,aRegs[i,7] ,;
		   aRegs[i,8] ,aRegs[i,9] ,aRegs[i,10],iif(len(aRegs[i])>=26,aRegs[i,26],""),aRegs[i,27],"",aRegs[i,11],aRegs[i,12],;
		   aRegs[i,12],aRegs[i,12],aRegs[i,13],aRegs[i,15],aRegs[i,15],aRegs[i,15],aRegs[i,18],aRegs[i,18],aRegs[i,18],;
		   aRegs[i,21],aRegs[i,21],aRegs[i,21],aRegs[i,24],aRegs[i,24],aRegs[i,24])
	
Next i

dbSelectArea(_sAlias)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidPerg
Valida as Perguntas do Relatório.

@type function
@author TOTVS
@since 29/03/2012
@version P12.1.23

@param _nOpc, Opção da Rotina.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Parâmetros MV.
/*/
/*/================================================================================================================================/*/

Static Function _fSelFile(_nOpc)

Local _cTitulo  := "Selecione o Arquivo"
Local _aMvPar   := {}
Local _cQuery   := ""
Local _cArqTMP  := CriaTrab(nil,.f.)
Private _aFiles := {}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF _nOpc == 1 												// Planilha
	_cQuery := "SELECT DISTINCT AK2_XFILE XFILE "
	_cQuery += "FROM "+RetSqlName("AK2")+" WHERE D_E_L_E_T_ = ' ' AND AK2_FILIAL = '"+xFilial("AK2")+"' "
	_cQuery += "AND AK2_PERIOD BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
	_cQuery += "AND AK2_CO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	_cQuery += "AND AK2_ITCTB BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	_cQuery += "AND AK2_OPER BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	_cQuery += "AND AK2_CLASSE = '"+MV_PAR10+"' "
	_cQuery += "AND AK2_XFILE <> ' '"
ELSE 														// Movimentos
	_cQuery := "SELECT DISTINCT AKD_XFILE XFILE "
	_cQuery += "FROM "+RetSqlName("AKD")+" WHERE D_E_L_E_T_ = ' ' AND AKD_FILIAL = '"+xFilial("AKD")+"' AND AKD_STATUS = '1' "
	_cQuery += "AND AKD_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
	_cQuery += "AND AKD_CO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	_cQuery += "AND AKD_ITCTB BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	_cQuery += "AND AKD_OPER BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	_cQuery += "AND AKD_TPSALD = '"+MV_PAR09+"' "
	_cQuery += "AND AKD_CLASSE = '"+MV_PAR10+"' "
	_cQuery += "AND AKD_XFILE <> ' '"
ENDIF

_cQuery := ChangeQuery(_cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqTMP,.t.,.t.)

While (_cArqTMP)->(!Eof())
	Aadd(_aFiles,(_cArqTMP)->XFILE)
	(_cArqTMP)->(dbSkip())
Enddo

(_cArqTMP)->(dbCloseArea())
FErase( _cArqTMP + GetDBExtension() )

f_Opcoes(@_aMvPar,_cTitulo,_aFiles,NIL,12,49,.f.,,Len(_aFiles),,,,,,.t.)  // Chama funcao f_Opcoes

Return(_aMvPar)
