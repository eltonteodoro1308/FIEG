#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} DMatr170
Emissao do Boletim de Entrada.

@type function
@author Ricardo Berti
@since 05/07/2006
@version P12.1.23

@param cAlias, Caractere, Aliás do arquivo.
@param nReg, Numérico, Número do registro.
@param nOpcx, Numérico, Opção Selecionada.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function DMatr170(cAlias,nReg,nOpcx)

	Local oReport

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If FindFunction("TRepInUse") .And. TRepInUse() //.And. .F.
		//+------------------------------------------------------------------------+
		//|Interface de impressao                                                  |
		//+------------------------------------------------------------------------+
		// 22/11/2016 - Thiago Rasmussen - Imprimir a pré-nota posicionada
		nReg := SF1->(Recno())
		oReport := ReportDef(cAlias,nReg,nOpcx)

		oReport:LoadLayout("Pre-Nota")
		oReport:cFile	:= SF1->F1_FILIAL+"_"+Alltrim(SF1->F1_DOC)+"_"+DtoS(SF1->F1_EMISSAO)
		oReport:SetEnvironment(2)
		oReport:SetDevice(6)
		oReport:nDevice := 6
		oReport:SetPreview(.F.)
		MsAguarde({|| oReport:Print() },"FIEG - "+FunName(),"Gerando PDF. Aguarde...")

	Else

		MATR170R3(cAlias,nReg,nOpcx)

	EndIf

Return NIL

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
A funcao estatica ReportDef deverá ser criada para todos os relatórios que poderão ser agendados pelo usuário.

@type function
@author Ricardo Berti
@since 05/07/2006
@version P12.1.23

@param cAlias, Caractere, Aliás do arquivo.
@param nReg, Numérico, Número do registro.
@param nOpcx, Numérico, Opção Selecionada.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, Objeto do relatorio.

