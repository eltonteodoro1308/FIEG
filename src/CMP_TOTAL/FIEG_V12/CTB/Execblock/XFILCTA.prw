#Include "Protheus.ch"
#Include 'TopConn.ch'

/*/================================================================================================================================/*/
/*/{Protheus.doc} XFILCTA
Função utilizada para filtrar item contábil, conforme cadastro de amarrações contabeis.

@type function
@author Thiago Rasmussen
@since 07/11/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Código utilizado no Filtro.

/*/
/*/================================================================================================================================/*/

User Function XFILCTA()

	Local cFiltro := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	
	DO CASE
		// Solicitacao de Compra
		CASE ALLTRIM(UPPER(FUNNAME())) == "MATA110"
			cFiltro += CCUSTO

		// PCO - Planilha Orçamentária
		CASE ALLTRIM(UPPER(FUNNAME())) == "PCOA100"
			IF LEN(ALLTRIM(ACOLS[N,2]))==6
				// Planilha Completa
				cFiltro += ACOLS[N,2]
			ELSE
				// Planilha Específica
				cFiltro += CTT->CTT_CUSTO
			ENDIF

		// PCO - Manutenção de Lançamentos
		CASE ALLTRIM(UPPER(FUNNAME())) == "PCOA050"
			cFiltro += M->AKD_CC

		// Contas a Pagar - Rateio - Débito
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA050" .AND. ALLTRIM(READVAR()) == "M->CTJ_ITEMD"
			cFiltro += TMP->CTJ_CCD

		// Contas a Pagar - Rateio - Crédito
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA050" .AND. ALLTRIM(READVAR()) == "M->CTJ_ITEMC"
			cFiltro += TMP->CTJ_CCC

		// Funções do Conta a Pagar - Rateio - Débito
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA750" .AND. ALLTRIM(READVAR()) == "M->CTJ_ITEMD"
			cFiltro += TMP->CTJ_CCD

		// Funções do Conta a Pagar - Rateio - Crédito
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA750" .AND. ALLTRIM(READVAR()) == "M->CTJ_ITEMC"
			cFiltro += TMP->CTJ_CCC

		/*
		// Pedido de Compra
		CASE ALLTRIM(UPPER(FUNNAME())) == "MATA121"
			_nPosCC	:= aScan(aHeader,{|x| ALLTRIM(x[2]) == "C7_CC"})
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +aCols[n][_nPosCC]+"' "

		// Nota Fiscal de Entrada
		CASE ALLTRIM(UPPER(FUNNAME())) == "MATA103" .AND. ALLTRIM(READVAR()) == "M->D1_ITEMCTA"
			_nPosCC	:= aScan(aHeader,{|x| ALLTRIM(x[2]) == "D1_CC"})
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +aCols[n][_nPosCC]+"' "

		// Nota Fiscal de Entrada - Rateio CC
		CASE ALLTRIM(UPPER(FUNNAME())) == "MATA103" .AND. ALLTRIM(READVAR()) == "M->DE_ITEMCTA"
			_nPosCC	:= aScan(aHeader,{|x| ALLTRIM(x[2]) == "DE_CC"})
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +aCols[n][_nPosCC]+"' "

		// Pedido de Venda
		CASE ALLTRIM(UPPER(FUNNAME())) == "MATA410" .AND. ALLTRIM(READVAR()) == "M->C6_XITEMC"
			_nPosCC	:= aScan(aHeader,{|x| ALLTRIM(x[2]) == "C6_XCC"})
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +aCols[n][_nPosCC]+"' "

		// Pedido de Venda - Rateio
		CASE ALLTRIM(UPPER(FUNNAME())) == "MATA410" .AND. ALLTRIM(READVAR()) == "M->AGG_ITEMCT"
			_nPosCC	:= aScan(aHeader,{|x| ALLTRIM(x[2]) == "AGG_CC"})
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +aCols[n][_nPosCC]+"' "

		// Planilha de Contratos
		CASE ALLTRIM(UPPER(FUNNAME())) == "CNTA200"
			_nPosCC	:= aScan(aHeader,{|x| ALLTRIM(x[2]) == "CNB_CC"})
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +aCols[n][_nPosCC]+"' "

		// Contratos
		CASE ALLTRIM(UPPER(FUNNAME())) == "CNTA100"
			_nPosCC	:= aScan(aHeader,{|x| ALLTRIM(x[2]) == "CNB_CC"})
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +aCols[n][_nPosCC]+"' "

		// Contas a Receber
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA040"
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +M->E1_CCC+ "' "

		// Funções do Contas a Receber
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA740"
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +M->E1_CCC+ "' "

		// Contas a Pagar
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA050" .AND. ALLTRIM(READVAR()) == "M->E2_ITEMD"
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +M->E2_CCD+ "' "

		// Funções do Conta a Pagar
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA750" .AND. ALLTRIM(READVAR()) == "M->E2_ITEMD"
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +M->E2_CCD+ "' "

		// Movimentos Bancarios - Crédito
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA100" .AND. ALLTRIM(READVAR()) == "M->E5_ITEMC"
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +M->E5_CCC+ "' "

		// Movimentos Bancarios - Rateio - Crédito
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA100" .AND. ALLTRIM(READVAR()) == "M->CTJ_ITEMC"
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +TMP->CTJ_CCC+ "' "

		// Movimentos Bancarios - Débito
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA100" .AND. ALLTRIM(READVAR()) == "M->E5_ITEMD"
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +M->E5_CCD+ "' "

		// Movimentos Bancarios - Rateio - Débito
		CASE ALLTRIM(UPPER(FUNNAME())) == "FINA100" .AND. ALLTRIM(READVAR()) == "M->CTJ_ITEMD"
			cFiltro += "CTA_FILIAL == '" +xFilial("CTA") +"' .AND. CTA_CUSTO == '" +TMP->CTJ_CCD+ "' "
		*/
	EndCase

