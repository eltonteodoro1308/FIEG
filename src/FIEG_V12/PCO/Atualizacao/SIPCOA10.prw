#Include "Protheus.ch"
#include "ap5mail.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA10
Rotina para executar a finalizacao da Digitacao.

@type function
@author Claudinei Ferreira
@since 10/01/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIPCOA10
	Local lRet		:= .T.
	Local lAchou	:= .F.
	Local aVet		:= {}
	Local nPosRespCC:= 0
	Local _aArea	:= GetArea()
	Local _aAreaCTT	:= CTT->(GetArea())
	Local aPergs	:= {}
	Local nTamCC	:= Space(TamSx3("CTT_CUSTO")[1])
	Local _aRet 	:= {}
	Local CTG    	:= ''
	Private _aCTT   := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+----------------------------------------------------------+
	//|Executa validacao para prosseguir finalizacao da Digitacao|
	//+----------------------------------------------------------+

	//+----------------------------------------------------------+
	//|Verifica se Acols dos itens AK2 nao esta em modo de edicao|
	//+----------------------------------------------------------+
	If Eval(oWrite:bWhen)
		MsgStop("Existe itens que não foram gravados, grave os itens para Finalização da Digitação","Atencao")
		lRet:= .F.
	Else
		aAdd(aPergs,{1,"UO De : ",nTamCC,"@!","","CTT","",nTamCC,.F.})
		aAdd(aPergs,{1,"UO Até: ",Replicate("Z",TamSx3("CTT_CUSTO")[1]),"@!","","CTT","",nTamCC,.T.})

		If  ParamBox(aPergs,"Selecione a UO para finalização",@_aRet)
			/*
			lRet:= .F.

			//+----------------------------------------------------------------+
			//|Posiciona na CTT para verificar se usuario e resp. de C.Custo   |
			//+----------------------------------------------------------------+
			CTT->(DBCloseArea())
			dbSelectArea('CTT')
			CTT->(dbSetOrder(1))

			//+----------------------------+
			//|Carrega o Vetor do LISTBOX  |
			//+----------------------------+
			CTT->(dbEval({|| AADD(aVet, {CTT->(CTT_CUSTO),;
			CTT->(CTT_DESC01),;
			CTT->(CTT_USER)})},, {|| !EOF() }))
			CTT->(dbCloseArea())

			//+------------------------------------------------------+
			//|Valida se existe registros como responsavel de um CTT |
			//+------------------------------------------------------+
			nPosRespCC:= aScan(aVet,{|x| AllTrim(x[3])==__CUSERID})

			If nPosRespCC == 0 .and. __CUSERID <> "000000"
			MsgStop("Somente o usuario responsavel por Centro de Custo poderá executar a rotina para Finalizar Digitação!","Atencao")
			lRet:= .F.
			Return
			Endif
			*/

			IF SELECT("TRB1")>0
				DbSelectArea("TRB1")
				TRB1->(DbCloseArea())
			EndIf

			CTG  := " Select CTT_CUSTO  "
			CTG  += " FROM " + RetSqlName("CTT")
			CTG  += "   Where CTT_USER   = '" + __CUSERID  +"' "
			CTG  += "   and   CTT_CUSTO >= '" + _aRet[1]   +"' "
			CTG  += "   and   CTT_CUSTO <= '" + _aRet[2]   +"' "
			CTG  += "   and   D_E_L_E_T_ = ' '     "
			DBUseArea(.T.,"TOPCONN",TCGENQRY(,,CTG),"TRB1",.F.)

			If Empty(TRB1->CTT_CUSTO)
				MsgAlert("Conforme Faixa de Centro de Custo mencionada, foi identificado que o seu Usuário não é o resposável por nenhum dos Centros de Custos. A rotina para Finalizar Digitação, não poderá ser executada!","Atencao")
				lRet:= .F.

			Else
				TRB1->(DbGoTop())
				While !TRB1->(Eof())
					aAdd(_aCTT,{TRB1->CTT_CUSTO})
					TRB1->(DBSkip())
				EndDO
				TRB1->(Dbclosearea())
			Endif

		Endif


		//+------------------------------------------------+
		//|Executa Gravacao para finalizar item da Planilha|
		//+------------------------------------------------+
		If lRet
			Processa({|| GrvFlzDig(_aRet) },"Aguarde","Processando itens...")
		Endif

	Endif

	RestArea(_aAreaCTT)
	RestArea(_aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} GrvFlzDig
Grava campo AK2_XSTS=1 (Finalizado) conforme acesso.

@type function
@author Claudinei Ferreira
@since 15/01/2012
@version P12.1.23

