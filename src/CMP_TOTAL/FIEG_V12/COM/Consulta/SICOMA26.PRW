#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA26
Consulta de Valores na SC.

@type function
@author Leonardo Soncin
@since 16/12/2011
@version P12.1.23

@obs Projeto ELO

@history 21/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nulo, função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SICOMA26

//--< Declaracao de Variaveis >-----------------------------
Local aArea 	:= GetArea()
Local cPerg 	:= "SICA12"
Local cQuery 	:= ""
Local nPosCod 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C1_PRODUTO"})
Local cCod 		:= aCols[n][nPosCod]
Local cAliasTRB	:= GetNextAlias()

Local cTitulo	:= "Consulta de Compras"
Local oDlg, oLbx

Local aList		:={}
Local nSaldoC1 	:= 0
Local nSaldoNF	:= 0
Local nTotal	:= 0
Local cGrupo    := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+cCod))

cGrupo := SB1->B1_GRUPO

AjustaSX1(cPerg)

If Pergunte(cPerg,.T.)
	
	nSaldoC1 := xRetSld(cCod,cGrupo,"SC1")
	nSaldoC7 := xRetSld(cCod,cGrupo,"SC7")
	nSaldoNF := xRetSld(cCod,cGrupo,"SF1")
	
	aAdd( aList, { Iif(MV_PAR01==1,cCod,cGrupo), Transform(nSaldoC1,PesqPict("SC1","C1_TOTAL")) ,Transform(nSaldoC7,PesqPict("SC7","C7_TOTAL")) , Transform(nSaldoNF,PesqPict("SD1","D1_TOTAL")) } )
	
	nTotal := nSaldoC1 + nSaldoC7 + nSaldoNF
	
	If !Len(aList) == 0
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,650 PIXEL
		
		@ 10,10 LISTBOX oLbx FIELDS HEADER "Produto/Grupo", "Vl. Solicitação de Compras", "Vl. Pedido de Compras","Vl. Nota de Entrada" SIZE 305,95 OF oDlg PIXEL
		
		oLbx:SetArray( aList )
		oLbx:bLine := {|| {aList[oLbx:nAt,1],;
		aList[oLbx:nAt,2],;
		aList[oLbx:nAt,3],;
		aList[oLbx:nAt,4]}}
		
		@ 107,10 SAY "Total:" SIZE 45,8 PIXEL OF oDlg
		@ 107,35 SAY Transform(nTotal,PesqPict("SC1","C1_TOTAL")) SIZE 45,8 PIXEL OF oDlg
		
		DEFINE SBUTTON FROM 107,290 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTER
		
	Else
		MsgInfo("Não existem dados para esta consulta.","Atenção")
	Endif
	
Endif

RestArea(aArea)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustaSX1
Ajusta o grupo de perguntas.

@type function
@author Marcos V. Ferreira
@since 21/06/2006
@version P12.1.23

@obs Projeto ELO

@history 21/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nulo, função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function AjustaSX1(cPerg)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
PutSx1(cPerg,'01' ,'Visualiza por', 'Visualiza por', 'Visualiza por',	'mv_ch1', 'N', 1, 0, 3, 'C','','','','', 'mv_par01','Produto',;
'Produto','Produto', '','Grupo de Produto','Grupo de Produto','Grupo de Produto','','','','','','','','','',{"Indica se a soma de valores das Solicitações, Pedidos e Notas de Entrada de Compras é por produto ou grupo de produtos."},{"Indica se a soma de valores das Solicitações, Pedidos e Notas de Entrada de Compras é por produto ou grupo de produtos."},{"Indica se a soma de valores das Solicitações, Pedidos e Notas de Entrada de Compras é por produto ou grupo de produtos."},)
                                                                                                                                 
Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} xRetSld
Retorna Saldos.

@type function
@author Leonardo Soncin
@since 19/12/2011
@version P12.1.23

@param cCod, Caractere, Código do Produto.
@param cGrupo, Caractere, Grupo de Produto.
@param cTabela, Caractere, Tabela a ser consultada.

@obs Projeto ELO