/*/
/*/================================================================================================================================/*/

Static Function ReportDef(cAlias,nReg,nOpcx)

	Local oReport
	Local oEmpresa
	Local oFornec1
	Local oFornec2
	Local oClient1
	Local oClient2
	Local oNF
	Local oNFItem
	Local oEntCtb
	Local oQuali
	Local oDivPC
	Local oNFTot1
	Local oNFTot2
	Local oDupli
	Local oFisc1
	Local oFisc2
	Local oFisc3
	Local oCell
	Local aVencto	:= {}
	Local aImps		:= {}
	Local cAliasSF1 := "SF1"
	Local cAliasSD1 := "SD1"
	Local lAuto		:= (nReg!=Nil)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+------------------------------------------------------------------------+
	//|Criacao do componente de impressao                                      |
	//|                                                                        |
	//|TReport():New                                                           |
	//|ExpC1 : Nome do relatorio                                               |
	//|ExpC2 : Titulo                                                          |
	//|ExpC3 : Pergunte                                                        |
	//|ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  |
	//|ExpC5 : Descricao                                                       |
	//|                                                                        |
	//+------------------------------------------------------------------------+

	oReport := TReport():New("MATR170","Boletim de Entrada","MTR170", {|oReport| ReportPrint(oReport,@aVencto,@aImps,nReg,@cAliasSF1,@cAliasSD1)},"Este programa ira emitir o Boletim de Entrada.") ////##
	oReport:SetPortrait()	// Define a orientacao default de pagina do relatorio como Retrato.

	If lAuto
		oReport:ParamReadOnly() // Desabilita a edicao de parametros pelo usuario na tela de impressao
	EndIf

	oReport:HideParamPage()	// inibe impressao da pagina de parametros
	//oReport:SetPageFooter(4,{|| ImpRoda(oReport)})  // define rodape'

	//+--------------------------------------------------------------+
	//| Verifica as perguntas selecionadas                           |
	//+--------------------------------------------------------------+
	AjustaSx1()
	Pergunte("MTR170",.F.)
	//+---------------------------------------------------------------------+
	//| Variaveis utiLizadas para parametros                    		    |
	//| mv_par01             // da Data                 		            |
	//| mv_par02             // ate a Data      		                    |
	//| mv_par03             // Nota De			                            |
	//| mv_par04             // Nota Ate                          			|
	//| mv_par05             // Imprime Cta.Contabil x C.Custo x Entid.Ctb.	|
	//| mv_par06             // Imprimir o Custo ? Total ou Unit rio 		|
	//| mv_par07             // Ordenar itens por? Item+Prod/ Prd+It 		|
	//| mv_par08             // Imprime armazem? Sim/Nao			 		|
	//+---------------------------------------------------------------------+

	If lAuto
		dbSelectArea("SF1")
		SF1->(dbGoto(nReg))
		MV_PAR01 := SF1->F1_DTDIGIT
		MV_PAR02 := SF1->F1_DTDIGIT
		MV_PAR03 := SF1->F1_DOC
		MV_PAR04 := SF1->F1_DOC
	EndIf

	//+------------------------------------------------------------------------+
	//|Criacao da secao utilizada pelo relatorio                               |
	//|                                                                        |
	//|TRSection():New                                                         |
	//|ExpO1 : Objeto TReport que a secao pertence                             |
	//|ExpC2 : Descricao da seçao                                              |
	//|ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   |
	//|        sera considerada como principal para a seção.                   |
	//|ExpA4 : Array com as Ordens do relatório                                |
	//|ExpL5 : Carrega campos do SX3 como celulas                              |
	//|        Default : False                                                 |
	//|ExpL6 : Carrega ordens do Sindex                                        |
	//|        Default : False                                                 |
	//+------------------------------------------------------------------------+
	//+------------------------------------------------------------------------+
	//|Criacao das celulas da secao do relatorio                               |
	//|                                                                        |
	//|TRCell():New                                                            |
	//|ExpO1 : Objeto TSection que a secao pertence                            |
	//|ExpC2 : Nome da celula do relatório. O SX3 será consultado              |
	//|ExpC3 : Nome da tabela de referencia da celula                          |
	//|ExpC4 : Titulo da celula                                                |
	//|        Default : X3Titulo()                                            |
	//|ExpC5 : Picture                                                         |
	//|        Default : X3_PICTURE                                            |
	//|ExpC6 : Tamanho                                                         |
	//|        Default : X3_TAMANHO                                            |
	//|ExpL7 : Informe se o tamanho esta em pixel                              |
	//|        Default : False                                                 |
	//|ExpB8 : Bloco de código para impressao.                                 |
	//|        Default : ExpC2                                                 |
	//+------------------------------------------------------------------------+

	//+------------------------------------------------------------------------+
	//|Secao 1 - Dados Boletim       			                               |
	//+------------------------------------------------------------------------+
	oSection1:= TRSection():New(oReport,"Cabeçalho do Boletim (Parte 2)",{"SF1"},/*Ordem*/)  //
	oCell := TRCell():New(oSection1,"Tit"	,"",,,,,{|| "Boletim de Entrada"+"   "+"N. "+(cAliasSD1)->D1_NUMSEQ ;  //##
	+If((cAliasSF1)->F1_TIPO $ "DB", If( (cAliasSF1)->F1_TIPO=="D"," - (Devolucao)","  - "+AllTrim("Beneficiamento    ")),"" ) })  //"Devolucao / Beneficiamento
	oCell:SetSize(3+Len("Boletim de Entrada"+"N. ")+TamSX3("D1_NUMSEQ")[1]+If((cAliasSF1)->F1_TIPO $ "DB",15,0) )
	oCell := TRCell():New(oSection1,"DtRec"	,"",,,,,{|| "Material Recebido em: "+dtoc((cAliasSF1)->F1_DTDIGIT) }) // //"Material Recebido em: "###"Material Recebido em: "
	oCell:SetSize(10+Len("Material Recebido em: ")) //

	//+------------------------------------------------------------------------+
	//|Secao 0 - Cabecalho 	  	                                        	   |
	//+------------------------------------------------------------------------+
	oCabec:= TRSection():New(oSection1,"Cabeçalho do Boletim (Parte 1)",{"SF1"},/*Ordem*/) //
	oCabec:SetHeaderSection(.F.)
	TRCell():New(oCabec,"Usu"	,"Usuario: ",,,Len("Usuario: ")+15,,{|| "Usuario: "+CUSERNAME  })  //
	TRCell():New(oCabec,"DtBase","Data Base: ",,,Len("Data Base: ")+10,,{|| " Data Base: "+Dtoc(dDataBase) }) //
	TRCell():New(oCabec,"DtImp" ,"Data Impressao ",,,Len("Data Impressao ")+25,,{|| Space(15)+"Data Impressao "+Dtoc(Date()) }) //)
	TRCell():New(oCabec,"HrImp" ,"Hora Ref. ",,,Len("Hora Ref. ")+ 8,,{|| "Hora Ref. "+Time() }) //)

	//+------------------------------------------------------------------------+
	//|Secao 2 - Dados da Empresa			                                   |
	//+------------------------------------------------------------------------+

	oEmpresa := TRSection():New(oSection1,"Dados da Empresa/Filial",{"SM0"},) //
	TRCell():New(oEmpresa,"M0_NOME","SM0","M0NOME",,,,)
	TRCell():New(oEmpresa,"M0_FILIAL","SM0","M0FILIAL")
	oCell := TRCell():New(oEmpresa,"M0_CGC","SM0","M0CGC",,,,{|| "  - "+AllTrim(RetTitle("A1_CGC"))+": "+SM0->M0_CGC })
	oCell:SetSize(5+Len(AllTrim(RetTitle("A1_CGC")))+TamSX3("A1_CGC")[1])


	//+------------------------------------------------------------------------+
	//|Secao 3 - Dados do Fornecedor - I	                                   |
	//+------------------------------------------------------------------------+
	oFornec1 := TRSection():New(oSection1,"Fornecedor (Parte 1)",{"SA2"},/*Ordem*/) //
	TRCell():New(oFornec1,"A2_COD","SA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oFornec1,"A2_LOJA","SA2")
	TRCell():New(oFornec1,"A2_NOME","SA2")
	TRCell():New(oFornec1,"A2_END","SA2")
	//+------------------------------------------------------------------------+
	//|Secao 4 - Dados do Fornecedor - II	                                   |
	//+------------------------------------------------------------------------+
	oFornec2 := TRSection():New(oSection1,"Fornecedor (Parte 2)",{"SA2"},/*Ordem*/) //
	TRCell():New(oFornec2,"A2_MUN","SA2")
	TRCell():New(oFornec2,"A2_EST","SA2")
	oCell := TRCell():New(oFornec2,"CGCFOR","SA2","@X",,,,{|| AllTrim(RetTitle("A2_CGC"))+': '+If(cPaisLoc<>"BRA",Transform(SA2->A2_CGC,PesqPict("SA2","A2_CGC")),Transform(SA2->A2_CGC,PicPesFJ(If(Len(AllTrim(SA2->A2_CGC))<14,"F","J")))) } )
	oCell:SetSize(6+Len(AllTrim(RetTitle("A2_CGC")))+TamSX3("A2_CGC")[1])
	If cPaisLoc <> "PTG"
		oCell := TRCell():New(oFornec2,"A2_INSCR","SA2",,,,,{|| AllTrim(RetTitle("A2_INSCR"))+': '+Transform(SA2->A2_INSCR,PesqPict("SA2","A2_INSCR")) } )
		oCell:SetSize(2+Len(AllTrim(RetTitle("A2_INSCR")))+TamSX3("A2_INSCR")[1])
		oCell := TRCell():New(oFornec2,"A2_INSCRM","SA2",,,,,{|| AllTrim(RetTitle("A2_INSCRM"))+': '+Transform(SA2->A2_INSCRM,PesqPict("SA2","A2_INSCRM")) } )
		oCell:SetSize(2+Len(AllTrim(RetTitle("A2_INSCRM")))+TamSX3("A2_INSCRM")[1])
	Endif

	//+------------------------------------------------------------------------+
	//|Secao 5 - Dados do Cliente - I 		                                   |
	//+------------------------------------------------------------------------+
	oClient1 := TRSection():New(oSection1,"Cliente (Parte 1)",{"SA1"},/*Ordem*/) //
	TRCell():New(oClient1,"A1_COD","SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oClient1,"A1_LOJA","SA1")
	TRCell():New(oClient1,"A1_NOME","SA1")
	TRCell():New(oClient1,"A1_END","SA1")
	//+------------------------------------------------------------------------+
	//|Secao 6 - Dados do Cliente - II		                                   |
	//+------------------------------------------------------------------------+
	oClient2 := TRSection():New(oSection1,"Cliente (Parte 2)",{"SA1"},/*Ordem*/) //
	TRCell():New(oClient2,"A1_MUN","SA1")
	TRCell():New(oClient2,"A1_EST","SA1")
	oCell := TRCell():New(oClient2,"CGCCLI","SA1",,,,,{|| AllTrim(RetTitle("A1_CGC"))+': '+Transform(SA1->A1_CGC,PicPesFJ(If(Len(AllTrim(SA1->A1_CGC))<14,"F","J"))) })
	oCell:SetSize(6+Len(AllTrim(RetTitle("A1_CGC")))+TamSX3("A1_CGC")[1])
	If cPaisLoc <> "PTG"
		oCell := TRCell():New(oClient2,"A1_INSCR","SA1",,,,,{|| AllTrim(RetTitle("A1_INSCR"))+': '+Transform(SA1->A1_INSCR,PesqPict("SA1","A1_INSCR")) } )
		oCell:SetSize(2+Len(AllTrim(RetTitle("A1_INSCR")))+TamSX3("A1_INSCR")[1])
		oCell := TRCell():New(oClient2,"A1_INSCRM","SA1",,,,,{|| AllTrim(RetTitle("A1_INSCRM"))+': '+Transform(SA1->A1_INSCRM,PesqPict("SA1","A1_INSCRM")) } )
		oCell:SetSize(2+Len(AllTrim(RetTitle("A2_INSCRM")))+TamSX3("A2_INSCRM")[1])
	Endif

	//+------------------------------------------------------------------------+
	//|Secao 7 - Dados da Nota Fiscal	                                       |
	//+------------------------------------------------------------------------+
	oNF := TRSection():New(oSection1,"Cabeçalhos de documentos de entrada",{"SF1"},/*Ordem*/) //
	TRCell():New(oNF,"F1_SERIE"	,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNF,"F1_DOC"		,"SF1")
	TRCell():New(oNF,"F1_ESPECIE"	,"SF1")
	TRCell():New(oNF,"F1_TIPO"		,"SF1")
	TRCell():New(oNF,"F1_EMISSAO"	,"SF1")
	TRCell():New(oNF,"DTVENC"		,"",RetTitle("E2_VENCTO"),,8,,{|| If( Len(aVencto) == 1, Dtoc(aVencto[1]),If(Len(aVencto) ==0,"STR0115","Diversos")) }) //
	TRCell():New(oNF,"F1_VALBRUT"	,"SF1")

	//+------------------------------------------------------------------------+
	//|Secao 8 - Dados da Nota Fiscal - Itens                          	       |
	//+------------------------------------------------------------------------+
	oNFItem := TRSection():New(oSection1,"Itens de documentos de entrada",{"SD1","SB1"},/*Ordem*/) //
	TRCell():New(oNFItem,"D1_COD"	,"SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNFItem,"D1_UM"	,"SD1","STR0111")
	TRCell():New(oNFItem,"B1_DESC"	,"SB1",,,20)
	oNFItem:Cell("B1_DESC"):SetLineBreak()
	TRCell():New(oNFItem,"D1_LOCAL","SD1")
	TRCell():New(oNFItem,"D1_QUANT","SD1")
	TRCell():New(oNFItem,"D1_VUNIT","SD1",,,12)
	TRCell():New(oNFItem,"D1_TOTAL","SD1")
	TRCell():New(oNFItem,"D1_IPI"	,"SD1","STR0112")
	TRCell():New(oNFItem,"D1_PICM"	,"SD1","STR0113")
	TRCell():New(oNFItem,"D1_CONTA","SD1")
	TRCell():New(oNFItem,"D1_CC"	,"SD1")
	TRCell():New(oNFItem,"D1_TES"	,"SD1","STR0110")
	TRCell():New(oNFItem,"D1_CF"	,"SD1","STR0114")
	TRCell():New(oNFItem,"D1_CUSTO","SD1","Custo Total ",,10,,{|| If( mv_par06==1,(cAliasSD1)->D1_CUSTO,(cAliasSD1)->D1_CUSTO / (cAliasSD1)->D1_QUANT ) }) //

	//+------------------------------------------------------------------------+
	//|Secao 9 - Entidades Contabeis 		                                   |
	//+------------------------------------------------------------------------+
	oEntCtb := TRSection():New(oSection1,"Entidades Contábeis",{"SDE"},/*Ordem*/) //
	oCell := TRCell():New(oEntCtb,"DEITEMNF","")
	oCell:GetFieldInfo("DE_ITEMNF")
	oCell := TRCell():New(oEntCtb,"DEITEM"	,"")
	oCell:GetFieldInfo("DE_ITEM")
	TRCell():New(oEntCtb,"DEPERC"	,"",RetTitle("DE_PERC"),,6)
	oCell := TRCell():New(oEntCtb,"DECC"	,"")
	oCell:GetFieldInfo("DE_CC")
	oCell := TRCell():New(oEntCtb,"DECONTA"	,"")
	oCell:GetFieldInfo("DE_CONTA")
	oCell := TRCell():New(oEntCtb,"DEITEMCTA","")
	oCell:GetFieldInfo("DE_ITEMCTA")
	oCell := TRCell():New(oEntCtb,"DECLVL"	,"")
	oCell:GetFieldInfo("DE_CLVL")

	//+------------------------------------------------------------------------+
	//|Secao 10 - Produtos Enviados ao Controle de Qualidade                   |
	//+------------------------------------------------------------------------+
	oQuali := TRSection():New(oSection1,"Produtos enviados ao CQ",{"SD7"},/*Ordem*/) //
	oCell := TRCell():New(oQuali,"D7PRODUTO","",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	oCell:GetFieldInfo("D7_PRODUTO")
	oCell := TRCell():New(oQuali,"D7LOCAL"	,"")
	oCell:GetFieldInfo("D7_LOCAL")
	oCell := TRCell():New(oQuali,"D7LOCDEST","")
	oCell:GetFieldInfo("D7_LOCDEST")
	oCell := TRCell():New(oQuali,"D7DATA"	,"")
	oCell:GetFieldInfo("D7_DATA")
	oCell := TRCell():New(oQuali,"D7NUMERO"	,"")
	oCell:GetFieldInfo("D7_NUMERO")

	//+------------------------------------------------------------------------+
	//|Secao 11 - Divergencia com Pedido de Compra                             |
	//+------------------------------------------------------------------------+
	oDivPC := TRSection():New(oSection1,"Divergência com Pedido de Compra",{"SC7"},/*Ordem*/) //
	TRCell():New(oDivPC,"DivPC"	,"","Div",/*Picture*/,3,/*lPixel*/,/*{|| code-block de impressao }*/)
	oCell := TRCell():New(oDivPC,"C7NUM"	,"",RetTitle("C7_NUM"),,TamSX3("C7_NUM")[1]+TamSX3("C7_ITEM")[1]+1)
	oCell := TRCell():New(oDivPC,"C7DESCRI"	,"")
	oCell:GetFieldInfo("C7_DESCRI")
	If cPaisLoc == "BRA"
		oCell:SetSize(20)
	Else
		oCell:SetSize(18)
	EndIf
	oCell:SetLineBreak()
	oCell := TRCell():New(oDivPC,"C7QUJE"	,"",RetTitle("C7_QUJE"),,11)
	oCell := TRCell():New(oDivPC,"C7QUANT"	,"",RetTitle("C7_QUANT"),,11)
	oCell := TRCell():New(oDivPC,"C7PRECO"	,"",RetTitle("C7_PRECO"),,13)
	oCell := TRCell():New(oDivPC,"C7EMISSAO","")
	oCell:GetFieldInfo("C7_EMISSAO")
	oCell := TRCell():New(oDivPC,"C7DATPRF"	,"")
	oCell:GetFieldInfo("C7_DATPRF")
	oCell := TRCell():New(oDivPC,"C7NUMSC"	,"")
	oCell:GetFieldInfo("C7_NUMSC")
	oCell := TRCell():New(oDivPC,"C1SOLICIT","")
	oCell:GetFieldInfo("C1_SOLICIT")
	oCell := TRCell():New(oDivPC,"C1CC","")
	oCell:GetFieldInfo("C1_CC")
	oCell := TRCell():New(oDivPC,"E4DESCRI"	,"")
	oCell:GetFieldInfo("E4_DESCRI")

	//+------------------------------------------------------------------------+
	//|Secao 12 - TOTAIS DA NF (1/2)                                           |
	//+------------------------------------------------------------------------+
	oNFTot1 := TRSection():New(oSection1,"Totais da Nota Fiscal (Parte 1)",{"SF1"},/*Ordem*/) //
	If cPaisLoc=="BRA"
		TRCell():New(oNFTot1,"F1_BASEICM"	,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oNFTot1,"F1_VALICM"	,"SF1")
		TRCell():New(oNFTot1,"F1_BRICMS"	,"SF1")
		TRCell():New(oNFTot1,"F1_ICMSRET"	,"SF1")
	Else
		TRCell():New(oNFTot1,"QTIMP1"	,"","Base de Calculo Imp."	,"@E 999,999,999,999.99",,,{|| aImps[1] }) //
		TRCell():New(oNFTot1,"VLIMP1"	,"","Valor dos Impostos"	,"@E 999,999,999,999.99",,,{|| aImps[2] }) //
	EndIf
	TRCell():New(oNFTot1,"F1_VALMERC"	,"SF1")
	TRCell():New(oNFTot1,"F1_DESCONT"	,"SF1")

	//+------------------------------------------------------------------------+
	//|Secao 13 - TOTAIS DA NF (2/2)                                           |
	//+------------------------------------------------------------------------+
	oNFTot2 := TRSection():New(oSection1,"Totais da Nota Fiscal (Parte 2)",{"SF1"},/*Ordem*/) //
	TRCell():New(oNFTot2,"F1_FRETE"	,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNFTot2,"F1_SEGURO"	,"SF1")
	TRCell():New(oNFTot2,"F1_DESPESA"	,"SF1")
	If cPaisLoc=="BRA"
		TRCell():New(oNFTot2,"F1_VALIPI"	,"SF1")
	EndIf
	TRCell():New(oNFTot2,"F1_VALBRUT"	,"SF1")

	//+------------------------------------------------------------------------+
	//|Secao 14 - DESDOBRAMENTO DAS DUPLICATAS                                 |
	//+------------------------------------------------------------------------+
	oDupli := TRSection():New(oSection1,"Contas a Pagar",{"SE2"},/*Ordem*/) //
	oCell := TRCell():New(oDupli,"E2PREFIXO" ,"SE2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	oCell:GetFieldInfo("E2_PREFIXO")
	oCell := TRCell():New(oDupli,"E2NUM"	 ,"SE2")
	oCell:GetFieldInfo("E2_NUM")
	oCell := TRCell():New(oDupli,"E2PARCELA" ,"SE2")
	oCell:GetFieldInfo("E2_PARCELA")
	oCell := TRCell():New(oDupli,"E2VENCTO"	 ,"SE2")
	oCell:GetFieldInfo("E2_VENCTO")
	oCell := TRCell():New(oDupli,"E2VALOR"	 ,"SE2")
	oCell:GetFieldInfo("E2_VALOR")
	oCell := TRCell():New(oDupli,"E2NATUREZ" ,"SE2")
	oCell:GetFieldInfo("E2_NATUREZ")

	//+------------------------------------------------------------------------+
	//|Secao 15 - DEMONSTRATIVO DOS LIVROS FISCAIS                             |
	//+------------------------------------------------------------------------+
	oFisc1 := TRSection():New(oSection1,"Livros Fiscais",{"SF3"},/*Ordem*/) //
	oCell := TRCell():New(oFisc1,"IMP1" 	 ,"SF3"	,"IMP1",/*Picture*/,4,/*lPixel*/,/*{|| code-block de impressao }*/)
	oFisc1:Cell("IMP1"):HideHeader()
	oCell := TRCell():New(oFisc1,"CFOP" 	 ,"SF3")
	oCell:GetFieldInfo("F3_CFOP")
	TRCell():New(oFisc1,"ALIQ" 		,"SF3","Aliq","99")
	TRCell():New(oFisc1,"F3_VALCONT","SF3")
	TRCell():New(oFisc1,"BASEIMP1" ,"SF3","Base de Calculo","@E 999,999,999,999.99") //
	TRCell():New(oFisc1,"VALIMP1" 	,"SF3","Imposto","@E 999,999,999,999.99") //
	TRCell():New(oFisc1,"ISENTAS1" ,"SF3","Isentas","@E 999,999,999,999.99") //
	TRCell():New(oFisc1,"OUTRAS1" 	,"SF3","Outras","@E 999,999,999,999.99") //
	TRCell():New(oFisc1,"OBS1" 	,"SF3","Observacao",,22) //

	//+------------------------------------------------------------------------+
	//|Secao 16 - DEMONSTRATIVO DOS DEMAIS IMPOSTOS - PIS / COFINS             |
	//+------------------------------------------------------------------------+
	oFisc2 := TRSection():New(oSection1,"Demais Impostos",{"SF1"},/*Ordem*/) //
	oCell := TRCell():New(oFisc2,"IMP2"		,"","IMP2",/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
	oFisc2:Cell("IMP2"):HideHeader()
	TRCell():New(oFisc2,"BASEIMP2","","Base de Calculo","@E 999,999,999,999.99") //
	TRCell():New(oFisc2,"VALIMP2" ,"","Imposto","@E 999,999,999,999.99") //

	//+------------------------------------------------------------------------+
	//|Secao 17 - DEMONSTRATIVO DOS LIVROS FISCAIS (LOCALIZADO)                |
	//+------------------------------------------------------------------------+
	oFisc3 := TRSection():New(oSection1,"Livros Fiscais (Localizado)",{"SD1"},/*Ordem*/) //
	oCell := TRCell():New(oFisc3,"PRO3" ,"")
	oCell:GetFieldInfo("D1_COD")
	TRCell():New(oFisc3,"DESC3","","Descricao",,40) //
	TRCell():New(oFisc3,"IMP3"	,"","Imp",,5) //
	TRCell():New(oFisc3,"ALI3"	,"","Aliq",PesqPict("SD1","D1_ALQIMP6")) //
	TRCell():New(oFisc3,"BASEIMP3","","Base de Calculo" ,"@E 999,999,999,999.99") //
	TRCell():New(oFisc3,"VALORIMP3","","Valor do imposto","@E 999,999,999,999.99") //

	//+------------------------------------------------------------------------+
	//|Secao 18 - MENSAGEM FIXA E ASSINATURA                                   |
	//+------------------------------------------------------------------------+
	oReport:SkipLine(4)

	oReport:ThinLine()
	oReport:PrintText("RECEBIMENTO DO(S) MATERIAL(IS) / SERVIÇO(S):")
	oReport:SkipLine()
	oReport:PrintText("Declaro que recebi, da empresa supra citada, o(s) material(is) / serviço(s) e está(ão) de acordo com o solicitado.")
	oReport:SkipLine()
	oReport:SkipLine(5)
	oReport:SkipLine()
	oReport:PrintText("_______________________________________________")
	oReport:SkipLine()
	oReport:PrintText("          Ass. Responsável - Matrícula")
	oReport:SkipLine()
	oReport:ThinLine()

	oReport:HideHeader()

	oEmpresa:SetNoFilter({"SM0"})
	oClient1:SetNoFilter({"SA1"})
	oClient2:SetNoFilter({"SA1"})
	oFornec1:SetNoFilter({"SA2"})
	oFornec2:SetNoFilter({"SA2"})
	oFisc1:SetNoFilter({"SF3"})
	oQuali:SetNoFilter({"SD7"})
	oDivPC:SetNoFilter({"SC7"})
	oDupli:SetNoFilter({"SE2"})
	oNFItem:SetNoFilter({"SB1"})
	oEntCtb:SetNoFilter({"SDE"})

Return(oReport)

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportPrint
Descrição detalhada da função.

@type function
@author Ricardo Berti
@since 04/07/2006
@version P12.1.23

@param oReport, Objeto, Objeto Report do Relatorio.
@param aVencto, Array, Array contendo os vencimentos das duplicatas da NF.
@param aImps, Array, Array c/ bases e valores de impostos (LOCALIZ.).
@param nReg, Numérico, Numero do registro   (ROT.AUT.).
@param cAliasSF1, Caractere, Alias do arquivo SF1.
@param cAliasSD1, Caractere, Alias do arquivo SD1.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ReportPrint(oReport,aVencto,aImps,nReg,cAliasSF1,cAliasSD1)
	LOCAL aAreaSF3	:= SF3->(GetArea())
	LOCAL aAreaSF1	:= SF1->(GetArea())
	LOCAL aAreaSE2	:= SE2->(GetArea())
	LOCAL aAreaSC7	:= SC7->(GetArea())
	Local cAliasSC7 := GetNextAlias()
	Local cAliasSB1 := "SB1"
	Local cAliasSF4 := "SF4"
	Local lQuery	:= .F.
	Local lQuali	:= .T.
	Local lDupli	:= .T.
	Local oSection1	:= oReport:Section(1)
	Local oCabec	:= oReport:Section(1):Section(1)
	Local oEmpresa	:= oReport:Section(1):Section(2)
	Local oFornec1	:= oReport:Section(1):Section(3)
	Local oFornec2	:= oReport:Section(1):Section(4)
	Local oClient1	:= oReport:Section(1):Section(5)
	Local oClient2	:= oReport:Section(1):Section(6)
	Local oNF 		:= oReport:Section(1):Section(7)
	Local oNFItem	:= oReport:Section(1):Section(8)
	Local oEntCtb	:= oReport:Section(1):Section(9)
	Local oQuali	:= oReport:Section(1):Section(10)
	Local oDivPC	:= oReport:Section(1):Section(11)
	Local oNFTot1	:= oReport:Section(1):Section(12)
	Local oNFTot2	:= oReport:Section(1):Section(13)
	Local oDupli	:= oReport:Section(1):Section(14)
	Local oFisc1	:= oReport:Section(1):Section(15)
	Local oFisc2	:= oReport:Section(1):Section(16)
	Local oFisc3	:= oReport:Section(1):Section(17)

	Local aAuxCombo1:= {"N","D","B","I","P","C"}
	Local aCombo1	:= {"Normal            ",;	//"Normal"
	"Devoluçao",;	//"Devoluçao"
	"Beneficiamento",;	//"Beneficiamento"
	"Compl.  ICMS",;	//"Compl.  ICMS"
	"Compl.  IPI",;	//"Compl.  IPI"
	"Compl. Preco/frete"}	//"Compl. Preco/frete"
	Local cLocDest    := GetMV("MV_CQ")
	Local cForMunic   := GetMv("MV_MUNIC")
	Local aTotalNF    := {}
	Local aDivergencia:= {}
	Local aPedidos	  := {}
	Local aDescPed    := {}
	Local aCQ         := {}
	Local aEntCont    := {}
	Local cForAnt     := 0
	Local nDocAnt     := 0
	Local nX          := 0
	Local nImp        := 0
	Local nRecno      := 0
	Local lPedCom     := .F.
	Local cParcIR     := ""
	Local cParcINSS   := ""
	Local cParcISS    := ""
	Local cParcCof    := ""
	Local cParcPis    := ""
	Local cParcCsll   := ""
	Local cParcSest   := ""
	Local cDtEmis     := ""
	Local cPrefixo
	Local aItens      := {}
	Local nBasePis    := 0
	Local nValPis     := 0
	Local nBaseCof    := 0
	Local nValCof     := 0
	Local nCT         := 0
	Local nRec        := 0
	Local i           := 0
	Local nCell
	Local cFornece
	Local cLoja
	Local cDoc
	Local cSerie
	Local nISS
	Local aRelImp     := MaFisRelImp("MT100",{ "SF1" })
	Local lAuto	  := (nReg!=Nil)
	Local lFornIss    := (SE2->(FieldPos("E2_FORNISS")) > 0 .And. SE2->(FieldPos("E2_LOJAISS")) > 0)
	Local cFornIss 	  := ""
	Local cLojaIss    := ""
	Local cRemito     := ""
	Local cItemRem    := ""
	Local cSerieRem   := ""
	Local cFornRem    := ""
	Local cLojaRem    := ""
	Local cCodRem     := ""
	Local cPedido     := ""
	Local cItemPed    := ""
	Local cQuery      := ""



	#IFDEF TOP
	Local cOrderBy
	Local cWhere	:= ""
	#ELSE
	Local cCondicao
	Local cArqIndSD1:= ""
	#ENDIF

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))
	dbSelectArea("SD1")
	SD1->(dbSetOrder(1))
	dbSelectArea("SC7")
	SC7->(dbSetOrder(19))
	dbSelectArea("SC1")
	SC1->(dbSetOrder(1))
	dbSelectArea("SE4")
	SE4->(dbSetOrder(1))

	If lAuto
		dbSelectArea("SF1")
		SF1->(dbGoto(nReg))
	Else
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1))
		//+------------------------------------------------------------------------+
		//|Filtragem do relatorio                                                  |
		//+------------------------------------------------------------------------+
		#IFDEF TOP
		cAliasSF1		:= GetNextAlias()
		cAliasSD1		:= cAliasSF1
		cAliasSB1		:= cAliasSF1
		cAliasSF4		:= cAliasSF1
		//+------------------------------------------------------------------------+
		//|Transforma parametros Range em expressao SQL                            |
		//+------------------------------------------------------------------------+
		MakeSqlExpr(oReport:uParam)

		lQuery := .T.

		cWhere := "% AND NOT ("+IsRemito(3,'F1_TIPODOC')+ ")%"

		If mv_par07 == 1
			cOrderBy := "%F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,D1_ITEM%"
		Else
			cOrderBy := "%F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,D1_COD,D1_ITEM%"
		EndIf
		//+------------------------------------------------------------------------+
		//|Query do relatorio da secao 1                                           |
		//+------------------------------------------------------------------------+
		oSection1:BeginQuery()

		BeginSql Alias cAliasSF1

			SELECT SF1.F1_FILIAL,  SF1.F1_DOC,     SF1.F1_SERIE,   SF1.F1_FORNECE, SF1.F1_LOJA,   SF1.F1_DTDIGIT, SF1.F1_TIPO,
			SF1.F1_ESPECIE, SF1.F1_EMISSAO, SF1.F1_PREFIXO, SF1.F1_ISS,     SF1.F1_VALBRUT,SF1.F1_BASEICM, SF1.F1_VALICM,
			SF1.F1_BRICMS,  SF1.F1_ICMSRET, SF1.F1_VALMERC, SF1.F1_DESCONT, SF1.F1_FRETE,  SF1.F1_SEGURO,  SF1.F1_DESPESA,
			SF1.F1_VALIPI,  SF1.F1_VALBRUT, SF1.F1_TIPODOC,
			SD1.D1_FILIAL,  SD1.D1_DOC,     SD1.D1_SERIE,   SD1.D1_FORNECE, SD1.D1_LOJA,   SD1.D1_ITEM,    SD1.D1_TES,
			SD1.D1_PEDIDO,  SD1.D1_ITEMPC,  SD1.D1_QTDPEDI, SD1.D1_QUANT,   SD1.D1_VUNIT,  SD1.D1_DTDIGIT,
			SD1.D1_NUMCQ,   SD1.D1_UM,      SD1.D1_LOCAL,   SD1.D1_TOTAL,   SD1.D1_IPI,    SD1.D1_IPI,     SD1.D1_PICM,
			SD1.D1_CONTA,   SD1.D1_CC,      SD1.D1_CF,      SD1.D1_CUSTO,   SD1.D1_RATEIO, SD1.D1_ITEMCTA, SD1.D1_CLVL,
			SD1.D1_NUMSEQ,  SD1.D1_EMISSAO, SD1.D1_COD,
			SB1.B1_COD,     SB1.B1_DESC,    SF4.F4_ESTOQUE, 	SD1.D1_REMITO,  SD1.D1_ITEMREM, SD1.D1_SERIREM

			FROM  %table:SF1% SF1, %table:SB1% SB1, %table:SD1% SD1
			LEFT JOIN %table:SF4% SF4
			ON  SF4.F4_FILIAL    = %xFilial:SF4%	 	AND
			SF4.F4_CODIGO	   = SD1.D1_TES 		AND
			SF4.%NotDel%

			WHERE SF1.F1_FILIAL    = %xFilial:SF1%	 	AND
			SF1.F1_DTDIGIT  >= %Exp:Dtos(mv_par01)% AND
			SF1.F1_DTDIGIT  <= %Exp:Dtos(mv_par02)% AND
			SF1.F1_DOC      >= %Exp:mv_par03%		AND
			SF1.F1_DOC      <= %Exp:mv_par04%	 	AND
			SD1.D1_FILIAL    = %xFilial:SD1%	 	AND
			SD1.D1_DOC	   = SF1.F1_DOC 		AND
			SD1.D1_SERIE     = SF1.F1_SERIE		AND
			SD1.D1_FORNECE   = SF1.F1_FORNECE	    AND
			SD1.D1_LOJA      = SF1.F1_LOJA	    AND
			SB1.B1_FILIAL    = %xFilial:SB1%	 	AND
			SB1.B1_COD	   = SD1.D1_COD 		AND
			SB1.%NotDel%						 	AND
			SD1.%NotDel%						 	AND
			SF1.%NotDel%
			%Exp:cWhere%

			ORDER BY %Exp:cOrderBy%

		EndSql
		oSection1:EndQuery()

		oNF:SetParentQuery()
		oNFItem:SetParentQuery()

		#ELSE

		//+------------------------------------------------------------------------+
		//|Transforma parametros Range em expressao SQL                            |
		//+------------------------------------------------------------------------+
		MakeAdvplExpr(oReport:uParam)

		cCondicao := "F1_FILIAL == '"	 +xFilial("SF1")	+"'.And."
		cCondicao += "Dtos(F1_DTDIGIT) >= '"+Dtos(mv_par01)	+"'.And."
		cCondicao += "Dtos(F1_DTDIGIT)<='"	+Dtos(MV_PAR02)	+"'.And."
		cCondicao += "F1_DOC >= '"  	   	+MV_PAR03		+"'.And."
		cCondicao += "F1_DOC <= '"  		+MV_PAR04		+"'.And."
		cCondicao += "!("+IsRemito(2,'SF1->F1_TIPODOC')+")"

		oSection1:SetFilter(cCondicao,IndexKey())
		If mv_par07 == 1
			//+------------------------------------------------------------------------+
			//| Novo Indice para pesquisa do SD1.                                      |
			//+------------------------------------------------------------------------+
			cArqIndSD1 := CriaTrab(,.F.)
			IndRegua( "SD1", cArqIndSD1, "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM" )
			//nOrderSD1 := RetIndex("SD1") + 1
			SD1->( dbSetIndex( cArqIndSD1 + OrdBagExt() ) )
		EndIf

		#ENDIF

	EndIf

	If !lQuery
		TRPosition():New(oNFItem,"SB1",1,{|| xFilial("SB1")+(cAliasSD1)->D1_COD })
	EndIf

	//+------------------------------------------------------------------------+
	//|Inicio da impressao do fluxo do relatorio                               |
	//+------------------------------------------------------------------------+
	If !lAuto .And. !lQuery .And. !Empty(mv_par03)
		(cAliasSF1)->(dbSeek(xFilial("SF1")+mv_par03,.T.))
	ElseIf !lAuto
		(cAliasSF1)->(dbGoTop())
	EndIf

	oReport:SetMeter(SF1->(LastRec()))

	If mv_par06 == 2
		oNFItem:Cell("D1_CUSTO"):SetTitle("Custo Unit. ") //
	EndIf
	If mv_par08 == 1
		oNFItem:Cell("B1_DESC"):SetSize(17)
	Else
		oNFItem:Cell("D1_LOCAL"):Disable()
	EndIf
	oNFItem:Cell("B1_DESC"):SetLineBreak()

	If cPaisLoc=="BRA"
		oNFItem:Cell("D1_TOTAL"):SetSize(12)
	Else
		oNFItem:Cell("D1_IPI"):Disable()
		oNFItem:Cell("D1_PICM"):Disable()
	EndIf
	If mv_par05 == 1
		oNFItem:Cell("D1_CC"):Disable()
	ElseIf mv_par05 == 2
		oNFItem:Cell("D1_CONTA"):Disable()
	Else
		oNFItem:Cell("D1_CONTA"):Disable()
		oNFItem:Cell("D1_CC"):Disable()
	EndIf
	dbSelectArea(cAliasSF1)

	While !oReport:Cancel() .And. !(cAliasSF1)->(Eof()) .And. ;
	(cAliasSF1)->F1_FILIAL == xFilial("SF1") .And. (cAliasSF1)->F1_DOC <= MV_PAR04
		If oReport:Cancel()
			Exit
		EndIf

		If (lAuto .And. (cAliasSF1)->(Recno()) <> nReg)
			(cAliasSF1)->(dbSkip())
			Loop
		EndIf

		oSection1:Init(.f.)
		oReport:IncMeter()

		If !lQuery
			dbSelectArea("SD1")
			SD1->(dbSeek(xFilial("SD1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
		Else
			dbSelectArea("SF1")
			SD1->(dbSeek(xFilial("SF1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
		EndIf
		//+-----------------------------------------------------------------+
		//|Definicao do titulo do relatorio - muda a cada nota				|
		//+-----------------------------------------------------------------+
		oReport:SetTitle("Boletim de Entrada"+" "+(cAliasSD1)->D1_NUMSEQ)

		aImps		 := {}
		aItens		 := {}
		aDivergencia := {}
		aPedidos     := {}
		aDescPed     := {}
		aEntCont     := {}
		aCQ			 := {}
		aVencto		 := {}
		aTotalNF	 := {}
		// Totais da NF
		aAdd(aTotalNF,(cAliasSF1)->F1_BASEICM)
		aAdd(aTotalNF,(cAliasSF1)->F1_VALICM)
		aAdd(aTotalNF,(cAliasSF1)->F1_ICMSRET)
		aAdd(aTotalNF,(cAliasSF1)->F1_VALMERC)
		aAdd(aTotalNF,(cAliasSF1)->F1_DESCONT)
		aAdd(aTotalNF,(cAliasSF1)->F1_FRETE)
		aAdd(aTotalNF,(cAliasSF1)->F1_SEGURO)
		aAdd(aTotalNF,(cAliasSF1)->F1_DESPESA)
		aAdd(aTotalNF,(cAliasSF1)->F1_VALIPI)
		aAdd(aTotalNF,(cAliasSF1)->F1_VALBRUT)
		If cPaisLoc <> "BRA"
			aImps	:= R170IMPT(cAliasSF1)
			aItens	:= R170IMPI(cAliasSF1)
		EndIf
		// Variaveis do cabecalho da NF
		cFornece := (cAliasSF1)->F1_FORNECE
		cLoja	 := (cAliasSF1)->F1_LOJA
		cDoc	 := (cAliasSF1)->F1_DOC
		cPrefixo := If(Empty((cAliasSF1)->F1_PREFIXO),&(GetMV("MV_2DUPREF")),(cAliasSF1)->F1_PREFIXO)
		cSerie	 := (cAliasSF1)->F1_SERIE
		cDtEmis  := (cAliasSF1)->F1_EMISSAO
		nISS	 := (cAliasSF1)->F1_ISS
		nBasePis := 0
		nValPis  := 0
		nBaseCof := 0
		nValCof  := 0
		If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_BASEPS2"} ) )
			If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2])))
				nBasePis := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2]) ) ) )
			EndIf
		EndIf
		If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_VALPS2"} ) )
			If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2])))
				nValPis := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2]) ) ) )
			EndIf
		EndIf
		If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_BASECF2"} ) )
			If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2])))
				nBaseCof := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2]) ) ) )
			EndIf
		EndIf
		If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_VALCF2"} ) )
			If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2])))
				nValCof := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2]) ) ) )
			EndIf
		EndIf
		//+------------------------------------------------------------------------+
		//|Cabecalho 			  	                                        	   |
		//+------------------------------------------------------------------------+
		oCabec:Init(.F.)
		oCabec:PrintLine()
		oCabec:Finish()
		oReport:FatLine()
		//+------------------------------------------------------------------------+
		//|Dados do Boletim		  	                                        	   |
		//+------------------------------------------------------------------------+
		oSection1:PrintLine()
		//+------------------------------------------------------------------------+
		//|Dados da Empresa		  	                                        	   |
		//+------------------------------------------------------------------------+
		oEmpresa:Init(.f.)
		oEmpresa:PrintLine()
		oEmpresa:Finish()
		oReport:FatLine()

		If (cAliasSF1)->F1_TIPO $ "DB"
			dbSelectArea("SE1")
			SE1->(dbSetOrder(2))
			SE1->(dbSeek(xFilial("SE1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC))
			While SE1->(!Eof()) .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM == ;
			xFilial("SE1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC
				If ALLTRIM(E1_ORIGEM)=="MATA100"
					aADD(aVencto,E1_VENCREA)
				EndIf
				SE1->(dbSkip())
			EndDo

			oReport:PrintText("Dados do Cliente") //
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
			oClient1:Init(.F.)
			oClient1:PrintLine()
			oClient2:Init(.F.)
			oClient2:PrintLine()
			oClient2:Finish()
			oClient1:Finish()
		Else
			dbSelectArea("SE2")
			SE2->(dbSetOrder(6))
			SE2->(dbSeek(xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC))
			While SE2->(!Eof()) .And. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == ;
			xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC
				If ALLTRIM(E2_ORIGEM)=="MATA100"
					aADD(aVencto,E2_VENCTO)
				EndIf
				SE2->(dbSkip())
			EndDo

			oReport:PrintText("Dados do Fornecedor") //
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
			nCell := Len(AllTrim(RetTitle("A2_CGC"))+': '+If(cPaisLoc<>"BRA",Transform(SA2->A2_CGC,PesqPict("SA2","A2_CGC")),Transform(SA2->A2_CGC,PicPesFJ(If(Len(AllTrim(SA2->A2_CGC))<14,"F","J")))))
			oFornec1:Init(.f.)
			oFornec1:PrintLine()
			oFornec2:Init(.f.)
			oFornec2:PrintLine()
			oFornec2:Finish()
			oFornec1:Finish()
		EndIf
		oReport:FatLine()
		//+--------------------------------------------------------------+
		//| Impressao do cabecalho da Nota de Entrada                    |
		//+--------------------------------------------------------------+
		oReport:SkipLine()
		oReport:PrintText("------------------------------------------------------- DADOS DA NOTA FISCAL -------------------------------------------------------") //
		oNF:Init(.t.)
		oNF:Cell("F1_TIPO"):SetValue(aCombo1[aScan(aAuxCombo1,(cAliasSF1)->F1_TIPO)])
		oNF:PrintLine()
		//+--------------------------------------------------------------+
		//| Impressao dos itens da Nota de Entrada                       |
		//+--------------------------------------------------------------+
		dbSelectArea(cAliasSD1)
		nDocAnt := D1_DOC+D1_SERIE
		cForAnt := D1_FORNECE+D1_LOJA

		oNFItem:Init(.t.)
		While (!oReport:Cancel() .And. (cAliasSD1)->(!Eof()) .And. (cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE == nDocAnt .And.;
		cForAnt == (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA .And. (cAliasSD1)->D1_FILIAL == xFilial("SD1") )
			If oReport:Cancel()
				Exit
			EndIf
			aArea := GetArea()
			If !lQuery
				dbSelectArea("SF4")
				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))
			EndIf
			cPedido  := (cAliasSD1)->D1_PEDIDO
			cItemPed := (cAliasSD1)->D1_ITEMPC

			If cPaisLoc <> "BRA" .And. !Empty((cAliasSD1)->D1_REMITO)
				cRemito   := (cAliasSD1)->D1_REMITO
				cItemRem  := (cAliasSD1)->D1_ITEMREM
				cSerieRem := (cAliasSD1)->D1_SERIREM
				cFornRem  := (cAliasSD1)->D1_FORNECE
				cLojaRem  := (cAliasSD1)->D1_LOJA
				cCodRem	  := (cAliasSD1)->D1_COD

				dbSelectArea("SD1")
				SD1->(dbSetOrder(1))
				If SD1->(dbSeek(xFilial("SD1")+cRemito+cSerieRem+cFornRem+cLojaRem+cCodRem+Alltrim(cItemRem)))
					If !Empty(SD1->D1_PEDIDO)
						cPedido   := SD1->D1_PEDIDO
						cItemPed  := SD1->D1_ITEMPC
					Endif
				Endif
				RestArea(aArea)
			Endif

			dbSelectArea("SC7")
			SC7->(dbSetOrder(19))
			SC7->(dbSeek(xFilial("SC7")+(cAliasSD1)->D1_COD+cPedido+cItemPed))
			If Empty(SC7->C7_NUM)
				aADD(aDivergencia,"Err") //
				aADD(aPedidos,{"","Sem Pedido de Compra","","","","","","","","",""}) //
			Else
				_C7_XFILCOM  := SC7->C7_XFILCOM
				_C7_CONTRA   := SC7->C7_CONTRA
				_C7_CONTREV  := SC7->C7_CONTREV
				_C7_MEDICAO  := SC7->C7_MEDICAO
				_D1_DOC      := ALLTRIM(STR(VAL((cAliasSD1)->D1_DOC)))
				_D1_ITEMCTA  := (cAliasSD1)->D1_ITEMCTA
				_D1_EMISSAO  := dTos((cAliasSD1)->D1_EMISSAO)
				dbSelectArea("SC1")
				SC1->(dbSetOrder(2))
				SC1->(dbSeek(xFilial("SC1")+SC7->C7_PRODUTO+SC7->C7_NUMSC+SC7->C7_ITEMSC))
				dbSelectArea("SE4")
				SE4->(dbSetOrder(1))
				SE4->(dbSeek(xFilial("SE4")+SC7->C7_COND))
				lPedCom := !Empty(IF(SC7->C7_TIPO == 1,SubStr(SC1->C1_SOLICIT,1,15), SubStr(UsrFullName(SC7->C7_USER),1,15))+SC7->C7_CC)
				cProblema := ""
				If ( (cAliasSD1)->D1_QTDPEDI > 0 .And. (SC7->C7_QUANT <> (cAliasSD1)->D1_QTDPEDI) ) .Or. ;
				SC7->C7_QUANT <> (cAliasSD1)->D1_QUANT
					cProblema += "Q"
				Else
					cProblema += " "
				EndIf
				If (SC7->C7_QUANT - SC7->C7_QUJE) < (cAliasSD1)->D1_QUANT  .AND. (cAliasSD1)->D1_TES == "   "
					n_proc1 :=-((cAliasSD1)->D1_QUANT - (SC7->C7_QUANT - SC7->C7_QUJE)) / SC7->C7_QUANT * 100
				EndIf
				If (cAliasSD1)->D1_TES != "   " .AND. (SC7->C7_QUANT - SC7->C7_QUJE) < 0
					N_PORC1 :=-(SC7->C7_QUANT - SC7->C7_QUJE) / SC7->C7_QUANT * 100
				EndIf
				If If(Empty(SC7->C7_REAJUSTE),SC7->C7_PRECO,Formula(SC7->C7_REAJUSTE)) # (cAliasSD1)->D1_VUNIT
					If SC7->C7_MOEDA <> 1
						cProblema := cProblema+"M"
					Else
						cProblema := cProblema+"P"
					EndIf
				Else
					cProblema := cProblema+" "
				EndIf
				If SC7->C7_DATPRF <> (cAliasSD1)->D1_DTDIGIT
					cProblema := cProblema+"E"
				Else
					cProblema := cProblema+" "
				EndIf
				If !Empty(cProblema)
					aADD(aDivergencia,cProblema)
				Else
					aADD(aDivergencia,"Ok ")
				Endif
				aADD(aPedidos,{SC7->C7_NUM+"/"+SC7->C7_ITEM,;
				SC7->C7_DESCRI,;
				TransForm(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT",11)),;
				TransForm(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO",13)),;
				DTOC(SC7->C7_EMISSAO),;
				DTOC(SC7->C7_DATPRF),;
				SC7->C7_NUMSC+"/"+SC7->C7_ITEMSC,;
				If(lPedCom,IF(SC7->C7_TIPO == 1,SubStr(SC1->C1_SOLICIT,1,15), SubStr(UsrFullName(SC7->C7_USER),1,15)),"") ,;
				If(lPedCom,SC7->C7_CC,""),;
				AllTrim(SE4->E4_DESCRI),;
				TransForm(SC7->C7_QUANT,PesqPict("SC7","C7_QUJE",11)) }	)
			Endif
			If !Empty((cAliasSD1)->D1_NUMCQ) .AND. (cAliasSF4)->F4_ESTOQUE == "S"
				AADD(aCQ,(cAliasSD1)->D1_NUMCQ+(cAliasSD1)->D1_COD+cLocDest+"001"+Dtos((cAliasSD1)->D1_DTDIGIT))
			Endif
			dbSelectArea(cAliasSD1)
			oNFItem:PrintLine()

			// Entidades Contabeis
			If ( mv_par05 == 3 )
				If ( (cAliasSD1)->D1_RATEIO == "1" )
					dbSelectArea("SDE")
					SDE->(dbSetOrder(1))
					If SDE->(MsSeek(xFilial("SDE")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM))
						While SDE->(!Eof()) .And. DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF ==;
						xFilial("SDE")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM
							aAdd(aEntCont,{SDE->DE_ITEMNF,SDE->DE_ITEM,Transform(SDE->DE_PERC,"@E 999.99"),SDE->DE_CC,SDE->DE_CONTA,SDE->DE_ITEMCTA,SDE->DE_CLVL})
							SDE->(dbSkip())
						EndDo
					EndIf
				Else
					If !Empty((cAliasSD1)->D1_CC) .Or. !Empty((cAliasSD1)->D1_CONTA) .Or. !Empty((cAliasSD1)->D1_ITEMCTA)
						aAdd(aEntCont,{(cAliasSD1)->D1_ITEM," - ","   -  ",(cAliasSD1)->D1_CC,(cAliasSD1)->D1_CONTA,(cAliasSD1)->D1_ITEMCTA,(cAliasSD1)->D1_CLVL})
					EndIf
				EndIf
			EndIf
			dbSelectArea(cAliasSD1)
			(cAliasSD1)->(dbSkip())
		EndDo
		oNFItem:Finish()
		oNF:Finish()
		oReport:FatLine()
		//+-----------------------------+
		//| Imprime Entidades Contabeis |
		//+-----------------------------+
		If Len(aEntCont) > 0
			oReport:SkipLine()
			oReport:PrintText("------------------------------------------------------- ENTIDADES CONTABEIS --------------------------------------------------------")  //"------------------------------------------------------- ENTIDADES CONTABEIS ---------------------------------------------------------"
			oEntCtb:Init()
			For nX:=1 to Len(aEntCont)
				oEntCtb:Cell("DEITEMNF"):SetValue(aEntCont[nX][1])
				oEntCtb:Cell("DEITEM"):SetValue(aEntCont[nX][2])
				oEntCtb:Cell("DEPERC"):SetValue(aEntCont[nX][3])
				oEntCtb:Cell("DECC"):SetValue(aEntCont[nX][4])
				oEntCtb:Cell("DECONTA"):SetValue(aEntCont[nX][5])
				oEntCtb:Cell("DEITEMCTA"):SetValue(aEntCont[nX][6])
				oEntCtb:Cell("DECLVL"):SetValue(aEntCont[nX][7])
				oEntCtb:PrintLine()
			Next
			oEntCtb:Finish()
			oReport:FatLine()
		EndIf
		//+--------------------------------------------------------------+
		//| Imprime produtos enviados ao Controle de Qualidade SD7       |
		//+--------------------------------------------------------------+
		If Len(aCQ) > 0
			oReport:SkipLine()
			oReport:PrintText("------------------------------------------- PRODUTO(s) ENVIADO(s) AO CONTROLE DE QUALIDADE -----------------------------------------")//
			lFirst := .T.
			For nX:=1 to Len(aCQ)
				dbSelectArea("SD7")
				SD7->(dbSetOrder(1))
				If SD7->(dbSeek(xFilial("SD7")+aCQ[nX]))
					If lFirst
						oQuali:Init()
						lFirst := .F.
						lQuali := .T.
					EndIf
					oQuali:Cell("D7PRODUTO"):SetValue(SD7->D7_PRODUTO)
					oQuali:Cell("D7LOCAL"):SetValue(SD7->D7_LOCAL)
					oQuali:Cell("D7LOCDEST"):SetValue(SD7->D7_LOCDEST)
					oQuali:Cell("D7DATA"):SetValue(SD7->D7_DATA)
					oQuali:Cell("D7NUMERO"):SetValue(SD7->D7_NUMERO)
					oQuali:PrintLine()
				EndIf
			Next
			If lQuali
				oQuali:Finish()
				oReport:FatLine()
			EndIf
		EndIf
		//+--------------------------------------------------------------+
		//| Imprime Divergencia com Pedido de Compra                     |
		//+--------------------------------------------------------------+
		If !Empty(aPedidos) .And. !Empty(aDivergencia)
			oReport:SkipLine()
			oReport:PrintText("--------------------------------------------- DIVERGENCIAS COM O PEDIDO DE COMPRA --------------------------------------------------")  //
			oDivPC:Init()
			For nX := 1 To Len(aPedidos)
				oDivPC:Cell("DivPC"):SetValue(aDivergencia[nX])
				oDivPC:Cell("C7NUM"):SetValue(aPedidos[nX][1])
				oDivPC:Cell("C7DESCRI"):SetValue(aPedidos[nX][2])
				oDivPC:Cell("C7QUJE"):SetValue(aPedidos[nX][11])
				oDivPC:Cell("C7QUANT"):SetValue(aPedidos[nX][3])
				oDivPC:Cell("C7PRECO"):SetValue(aPedidos[nX][4])
				oDivPC:Cell("C7EMISSAO"):SetValue(aPedidos[nX][5])
				oDivPC:Cell("C7DATPRF"):SetValue(aPedidos[nX][6])
				oDivPC:Cell("C7NUMSC"):SetValue(aPedidos[nX][7])
				oDivPC:Cell("C1SOLICIT"):SetValue(aPedidos[nX][8])
				oDivPC:Cell("C1CC"):SetValue(aPedidos[nX][9])
				oDivPC:Cell("E4DESCRI"):SetValue(aPedidos[nX][10])
				oDivPC:PrintLine()
			Next
			oDivPC:Finish()
			oReport:FatLine()
		EndIf
		//+--------------------------------------------------------------+
		//| Imprime Totais da Nota Fiscal                                |
		//+--------------------------------------------------------------+
		oReport:SkipLine()
		oReport:PrintText("------------------------------------------------------- TOTAIS DA NOTA FISCAL ------------------------------------------------------") //
		oNFTot1:Init()
		If cPaisLoc=="BRA"
			oNFTot1:Cell("F1_BASEICM"):SetValue(aTotalNF[1])
			oNFTot1:Cell("F1_VALICM"):SetValue(aTotalNF[2])
			oNFTot1:Cell("F1_ICMSRET"):SetValue(aTotalNF[3])
		EndIf
		oNFTot1:Cell("F1_VALMERC"):SetValue(aTotalNF[4])
		oNFTot1:Cell("F1_DESCONT"):SetValue(aTotalNF[5])
		oNFTot1:PrintLine()
		oReport:ThinLine()
		oNFTot2:Init()
		oNFTot2:Cell("F1_FRETE"):SetValue(aTotalNF[6])
		oNFTot2:Cell("F1_SEGURO"):SetValue(aTotalNF[7])
		oNFTot2:Cell("F1_DESPESA"):SetValue(aTotalNF[8])
		If cPaisLoc=="BRA"
			oNFTot2:Cell("F1_VALIPI"):SetValue(aTotalNF[9])
		EndIf
		oNFTot2:Cell("F1_VALBRUT"):SetValue(aTotalNF[10])
		oNFTot2:PrintLine()
		oNFTot2:Finish()
		oNFTot1:Finish()
		oReport:FatLine()

		//+--------------------------------------------------------------+
		//| Imprime desdobramento de Duplicatas                          |
		//+--------------------------------------------------------------+
		dbSelectArea("SE2")
		SE2->(dbSetOrder(6))

		//+--------------------------------------------------------------+
		//| Carrega array conforme parâmetros                            |
		//+--------------------------------------------------------------+
		If nCT == 0
			aFornece := {{cFornece,cLoja,PadR(MVNOTAFIS,Len(SE2->E2_TIPO))},;
			{PadR(GetMv('MV_UNIAO')        ,Len(SE2->E2_FORNECE)),PadR(Replicate('0',Len(SE2->E2_LOJA)),Len(SE2->E2_LOJA)),PadR(MVTAXA,Len(SE2->E2_TIPO)) },;
			{PadR(GetMv('MV_FORINSS')      ,Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR(MVINSS,Len(SE2->E2_TIPO))},;
			{PadR(GetMv('MV_MUNIC')        ,Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR(MVISS ,Len(SE2->E2_TIPO))} }

			If SE2->(FieldPos("E2_PARCSES")) > 0
				aadd(aFornece,{PadR(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)),PadR(IIf(SubStr(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)+1)<>"",SubStr(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)+1),"00"),Len(SE2->E2_LOJA)),PadR('SES',Len(SE2->E2_TIPO)),"E2_PARCSES",{ || .T. }})
			EndIf
			nCT+=1
		EndIf

		If SE2->(dbSeek(xFilial("SE2")+cFornece+cLoja+cPrefixo+cDoc))
			nRec:=RECNO()
			oReport:SkipLine()
			oReport:PrintText("--------------------------------------------------- DESDOBRAMENTO DE DUPLICATAS ----------------------------------------------------")//
			oDupli:Init()

			//Verifica se o Fornecedor do Titulo ja existe no aFornec //
			IF SE2->(dbSeek(xFilial("SE2")+cForMunic))
				While SE2->(!Eof()).and. alltrim(SE2->E2_FORNECE) == alltrim(cForMunic)
					IF Ascan(aFornece,{|x| (alltrim(x[1])+alltrim(x[2])) == (alltrim(cForMunic)+alltrim(SE2->E2_LOJA))}) = 0
						aAdd(aFornece, {PadR(GetMv('MV_MUNIC'),Len(SE2->E2_FORNECE)),SE2->E2_LOJA,PadR(MVISS ,Len(SE2->E2_TIPO))} )
					EndIf
					SE2->(DBSkip())
				EndDo
			EndIF
			SE2->(dbGoto(nRec))

			While SE2->(!Eof()) .And. xFilial('SE2')+aFornece[1][1]+aFornece[1][2]+cPrefixo+cDoc==;
			E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM

				If SE2->E2_TIPO == aFornece[1,3]

					R170DupTR(oReport)
					cParcCSS := SE2->E2_PARCCSS
					cParcIR  := SE2->E2_PARCIR
					cParcINSS:= SE2->E2_PARCINS
					cParcISS := SE2->E2_PARCISS
					cParcCof := SE2->E2_PARCCOF
					cParcPis := SE2->E2_PARCPIS
					cParcCsll:= SE2->E2_PARCSLL
					cParcSest:= IIf(SE2->(FieldPos("E2_PARCSES"))>0,SE2->E2_PARCSES,"")
					If lFornIss .And. !Empty(SE2->E2_FORNISS) .And. !Empty(SE2->E2_LOJAISS)
						cFornIss := SE2->E2_FORNISS
						cLojaIss := SE2->E2_LOJAISS
					Else
						cFornIss := aFornece[4,1]
						cLojaIss :=	aFornece[4,2]
					Endif

					nRecno   := SE2->(Recno())

					dbSelectArea('SE2')
					SE2->(dbSetOrder(1))
					If (!Empty(cParcIR)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcIR+aFornece[2,3]+aFornece[2,1]+aFornece[2,2]))
						R170DupTR(oReport)
					Endif
					If (!Empty(cParcINSS)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcINSS+aFornece[3,3]))
						R170DupTR(oReport)
					Endif

					For i=1 to Len(aFornece)
						If AllTrim(aFornece[i,1])==alltrim(cForMunic)
							If (!Empty(cParcISS)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcISS+aFornece[i,3]+cFornIss+aFornece[i,2]))
								IF cDtEmis == SE2->E2_EMISSAO
									R170DupTR(oReport)
								EndIf
							EndIf
						EndIf
					Next i

					If (!Empty(cParcCof)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcCof+aFornece[2,3]))
						R170DupTR(oReport)
					Endif
					If (!Empty(cParcPis)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcPis+aFornece[2,3]))
						R170DupTR(oReport)
					Endif
					If (!Empty(cParcCsll)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcCsll+aFornece[2,3]))
						R170DupTR(oReport)
					Endif

					If (!Empty(cParcCSS)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcCSS+aFornece[2,3]))
						While SE2->(!Eof()) .And. xFilial('SE2')+cPrefixo+cDoc+cParcCSS+aFornece[2,3] ==;
						SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO

							If PadR(GetMv('MV_CSS'),Len(SE2->E2_NATUREZ)) == SE2->E2_NATUREZ
								R170DupTR(oReport)
							EndIf

							dbSelectArea('SE2')
							SE2->(dbSetOrder(1))
							SE2->(dbSkip())
						EndDo
					Endif
					If (!Empty(cParcSest)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcSest+aFornece[5,3]))
						R170DupTR(oReport)
					Endif

					SE2->(dbGoto(nRecno))

				EndIf

				dbSelectArea('SE2')
				SE2->(dbSetOrder(6))
				SE2->(dbSkip())
			EndDo
			oDupli:Finish()
			oReport:FatLine()
		Endif
		//+--------------------------------------------------------------+
		//| Imprime Dados dos Livros Fiscais                             |
		//+--------------------------------------------------------------+
		If cPaisloc=="BRA"
			dbSelectArea("SF3")
			SF3->(dbSetOrder(4))
			If SF3->(dbSeek(xFilial("SF3")+cFornece+cLoja+cDoc+cSerie))
				lFirst := .T.
				While SF3->(! Eof()) .And. xFilial("SF3")+cFornece+cLoja+cDoc+cSerie==F3_FILiAL+F3_CLiEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

					If Val(Substr(SF3->F3_CFO,1,1))<5

						If lFirst
							oReport:SkipLine()
							oReport:PrintText("----------------------------------------------- DEMONSTRATIVO DOS LIVROS FISCAIS ---------------------------------------------------") //
							oFisc1:Init(.t.)
							lFirst := .F.
						EndIf
						oFisc1:Cell("IMP1"):SetValue(If(!Empty(nISS) .And. SF3->F3_TIPO == "S" ,"ISS","ICMS")) //##
						oFisc1:Cell("CFOP"):SetValue(SF3->F3_CFO)
						oFisc1:Cell("ALIQ"):SetValue(SF3->F3_ALIQICM)
						oFisc1:Cell("BASEIMP1"):SetValue(SF3->F3_BASEICM)
						oFisc1:Cell("VALIMP1"):SetValue(SF3->F3_VALICM)
						oFisc1:Cell("ISENTAS1"):SetValue(SF3->F3_ISENICM)
						oFisc1:Cell("OUTRAS1"):SetValue(SF3->F3_OUTRICM)
						oFisc1:Cell("OBS1"):SetValue("")
						oFisc1:PrintLine()
						If !Empty(SF3->F3_ICMSRET)
							oReport:PrintText("RET  "+Transform(SF3->F3_ICMSRET,"@E 9,999,999,999.99"), oReport:Row() ,oFisc1:Cell("OBS1"):ColPos() ) //
							oReport:SkipLine()
						Endif
						If !EMPTY(SF3->F3_ICMSCOM)
							oReport:PrintText("Compl"+Transform(SF3->F3_ICMSCOM,"@E 9,999,999,999.99"), oReport:Row() ,oFisc1:Cell("OBS1"):ColPos() ) //
							oReport:SkipLine()
						Endif
						If !Empty(SF3->F3_BASEIPI) .Or. !Empty(SF3->F3_ISENIPI) .Or. !Empty(SF3->F3_OUTRIPI)
							oFisc1:Cell("IMP1"):SetValue("IPI") //
							oFisc1:Cell("CFOP"):SetValue("")
							oFisc1:Cell("ALIQ"):SetValue("")
							oFisc1:Cell("BASEIMP1"):SetValue(SF3->F3_BASEIPI)
							oFisc1:Cell("VALIMP1"):SetValue(SF3->F3_VALIPI)
							oFisc1:Cell("ISENTAS1"):SetValue(SF3->F3_ISENIPI)
							oFisc1:Cell("OUTRAS1"):SetValue(SF3->F3_OUTRIPI)
							oFisc1:Cell("OBS1"):SetValue("")
							oFisc1:PrintLine()
						Endif
						If ! Empty(SF3->F3_VALOBSE)
							oReport:PrintText("OBS. "+Transform(SF3->F3_VALOBSE,"@E 9,999,999,999.99"), oReport:Row() ,oFisc1:Cell("OBS1"):ColPos() ) //
							oReport:SkipLine()
						Endif
					Endif

					SF3->(dbSkip())
				EndDo
				If ! lFirst
					oFisc1:Finish()
					oReport:FatLine()
				EndIf

			EndIf
			//+--------------------------------------------------------------+
			//| Imprime Dados dos Demais Impostos                            |
			//+--------------------------------------------------------------+
			oReport:SkipLine()
			If !Empty(nValPis) .Or. !Empty(nValCof)
				oReport:PrintText("----------------------------------------------- DEMONSTRATIVO DOS DEMAIS IMPOSTOS --------------------------------------------------") //  "----------------------------------------------- DEMONSTRATIVO DOS DEMAIS IMPOSTOS ---------------------------------------------------"
				oFisc2:Init(.t.)
				If !Empty(nValPis)
					//+--------------------------------------------------------------+
					//| Imprime Dados ref ao PIS                                     |
					//+--------------------------------------------------------------+
					oFisc2:Cell("IMP2"):SetValue("PIS APURACAO") //
					oFisc2:Cell("BASEIMP2"):SetValue(nBasePis)
					oFisc2:Cell("VALIMP2"):SetValue(nValPis)
					oFisc2:PrintLine()
				Endif
				//+--------------------------------------------------------------+
				//| Imprime Dados ref ao COFINS                                  |
				//+--------------------------------------------------------------+
				If !Empty(nValCof)
					oFisc2:Cell("IMP2"):SetValue("COFINS APURACAO") //
					oFisc2:Cell("BASEIMP2"):SetValue(nBaseCof)
					oFisc2:Cell("VALIMP2"):SetValue(nValCof)
					oFisc2:PrintLine()
				Endif
				oFisc2:Finish()
				oReport:FatLine()
			EndIf
		Else
			If Len(aItens[1])>=0
				oReport:SkipLine()
				oReport:PrintText("-----------------------------------------------   RELACAO DE IMPOSTOS POR ITEM   ---------------------------------------------------") //
				oFisc3:Init(.t.)
				For nImp:=1 to Len(aItens)
					oFisc3:Cell("PRO3"):SetValue(aItens[nImp][1])
					oFisc3:Cell("DESC3"):SetValue(aItens[nImp][2])
					oFisc3:Cell("IMP3"):SetValue(aItens[nImp][3])
					oFisc3:Cell("ALI3"):SetValue(aItens[nImp][4])
					oFisc3:Cell("BASEIMP3"):SetValue(aItens[nImp][5])
					oFisc3:Cell("VALORIMP3"):SetValue(aItens[nImp][6])
					oFisc3:PrintLine()
				Next
				oFisc2:Finish()
				oReport:FatLine()
			Endif
		EndIf

		If Select(cAliasSC7) > 0
			dbSelectArea(cAliasSC7)
			(cAliasSC7)->(DbCloseArea())
		EndIf


		IF !EMPTY(_C7_CONTRA) .AND. POSICIONE("CN9", 1,IIF(EMPTY(_C7_XFILCOM), xFilial("SD1"), _C7_XFILCOM) + _C7_CONTRA + _C7_CONTREV, "CN9_XREGP") == "1"
			cQuery := "EXEC LK_SESUITE.SE_SUITE.dbo.SP_IMPRESSAO_PRE_NOTA '"+xFilial("SD1")+"','"+cPedido+"','"+_D1_DOC+"','"+_D1_EMISSAO+"'"
		ELSE
			cQuery := "EXEC LK_SESUITE.SE_SUITE.dbo.SP_IMPRESSAO_PRE_NOTA '"+xFilial("SD1")+"','"+cPedido+"','"+_D1_DOC+"','"+_D1_EMISSAO+"','"+_C7_MEDICAO+"'"
		ENDIF

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.F.)

		DbSelectArea(cAliasSC7)
		(cAliasSC7)->(dbGotop())


		cMensagem := ALLTRIM(Posicione("ZZ5", 1, xFilial("ZZ5") + ALLTRIM(_D1_ITEMCTA), "ZZ5_MENSAG" ))
		cTamanho  := Len(cMensagem)
		cColuna   := ((220 - cTamanho) / 2) * 7

		If !Empty(cMensagem)
			oReport:PrintText("           ============================================================================================================================")
			oReport:PrintText("           !|!|!|!|!|!|  " + cMensagem + "   |!|!|!|!|!|!",,cColuna)
			oReport:PrintText("           ============================================================================================================================")
		EndIf

		If ( Select(cAliasSC7) > 0 .AND.  !(cAliasSC7)->(Eof()) )
			oReport:SkipLine(3)
			oReport:ThinLine()
			oReport:SkipLine(2)
			oReport:PrintText(" - Responsável pela Aprovação do Recebimento Produto / Serviço: " + (cAliasSC7)->NMUSER)
			oReport:SkipLine()
			oReport:PrintText("       Data / Hora.: " + (cAliasSC7)->DTAPROVACAO)
			oReport:SkipLine(1)
			oReport:PrintText("       Nº Processo.: " + (cAliasSC7)->IDPROCESS)
			oReport:SkipLine(2)
			oReport:PrintText("** NOTA: Centro de Custos e Conta Contabil verificado pela GECON durante o processo de aprovação da Solicitação de Compras.")
			oReport:SkipLine(2)
			oReport:ThinLine()
		Else
			oReport:SkipLine(3)
			oReport:ThinLine()
			oReport:SkipLine(2)
			oReport:PrintText("RECEBIMENTO DO(S) MATERIAL(IS) / SERVIÇO(S):")
			oReport:SkipLine()
			oReport:PrintText("Declaro que recebi, da empresa supra citada, o(s) material(is) / serviço(s) e está(ão) de acordo com o solicitado.")
			oReport:SkipLine()
			oReport:SkipLine(5)
			oReport:SkipLine()
			oReport:PrintText("_______________________________________________")
			oReport:SkipLine()
			oReport:PrintText("          Ass. Responsável - Matrícula")
			oReport:SkipLine(5)
			oReport:ThinLine()
			oReport:PrintText("------------------------------------------------------------------- VISTOS ---------------------------------------------------------")
			oReport:PrintText("|                               |                                |                                  |                              |")
			oReport:PrintText("| Recebimento  Fiscal           | Contabil/Custos                | Departamento Fiscal              | Administracao                |")
			oReport:ThinLine()
		EndIf

		If Select(cAliasSC7) > 0
			(cAliasSC7)->(DbCloseArea())
		EndIf

		dbSelectArea(cAliasSF1)
		If !lQuery
			(cAliasSF1)->(dbSkip())
		EndIf
		oReport:IncMeter()
		oSection1:Finish()

		If !lAuto .And. (cAliasSF1)->(!Eof())
			oReport:EndPage()
		Endif

	EndDo

	//+--------------------------------------------------------------+
	//| Devolve a condicao original dos arquivos		             |
	//+--------------------------------------------------------------+
	RestArea(aAreaSF3)
	RestArea(aAreaSF1)
	RestArea(aAreaSE2)
	RestArea(aAreaSC7)

	If !lAuto .And. !lQuery
		dbSelectArea("SD1")
		RetIndex("SD1")
		If File(cArqIndSD1+ OrdBagExt())
			FErase(cArqIndSD1+ OrdBagExt() )
		EndIf
	EndIf