@param _aRet, Array, Array populado com os parâmetros do Parambox.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GrvFlzDig(_aRet)
	//Local lAcessOk		:= .F.
	Local lVisualiza	:= .T.
	Local _aArea		:= GetArea()
	Local _aAreaAK2		:= AK2->(GetArea())
	Local _aAreaCTT		:= CTT->(GetArea())
	Local aUOFim		:= {}
	Local cDescCC		:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+----------------------------------------------------------------+
	//|Verifica se usuario possui acesso ao C.Custo e finaliza item    |
	//|conforme os parametros informado de Centro de Custo			   |
	//+----------------------------------------------------------------+
	dbSelectArea('AK2')
	AK2->(dbSetOrder(1))
	AK2->(dbSeek(xFilial('AK2')+AK1->(AK1_CODIGO+AK1_VERSAO)))

	Begin Transaction

		While AK2->(!Eof()) .and. AK2->(AK2_FILIAL+AK2_ORCAME+AK2_VERSAO) = AK1->(AK1_FILIAL+AK1_CODIGO+AK1_VERSAO)

			If  aScan(_aCTT,{|x| AllTrim(x[1])==AllTrim(AK2->(AK2_CC))}) > 0

				RecLock("AK2", .F.)
				AK2->AK2_XSTS := '1'
				AK2->(MsUnLock())

				nPos := Ascan(aUOFim,{|x| AllTrim(x[1])==AllTrim(AK2->(AK2_CC))})

				If nPos == 0
					cDescCC:= Posicione('CTT',1,xFilial('CTT')+AK2->AK2_CC,'CTT_DESC01')
					AADD(aUOFim,{AK2->AK2_CC,cDescCC})
				Endif

			Endif
			AK2->(dbSkip())
		Enddo

	End Transaction

	If !Empty(aUOFim)
		//+----------------------------------------------------------------------------+
		//|Enviar email para o responsavel da planilha com a finalizacao do C.Custo    |
		//+----------------------------------------------------------------------------+
		EmailRPlan(aUOFim)

		MsgAlert("Uo(s) Finalizada(s) com sucesso !", "Processamento concluído")
	Endif

	// Somente para visualização completa
	IF MV_PAR01 == "1"
		For i := 1 to Len(oGD[1]:aCols)
			_cCC  := GDFieldGet("AK2_CC",i,,oGD[1]:aHeader,oGD[1]:aCols)
			_cID  := GDFieldGet("AK2_ID",i,,oGD[1]:aHeader,oGD[1]:aCols)
			_cOpc := Posicione("AK2",8,XFilial("AK2")+AK1->(AK1_CODIGO+AK1_VERSAO)+_cCC+_cID,"AK2_XSTS")
			GDFieldPut("AK2_XSTS",_cOpc,i,oGD[1]:aHeader,oGD[1]:aCols)
		Next
	ENDIF

	RestArea(_aAreaAK2)
	RestArea(_aAreaCTT)
	RestArea(_aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIVldAK2_CC_CV_IC
Funcao para validar acesso do usuario conforme registro AK2.

@type function
@author Claudinei Ferreira
@since 15/01/2012
@version P12.1.23

@param lVisualiza, Lógico, Indica se visuzliza.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para a validação do acesso do usuário.

/*/
/*/================================================================================================================================/*/

User Function SIVldAK2_CC_CV_IC(lVisualiza)
	Local lRet    := .T.
	Local cCtaOrc := AK2->AK2_CO
	Local cCCusto := AK2->AK2_CC
	Local cItCtb  := AK2->AK2_ITCTB
	Local cClVlr  := AK2->AK2_CLVLR
	Local cRevisa := AK1->AK1_VERSAO
	Local lMore

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !Empty(cCtaOrc)
		dbSelectArea("AK3")
		AK3->(dbSetOrder(1))
		If AK3->(MsSeek(xFilial()+AK1->AK1_CODIGO+cRevisa+cCtaOrc))
			lMore := .T.
			While lMore
				// verifica centro de custo
				lRet := !Empty(cCCusto)
				If lRet
					lRet := PcoCC_User(AK1->AK1_CODIGO,AK3->AK3_CO,AK3->AK3_PAI,2,"CCUSTO",cRevisa,cCCusto,If(lVisualiza, 1, 2) )
					If ! lRet
						Exit
					EndIf
				EndIf
				//verifica item contabil
				lRet := !Empty(cItCtb)
				If lRet
					lRet := PcoIC_User(AK1->AK1_CODIGO,AK3->AK3_CO,AK3->AK3_PAI,2,"ITMCTB",cRevisa,cItCtb,If(lVisualiza, 1, 2) )
					If ! lRet
						Exit
					EndIf
				EndIf
				//verifica classe de valor
				lRet := !Empty(cClVlr)
				If lRet
					lRet := PcoCV_User(AK1->AK1_CODIGO,AK3->AK3_CO,AK3->AK3_PAI,2,"CLAVLR",cRevisa,cClVlr,If(lVisualiza, 1, 2) )
					If 	! lRet
						Exit
					EndIf
				EndIf
				//Se nao sair em nenhum if encerra o laco e retorna .T.
				lRet  := .T.
				lMore := .F.
			End
		EndIf
	EndIf

Return(lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} EmailRPlan
Envia email para o responsavel da planilha referente ao fechamento de um C.Custo (UO).

@type function
@author Claudinei Ferreira
@since 22/01/2012
@version P12.1.23

@param aUOFim, Array, Itens da planilha que foram finalizados.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function EmailRPlan(aUOFim)
	Local cEmailRPlan:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cEmailRPlan:=UsrRetMail(AK1->(AK1_XRESPP))

	if !VldMail(cEmailRPlan)
		MsgStop("E-Mail do responsavel pela planilha inválido " + ALLTRIM(cEmailRPlan),"Atenção")
	Else
		SendMail(cEmailRPlan,aUOFim)
	endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} VldMail
Valida o E-mail do responsavel pela planilha.

@type function
@author Thiago Rasmussen
@since 23/01/2012
@version P12.1.23

@param cEMail, Caractere, Conteúdo do E-mail.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando E-mail válido.

/*/
/*/================================================================================================================================/*/

Static Function VldMail(cEMail)
	Local nI
	Local cChar      := ""
	Local lOK 		 := .F.
	Local nQtdArrba  := 0
	Local aPto       := {}
	Local cConteudo  := AllTrim(LOWER(cEMail))
	Local nP1Arrba   := At('@',cConteudo)
	Local lRet       := .T.

	//+------------------------------------------------------+
	//|Carrega Vetor com caracteres especiais nao permitidos |
	//+------------------------------------------------------+
	Local aNoChar    := {",","\","/","*","+","=","(",")","[","]",;
	"{","}",";",":","?","!","&","%","#","$","%","¨",;
	"'",'"',"|","<",">","~","^"}

	//+------------------------------------------------------+
	//|Carrega Vetor aChar com as LETRAS ALFABETO exigida 	 |
	//+------------------------------------------------------+
	Local aChar    := {"a","b","c","d","e","f","g","h","i","j","k","l","m",;
	"n","o","p","q","r","s","t","u","v","w","x","y","z",;
	"0",'1',"2","3","4","5","6","7","8","9"}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+-----------------------------------+
	//|Verifica se o campo esta em branco |
	//+-----------------------------------+
	If Empty(cConteudo)
		lRet := .F.
	Endif

	//+--------------------------------------+
	//|Valida se a String eh menor do que 7  |
	//+--------------------------------------+
	If lRet .And. Len(cConteudo) < 7
		lRet := .F.
	Endif

	If lRet

		//+------------------------------------------------+
		//|Verifica se possui caracter especial preenchido |
		//+------------------------------------------------+
		For nI:=1 to Len(AllTrim(cConteudo))
			cChar := SubStr(cConteudo,nI,1)
			If aScan(aNoChar, cChar) > 0
				lRet := .F.
				Exit
			Endif
		Next nI

	EndIf

	If lRet

		//+---------------------------------------------+
		//|Verifica a QTD de pontos e arrobas na string |
		//+---------------------------------------------+
		For nI:=1 to Len(cConteudo)
			// Soma a QTD de Pontos
			If SubStr(cConteudo,nI,1) == '.'
				AADD(aPto, nI)
				Loop
			Endif

			// Valida a QTD de @
			If SubStr(cConteudo,nI,1) == '@'
				If nQtdArrba == 0
					nQtdArrba++
					Loop
				Else
					lRet := .F.
					Exit
				Endif
			Endif
		Next nI

	EndIf

	If lRet

		//+--------------------------------------+
		//|Valida a posicao do ARROBA na STRING  |
		//+--------------------------------------+
		For nI:=1 to Len(SubStr(cConteudo,1,nP1Arrba))
			cChar := SubStr(cConteudo,nI,1)
			If aScan(aChar, cChar) > 0
				lOK := .T.
				Exit
			Endif
		Next nI

	EndIf

	If lRet .And. !lOK
		lRet := .F.
	Endif

	If lRet

		//+--------------------------------------+
		//|Valida a posicao dos pontos na STRING |
		//+--------------------------------------+
		For nI:=1 to Len(aPto)
			If aPto[nI] <= 1
				Loop
			Endif

			cChar := SubStr(cConteudo,aPto[nI]-1,1)
			If aScan(aChar, cChar) == 0
				lOK := .F.
				Exit
			Endif
		Next nI
		If SubStr(cConteudo,Len(cConteudo),1) == '.'
			lOk := .F.
		Endif

	EndIf

	If lRet .And. !lOK
		lRet := .F.
	Endif

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} Sendmail
Envia o e-mail para o responsavel pela planilha.