@history 21/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return nRet, Retorna o Saldo.
/*/
/*/================================================================================================================================/*/

Static Function xRetSld(cCod,cGrupo,cTabela)

Local nRet 		:= 0
Local cQuery 	:= ""
Local cAliasTRB	:= GetNextAlias()
Local cAno 		:= Alltrim(Str(Year(dDataBase)))
Local lOracle	:= "ORACLE"$Upper(TCGetDB())

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If cTabela == "SC1"
	
	cQuery := "SELECT Sum((C1_QUANT-C1_QUJE) * C1_VUNIT) AS SALDO FROM "
	cQuery += RetSqlName("SC1")+" SC1 "
	If MV_PAR01 == 1
		cQuery += " WHERE C1_FILIAL = '"+xFilial("SC1")+"' AND C1_PRODUTO = '"+cCod+"' AND "
	Else
		cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = C1_PRODUTO AND SB1.D_E_L_E_T_ = '' AND B1_GRUPO = '"+cGrupo+"' "
		cQuery += " WHERE C1_FILIAL = '"+xFilial("SC1")+"' AND C1_PRODUTO = B1_COD AND"
	Endif
	cQuery += " C1_PEDIDO = '' AND C1_RESIDUO <> 'S' AND "
	cQuery += " C1_QUANT <> C1_QUJE AND "
	If lOracle
		//cQuery += " TO_CHAR(TO_DATE(C1_EMISSAO,'YYYYMMDD'),'YYYY') = "+cAno+" AND "
		cQuery += " SUBSTRING(C1_EMISSAO,1,4) = '"+cAno+"' AND "
	Else
		cQuery += " Year(C1_EMISSAO) = "+cAno+" AND "	
	Endif
	cQuery += " SC1.D_E_L_E_T_ <> '*' "
	
ElseIf cTabela == "SC7"
	
	cQuery := "SELECT Sum((C7_QUANT-C7_QUJE) * C7_PRECO) AS SALDO FROM "
	cQuery += RetSqlName("SC7")+" SC7 "	
	If MV_PAR01 == 1
		cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' AND C7_PRODUTO = '"+cCod+"' AND "
	Else
		cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_ = '' AND B1_GRUPO = '"+cGrupo+"' "
		cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' AND C7_PRODUTO = B1_COD AND "
	Endif	
	cQuery += " C7_ENCER <> 'S' AND C7_RESIDUO <> 'S' AND "
	If lOracle
		cQuery += " TO_CHAR(TO_DATE(C7_EMISSAO,'YYYYMMDD'),'YYYY') = "+cAno+" AND "
	Else
		cQuery += " Year(C7_EMISSAO) = "+cAno+" AND "	
	Endif
	cQuery += " SC7.D_E_L_E_T_ <> '*' "
	
Else
	
	cQuery := "SELECT Sum(D1_TOTAL) AS SALDO FROM "
	cQuery += RetSqlName("SD1")+" SD1 "
	If MV_PAR01 == 1
		cQuery += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' AND D1_COD = '"+cCod+"' AND "
	Else
		cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ = '' AND B1_GRUPO = '"+cGrupo+"' "
		cQuery += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' AND D1_COD = B1_COD AND "
	Endif	
	If lOracle
		cQuery += " TO_CHAR(TO_DATE(D1_EMISSAO,'YYYYMMDD'),'YYYY') = "+cAno+" AND "
	Else
		cQuery += " Year(D1_EMISSAO) = "+cAno+" AND "
	Endif
	cQuery += " SD1.D_E_L_E_T_ <> '*' "	
	
	/*
	cQuery := "SELECT Sum(F1_VALBRUT) AS SALDO FROM "
	cQuery += RetSqlName("SF1")+" SF1 "
	If MV_PAR01 == 1
		cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SD1")+" SD1 ON D1_FILIAL = '"+xFilial("SD1")+"' AND D1_DOC = F1_DOC AND "
		cQuery +=  "D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND SD1.D_E_L_E_T_ = '' AND D1_COD = '"+cCod+"' "
	Else
		cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SD1")+" SD1 ON D1_FILIAL = '"+xFilial("SD1")+"' AND D1_DOC = F1_DOC AND "
		cQuery +=  "D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND SD1.D_E_L_E_T_ = '' "		
		cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ = '' AND B1_GRUPO = '"+cGrupo+"' "
	Endif	
	cQuery += " WHERE F1_FILIAL = '"+xFilial("SF1")+"' AND "	
	If lOracle
		cQuery += " TO_CHAR(TO_DATE(F1_EMISSAO,'YYYYMMDD'),'YYYY') = "+cAno+" AND "
	Else
		cQuery += " Year(F1_EMISSAO) = "+cAno+" AND "
	Endif
	cQuery += " SF1.D_E_L_E_T_ <> '*' "
	*/
		
Endif

cQuery := ChangeQuery(cQuery)

If Select(cAliasTRB) > 0
	//dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.F.)

//DbSelectArea(cAliasTRB)
(cAliasTRB)->(dbGotop())

If !Eof()
	nRet := (cAliasTRB)->SALDO
Endif

Return nRet