Return NIL

/*/================================================================================================================================/*/
/*/{Protheus.doc} ImpRoda
Imprime o Desdobramento de duplicatas.

@type function
@author Ricardo Berti
@since 09/08/2006
@version P12.1.23

@param oReport, Objeto, Objeto Report do Relatorio.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@Deprecated Função não utilizada.
/*/
/*/================================================================================================================================/*/

Static Function ImpRoda(oReport)

	oReport:PrintText("------------------------------------------------------------------- VISTOS ---------------------------------------------------------") //
	oReport:PrintText("|                               |                                |                                  |                              |")
	oReport:PrintText("| Recebimento  Fiscal           | Contabil/Custos                | Departamento Fiscal              | Administracao                |") //
	oReport:ThinLine()
Return Nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} R170DupTR
Imprime o Desdobramento de duplicatas.

@type function
@author Ricardo Berti
@since 05/07/2006
@version P12.1.23

@param oReport, Objeto, Objeto Report do Relatorio.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function R170DupTR(oReport)

	Local oDupli := oReport:Section(1):Section(14)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oDupli:Cell("E2PREFIXO"):SetValue(SE2->E2_PREFIXO)
	oDupli:Cell("E2NUM"):SetValue(SE2->E2_NUM)
	oDupli:Cell("E2PARCELA"):SetValue(SE2->E2_PARCELA)
	oDupli:Cell("E2VENCTO"):SetValue(SE2->E2_VENCTO)
	oDupli:Cell("E2VALOR"):SetValue(SE2->E2_VALOR)
	oDupli:Cell("E2NATUREZ"):SetValue(SE2->E2_NATUREZA)
	oDupli:PrintLine()