@type function
@author Claudinei Ferreira
@since 23/01/2012
@version P12.1.23

@param cEmail, Caractere, Endereço de e-mail do responsável.
@param aUOFim, Array, Itens da planilha que foram finalizados.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function Sendmail(cEmail,aUOFim)

	Local cMensagem		:= ""
	Local lOk			:= .F.
	Local lSendOk		:= .T.
	Local cError		:= ""
	Local cPassword 	:= AllTrim(GetNewPar("MV_RELPSW"," "))
	Local lAutentica	:= GetMv("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
	Local cAccount  	:= AllTrim(GetNewPar("MV_RELACNT"," ")) //Space(50)
	//Local cUserAut  	:= Alltrim(GetNewPar("MV_RELAUSR",cAccount))//Usuario para Autenticação no Servidor de Email
	Local cPassAut  	:= Alltrim(GetNewPar("MV_RELAPSW",cPassword))//Senha para Autenticação no Servidor de Email
	Local cServer   	:= AllTrim(GetNewPar("MV_RELSERV",""))
	Local nTimeOut  	:= GetNewPar("MV_RELTIME",120)
	Local cMailConta	:= ""
	Local cSubject  	:= ""
	//Local cMailTo 		:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+---------------------------------------------------------+
	//|Gera HTML com todos os itens da planilha foram finalizado|
	//+---------------------------------------------------------+
	cMensagem:= Geramail(aUOFim)

	//+------------+
	//|Envia Email |
	//+------------+
	If !Empty(cServer) .And. !Empty(cAccount) .And. (!Empty(cPassword) .OR. !Empty(cPassAut))

		// Conecta uma vez com o servidor de e-mails
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword TIMEOUT nTimeOut Result lOk

		If !lOK
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			MsgStop("Não foi possível efetuar a conexão com o servidor de e-mail !" + cError,"Atenção")
		Else		//Envio de e-mail HTML
			cSubject	:="UO Finalizada: "+AllTrim(AK1->AK1_CODIGO) +'/'+ AK1->AK1_VERSAO
			cMailConta	:= UsrRetMail(__CUSERID)

			If lAutentica
				If !MailAuth(cAccount,cPassword)
					GET MAIL ERROR cError
					MsgStop("Erro de autenticação no servidor SMTP:" + cError,"Atenção")
				Endif
			Endif

			SEND MAIL FROM cMailConta to cEMail SUBJECT cSubject BODY cMensagem RESULT lSendOk

			If !lSendOk
				//Erro no Envio do e-mail
				GET MAIL ERROR cError
				MsgStop("Erro ao enviar e-mail para Responsáavel da Planilha!" + cError,"Atenção")
			EndIf
		EndIf
	EndIf

	// Desconecta com o servidor de e-mails
	If lOk
		DISCONNECT SMTP SERVER
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} Geramail
Gera o e-mail para o responsavel pela planilha avisando finalizacao da digitacao de um C.Custo (UO).