Return(cFiltro)

/*
USER FUNCTION DOITU01(lFirst)
Local aDados	:= {}
Local n			:= 0
Local aAtuSf3	:= {}
Local aAtuVld	:= {}
Default lFirst	:= .t.

IF lFirst
	IF Aviso("Atualização de dicionários", "Confirma a atualização de dicionários SIGCTE01?", {"Sim", "Não"}) == 1
		MsgRun("Atualizando dicionários... Aguarde!",, {|| U_DoitU01(.f.)})
		Aviso("Atualização de dicionários", "Atualização de dicionários concluída!", {"Ok"})
	ENDIF
	RETURN
ENDIF

Aadd(aDados, {"CTACTD","1","01","DB","Item Contabil","Item Contable","Accounting Item","CTA",""})
Aadd(aDados, {"CTACTD","2","01","03","Codigo","Codigo","Code","",""})
Aadd(aDados, {"CTACTD","4","01","01","Codigo","Codigo","Code","CTA_ITEM",""})
Aadd(aDados, {"CTACTD","4","01","02","Descricao","Descripcion","Description","POSICIONE('CTD',1,XFILIAL('CTD')+CTA->CTA_ITEM,'CTD_DESC01')",""})
Aadd(aDados, {"CTACTD","5","01","","","","","IIF(FUNNAME()$'CTBA080,CONA010','CTA->CTA_ITEM',CTA->CTA_ITEM)",""})
Aadd(aDados, {"CTACTD","6","01","","","","","@#U_SIGCTE01()",""})

DbSelectArea("SXB")
DbSetOrder(1)
DbSeek("CTACTD", .f.)
WHILE !Eof() .AND. SXB->XB_ALIAS == "CTACTD"
	RecLock("SXB", .f.)
		DbDelete()
	MsUnlock()

	DbSkip()
ENDDO

FOR n := 1 TO Len(aDados)
	RecLock("SXB", .t.)
		AEval(aDados[n], {|y,z| FieldPut(z, y)})
	MsUnlock()
NEXT

// Atualizar campo X3_F3 com a expressão 'CTACTD'
Aadd(aAtuSf3, "AGG_ITEMCT")
Aadd(aAtuSf3, "CTJ_ITEMD ")
Aadd(aAtuSf3, "CTJ_ITEMC ")
Aadd(aAtuSf3, "C7_ITEMCTA")
Aadd(aAtuSf3, "D1_ITEMCTA")
Aadd(aAtuSf3, "DE_ITEMCTA")
Aadd(aAtuSf3, "E1_ITEMD  ")
Aadd(aAtuSf3, "E1_ITEMC  ")
Aadd(aAtuSf3, "E2_ITEMD  ")
Aadd(aAtuSf3, "E2_ITEMC  ")
Aadd(aAtuSf3, "E5_ITEMD  ")
Aadd(aAtuSf3, "E5_ITEMC  ")
Aadd(aAtuSf3, "EZ_ITEMCTA")
Aadd(aAtuSf3, "C6_XITEMC ")
Aadd(aAtuSf3, "CNB_ITEMCT")

DbSelectArea("SX3")
DbSetOrder(2)
FOR n := 1 TO Len(aAtuSf3)
	IF DbSeek(aAtuSf3[n], .f.)
		RecLock("SX3", .f.)
			SX3->X3_F3	:= "CTACTD"
		MsUnlock()
	ENDIF
NEXT

// Atualizar campo X3_VLDUSER
Aadd(aAtuVld, {"AGG_CC    ", "CtbAmarra(GDFIELDGET('AGG_CONTA'),M->AGG_CC,GDFIELDGET('AGG_ITEMCT'),GDFIELDGET('AGG_CLVL'),.T.)                                "})
Aadd(aAtuVld, {"AGG_ITEMCT", "CtbAmarra(GDFIELDGET('AGG_CONTA'),GDFIELDGET('AGG_CC'),M->AGG_ITEMCT,GDFIELDGET('AGG_CLVL'),.T.)                                "})
Aadd(aAtuVld, {"§_CCD   ", 	 "CtbAmarra(TMP->CTJ_DEBITO,M->CTJ_CCD,TMP->CTJ_ITEMD,TMP->CTJ_CLVLDB,.T.)                                                        "})
Aadd(aAtuVld, {"CTJ_CCC   ", "CtbAmarra(TMP->CTJ_CREDIT,M->CTJ_CCC,TMP->CTJ_ITEMC,TMP->CTJ_CLVLCR,.T.)                                                        "})
Aadd(aAtuVld, {"CTJ_ITEMD ", "CtbAmarra(TMP->CTJ_DEBITO,TMP->CTJ_CCD,M->CTJ_ITEMD,TMP->CTJ_CLVLDB,.T.)                                                        "})
Aadd(aAtuVld, {"CTJ_ITEMC ", "CtbAmarra(TMP->CTJ_CREDIT,TMP->CTJ_CCC,M->CTJ_ITEMC,TMP->CTJ_CLVLCR,.T.)                                                        "})
Aadd(aAtuVld, {"C7_CC     ", "CtbAmarra(GDFIELDGET('C7_CONTA'),M->C7_CC,GDFIELDGET('C7_ITEMCTA'),GDFIELDGET('C7_CLVL'),.T.)                                   "})
Aadd(aAtuVld, {"C7_ITEMCTA", "CtbAmarra(GDFIELDGET('C7_CONTA'),GDFIELDGET('C7_CC'),M->C7_ITEMCTA,GDFIELDGET('C7_CLVL'),.T.)                                   "})
Aadd(aAtuVld, {"D1_ITEMCTA", "CtbAmarra(GDFIELDGET('D1_CONTA'),GDFIELDGET('D1_CC'),M->D1_ITEMCTA,GDFIELDGET('D1_CLVL'),.T.)                                   "})
Aadd(aAtuVld, {"D1_CC     ", "CtbAmarra(GDFIELDGET('D1_CONTA'),M->D1_CC,GDFIELDGET('D1_ITEMCTA'),GDFIELDGET('D1_CLVL'),.T.)                                   "})
Aadd(aAtuVld, {"DE_CC     ", "CtbAmarra(GDFIELDGET('DE_CONTA'),M->DE_CC,GDFIELDGET('DE_ITEMCTA'),GDFIELDGET('DE_CLVL'),.T.)                                   "})
Aadd(aAtuVld, {"DE_ITEMCTA", "CtbAmarra(GDFIELDGET('DE_CONTA'),GDFIELDGET('DE_CC'),M->DE_ITEMCTA,GDFIELDGET('DE_CLVL'),.T.)                                   "})
Aadd(aAtuVld, {"E1_CCD    ", "CtbAmarra(M->E1_DEBITO,M->E1_CCD,M->E1_ITEMD,M->E1_CLVLDB,.T.)                                                                  "})
Aadd(aAtuVld, {"E1_ITEMD  ", "CtbAmarra(M->E1_DEBITO,M->E1_CCD,M->E1_ITEMD,M->E1_CLVLDB,.T.)                                                                  "})
Aadd(aAtuVld, {"E1_CCC    ", "CtbAmarra(M->E1_CREDIT,M->E1_CCC,M->E1_ITEMC,M->E1_CLVLCR,.T.)                                                                  "})
Aadd(aAtuVld, {"E1_ITEMC  ", "CtbAmarra(M->E1_CREDIT,M->E1_CCC,M->E1_ITEMC,M->E1_CLVLCR,.T.)                                                                  "})
Aadd(aAtuVld, {"E2_CCD    ", "CtbAmarra(M->E2_CONTAD,M->E2_CCD,M->E2_ITEMD,M->E2_CLVLDB,.T.)                                                                  "})
Aadd(aAtuVld, {"E2_ITEMD  ", "CtbAmarra(M->E2_CONTAD,M->E2_CCD,M->E2_ITEMD,M->E2_CLVLDB,.T.)                                                                  "})
Aadd(aAtuVld, {"E2_CCC    ", "CtbAmarra(M->E2_CREDIT,M->E2_CCC,M->E2_ITEMC,M->E2_CLVLCR,.T.)                                                                  "})
Aadd(aAtuVld, {"E2_ITEMC  ", "CtbAmarra(M->E2_CREDIT,M->E2_CCC,M->E2_ITEMC,M->E2_CLVLCR,.T.)                                                                  "})
Aadd(aAtuVld, {"E5_CCD    ", "CtbAmarra(M->E5_DEBITO,M->E5_CCD,M->E5_ITEMD,M->E5_CLVLDB,.T.)                                                                  "})
Aadd(aAtuVld, {"E5_CCC    ", "CtbAmarra(M->E5_CREDITO,M->E5_CCC,M->E5_ITEMC,M->E5_CLVLCR,.T.)                                                                 "})
Aadd(aAtuVld, {"E5_ITEMD  ", "CtbAmarra(M->E5_DEBITO,M->E5_CCD,M->E5_ITEMD,M->E5_CLVLDB,.T.)                                                                  "})
Aadd(aAtuVld, {"E5_ITEMC  ", "CtbAmarra(M->E5_CREDITO,M->E5_CCC,M->E5_ITEMC,M->E5_CLVLCR,.T.)                                                                 "})
Aadd(aAtuVld, {"EZ_CCUSTO ", "CtbAmarra(SPACE(TAMSX3('CT1_CONTA')[1]),M->EZ_CCUSTO,GDFIELDGET('EZ_ITEMCTA'),GDFIELDGET('EZ_CLVL'),.T.)                        "})
Aadd(aAtuVld, {"EZ_ITEMCTA", "CtbAmarra(SPACE(TAMSX3('CT1_CONTA')[1]),GDFIELDGET('EZ_CCUSTO'),M->EZ_ITEMCTA,GDFIELDGET('EZ_CLVL'),.T.)                        "})
Aadd(aAtuVld, {"C6_XCC    ", "CtbAmarra(GDFIELDGET('C6_XCONTA'),M->C6_XCC,GDFIELDGET('C6_XITEMC'),GDFIELDGET('C6_XCLVL'),.T.)                                 "})
Aadd(aAtuVld, {"C6_XITEMC ", "vazio().or.(U_DoitA01B(7) .AND.CtbAmarra(GDFIELDGET('C6_XCONTA'),GDFIELDGET('C6_XCC'),M->C6_XITEMC,GDFIELDGET('C6_XCLVL'),.T.)) "})
Aadd(aAtuVld, {"CNB_CC    ", "CtbAmarra(GDFIELDGET('CNB_CONTA'),M->CNB_CC,GDFIELDGET('CNB_ITEMCT'),GDFIELDGET('CNB_CLVL'),.T.)                                "})
Aadd(aAtuVld, {"CNB_ITEMCT", "CtbAmarra(GDFIELDGET('CNB_CONTA'),GDFIELDGET('CNB_CC'),M->CNB_ITEMCT,GDFIELDGET('CNB_CLVL'),.T.)                                "})

DbSelectArea("SX3")
DbSetOrder(2)
FOR n := 1 TO Len(aAtuVld)
	IF DbSeek(aAtuVld[n, 1])
		RecLock("SX3", .f.)
			SX3->X3_VLDUSER	:= aAtuVld[n, 2]
		MsUnlock()
	ENDIF
NEXT

RETURN
*/