Return NIL


/*/================================================================================================================================/*/
/*/{Protheus.doc} MATR170R3
Emissao do Boletim de Entrada.

@type function
@author Edson Maricate
@since 07/07/2000
@version P12.1.23

@param cAlias, Caractere, Alias do arquivo.
@param nReg, Numérico, Numero do registro.
@param nOpcx, Numérico, Opcao selecionada.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function MATR170R3(cAlias,nReg,nOpcx)
	//+--------------------------------------------------------------+
	//| Define Variaveis                                             |
	//+--------------------------------------------------------------+
	LOCAL wnrel  :="MATR170"
	LOCAL cDesc1 := "Este programa ira emitir o Boletim de Entrada."	//
	LOCAL cDesc2 := ""
	LOCAL cDesc3 := ""
	LOCAL cString:= "SF1"
	LOCAL aArea		:= GetArea()
	LOCAL aAreaSF1	:= SF1->(GetArea())

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	STATIC aTamSXG

	PRIVATE lAuto		:= (nReg!=Nil)
	PRIVATE Titulo		:= "Boletim de Entrada"	//
	PRIVATE aReturn		:= {"Zebrado", 1,"Administracao", 1, 2, 1, "",1 }		//###
	PRIVATE nomeprog	:= "MATR170"
	PRIVATE nLastKey	:= 0
	PRIVATE cPerg		:= If(lAuto,"","MTR170")
	PRIVATE cAuxLinha	:= SPACE(132)

	//+--------------------------------------------------------------+
	//| Verifica conteudo da variavel Grupo de Fornecedor (001)      |
	//+--------------------------------------------------------------+
	aTamSXG := If(aTamSXG == NIL, TamSXG("001"), aTamSXG)

	//+--------------------------------------------------------------+
	//| Verifica as perguntas selecionadas                           |
	//+--------------------------------------------------------------+
	AjustaSx1()
	Pergunte("MTR170",.F.)

	//+--------------------------------------------------------------+
	//| Variaveis utiLizadas para parametros                         |
	//| mv_par01             // da Data                              |
	//| mv_par02             // ate a Data                           |
	//| mv_par03             // Nota De                              |
	//| mv_par04             // Nota Ate                             |
	//| mv_par05             // Imprime Centro Custo X Cta. Contabil |
	//| mv_par06             // Imprimir o Custo ? Total ou Unit rio |
	//| mv_par07             // Ordenar itens por? Item+Prod/ Prd+It |
	//+--------------------------------------------------------------+

	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,"M",,!lAuto)

	If nLastKey == 27
		dbClearFilter()
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		dbClearFilter()
		Return
	Endif

	RptStatus({|lEnd| R170Imp(@lEnd,wnrel,cString,nReg)},Titulo)


	RestArea(aAreaSF1)
	RestArea(aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} R170Imp
Chamada e impressao do Relatorio.

@type function
@author Edson Maricate
@since 06/07/2000
@version P12.1.23

@param lEnd, Lógica, Variável que indica o cancelamento do relatório.
@param wnrel, Caractere, Nome do Relatório.
@param cString, Caractere, descricao
@param nReg, Numérico, Recno posicionado.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function R170Imp(lEnd,wnrel,cString,nReg)

	Local li          := 99
	LOCAL cLocDest    := GetMV("MV_CQ")
	Local cForMunic   := GetMv("MV_MUNIC")
	Local aDivergencia:= {}
	Local aPedidos  	:= {}
	Local aDescPed    := {}
	Local aCQ         := {}
	Local aEntCont    := {}
	Local _lQtdErr    := .F.
	Local _lPrcErr    := .F.
	Local _QtdSal     := .F.
	Local _lTes       := .F.
	Local cForAnt     := 0
	Local nDocAnt     := 0
	Local nCt         := 0
	Local nX          := 0
	Local nImp        := 0
	Local nRecno      := 0
	Local lPedCom     := .F.
	Local cQuery      := ""
	Local cArqInd     := ""
	Local cArqIndSD1  := ""
	Local cParcIR     := ""
	Local cParcINSS   := ""
	Local cParcISS    := ""
	Local cParcCof    := ""
	Local cParcPis    := ""
	Local cParcCsll   := ""
	Local cParcSest   := ""
	Local cPrefixo
	Local aImps       := {}
	Local nBasePis    := 0
	Local nValPis     := 0
	Local nBaseCof    := 0
	Local nValCof     := 0
	Local nRec        := 0
	Local aRelImp     := MaFisRelImp("MT100",{ "SF1" })
	Local lFornIss    := (SE2->(FieldPos("E2_FORNISS")) > 0 .And. SE2->(FieldPos("E2_LOJAISS")) > 0)
	Local cFornIss 	  := ""
	Local cLojaIss    := ""
	Local cRemito     := ""
	Local cItemRem    := ""
	Local cSerieRem   := ""
	Local cFornRem    := ""
	Local cLojaRem    := ""
	Local cCodRem     := ""
	Local cPedido     := ""
	Local cItemPed    := ""
	Local lQuery      := .F.
	Local cDtEmis     := ""
	Local i 		  := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Private cAliasSF1	:= "SF1"

	If lAuto
		dbSelectArea("SF1")
		SF1->(dbGoto(nReg))
		MV_PAR03 := SF1->F1_DOC
		MV_PAR04 := SF1->F1_DOC
		MV_PAR01 := SF1->F1_DTDIGIT
		MV_PAR02 := SF1->F1_DTDIGIT
	Else
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1))
		#IFDEF TOP
		//+--------------------------------+
		//| Query para SQL                 |
		//+--------------------------------+
		cQuery := "SELECT *  "
		cQuery += "FROM "	    + RetSqlName( 'SF1' )
		cQuery += " WHERE "
		cQuery += "F1_FILIAL='"    	+ xFilial( 'SF1' )	+ "' AND "
		cQuery += "F1_DTDIGIT>='"  	+ DTOS(MV_PAR01)	+ "' AND "
		cQuery += "F1_DTDIGIT<='"  	+ DTOS(MV_PAR02)	+ "' AND "
		cQuery += "F1_DOC>='"  		+ MV_PAR03			+ "' AND "
		cQuery += "F1_DOC<='"  		+ MV_PAR04			+ "' AND "
		cQuery += "NOT ("+IsRemito(3,'F1_TIPODOC')+ ") AND "
		cQuery += "D_E_L_E_T_<>'*' "
		cQuery += "ORDER BY " + SqlOrder(SF1->(IndexKey()))
		cQuery := ChangeQuery(cQuery)

		cAliasSF1 := "QRYSF1"
		dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), 'QRYSF1', .F., .T.)
		aEval(SF1->(dbStruct()),{|x| If(x[2]!="C",TcSetField("QRYSF1",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

		If ( mv_par07 == 1 )
			cArqIndSD1 := CriaTrab(,.F.)
			IndRegua( "SD1", cArqIndSD1, "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM" )
		EndIf

		lQuery := .T.
		#ELSE
		If !Empty(MV_PAR03)
			SF1->(dbSeek(xFilial("SF1")+MV_PAR03,.T.))
		Else
			cArqInd   := CriaTrab( , .F. )
			cQuery := "F1_FILIAL=='"	   	+xFilial("SF1")	+"'.AND."
			cQuery += "DTOS(F1_DTDIGIT)>='"	+DTOS(MV_PAR01)	+"'.AND."
			cQuery += "DTOS(F1_DTDIGIT)<='"	+DTOS(MV_PAR02)	+"'.AND."
			cQuery += "F1_DOC >= '"  	   	+MV_PAR03		+"'.AND."
			cQuery += "F1_DOC <= '"  		+MV_PAR04		+"'"
			cQuery += ".AND. !("+IsRemito(2,'SF1->F1_TIPODOC')+")"

			IndRegua( "SF1", cArqInd, IndexKey(), , cQuery )
			SF1->( dbSetIndex( cArqInd + OrdBagExt() ) )
		EndIf

		If ( mv_par07 == 1 )
			cArqIndSD1 := CriaTrab(,.F.)
			IndRegua( "SD1", cArqIndSD1, "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM" )
			SD1->( dbSetIndex( cArqIndSD1 + OrdBagExt() ) )
		EndIf

		lQuery := .F.
		#ENDIF
	EndIf

	If !lAuto
		(cAliasSF1)->(dbGoTop())
	EndIf

	SF1->(SetRegua(LastRec()))
	While ( (cAliasSF1)->(!Eof()) .And. (cAliasSF1)->F1_FILIAL == xFilial("SF1") .And.;
	((cAliasSF1)->F1_DOC <= MV_PAR04) )

		IncRegua()
		aCQ	:= {}
		If lEnd
			@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"		//
			Exit
		Endif

		dbSelectArea(cAliasSF1)
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			(cAliasSF1)->(dbSkip())
			Loop
		EndIf
		If (cAliasSF1)->F1_DTDIGIT < MV_PAR01 .OR. (cAliasSF1)->F1_DTDIGIT > MV_PAR02
			(cAliasSF1)->(dbSkip())
			Loop
		EndIf

		If (cAliasSF1)->F1_DOC < MV_PAR03 .or. (cAliasSF1)->F1_DOC > MV_PAR04
			(cAliasSF1)->(dbSkip())
			Loop
		EndIf

		If (lAuto .And. (cAliasSF1)->(Recno()) <> nReg)
			(cAliasSF1)->(dbSkip())
			Loop
		EndIf
		cDtEmis  := (cAliasSF1)->F1_EMISSAO

		If lQuery
			dbSelectArea("SF1")
			SF1->(dbSeek(xFilial("SF1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
		EndIf

		dbSelectArea("SD1")
		SF1->(dbSeek(xFilial("SD1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))

		//+--------------------------------------------------------------+
		//| Impressao do Cabecalho.                                      |
		//+--------------------------------------------------------------+
		dbSelectArea(cAliasSF1)
		If li > 20
			li := R170Cabec()
		EndIf

		//+--------------------------------------------------------------+
		//| Impressao dos itens da Nota de Entrada.                      |
		//+--------------------------------------------------------------+
		dbSelectArea("SD1")
		nCt     := 1
		nDocAnt := D1_DOC+D1_SERIE
		cForAnt := D1_FORNECE+D1_LOJA
		aDivergencia := {}
		aPedidos     := {}
		aDescPed     := {}
		aEntCont     := {}

		//                                 1         2         3         4         5         6         7         8         9        10        11        12        13
		//                         012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		//                         999999999999999 XX XXXXXXXXXXXXXXXXXXXX 99999999.99 99,999,999.99 999,999,999.99  99  99 12345678901234567890 999 9999 99,999,999.99
		//                         999999999999999 XX XXXXXXXXXXXXXXXXX XX 99999999.99 99,999,999.99 999,999,999.99  99  99 12345678901234567890 999 9999 99,999,999.99
		If mv_par05 <> 3
			If mv_par08 == 1
				cLinha :=         "               |  |                 |  |           |            |            |     |     |                    |   |     |             "
			Else
				cLinha :=         "               |  |                    |           |            |            |     |     |                    |   |     |             "
			EndIf
		Else
			If mv_par08 == 1
				cLinha :=         "               |  |                 |  |           |            |            |     |     |   |     |             "
			Else
				cLinha :=         "               |  |                    |           |            |            |     |     |   |     |             "
			EndIf
		EndIf
		@ li,000 PSAY __PrtThinLine()
		li += 1
		@ li,000 PSAY "------------------------------------------------------- DADOS DA NOTA FISCAL -------------------------------------------------------" // "-------------------------------------------------------- DADOS DA NOTA FISCAL -------------------------------------------------------"
		li += 1
		@ li,000 PSAY If(mv_par08==1,If(cPaisLoc<>"BRA","Codigo Material|UN|Descr. Mercadoria|Az|Quantidade |Vlr. Unitario| Valor Total            | ","Codigo Material|UN|Descr. Mercadoria|Az|Quantidade |Vlr.Unitario|Valor Total |IPI  |ICMS |	"),If(cPaisLoc<>"BRA","Codigo Material|UN|Descr.da Mercadoria |Quantidade |Vlr. Unitario| Valor Total            | ","Codigo Material|UN|Descr.da Mercadoria |Quantidade |Vlr.Unitario|Valor Total |IPI  |ICMS |"))+If(mv_par05==1,"   "+"Conta Contabil"+If(cPaisLoc=="BRA"," ","")+"  |",If(mv_par05==2,"   "+"Centro  Custo "+If(cPaisLoc=="BRA"," ","")+"   |",""))+"TES|CFOP |"+If(mv_par06==2,"Custo Unit. ","Custo Total ")  //"Codigo Material|UN|Descr. da Mercadoria|Quantidade |Vlr. Unitario| Valor Total  |IPI|ICM|   "#########"   |TES|CFOP|"######
		li += 1

		While ( SD1->(!Eof()) .And. SD1->D1_DOC+SD1->D1_SERIE == nDocAnt .And.;
		cForAnt == SD1->D1_FORNECE+SD1->D1_LOJA .And.;
		SD1->D1_FILIAL == xFilial("SD1") )

			If li >= 60
				li := 1
				@ li,000 PSAY "------------------------------------------------------- ITENS DA NOTA FISCAL -------------------------------------------------------" //"------------------------------------------------------- ITENS DA NOTA FISCAL ----------------------------------------------------"
				li += 1
				@ li,000 PSAY If(mv_par08==1,If(cPaisLoc<>"BRA","Codigo Material|UN|Descr. Mercadoria|Az|Quantidade |Vlr. Unitario| Valor Total            | ","Codigo Material|UN|Descr. Mercadoria|Az|Quantidade |Vlr.Unitario|Valor Total |IPI  |ICMS |	"),If(cPaisLoc<>"BRA","Codigo Material|UN|Descr.da Mercadoria |Quantidade |Vlr. Unitario| Valor Total            | ","Codigo Material|UN|Descr.da Mercadoria |Quantidade |Vlr.Unitario|Valor Total |IPI  |ICMS |"))+If(mv_par05==1,"   "+"Conta Contabil"+If(cPaisLoc=="BRA"," ","")+"  |",If(mv_par05==2,"   "+"Centro  Custo "+If(cPaisLoc=="BRA"," ","")+"   |",""))+"TES|CFOP |"+If(mv_par06==2,"Custo Unit. ","Custo Total ")  //"Codigo Material|UN|Descr. da Mercadoria|Quantidade |Vlr. Unitario| Valor Total  |IPI|ICM|   "#########"   |TES|CFOP|"######
				li += 1
				@ li,000 PSAY __PrtThinLine()
				li += 1
			Endif
			//+--------------------------------------------------------------+
			//| Posiciona Todos os Arquivos Ref. ao Itens                    |
			//+--------------------------------------------------------------+
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD))

			dbSelectArea("SF4")
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))

			cPedido   := SD1->D1_PEDIDO
			cItemPed  := SD1->D1_ITEMPC

			If cPaisLoc <> "BRA" .And. !Empty(SD1->D1_REMITO)
				cRemito   := SD1->D1_REMITO
				cItemRem  := SD1->D1_ITEMREM
				cSerieRem := SD1->D1_SERIREM
				cFornRem  := SD1->D1_FORNECE
				cLojaRem  := SD1->D1_LOJA
				cCodRem	  := SD1->D1_COD

				aArea := SD1->(GetArea())

				dbSelectArea("SD1")
				SD1->(dbSetOrder(1))
				If SD1->(dbSeek(xFilial("SD1")+cRemito+cSerieRem+cFornRem+cLojaRem+cCodRem+Alltrim(cItemRem))) .And. !Empty(SD1->D1_PEDIDO)
					cPedido   := SD1->D1_PEDIDO
					cItemPed  := SD1->D1_ITEMPC
				Endif
				RestArea(aArea)
			Endif

			dbSelectArea("SC7")
			SC7->(dbSetOrder(19))
			If SC7->(dbSeek(xFilial("SC7")+SD1->D1_COD+cPedido+cItemPed))
				dbSelectArea("SC1")
				SC1->(dbSetOrder(2))
				SC1->(dbSeek(xFilial("SC1")+SC7->C7_PRODUTO+SC7->C7_NUMSC+SC7->C7_ITEMSC))

				dbSelectArea("SE4")
				SE4->(dbSetOrder(1))
				SE4->(dbSeek(xFilial("SE4")+SC7->C7_COND))

				lPedCom := !Empty(IF(SC7->C7_TIPO == 1,SubStr(SC1->C1_SOLICIT,1,15), SubStr(UsrFullName(SC7->C7_USER),1,15))+SC7->C7_CC)

				cProblema := ""
				If ( SD1->D1_QTDPEDI > 0 .And. (SC7->C7_QUANT <> SD1->D1_QTDPEDI) ) .Or. SC7->C7_QUANT <> SD1->D1_QUANT
					cProblema += "Q"
					_lQtdErr := .T.
				Else
					cProblema += " "
				EndIf
				If (SC7->C7_QUANT - SC7->C7_QUJE) < SD1->D1_QUANT  .AND. SD1->D1_TES == "   "
					_QtdSal := .T.
					n_proc1 :=-(SD1->D1_QUANT - (SC7->C7_QUANT - SC7->C7_QUJE)) / SC7->C7_QUANT * 100
				EndIf
				If SD1->D1_TES != "   " .AND. (SC7->C7_QUANT - SC7->C7_QUJE) < 0
					_QtdSal := .T.
					N_PORC1 :=-(SC7->C7_QUANT - SC7->C7_QUJE) / SC7->C7_QUANT * 100
				EndIf
				If IIf(Empty(SC7->C7_REAJUSTE),SC7->C7_PRECO,Formula(SC7->C7_REAJUSTE)) # SD1->D1_VUNIT
					If SC7->C7_MOEDA <> 1
						cProblema := cProblema+"M"
					Else
						cProblema := cProblema+"P"
					EndIf
					_lPrcErr := .T.
				Else
					cProblema := cProblema+" "
				EndIf
				If SC7->C7_DATPRF <> SD1->D1_DTDIGIT
					cProblema := cProblema+"E"
				Else
					cProblema := cProblema+" "
				EndIf
				If !Empty(cProblema)
					aADD(aDivergencia,cProblema)
				Else
					aADD(aDivergencia,"Ok ")
				Endif
				aADD(aPedidos,{SC7->C7_NUM+"/"+SC7->C7_ITEM,;
				SC7->C7_DESCRI,;
				TransForm(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT",11)),;
				TransForm(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO",13)),;
				DTOC(SC7->C7_EMISSAO),;
				DTOC(SC7->C7_DATPRF),;
				SC7->C7_NUMSC+"/"+SC7->C7_ITEMSC,;
				If(lPedCom,IF(SC7->C7_TIPO == 1,SubStr(SC1->C1_SOLICIT,1,15), SubStr(UsrFullName(SC7->C7_USER),1,15)),"") ,;
				If(lPedCom,SC7->C7_CC,""),;
				AllTrim(SE4->E4_DESCRI)} )
			Else
				aADD(aDivergencia,"Err") //
				aADD(aPedidos,{"","Sem Pedido de Compra","","","","","","","",""}) //
			Endif

			If !Empty(SD1->D1_NUMCQ) .AND. SF4->F4_ESTOQUE == "S"
				AADD(aCQ,SD1->D1_NUMCQ+SD1->D1_COD+cLocDest+"001"+DTOS(SD1->D1_DTDIGIT))
			Endif

			R170Load(0,cLinha)
			R170Load(0,SD1->D1_COD)
			R170Load(16,SD1->D1_UM)
			If mv_par08 == 1
				R170Load(19,SubStr(SB1->B1_DESC,1,17))
				R170Load(37,SubStr(SD1->D1_LOCAL,1,2))
			Else
				R170Load(19,SubStr(SB1->B1_DESC,1,20))
			EndIf
			R170Load(40,Transform(SD1->D1_QUANT,PesqPict("SD1","D1_QUANT",11)))
			R170Load(52,TransForm(SD1->D1_VUNIT,PesqPict("SD1","D1_VUNIT",12)))
			If cPaisLoc=="BRA"
				R170Load(65,Transform(SD1->D1_TOTAL,PesqPict("SD1","D1_TOTAL",12)))
				R170Load(78,Transform(SD1->D1_IPI,PesqPict("SD1","D1_IPI",5)))
				R170Load(84,Transform(SD1->D1_PICM,PesqPict("SD1","D1_PICM",5)))
			Else
				R170Load(73,Transform(SD1->D1_TOTAL,PesqPict("SD1","D1_TOTAL",14)))
			EndIf
			If mv_par05 == 1
				R170Load(90,SD1->D1_CONTA)
			ElseIf mv_par05 == 2
				R170Load(90,SD1->D1_CC)
			Endif

			If (( mv_par05 == 1 ) .Or. ( mv_par05 == 2 ))
				R170Load(111,SD1->D1_TES)
				R170Load(115,SD1->D1_CF)
				If mv_par06 = 1
					R170Load(121,Transform(SD1->D1_CUSTO,PesqPict("SD1","D1_CUSTO",10)))
				Else
					R170Load(121,Transform((SD1->D1_CUSTO/SD1->D1_QUANT),PesqPict("SD1","D1_CUSTO",10)))
				EndIf
			Else
				R170Load(90,SD1->D1_TES)
				R170Load(94,SD1->D1_CF)
				If mv_par06 = 1
					R170Load(100,Transform(SD1->D1_CUSTO,PesqPict("SD1","D1_CUSTO",10)))
				Else
					R170Load(100,Transform((SD1->D1_CUSTO/SD1->D1_QUANT),PesqPict("SD1","D1_CUSTO",10)))
				EndIf
			EndIf
			R170Say(Li)

			Li := Li + 1
			If !Empty(SD1->D1_TES)
				_lTES := .T.
			EndIf

			If mv_par08 == 1
				_nCntTam := 18
				While !(AllTrim(SubStr(SB1->B1_DESC,_nCntTam))=="")
					R170Load(0,cLinha)
					R170Load(19,SubStr(SB1->B1_DESC,_nCntTam,17))
					_nCntTam := _nCntTam + 17
					R170Say(Li)
					Li := Li + 1
				EndDo
			Else
				_nCntTam := 21
				While !(AllTrim(SubStr(SB1->B1_DESC,_nCntTam))=="")
					R170Load(0,cLinha)
					R170Load(19,SubStr(SB1->B1_DESC,_nCntTam,20))
					_nCntTam := _nCntTam + 20
					R170Say(Li)
					Li := Li + 1
				EndDo
			EndIf

			If ( mv_par05 == 3 )
				If ( SD1->D1_RATEIO == "1" )
					dbSelectArea("SDE")
					SDE->(dbSetOrder(1))
					If SDE->(MsSeek(xFilial("SDE")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM))
						While SDE->(!Eof()) .And. DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF ==;
						xFilial("SDE")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM
							aAdd(aEntCont,{SDE->DE_ITEMNF,SDE->DE_ITEM,SDE->DE_PERC,SDE->DE_CC,SDE->DE_CONTA,SDE->DE_ITEMCTA,SDE->DE_CLVL})
							dbSelectArea("SDE")
							SDE->(dbSkip())
						EndDo
					EndIf
				Else
					If !Empty(SD1->D1_CC) .Or. !Empty(SD1->D1_CONTA) .Or. !Empty(SD1->D1_ITEMCTA)
						aAdd(aEntCont,{SD1->D1_ITEM," - ","   -   ",SD1->D1_CC,SD1->D1_CONTA,SD1->D1_ITEMCTA,SD1->D1_CLVL})
					EndIf
				EndIf
			EndIf

			dbSelectArea("SD1")
			SD1->(dbSkip())
		End

		//+-----------------------------+
		//| Imprime Entidades Contabeis |
		//+-----------------------------+
		If Len(aEntCont) > 0
			If Li >= 60
				Li := 1
			Endif
			@ li,000 PSAY __PrtThinLine()
			li += 1
			cLinha :=   "        |      |       |                 |                      |            |              "
			@ Li, 0 PSAY "------------------------------------------------------- ENTIDADES CONTABEIS --------------------------------------------------------"  //"------------------------------------------------------- ENTIDADES CONTABEIS ---------------------------------------------------------"
			li += 1
			@ Li,000 PSAY "Item NF | Item | % Rat | Centro de Custo | Conta Contabil       | Item Conta | Classe Valor " //
			li += 1

			For nX:=1 to Len(aEntCont)
				If Li >= 60
					Li := 1
					cLinha :=   "        |      |       |                 |                      |            |              "
					@ Li, 0 PSAY "------------------------------------------------------- ENTIDADES CONTABEIS --------------------------------------------------------"  //"------------------------------------------------------- ENTIDADES CONTABEIS ---------------------------------------------------------"
					li += 1
					@ Li,000 PSAY "Item NF | Item | % Rat | Centro de Custo | Conta Contabil       | Item Conta | Classe Valor " //
					li += 1
				Endif
				R170Load(0,cLinha)
				R170Load(0,aEntCont[nX][1])
				R170Load(10,aEntCont[nX][2])
				R170Load(16,If(ValType(aEntCont[nX][3])=="N",Transform(aEntCont[nX][3],"@E 999.99"),aEntCont[nX][3]))
				R170Load(25,aEntCont[nX][4])
				R170Load(43,aEntCont[nX][5])
				R170Load(66,aEntCont[nX][6])
				R170Load(79,aEntCont[nX][7])
				R170Say(Li)
				li += 1
			Next nX
			aEntCont := {}
		EndIf

		//+--------------------------------------------------------------+
		//| Imprime produtos enviados ao Controle de Qualidade SD7       |
		//+--------------------------------------------------------------+

		If Len(aCQ) > 0
			If Li >= 60
				Li := 1
			Endif
			li += 1
			//                               1         2         3         4         5         6         7         8         9        10        11        12        13
			//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
			//                     XXXXXXXXXXXXXXX                    XX                               XX                      99/99/9999                        999999
			cLinha :=    "                     |                               |                            |                           |                     "
			@ Li, 0 PSAY "------------------------------------------- PRODUTO(s) ENVIADO(s) AO CONTROLE DE QUALIDADE -----------------------------------------" //
			li += 1
			@ Li,000 PSAY "Produto              |         Local Origem          |        Local Destino       |    Data Transferencia     |     Numero do CQ.   " //
			li += 1

			For nX:=1 to Len(aCQ)
				If Li >= 60
					Li := 1
					//                               1         2         3         4         5         6         7         8         9        10        11        12        13
					//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
					//                     XXXXXXXXXXXXXXX                    XX                               XX                      99/99/9999                        999999
					cLinha :=    "                     |                               |                            |                           |                     "
					@ Li, 0 PSAY "------------------------------------------- PRODUTO(s) ENVIADO(s) AO CONTROLE DE QUALIDADE -----------------------------------------" //
					li += 1
					@ Li,000 PSAY "Produto              |         Local Origem          |        Local Destino       |    Data Transferencia     |     Numero do CQ.   " //
					li += 1
				Endif
				dbSelectArea("SD7")
				SD7->(dbSetOrder(1))
				SD7->(dbSeek(xFilial("SD7")+aCQ[nX]))
				If Found()
					R170Load(0,cLinha)
					R170Load(0,SD7->D7_PRODUTO)
					R170Load(34,SD7->D7_LOCAL)
					R170Load(68,SD7->D7_LOCDEST)
					R170Load(92,DTOC(SD7->D7_DATA))
					R170Load(123,SD7->D7_NUMERO)
					R170Say(Li)
					li += 1
				Endif
			Next nX
		Endif
		//+--------------------------------------------------------------+
		//| Imprime Divergencia com Pedido de Compra.                    |
		//+--------------------------------------------------------------+
		Li := Li + 1
		//                            1         2         3         4         5         6         7         8         9        10        11        12        13
		//                  012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		//                   123 123456-12 12345678901234567890 99999999,99|99.999.999,99 99/99/9999 99/99/9999 999999/99 xxxxxxxxxxxx 999999999
		If cPaisLoc == "BRA"
			cLinha  :=    "   |           |                  |           |             |          |          |         |               |         |             "
		Else
			cLinha  :=    "   |           |                    |           |             |          |          |            |               |         |             "
		EndIf
		@ li,000 PSAY __PrtThinLine()
		Li += 1
		@ Li,000 PSAY "--------------------------------------------- DIVERGENCIAS COM O PEDIDO DE COMPRA --------------------------------------------------" //
		Li += 1
		@ Li,000 PSAY If(cPaisLoc=="BRA","Div|Numero   |Descricao do Produto|Quantidade |Preco Unitar.| Emissao  | Entrega  |   S.C.  |Solicitante    | C.Custo |Cond.Pagto   ","Div|Numero     |Descricao do Produto|Quantidade |Preco Unitar.| Emissao  | Entrega  |   S.C.     |Solicitante    | C.Custo |Cond.Pagto   ") //
		Li += 1
		If !Empty(aPedidos) .And. !Empty(aDivergencia)
			For nX := 1 To Len(aPedidos)
				If Li > 60
					Li := 0
					@ Li,000 PSAY "--------------------------------------------- DIVERGENCIAS COM O PEDIDO DE COMPRA --------------------------------------------------" //
					Li += 1
					@ Li,000 PSAY If(cPaisLoc=="BRA","Div|Numero   |Descricao do Produto|Quantidade |Preco Unitar.| Emissao  | Entrega  |   S.C.  |Solicitante    | C.Custo |Cond.Pagto   ","Div|Numero     |Descricao do Produto|Quantidade |Preco Unitar.| Emissao  | Entrega  |   S.C.     |Solicitante    | C.Custo |Cond.Pagto   ") //
					Li += 1
				EndIf
				R170Load(0,cLinha)
				R170Load(0,aDivergencia[nX])
				R170Load(4,aPedidos[nX][1])
				If cPaisLoc == "BRA"
					R170Load(16,AllTrim(Substr(aPedidos[nX][2],1,18)))
					R170Load(35,aPedidos[nX][3])
					R170Load(47,aPedidos[nX][4])
					R170Load(61,aPedidos[nX][5])
					R170Load(72,aPedidos[nX][6])
					R170Load(83,aPedidos[nX][7])
					R170Load(93,aPedidos[nX][8])
					R170Load(109,aPedidos[nX][9])
					R170Load(119,aPedidos[nX][10])
				Else
					R170Load(16,AllTrim(Substr(aPedidos[nX][2],1,18)))
					R170Load(37,aPedidos[nX][3])
					R170Load(49,aPedidos[nX][4])
					R170Load(63,aPedidos[nX][5])
					R170Load(74,aPedidos[nX][6])
					R170Load(85,aPedidos[nX][7])
					R170Load(98,aPedidos[nX][8])
					R170Load(114,aPedidos[nX][9])
					R170Load(124,aPedidos[nX][10])
				EndIf
				R170Say(Li)
				Li += 1
				_nCntTam := 19
				While !(AllTrim(SubStr(aPedidos[nX][2],_nCntTam)) == "")
					R170Load(0,cLinha)
					R170Load(16,SubStr(aPedidos[nX][2],_nCntTam,18))
					R170Say(Li)
					_nCntTam := _nCntTam + 18
					Li += 1
				End
			Next nX
		EndIf

		//+--------------------------------------------------------------+
		//| Imprime Totais da Nota Fiscal                                |
		//+--------------------------------------------------------------+

		If Li >= 60
			Li := 1
		Endif
		dbSelectArea(cAliasSF1)
		@ li,000 PSAY __PrtThinLine()
		Li += 1
		@ Li,000 PSAY "------------------------------------------------------- TOTAIS DA NOTA FISCAL ------------------------------------------------------" //
		Li += 1
		//                             1         2         3         4         5         6         7         8         9        10        11        12        13
		//                   012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		//                      999,999,999,999.99    999,999,999,999.99    999,999,999,999.99    999,999,999,999.99      999,999,999,999.99   999,999,999,999.99
		If cPaisLoc=="BRA"
			cLinha  :=     "                     |                     |                     |                      |                        |                  "
		Else
			cLinha  :=     "                     |                     |                                            |                        |                  "
		EndIf
		@ Li,000 PSAY If(cPaisLoc<>"BRA"," BASE DE CALCULO IMP.|  VALOR DOS IMPOST. |                                             |VALOR TOTAL DOS PRODUTOS|    DESCONTOS     "," BASE DE CALCULO ICMS|  VALOR DO ICMS      |BASE CALC.ICMS SUBST.|  VALOR ICMS SUBST.   |VALOR TOTAL DOS PRODUTOS|    DESCONTOS     ") //
		Li += 1
		R170Load(0,cLinha)
		If cPaisLoc=="BRA"
			R170Load(003,Transform((cAliasSF1)->F1_BASEICM,"@E 999,999,999,999.99"))
			R170Load(025,Transform((cAliasSF1)->F1_VALICM, "@E 999,999,999,999.99"))
			R170Load(047,Transform((cAliasSF1)->F1_BRICMS, "@E 999,999,999,999.99"))
			R170Load(069,Transform((cAliasSF1)->F1_ICMSRET,"@E 999,999,999,999.99"))
		Else
			aImps:=R170IMPT(cAliasSF1)
			R170Load(003,Transform(aImps[1],"@E 999,999,999,999.99")) // Base de imposto
			R170Load(025,Transform(aImps[2],"@E 999,999,999,999.99")) // Valor do Imposto
		EndIf
		R170Load(093,Transform((cAliasSF1)->F1_VALMERC,"@E 999,999,999,999.99"))
		R170Load(114,Transform((cAliasSF1)->F1_DESCONT,"@E 999,999,999,999.99"))
		R170Say(Li)
		Li += 1
		@ Li,000 PSAY __PrtThinLine()
		Li += 1
		cLinha  :=    "                        |                         |                        |                         |                             "
		@ Li,000 PSAY If(cPaisLoc<>"BRA","  VALOR DO FRETE        |      VALOR DO SEGURO    | OUTRAS DESPESAS ACESSO.|   VALOR TOTAL DA NOTA   |                              ","  VALOR DO FRETE        |      VALOR DO SEGURO    | OUTRAS DESPESAS ACESSO.|   VALOR TOTAL DO IPI    |   VALOR TOTAL DA NOTA       ") //
		Li += 1
		R170Load(0,cLinha)
		R170Load(001,Transform((cAliasSF1)->F1_FRETE,  "@E 99,999,999,999,999.99"))
		R170Load(027,Transform((cAliasSF1)->F1_SEGURO, "@E 99,999,999,999,999.99"))
		R170Load(053,Transform((cAliasSF1)->F1_DESPESA,"@E 99,999,999,999,999.99"))
		If cPaisLoc=="BRA"
			R170Load(079,Transform((cAliasSF1)->F1_VALIPI, "@E 99,999,999,999,999.99"))
			R170Load(108,Transform((cAliasSF1)->F1_VALBRUT,"@E 99,999,999,999,999.99"))
		Else
			R170Load(079,Transform((cAliasSF1)->F1_VALBRUT,"@E 99,999,999,999,999.99"))
		EndIf
		R170Say(Li)
		Li += 1
		@ Li,000 PSAY __PrtThinLine()
		Li += 1
		//+--------------------------------------------------------------+
		//| Imprime desdobramento de Duplicatas.                         |
		//+--------------------------------------------------------------+
		aFornece := {{(cAliasSF1)->F1_FORNECE,(cAliasSF1)->F1_LOJA,PadR(MVNOTAFIS,Len(SE2->E2_TIPO))},;
		{PadR(GetMv('MV_UNIAO')  ,Len(SE2->E2_FORNECE)),PadR(Replicate('0',Len(SE2->E2_LOJA)),Len(SE2->E2_LOJA)),PadR(MVTAXA,Len(SE2->E2_TIPO))},;
		{PadR(GetMv('MV_FORINSS'),Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR(MVINSS,Len(SE2->E2_TIPO))},;
		{PadR(GetMv('MV_MUNIC')  ,Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR(MVISS ,Len(SE2->E2_TIPO))}}
		If SE2->(FieldPos("E2_PARCSES")) > 0
			aadd(aFornece,{PadR(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)),PadR(IIf(SubStr(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)+1)<>"",SubStr(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)+1),"00"),Len(SE2->E2_LOJA)),PadR('SES',Len(SE2->E2_TIPO)),"E2_PARCSES",{ || .T. }})
		EndIf


		cPrefixo := If(Empty((cAliasSF1)->F1_PREFIXO),&(GetMV("MV_2DUPREF")),(cAliasSF1)->F1_PREFIXO)
		dbSelectArea("SE2")
		SE2->(dbSetOrder(6))
		SE2->(dbSeek(xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+cPrefixo+(cAliasSF1)->F1_DOC))

		nRec:=RECNO()
		//Verifica se o Fornecedor do Titulo ja existe no aFornec //
		IF SE2->(dbSeek(xFilial("SE2")+cForMunic))
			While SE2->(!Eof()).and. alltrim(SE2->E2_FORNECE) == alltrim(cForMunic)
				IF Ascan(aFornece,{|x| (alltrim(x[1])+alltrim(x[2])) == (alltrim(cForMunic)+alltrim(SE2->E2_LOJA))}) = 0
					aAdd(aFornece, {PadR(GetMv('MV_MUNIC'),Len(SE2->E2_FORNECE)),SE2->E2_LOJA,PadR(MVISS ,Len(SE2->E2_TIPO))} )
				EndIf
				SE2->(DBSkip())
			EndDo
		EndIF

		SE2->(dbGoto(nRec))

		Li += 1
		If Li >= 60
			Li := 1
		Endif
		//                               1         2         3         4         5         6         7         8         9        10        11        12        13
		//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		//                      123 123456789012A 99/99/9999 99,999,999,999.99                            123 123456789012A 99/99/99   99,999,999,999.99 xxxxxxxxxx
		@ Li,000 PSAY "--------------------------------------------------- DESDOBRAMENTO DE DUPLICATAS ----------------------------------------------------" //
		Li += 1
		If cPaisLoc=="MEX"
			cLinha :=     "   |                     |          |                 |           ||   |                     |          |                 |         "
		Else
			cLinha :=     "   |             |          |                 |                   ||   |             |          |                 |                 "
		EndIf

		@ Li,000 PSAY If(cPaisLoc=="MEX","STR0109","Ser|Titulo/Parc. | Vencto   |Valor do Titulo  | Natureza          ||Ser|Titulo/Parc. | Vencto   |Valor do Titulo  | Natureza        ") //
		Li += 1

		Col := 0
		R170Load(0,cLinha)

		dbSelectArea('SE2')
		SE2->(dbSetOrder(6))
		SE2->(dbSeek(xFilial('SE2')+aFornece[1][1]+aFornece[1][2]+cPrefixo+(cAliasSF1)->F1_DOC))

		While SE2->(!Eof()) .And. xFilial('SE2')+aFornece[1][1]+aFornece[1][2]+cPrefixo+(cAliasSF1)->F1_DOC==;
		E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM

			If SE2->E2_TIPO == aFornece[1,3]

				R170Dupl(@Li,@Col)
				cParcCSS := SE2->E2_PARCCSS
				cParcIR  := SE2->E2_PARCIR
				cParcINSS:= SE2->E2_PARCINS
				cParcISS := SE2->E2_PARCISS
				cParcCof := SE2->E2_PARCCOF
				cParcPis := SE2->E2_PARCPIS
				cParcCsll:= SE2->E2_PARCSLL
				If lFornIss .And. !Empty(SE2->E2_FORNISS) .And. !Empty(SE2->E2_LOJAISS)
					cFornIss := SE2->E2_FORNISS
					cLojaIss := SE2->E2_LOJAISS
				Else
					cFornIss := aFornece[4,1]
					cLojaIss :=	aFornece[4,2]
				Endif
				cParcSest := IIf(SE2->(FieldPos("E2_PARCSES"))>0,SE2->E2_PARCSES,"")

				nRecno   := SE2->(Recno())

				dbSelectArea('SE2')
				SE2->(dbSetOrder(1))
				If (!Empty(cParcIR)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcIR+aFornece[2,3]+aFornece[2,1]+aFornece[2,2]))
					R170Dupl(@Li,@Col)
				Endif
				If (!Empty(cParcINSS)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcINSS+aFornece[3,3]))
					R170Dupl(@Li,@Col)
				Endif

				For i=1 to Len(aFornece)
					If AllTrim(aFornece[i,1])==alltrim(cForMunic)
						If (!Empty(cParcISS)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcISS+aFornece[i,3]+cFornIss+aFornece[i,2]))
							IF cDtEmis == SE2->E2_EMISSAO
								R170Dupl(@Li,@Col)
							EndIf
						EndIf
					EndIf
				Next i

				If (!Empty(cParcCof)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCof+aFornece[2,3]))
					R170Dupl(@Li,@Col)
				Endif
				If (!Empty(cParcPis)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcPis+aFornece[2,3]))
					R170Dupl(@Li,@Col)
				Endif
				If (!Empty(cParcCsll)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCsll+aFornece[2,3]))
					R170Dupl(@Li,@Col)
				Endif

				If (!Empty(cParcCSS)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCSS+aFornece[2,3]))
					While SE2->(!Eof()) .And. xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCSS+aFornece[2,3] ==;
					SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO

						If PadR(GetMv('MV_CSS'),Len(SE2->E2_NATUREZ)) == SE2->E2_NATUREZ
							R170Dupl(@Li,@Col)
						EndIf

						dbSelectArea('SE2')
						SE2->(dbSetOrder(1))
						SE2->(dbSkip())
					EndDo
				Endif
				If (!Empty(cParcSest)).And.SE2->(dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcSest+aFornece[5,3]))
					R170Dupl(@Li,@Col)
				Endif

				SE2->(dbGoto(nRecno))

			EndIf

			dbSelectArea('SE2')
			SE2->(dbSetOrder(6))
			SE2->(dbSkip())
		EndDo

		R170Say(Li)
		Li += 1
		@ Li,000 PSAY __PrtThinLine()
		Li += 1

		//+--------------------------------------------------------------+
		//| Imprime Dados do Livros Fiscais.                             |
		//+--------------------------------------------------------------+
		If cPaisloc=="BRA"
			dbSelectArea("SF3")
			SF3->(dbSetOrder(4))
			SF3->(dbSeek(xFilial("SF3")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE))
			If Found()
				Li += 1
				If Li >= 60
					Li := 1
				Endif
				//                                    1         2         3         4         5         6         7         8         9        10        11        12        13
				//                           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
				//                            xxx xxxx  99  99,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99       9,999,999,999.99

				@ Li,000 PSAY "----------------------------------------------- DEMONSTRATIVO DOS LIVROS FISCAIS ---------------------------------------------------" //
				Li += 1
				@ Li,000 PSAY "|                                |   Operacoes c/ credito de Imposto   |            Operacoes s/ credito de Imposto                 |" //"|                               |   Operacoes c/ credito de Imposto   |            Operacoes s/ credito de Imposto                 |"
				Li += 1
				//                                 1         2         3         4         5         6         7         8         9        10        11        12        13
				//                       012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
				//                        xxxx xxxx  99   9,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99       9,999,999,999.99

				@ Li,000 PSAY "|    |CFOP |Aliq| Valor Contabil | Base de Calculo  |     Imposto      |     Isentas      |      Outras      |     Observacao       |" //"|    |CFOP |Alic| Valor Contable | Base de Calculo  |     Impuesto     |     Exentas      |      Otras       |     Observacion      |"
				Li += 1
				cLinha :=               "|    |     |    |                |                  |                  |                  |                  |                      |"
				While SF3->(! Eof()) .And. xFilial("SF3")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE==F3_FILiAL+F3_CLiEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

					If Val(Substr(SF3->F3_CFO,1,1))<5

						R170Load(0,cLinha)
						R170Load(01,IIf(!Empty((cAliasSF1)->F1_ISS) .And. SF3->F3_TIPO == "S" ,"ISS","ICMS")) //##
						R170Load(06,SF3->F3_CFO)
						R170Load(12,Transform(SF3->F3_ALIQICM,"99"))
						R170Load(17,Transform(SF3->F3_VALCONT,"@E 9,999,999,999.99"))
						R170Load(34,Transform(SF3->F3_BASEICM,"@E 999,999,999,999.99"))
						R170Load(53,Transform(SF3->F3_VALICM,"@E 999,999,999,999.99"))
						R170Load(72,Transform(SF3->F3_ISENICM,"@E 999,999,999,999.99"))
						R170Load(91,Transform(SF3->F3_OUTRICM,"@E 999,999,999,999.99"))
						R170Say(Li)
						Li++
						If !EMPTY(SF3->F3_ICMSRET)
							R170Load(0,cLinha)
							R170Load(109,"RET  ") //
							R170Load(114,Transform(SF3->F3_ICMSRET,"@E 9,999,999,999.99"))
							R170Say(Li)
							Li += 1
						Endif
						If !EMPTY(SF3->F3_ICMSCOM)
							R170Load(0,cLinha)
							R170Load(109,"Compl") //
							R170Load(114,Transform(SF3->F3_ICMSCOM,"@E 9,999,999,999.99"))
							R170Say(Li)
							Li += 1
						Endif
						If !Empty(SF3->F3_BASEIPI) .Or. !Empty(SF3->F3_ISENIPI) .Or. !Empty(SF3->F3_OUTRIPI)
							R170Load(0,cLinha)
							R170Load(01,"IPI") //
							R170Load(17,Transform(SF3->F3_VALCONT,"@E 9,999,999,999.99"))
							R170Load(34,Transform(SF3->F3_BASEIPI,"@E 999,999,999,999.99"))
							R170Load(53,Transform(SF3->F3_VALIPI,"@E 999,999,999,999.99"))
							R170Load(72,Transform(SF3->F3_ISENIPI,"@E 999,999,999,999.99"))
							R170Load(91,Transform(SF3->F3_OUTRIPI,"@E 999,999,999,999.99"))
						Endif

						If ! Empty(SF3->F3_VALOBSE)
							R170Load(110,"OBS. ") //
							R170Load(114,Transform(SF3->F3_VALOBSE,"@E 9,999,999,999.99"))
						Endif
						R170Say(Li)
						Li += 1
					Endif

					SF3->(dbSkip())
				End

			Endif

			Li += 1
			@ Li,000 PSAY __PrtThinLine()
			Li += 1
			@ Li,000 PSAY "----------------------------------------------- DEMONSTRATIVO DOS DEMAIS IMPOSTOS --------------------------------------------------" //  "----------------------------------------------- DEMONSTRATIVO DOS DEMAIS IMPOSTOS ---------------------------------------------------"
			Li += 1
			@ Li,000 PSAY "|                   | Base de Calculo  |     Imposto      |                                                                          " //  "|                   | Base de Calculo  |     Imposto      |                                                                         |"
			Li += 1
			//+--------------------------------------------------------------+
			//| Imprime Dados ref ao PIS                                     |
			//+--------------------------------------------------------------+
			If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_BASEPS2"} ) )
				If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2])))
					nBasePis := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2]) ) ) )
				EndIf
			EndIf

			If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_VALPS2"} ) )
				If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2])))
					nValPis := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2]) ) ) )
				EndIf
			EndIf

			If !Empty(nValPis)
				R170Load(0,"|                   | Base de Calculo  |     Imposto      |")
				R170Load(01,"PIS APURACAO") //
				R170Load(21,Transform(nBasePis,"@E 999,999,999,999.99"))
				R170Load(40,Transform(nValPis,"@E 999,999,999,999.99"))
				R170Say(Li)
				Li++
			Endif

			//+--------------------------------------------------------------+
			//| Imprime Dados ref ao COFINS                                  |
			//+--------------------------------------------------------------+
			If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_BASECF2"} ) )
				If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2])))
					nBaseCof := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2]) ) ) )
				EndIf
			EndIf

			If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_VALCF2"} ) )
				If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2])))
					nValCof := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2]) ) ) )
				EndIf
			EndIf

			If !Empty(nValCof)
				R170Load(0,"|                   | Base de Calculo  |     Imposto      |")
				R170Load(01,"COFINS APURACAO") //
				R170Load(21,Transform(nBaseCof,"@E 999,999,999,999.99"))
				R170Load(40,Transform(nValCof,"@E 999,999,999,999.99"))
				R170Say(Li)
				Li++
			Endif

			@ Li,000 PSAY __PrtThinLine()
			If Li < 57
				Li := 57
			Endif
		Else
			aItens:=R170IMPI(cAliasSF1)
			If Len(aItens[1])>=0
				Li += 1
				If Li >= 60
					Li := 1
				Endif
				//                                     1         2         3         4         5         6         7         8         9        10        11        12        13
				//                           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
				cLinha :=	    "|                  |                                          |     |        |                         |"
				@ Li,000 PSAY "-----------------------------------------------   RELACAO DE IMPOSTOS POR ITEM   ---------------------------------------------------" //
				Li :=Li+1
				@ Li,000 PSAY "|     PRODUTO      |               DESCRICAO                  | IMP |  ALIQ  |     BASE DE CALCULO     |      VALOR DO IMPOSTO      "  // |     PRODUTO      |               DESCRICAO                  | IMP |  ALIQ  |     BASE DE CALCULO     |      VALOR DO IMPOSTO
				Li += 1

				For nImp:=1 to Len(aItens)
					R170Load(000,cLinha)
					R170Load(001,aItens[nImp][1])
					R170Load(022,aItens[nImp][2])
					R170Load(064,aItens[nImp][3])
					R170Load(070,Transform(NoRound(aItens[nImp][4]),PesqPict("SD1","D1_ALQIMP6")))
					R170Load(080,Transform(aItens[nImp][5],PesqPict("SM2","M2_MOEDA1")))
					R170Load(106,Transform(aItens[nImp][6],PesqPict("SM2","M2_MOEDA1")))
					R170Say(Li)
					Li++
				Next
			Endif

			@ Li,000 PSAY __PrtThinLine()
			If Li < 57
				Li := 57
			Endif

		EndIf

		Li+= 2

		@ Li,000 PSAY "RECEBIMENTO DO(S) MATERIAL(IS) / SERVIÇO(S):"
		Li++
		@ Li,000 PSAY "Declaro que recebi, da empresa supra citada, o(s) material(is) / serviço(s) e está(ão) de acordo com o solicitado."
		Li+=5
		@ Li,000 PSAY "_______________________________________________"
		Li++
		@ Li,000 PSAY "          Ass. Responsável - Matrícula"

		Li+=2

		//@ Li,000 PSAY __PrtThinLine()

		If Li < 57
			Li := 57
		Endif




		//                           1         2         3         4         5         6         7         8         9        10        11        12        13
		//                  123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
		@ Li,000 PSAY "------------------------------------------------------------------- VISTOS ---------------------------------------------------------" //
		Li += 1
		@ Li,000 PSAY "|                               |                                |                                  |                              |"
		Li += 1
		@ Li,000 PSAY "| Recebimento  Fiscal           | Contabil/Custos                | Departamento Fiscal              | Administracao                |" //
		Li += 1
		@ Li,000 PSAY __PrtThinLine()
		dbSelectArea(cAliasSF1)
		(cAliasSF1)->(dbSkip())
		_lTES := .F.
		_lPrcErr := .F.
		_lQtdErr := .F.
		_QtdSal := .F.
	EndDo

	dbSelectArea("SF1")
	RetIndex("SF1")
	If File(cArqInd+ OrdBagExt())
		FErase(cArqInd+ OrdBagExt() )
	EndIf

	dbSelectArea("SD1")
	RetIndex("SD1")
	If File(cArqIndSD1+ OrdBagExt())
		FErase(cArqIndSD1+ OrdBagExt() )
	EndIf

	#IFDEF TOP
	If !lAuto
		dbSelectArea("QRYSF1")
		QRYSF1->(dbCloseArea())
	EndIf
	#ENDIF

	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} R170Cabec
Imprime o cabecalho do Boletim.

@type function
@author Edson Maricate
@since 06/07/2000
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Linha posicionada no relatório.

/*/
/*/================================================================================================================================/*/

