#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} FA050DEL
Funcao para validar e excluir titulo de imposto RPA.

@type function
@author TOTVS
@since 30/08/2011
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function FA050DEL()

Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local aAreaSE2  := SE2->(GetArea())
Local aAreaSED  := SED->(GetArea())
Local aTitulo	:= {}
Local nRecSE2	:= 0
Local cIDRPA 	:= ""        
Local lPrjCni   := FindFunction("ValidaCNI") .And. ValidaCNI()
Local cAliasNw  := "SE6_TMP"              
Local cQuery

Private lMsErroAuto := .F.  

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If SE2->E2_PREFIXO $ "DIA/FFX/AJC"
	MsgStop("Titulos referentes ao processo de viagens não podem ser excluídos manualmente.","Verifique")
	lRet := .F.
EndIf

//--< Verifica se o titulo esta amarrado em rateios >-------
If lRet .and. !lF050Auto .and. !Empty(SE2->E2_XMUTUO)
	MsgStop("Este título está amarrado ao rateio "+SE2->E2_XMUTUO+" e não poderá ser excluído!","Verifique")
	lRet := .F.
EndIf

If lRet .and. !Empty(SE2->E2_XIDRPA)
	MsgStop("Para exclusão deste título é necessário excluir o documento principal. Verifique!","Verifique")
	lRet := .F.
EndIf

If lRet .and. lPrjCni
	dbSelectArea('SE2')
                            
	cQuery := "Select E6_NUM  FROM " + RetSqlName("SE6")  + " WHERE E6_NUM = '" + SE2->E2_NUM + "' AND E6_PREFIXO = '" + SE2->E2_PREFIXO + "'  "
	cQuery :=  cQuery + " AND E6_FILIAL = '" + SE2->E2_FILIAL + "' AND D_E_L_E_T_ <> '*' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNw,.F.,.T.)                  

	If !(cAliasNw)->(Eof())
		MsgAlert("O Título foi criado pelo processo de Transferência! Efetuar o estorno desta Transferência!")         
		lRet := .F.
	EndIf              

	(cAliasNw)->(dbCloseArea())
EndIf

If (lRet)
	If !(IsInCallStack("U_SIFINA14"))
		If (SE2->E2_XTPTRF == "2")
			MsgStop("Este título foi gerado através da rotina de Transferência de Títulos." + CRLF + "Não é possível realizar esta exclusão!")
			lRet     := .F.
		Endif
	Endif
Endif

If lRet
	If Alltrim(SE2->E2_TIPO) == "RPA"
		SE2->(DbOrderNickName("SISE203"))
		_nRecno := SE2->(Recno())
		IF SE2->(DbSeek(XFilial("SE2")+&("SE2->("+SE2->(IndexKey(1))+")")))
			//--< Limpa flag, senao nao consegue excluir. >-
			nRecSE2	:= SE2->(Recno())
			cIDRPA 	:= SE2->E2_XIDRPA
			RecLock("SE2",.F.)
				SE2->E2_XIDRPA	:= ""
			SE2->(MsUnLock())
			
			aTitulo := { 	{"E2_PREFIXO"	, SE2->E2_PREFIXO	,	Nil},;
			{"E2_NUM"		, SE2->E2_NUM		, 	Nil},;
			{"E2_PARCELA"	, SE2->E2_PARCELA	,	Nil},;
			{"E2_TIPO"		, SE2->E2_TIPO		, 	Nil},;
			{"E2_NATUREZ"	, SE2->E2_NATUREZA	,	Nil},;
			{"E2_FORNECE"	, SE2->E2_FORNECE	,   Nil},;
			{"E2_LOJA"		, SE2->E2_LOJA		,	Nil},;
			{"E2_MOEDA"		, SE2->E2_MOEDA		,	NIL}}
			
			lMsErroAuto := .F.
			MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,5)
			
			If lMsErroAuto
				//--< Se ocorre erro na exclusao do imposto, retorna campo do titulo original, que foi limpo. >--
				SE2->(DbGoTo(nRecSE2))
				RecLock("SE2",.f.)
					SE2->E2_XIDRPA := cIDRPA
				SE2->(MsUnLock())
				MostraErro()
				lRet := .F.
			EndIf

			//--< volta posição atual >---------------------
			SE2->(dbGoTo(_nRecno))
			
			cPrefixo  := SE2->E2_PREFIXO
			cNum	  := SE2->E2_NUM
			cParcela  := SE2->E2_PARCELA
			cNatureza := SE2->E2_NATUREZ
			cFornece  := SE2->E2_FORNECE
			cTipo 	  := SE2->E2_TIPO
			cParcIr	  := SE2->E2_PARCIR
			cParcIss  := SE2->E2_PARCISS
			cParcInss := SE2->E2_PARCINS
			cParcSEST := SE2->E2_PARCSES
			nIss	  := SE2->E2_ISS
			nInss	  := SE2->E2_INSS
			nSEST	  := SE2->E2_SEST			
			nPis	  := SE2->E2_PIS
			nCofins	  := SE2->E2_COFINS
			nCsll	  := SE2->E2_CSLL
			cParcPis  := SE2->E2_PARCPIS
			cParcCof  := SE2->E2_PARCCOF
			cParcCsll := SE2->E2_PARCSLL
			
		EndIf
	EndIf
EndIf            

SE2->(RestArea(aAreaSE2))
SED->(RestArea(aAreaSED))
RestArea(aArea)

Return(lRet)