@type function
@author Claudinei Ferreira
@since 23/01/2012
@version P12.1.23

@param aUOFim, Array, Itens da planilha que foram finalizados.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Mensagem de e-mail.

/*/
/*/================================================================================================================================/*/

Static Function Geramail(aUOFim)

	Local nI
	Local cMsg      := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Texto
	cMsg := "<HTML><TABLE BORDER=0>"+CRLF
	cMsg += "<TR><TD>A(s) UO(s) abaixo finalizou(aram) seu orçamento "
	cMsg += "<TR><TD>&nbsp</TD></TR>" + CRLF
	cMsg += "</TABLE>"+CRLF

	//Cabecalho
	cMsg += '<table id="" style="border-collapse: collapse" cellSpacing="1" borderColorDark="#000000" width="450" borderColorLight="#000000" border="1">'
	cMsg += '    <tr><th colspan="8"><font face="Verdana" size="2"><b>Planilha: ' + AK1->AK1_CODIGO + ' - Revisão: ' + AK1->AK1_VERSAO + ' </b></font></th></tr>'
	cMsg += '      <td bgcolor="#99ccff" align="Left" ><font face="Verdana" size="1"><b>UO</b></font></td>'
	cMsg += '      <td bgcolor="#99ccff" align="Left" ><font face="Verdana" size="1"><b>Descrição</b></font></td>'

	//Adiciona Itens na tabela
	For nI := 1 to Len(aUOFim)
		cMsg += '<tr>'
		cMsg += '<td align=left><font face="Arial" size="2">' + aUOFim[nI,01] + '</td>'
		cMsg += '<td align=left><font face="Arial" size="2">' + aUOFim[nI,02] + '</td>'
		cMsg += '</tr>'
	Next nI

	cMsg += "</TABLE/HTML>"

Return(cMsg)