Static Function R170Cabec()

	Local li         := 01
	Local aVencto    := {}
	Local aAuxCombo1 := {"N","D","B","I","P","C"}
	Local aCombo1	 := {"Normal            ",;	//"Normal"
	"Devoluçao",;	//"Devoluçao"
	"Beneficiamento",;	//"Beneficiamento"
	"Compl.  ICMS",;	//"Compl.  ICMS"
	"Compl.  IPI",;	//"Compl.  IPI"
	"Compl. Preco/frete"}	//"Compl. Preco/frete"
	Local cNumDoc := ""
	Local nIncCol := If(cPaisLoc=="MEX",8,0)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+-------------------------------------------------------------------+
	//| Faz manualmente porque nao chama a funcao Cabec()                 |
	//+-------------------------------------------------------------------+
	@ li,000 PSAY AvalImp(132)
	@ li,000 PSAY  ""
	@ Li,000 PSAY "Usuario: " +CUSERNAME + " Data Base: "+Dtoc(dDataBase) //###
	Li += 1
	@ li,000 PSAY __PrtFatLine()
	Li += 1

	If (cAliasSF1)->F1_TIPO $ "DB"
		dbSelectArea("SE1")
		SE1->(dbSetOrder(2))
		SE1->(dbSeek(xFilial("SE1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC))
		While !Eof() .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM == xFilial("SE1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC
			If ALLTRIM(E1_ORIGEM)=="MATA100"
				aADD(aVencto,E1_VENCREA)
			EndIf
			SE1->(dbSkip())
		End
		@ li,000 PSAY OemToAnsi("N. ")+SD1->D1_NUMSEQ+Space(66)+OemToAnsi("Data Impressao ")+Dtoc(Date())+Space(14)+OemToAnsi("Hora Ref. ")+Time()   //  N. ## Data Ref. ### Hora Ref.
		li += 1
		@ li,000 PSAY "BOLETIM DE ENTRADA      Material recebido em: " +dtoc((cAliasSF1)->F1_DTDIGIT)+IIF((cAliasSF1)->F1_TIPO=="D"," - (Devolucao)"," - ("+Alltrim("Beneficiamento    ")+")") //###
		li += 1

		cCGC:=" - "
		cCGC+=Alltrim(RetTitle("A1_CGC"))
		cCGC+=": "
		cIE:=" "+AllTrim(RetTitle("A1_INSCR"))+": "
		cIEM:=" "+AllTrim(RetTitle("A1_INSCRM"))+": "

		@ li,0 PSAY SM0->M0_NOME + "-" + SM0->M0_FILIAL + cCGC + SM0->M0_CGC
		Li += 1
		@ li,0 PSAY __PrtThinLine()
		Li += 1
		@ li,0 PSAY If(cPaisLoc=="MEX","STR0107","Dados do Cliente                                                     |Nota Fiscal| Espec| Tipo da Nota        | Emissao  | Vencto") //"Dados do Cliente                                                                                 | Nota Fiscal  | Emissao  | Vencto"
		Li += 1
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
		cTipoNF	:= aCombo1[aScan(aAuxCombo1,(cAliasSF1)->F1_TIPO)]

		@ li,000 PSAY SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SUBS(SA1->A1_NOME,1,40)
		@ li,If(cPaisLoc=="BRA",069,065)-nIncCol PSAY "| "+(cAliasSF1)->F1_SERIE+" "+(cAliasSF1)->F1_DOC
		@ li,084 PSAY "| "+(cAliasSF1)->F1_ESPECIE
		@ li,091 PSAY "| "+PadR(CtipoNF,18)
		@ li,111 PSAY "|"+DTOC((cAliasSF1)->F1_EMISSAO)
		@ li,122 PSAY IIf( Len(aVencto) == 1,"|"+DTOC(aVencto[1]),If(Len(aVencto) ==0,"|"+"STR0115","|"+"Diversos")) //
		Li += 1
		@ li,000 PSAY SA1->A1_END
		@ li,If(cPaisLoc=="BRA",069,065)-nIncCol PSAY "| Valor Total   "
		@ li,115 PSAY transform(((cAliasSF1)->F1_VALBRUT),PesqPict("SF1","F1_VALBRUT")) //"| Valor Total   "
		Li += 1
		@ li,000 PSAY SA1->A1_MUN+" "+SA1->A1_EST+" "+Substr(cCGC,4,Len(cCGC)-3)+" "+If(cPaisLoc<>"BRA",Transform(SA1->A1_CGC,PesqPict("SA1","A1_CGC")),Transform(SA1->A1_CGC,PicPesFJ(If(Len(AllTrim(SA1->A1_CGC))<14,"F","J"))))+" "+cIE+" "+SA1->A1_INSCR+" "+cIEM+" "+SA1->A1_INSCRM //" CGC: "###"  I.E: "###"  I.M. "
	Else
		dbSelectArea("SE2")
		SE2->(dbSetOrder(6))
		SE2->(dbSeek(xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC))
		While SE2->(!Eof()) .And. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC
			If ALLTRIM(E2_ORIGEM)=="MATA100"
				aADD(aVencto,E2_VENCTO)
			EndIf
			SE2->(dbSkip())
		End
		@ li,000 PSAY OemToAnsi("N. ")+SD1->D1_NUMSEQ+Space(68)+OemToAnsi("Data Impressao ")+Dtoc(Date())+Space(14)+OemToAnsi("Hora Ref. ")+Time()   // N. ### Data Impressao ### Hora Ref.
		li += 1
		@ li,000 PSAY "BOLETIM DE ENTRADA      Material recebido em: " +Dtoc((cAliasSF1)->F1_DTDIGIT) //
		li += 1

		cCGC:=" - "
		cCGC+=Alltrim(RetTitle("A1_CGC"))
		cCGC+=": "
		cIE:=" "+AllTrim(RetTitle("A1_INSCR"))+": "
		cIEM:=" "+AllTrim(RetTitle("A1_INSCRM"))+": "

		@ li,0 PSAY SM0->M0_NOME + "-" + SM0->M0_FILIAL + cCGC + SM0->M0_CGC //" - CGC.: "
		li += 1
		@ li,000 PSAY __PrtThinLine()
		li += 1
		@ li,0 PSAY If(cPaisLoc=="BRA","Dados do Fornecedor                                                  |Nota Fiscal| Espec| Tipo da Nota        | Emissao  | Vencto",If(cPaisLoc=="MEX","STR0108","Dados do Fornecedor                                                  |Nota Fiscal       | Espec| Tipo da Nota     | Emissao  | Vencto")) //"Dados do Fornecedor                                                                              | Nota Fiscal  | Emissao  | Vencto"
		li += 1
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(XFilial("SA2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
		cTipoNF	:= aCombo1[aScan(aAuxCombo1,(cAliasSF1)->F1_TIPO)]
		cNumDoc := If(cPaisLoc=="BRA",(cAliasSF1)->F1_DOC,PadR((cAliasSF1)->F1_DOC,If(cPaisLoc=="MEX",21,13),""))

		@ li,000 PSAY SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+SubStr(SA2->A2_NOME,1,40)
		@ li,069-nIncCol PSAY "| "+(cAliasSF1)->F1_SERIE+" "+cNumDoc
		@ li,If(cPaisLoc=="BRA",84,88) PSAY "| "+(cAliasSF1)->F1_ESPECIE
		@ li,If(cPaisLoc=="BRA",91,95) PSAY "| "+PadR(CtipoNF,If(cPaisLoc=="BRA",19,16))
		@ li,If(cPaisLoc=="BRA",111,114) PSAY "|"+DTOC((cAliasSF1)->F1_EMISSAO)
		@ li,If(cPaisLoc=="BRA",122,125) PSAY "|"+IIf( Len(aVencto) == 1, DTOC(aVencto[1]), Iif(Len(aVencto) == 0,"STR0115","Diversos")) //

		li += 1
		@ li,000 PSAY SA2->A2_END
		@ li,069-nIncCol PSAY "| Valor Total   "
		@ li,115 PSAY transform(((cAliasSF1)->F1_VALBRUT),PesqPict("SF1","F1_VALBRUT")) //"| Valor Total   "
		li += 1
		@ li,000 PSAY SA2->A2_MUN+" "+SA2->A2_EST+" "+Substr(cCGC,4,Len(cCGC)-3)+" "+If(cPaisLoc<>"BRA",Transform(SA2->A2_CGC,PesqPict("SA2","A2_CGC")),Transform(SA2->A2_CGC,PicPesFJ(If(Len(AllTrim(SA2->A2_CGC))<14,"F","J"))))+" "+cIE+" "+SA2->A2_INSCR+" "+cIEM+" "+SA2->A2_INSCRM //" CGC: "###"  I.E: "###"  I.M. "
	EndIf
	li += 1
Return( li )

/*/================================================================================================================================/*/
/*/{Protheus.doc} R170Load
Imprime texto na posição especificada no relatório.

@type function
@author Edson Maricate
@since 06/07/2000
@version P12.1.23

@param nPos, Numérico, Posição a ser impresso texto.
@param cTexto, Caractere, Texto a ser impresso.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function R170Load(nPos,cTexto)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cAuxLinha := Substr(cAuxLinha,1,nPos)+cTexto+Substr(cAuxLinha,nPos+Len(cTexto)+1,132-nPos+Len(cTexto))

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} R170Say
Imprime uma linha em branco na posição recebida por parâmetro.

@type function
@author Thiago Rasmussen
@since 06/07/2000
@version P12.1.23

@param nLinha, Numérico, Linha a ser preenchida com brancos.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function R170Say(nLinha)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	@ nLinha,000 PSAY cAuxLinha
	cAuxLinha := SPACE(132)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} R170IMPT
Faz a somatoria dos impostos da nota.
Retornando um array com todas as informacoes a serem impressas.

@type function
@author Armando P. Waiteman
@since 08/07/2001
@version P12.1.23

@param cAliasSF1, Caractere, Alias do arquivo SF1.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com todas as informacoes a serem impressas.

/*/
/*/================================================================================================================================/*/

Static Function R170IMPT(cAliasSF1)


	Local aArea    := {}
	Local aAreaSD1 := {}
	Local aImp     := {}
	Local aImpostos:= {}
	Local nImpos:= 0
	Local nBase := 0
	Local nY,cCampImp,cCampBas

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aArea:=GetArea()


	dbSelectArea("SD1")
	aAreaSD1:=GetArea()

	SD1->(dbSetOrder(3))

	cSeek:=(xFilial("SD1")+Dtos((cAliasSF1)->F1_EMISSAO)+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+;
	(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)

	If SD1->(dbSeek(cSeek))
		While cSeek==xFilial("SD1")+dtos(D1_EMISSAO)+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
			aImpostos:=TesImpInf(D1_TES)
			For nY:=1 to Len(aImpostos)
				cCampImp:="SD1->"+(aImpostos[nY][2])
				cCampBas:="SD1->"+(aImpostos[nY][7])
				nImpos+=&cCampImp
				nBase +=&cCampBas
			Next
			SD1->(dbSkip())
		Enddo
	EndIf

	RestArea(aAreaSD1)
	RestArea(aArea)

	AADD(aImp,nBase)
	AADD(aImp,nImpos)


Return aImp

/*/================================================================================================================================/*/
/*/{Protheus.doc} R170IMPI
Retorna array com lista de impostos por item.

@type function
@author Armando P. Waiteman
@since 08/07/2001
@version P12.1.23

@param cAliasSF1, Caractere, Alias do arquivo SF1.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com lista de impostos por item.

/*/
/*/================================================================================================================================/*/

Static Function R170IMPI(cAliasSF1)


	Local aArea    := {}
	Local aAreaSD1 := {}
	Local aImp     := {}
	Local aRet     := {}
	Local nY

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aArea:=GetArea()


	dbSelectArea("SD1")
	aAreaSD1:=GetArea()

	SD1->(dbSetOrder(3))

	cSeek:=(xFilial("SD1")+Dtos((cAliasSF1)->F1_EMISSAO)+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+;
	(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)

	If SD1->(dbSeek(cSeek))
		While cSeek==xFilial("SD1")+dtos(D1_EMISSAO)+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
			aImp:=TesImpInf(D1_TES)

			// Pega a descricao do produto
			dbSelectArea("SB1")
			aAreaSB1:=GetArea()
			SD1->(dbSetOrder(1))
			SD1->(dbSeek(xFilial("SB1")+SD1->D1_COD))
			cDescProd:=B1_DESC
			RestArea(aAreaSB1)

			dbSelectArea("SD1")
			For nY:=1 to Len(aImp)
				AADD(aRet,{SD1->D1_COD,cDescProd,aImp[nY][1],&("SD1->"+aImp[nY][10]),&("SD1->"+(aImp[nY][7])),&("SD1->"+(aImp[nY][2]))})
			Next
			SD1->(dbSkip())
		Enddo
	EndIf

	If Len(aRet)<= 0
		AADD(aRet,{"" ,"" ,"" ,0 ,0 ,0})
	EndIf

	RestArea(aAreaSD1)
	RestArea(aArea)

Return aRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} R170DUPL
Imprime o Desdobramento de duplicatas.

@type function
@author ALexandre I. Lemes
@since 04/01/2002
@version P12.1.23

@param Li, Numérico, Posição da linha.
@param Col, Numérico, Posição da Coluna.

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function R170DUPL(Li,Col)
	Local nIncCol := If(cPaisLoc=="MEX",8,0)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SE2")

	If Li >= 60
		Li := 1
		@ Li,000 PSAY "--------------------------------------------------- DESDOBRAMENTO DE DUPLICATAS ----------------------------------------------------" //
		Li := Li + 1
		@ Li,000 PSAY If(cPaisLoc=="MEX","STR0109","Ser|Titulo/Parc. | Vencto   |Valor do Titulo  | Natureza          ||Ser|Titulo/Parc. | Vencto   |Valor do Titulo  | Natureza        ") //"Ser|Titulo       | Vencto   |Valor do Titulo  | Natureza          ||Ser|Titulo       | Vencto   |Valor do Titulo  | Natureza        "
		Li := Li + 1
	Endif

	R170Load(Col,SE2->E2_PREFIXO)
	R170Load(Col+4,SE2->E2_NUM)
	R170Load(Col+16+nIncCol,SE2->E2_PARCELA)
	R170Load(Col+18+nIncCol,dtoc(SE2->E2_VENCTO))
	R170Load(Col+29+nIncCol,Transform(SE2->E2_VALOR,"@E 99,999,999,999.99"))
	R170Load(Col+48+nIncCol,SE2->E2_NATUREZ)

	If Col == 0
		Col := 68
	Else
		Col := 0
		R170Say(Li)
		R170Load(0,cLinha)
		Li := Li + 1
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustaSX1
Ajusta perguntas do SX1.

@type function
@author Aline Correa do Vale
@since 16/01/2004
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function AjustaSX1()

	Local aAreaAnt	 := GetArea()
	Local aAreaSX1	 := SX1->(GetArea())
	Local aAreaSX3	 := SX3->(GetArea())
	Local aSXB		 := {}
	Local nTamSX1    := Len(SX1->X1_GRUPO)
	Local nTamSXB    := Len(SXB->XB_ALIAS)
	Local aEstrut	 := {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}
	Local i			 := 1
	Local j			 := 1
	Local aHelpPor07 := {'Ordem de Impressao ', '', ''}
	Local aHelpEsp07 := {'Orden de impresion ', '', ''}
	Local aHelpEng07 := {'Print Order        ', '', ''}
	Local aHelpPor08 := {'Se voce escolher imprimir o Armazem,  ', 'a descricao do Produto sera'      , 'reduzida em duas posicoes.'}
	Local aHelpEsp08 := {'Si usted elige imprimir el Deposito,  ', 'la descripcion del producto sera ', 'reducida en dos posiciones.'}
	Local aHelpEng08 := {'If you choose to print the Warehouse, ', 'the product description will be'  , 'reduced in two positions.'}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	PutSX1Help("P.MTR17007.", aHelpPor07, aHelpEng07, aHelpEsp07)

	PutSx1('MTR170','08','Imprime Armazem    ?','Imprime Deposito   ?','Show  Warehouse    ?','mv_ch8','N',2,0,2,'C','','','','','mv_par08','Sim','Si','Yes','','Nao','No','No','','','','','','','','','', aHelpPor08, aHelpEsp08, aHelpEng08)

	// Ajusta a opcao do tipo
	dbSelectArea("SX1")
	If SX1->(dbSeek(PADR("MTR170",nTamSX1)+"05"))
		RecLock("SX1",.F.)
		Replace X1_DEF03   With "Entidade Contab"
		Replace X1_DEFSPA3 With "Ente Contable"
		Replace X1_DEFENG3 With "Account.Entity"
		SX1->(MsUnLock())
	EndIf

	//-- Consulta SXB
	Aadd(aSXB,{"SD1NF","1","01","DB"	,"Documento de Entrada"	,"Factura de Entrada"	,"Inflow Invoice"		,"SD1"       		})
	Aadd(aSXB,{"SD1NF","2","01","01"	,"Documento"			,"Factura"				,"Document"				,"SD1"       		})
	Aadd(aSXB,{"SD1NF","4","01","01"	,"Documento"			,"Factura"				,"Document"				,"SD1->D1_DOC"  	})
	Aadd(aSXB,{"SD1NF","4","01","02"	,"Serie"				,"Serie"				,"Series"				,"SD1->D1_SERIE"	})
	Aadd(aSXB,{"SD1NF","4","01","03"	,"Fornecedor"			,"Proveedor"			,"Supplier"				,"SD1->D1_FORNECE"	})
	Aadd(aSXB,{"SD1NF","4","01","04"	,"Loja"		   			,"Tienda"				,"Unit"					,"SD1->D1_LOJA"		})
	Aadd(aSXB,{"SD1NF","4","01","05"	,"Item"					,"Item"					,"Item"					,"SD1->D1_ITEMORI"	})
	Aadd(aSXB,{"SD1NF","5","01",""		,""						,""						,""						,"SD1->D1_DOC"		})

	dbSelectArea("SXB")
	SXB->(dbSetOrder(1))
	For i := 1 To Len(aSXB)
		If !Empty(aSXB[i][1])
			If SXB->(!dbSeek(PADR(aSXB[i,1],nTamSXB)+aSXB[i,2]+aSXB[i,3]+aSXB[i,4]))
				lSXB := .T.
				RecLock("SXB",.T.)
				For j:=1 To Len(aSXB[i])
					If !Empty(FieldName(FieldPos(aEstrut[j])))
						FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
					EndIf
				Next j
				SXB->(dbCommit())
				SXB->(MsUnLock())
			EndIf
		EndIf
	Next i

	//+----------------------------------+
	//|Ajustando o dicionario SX1        |
	//+----------------------------------+
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If SX1->(dbSeek(PADR('MTR170',nTamSX1)+"03") .And. Empty(SX1->X1_F3))
		RecLock("SX1",.F.)
		Replace X1_F3 With 'SD1NF'
		SX1->(MsUnLock())
	EndIf
	If SX1->(dbSeek(PADR('MTR170',nTamSX1)+"04") .And. Empty(SX1->X1_F3))
		RecLock("SX1",.F.)
		Replace X1_F3 With 'SD1NF'
		SX1->(MsUnLock())
	EndIf
	RestArea(aAreaSX1)
	RestArea(aAreaSX3)
	RestArea(aAreaAnt)
Return
