#INCLUDE "rwmake.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOR05
Resumo de Rateio.

@type function
@author TOTVS
@since 10/08/2012
@version P12.1.23

@param _nOpc, Numérico, Numero da Opção.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCOR05()

Local _cArea    := GetArea()
Local _aPeriodo := PcoRetPer(Stod(SZR->ZR_ANO+"0101"),Stod(SZR->ZR_ANO+"1231"))
Local _aParam   := {}
Local _aRetorno := {}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Periodos >--------------------------------------------
For i := 1 to Len(_aPeriodo)
	aAdd(_aParam,{4,_aPeriodo[i],.T.,"",165,.F.,.F.})
next

//--< Regra de Rateio >-------------------------------------
Aadd(_aParam,{ 1,"Regra de Rateio",Space(6),"@!","","SZT","",0,	.T.})

//--< Filtro das entidades >--------------------------------
Aadd(_aParam,{ 1,"UO De",Space(TamSX3("ZS_CC")[1]),"@!","","CTT","",0,	.F.})
Aadd(_aParam,{ 1,"UO Ate",Replicate("Z",TamSX3("ZS_CC")[1]),"@!","","CTT","",0,	.T.})
Aadd(_aParam,{ 1,"CR De",Space(TamSX3("ZS_ITCTB")[1]),"@!","","CTD","",0,	.F.})
Aadd(_aParam,{ 1,"CR Ate",Replicate("Z",TamSX3("ZS_ITCTB")[1]),"@!","","CTD","",0,	.T.})
Aadd(_aParam,{ 1,"Conta Contábil De",Space(TamSX3("ZS_CONTA")[1]),"@!","","CT1","",0,	.F.})
Aadd(_aParam,{ 1,"Conta Contábil Ate",Replicate("Z",TamSX3("ZS_CONTA")[1]),"@!","","CT1","",0,	.T.})
Aadd(_aParam,{ 1,"Classe Valor De",Space(TamSX3("ZS_CLASSE")[1]),"@!","","CTH","",0,	.F.})
Aadd(_aParam,{ 1,"Classe Valor Ate",Replicate("Z",TamSX3("ZS_CLASSE")[1]),"@!","","CTH","",0,	.T.})

IF !ParamBox(_aParam ,"Parametros", @_aRetorno)
	Return()
ENDIF

//--< Verifica se foi selecionado algum periodo >-----------
IF Ascan(_aRetorno,.T.) == 0
	Aviso("Alerta","Nenhum período foi selecionado.",{"Sair"})
	Return()
ENDIF

IF Aviso("Confirmação","Confirma geração do relatório ?",{"Sim","Não"}) == 1
	SIPCO05Rel(_aRetorno)
ENDIF

RestArea(_cArea)

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO05Rel
Impressao do relatorio  de Rateio.

@type function
@author TOTVS
@since 10/08/2012
@version P12.1.23

@param _aRetorno, Array, Retorno do Relatório.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO05Rel(_aRetorno)

Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := "Rateio por Empresa"
Local cPict         := ""
Local titulo        := "Rateio por Empresa"
Local Cabec1        := ""
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd := {}
Private nLin        := 80
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 80
Private tamanho     := "P"
Private nomeprog    := "SIPCOR05"
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "SIPCOR05" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString     := "SZT"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Monta a interface padrao com o usuario >--------------
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//--< Processamento. RPTSTATUS monta janela com a regua de processamento. >--
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,_aRetorno) },Titulo)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} RunReport
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.

@type function
@author TOTVS
@since 14/08/12
@version P12.1.23

@param Cabec1, Caractere, Cabeçalho do Relatório.
@param Cabec2, Caractere, Cabeçalho do Relatório.
@param Titulo, Caractere, Título do Relatório.
@param _aRetorno, Array, Retorno do Relatório.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,_aRetorno)

Local nOrdem
Local _cString   := ""
Local _cAno      := Left(_aRetorno[13],4)
Local _cRev      := Right(_aRetorno[13],2)
Local _nTotEmp   := 0
Local _nTotUO    := 0
Local _nTotCR    := 0
Local _nTotGer   := 0
Local _cQuery    := ""
Private _cArqTRB := CriaTrab(nil,.f.)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
_cQuery := "SELECT ZV_CODEMP,ZV_PERC,ZS_CC,ZS_ITCTB,ZS_CONTA,ZS_CLASSE, "
For i := 1 to 12
	IF _aRetorno[i]
		_cString += IIF(Empty(_cString),"",'+')+"ZS_MES"+StrZero(i,2)
	ENDIF
Next
_cQuery += "("+_cString+")*(ZV_PERC/100) TOTAL "
_cQuery += "FROM "+RetSqlName("SZS")+" SZS "
_cQuery += "INNER JOIN "+RetSqlName("SZU")+" SZU ON ZS_CC = ZU_CC AND ZS_ITCTB = ZU_ITCTB AND ZS_CONTA BETWEEN ZU_CONTAI AND ZU_CONTAF "
_cQuery += "AND ZS_CLASSE BETWEEN ZU_CLVLI AND ZU_CLVLF "
_cQuery += "INNER JOIN "+RetSqlName("SZV")+" SZV ON ZV_ANO = ZU_ANO AND ZV_REVISAO = ZU_REVISAO AND ZV_ITEMSZU = ZU_ITEM "
_cQuery += "WHERE SZU.D_E_L_E_T_ = ' ' AND SZS.D_E_L_E_T_ = ' ' AND SZV.D_E_L_E_T_ = ' ' "
_cQuery += "AND ZS_ANO = '"+SZR->ZR_ANO+"' AND ZS_REVISAO = '"+SZR->ZR_REVISAO+"' "
_cQuery += "AND ZU_ANO = '"+_cAno+"' AND ZU_REVISAO = '"+_cRev+"' "
_cQuery += "AND ZS_CC BETWEEN '"+_aRetorno[14]+"' AND '"+_aRetorno[15]+"' "
_cQuery += "AND ZS_ITCTB BETWEEN '"+_aRetorno[16]+"' AND '"+_aRetorno[17]+"' "
_cQuery += "AND ZS_CONTA BETWEEN '"+_aRetorno[18]+"' AND '"+_aRetorno[19]+"' "
_cQuery += "AND ZS_CLASSE BETWEEN '"+_aRetorno[20]+"' AND '"+_aRetorno[21]+"' "
_cQuery += "ORDER BY ZV_CODEMP,ZS_CC,ZS_ITCTB,ZS_CONTA,ZS_CLASSE"
_cQuery := ChangeQuery(_cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqTRB,.t.,.t.)

_cChave1 := ""
_cChave2 := ""
_cChave3 := ""
_nQtdCta := 0

IF (_cArqTRB)->(!Eof())
	IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
	@nLin,000 PSAY "Empresa.: "+(_cArqTRB)->ZV_CODEMP+" - "+Posicione("SM0",1,cEmpAnt+(_cArqTRB)->ZV_CODEMP,"M0_NOMECOM")
	nLin++
	@nLin,003 PSAY "UO.: "+Alltrim((_cArqTRB)->ZS_CC)+" - "+Posicione("CTT",1,XFilial("CTT")+(_cArqTRB)->ZS_CC,"CTT_DESC01")
	nLin++
	@nLin,006 PSAY "CR.: "+Alltrim((_cArqTRB)->ZS_ITCTB)+" - "+Posicione("CTD",1,XFilial("CTD")+(_cArqTRB)->ZS_ITCTB,"CTD_DESC01")
	nLin++
	@nLin,009 PSAY "Contas"
	nLin++
ELSE
	MsgInfo("Não existem dados a serem exibidos!","Atenção")
	(_cArqTRB)->(dbCloseArea())
	FErase(_cArqTRB+GetDBExtension())
	FErase(_cArqTRB+OrdBagExt())
	Return()
ENDIF

While (_cArqTRB)->(!Eof())
	
	IF !Empty(_cChave1) .and. _cChave1 <> (_cArqTRB)->(ZV_CODEMP+ZS_CC+ZS_ITCTB)
		// Total por CR
		IF _nQtdCta > 1
			@nLin,060 PSAY Replicate("-",20)
			nLin++
			@nLin,063 PSAY _nTotCR	Picture "@E 99,999,999,999.99"
			nLin++
		ENDIF
		
		nLin++
		_nQtdCta := 0
		
		IF _cChave2 == (_cArqTRB)->(ZV_CODEMP+ZS_CC)
			@nLin,006 PSAY "CR.: "+Alltrim((_cArqTRB)->ZS_ITCTB)+" - "+Posicione("CTD",1,XFilial("CTD")+(_cArqTRB)->ZS_ITCTB,"CTD_DESC01")
			nLin++
			IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
			@nLin,009 PSAY "Contas"
			nLin++
		ELSEIF _cChave3 == (_cArqTRB)->ZV_CODEMP
			@nLin,003 PSAY "Sub-total UO >>"
			@nLin,063 PSAY _nTotUO	Picture "@E 99,999,999,999.99"
			nLin += 2
			IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
			@nLin,003 PSAY "UO.: "+Alltrim((_cArqTRB)->ZS_CC)+" - "+Posicione("CTT",1,XFilial("CTT")+(_cArqTRB)->ZS_CC,"CTT_DESC01")
			nLin++
			IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
			@nLin,006 PSAY "CR.: "+Alltrim((_cArqTRB)->ZS_ITCTB)+" - "+Posicione("CTD",1,XFilial("CTD")+(_cArqTRB)->ZS_ITCTB,"CTD_DESC01")
			nLin++
			IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
			@nLin,009 PSAY "Contas"
			nLin++
			_nTotUO := 0
		ENDIF
		_nTotCR := 0
	ENDIF
	
	IF !Empty(_cChave3) .and. _cChave3 <> (_cArqTRB)->ZV_CODEMP
		@nLin,003 PSAY "Sub-total UO >>"
		@nLin,063 PSAY _nTotUO	Picture "@E 99,999,999,999.99"
		nLin += 2
		@nLin,000 PSAY "Total da Empresa >>"
		@nLin,063 PSAY _nTotEmp	Picture "@E 99,999,999,999.99"
		nLin++
		@nLin,000 PSAY __PrtThinLine()
		nLin++
		@nLin,000 PSAY "Empresa.: "+(_cArqTRB)->ZV_CODEMP+" - "+Posicione("SM0",1,cEmpAnt+(_cArqTRB)->ZV_CODEMP,"M0_NOMECOM")
		nLin++
		@nLin,003 PSAY "UO.: "+Alltrim((_cArqTRB)->ZS_CC)+" - "+Posicione("CTT",1,XFilial("CTT")+(_cArqTRB)->ZS_CC,"CTT_DESC01")
		nLin++
		@nLin,006 PSAY "CR.: "+Alltrim((_cArqTRB)->ZS_ITCTB)+" - "+Posicione("CTD",1,XFilial("CTD")+(_cArqTRB)->ZS_ITCTB,"CTD_DESC01")
		nLin++
		@nLin,009 PSAY "Contas"
		nLin++
		_nTotEmp := 0
		_nTotUO  := 0
		_nTotCR  := 0
	ENDIF
	
	_cChave1 := (_cArqTRB)->(ZV_CODEMP+ZS_CC+ZS_ITCTB)
	_cChave2 := (_cArqTRB)->(ZV_CODEMP+ZS_CC)
	_cChave3 := (_cArqTRB)->ZV_CODEMP
	
	@nLin,009 PSAY Alltrim((_cArqTRB)->ZS_CONTA)+" - "+Left(Posicione("CT1",1,XFilial("CT1")+(_cArqTRB)->ZS_CONTA,"CT1_DESC01"),45)
	@nLin,063 PSAY (_cArqTRB)->TOTAL	Picture "@E 99,999,999,999.99"
	
	nLin++
	
	IIF(nLin > 55,Eval({|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo),nLin := 8 }),nil)
	
	_nTotEmp += (_cArqTRB)->TOTAL
	_nTotGer += (_cArqTRB)->TOTAL
	_nTotUO  += (_cArqTRB)->TOTAL
	_nTotCR  += (_cArqTRB)->TOTAL
	_nQtdCta++
	
	_cChave1 := (_cArqTRB)->(ZV_CODEMP+ZS_CC+ZS_ITCTB)
	_cChave2 := (_cArqTRB)->(ZV_CODEMP+ZS_CC)
	_cChave3 := (_cArqTRB)->ZV_CODEMP
	
	(_cArqTRB)->(dbSkip())
Enddo

nLin++
@nLin,003 PSAY "Sub-total UO >>"
@nLin,063 PSAY _nTotUO	Picture "@E 99,999,999,999.99"
nLin += 2
@nLin,000 PSAY "Total da Empresa >>"
@nLin,063 PSAY _nTotEmp	Picture "@E 99,999,999,999.99"
nLin++
@nLin,000 PSAY __PrtThinLine()
nLin++
@nLin,000 PSAY "Total Geral >>"
@nLin,063 PSAY _nTotGer	Picture "@E 99,999,999,999.99"

(_cArqTRB)->(dbCloseArea())
FErase(_cArqTRB+GetDBExtension())
FErase(_cArqTRB+OrdBagExt())

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
