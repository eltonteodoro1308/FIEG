#Include "Protheus.ch"
#include 'topconn.ch'
#include 'parmtype.ch'

#DEFINE USR_ID		2
#DEFINE USR_LOGIN	3
#DEFINE USR_NAME	4
#DEFINE USR_MAIL	5
#DEFINE USR_PSWID	1
#DEFINE USR_BLOQ	17

/*/================================================================================================================================/*/
/*/{Protheus.doc} ZCFGA001
Customização para preenchimento da tabela auxiliar de usuários ZZZ010 -  (FIEG)

@type function
@author Daniel Flávio
@since 31/01/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User function ZCFGA001()
	Local aXArea	:= GetArea()
	Local aXUsers	:= {}
	Local cXMsg		:= ""
	Local lXContinua:= .F.
	Local aPar		:= {}
	Local aSays		:= {}
	Local aButtons	:= {}
	Local aRet		:= {}
	Local oWnd		:= NIL
	Private cXRotina:= "FIEG - Tabela Auxiliar de Usuários"
	Private lJob	:= Type("cFilAnt") # "C"
	Private lProcTot:= .F.
	Private	nQtdUsr	:= 30

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	// Verifica se está sendo executado via tela ou JOB
	If !lJob

		// Verifica se o usuario logado é do grupo de administradores
		If !FWIsAdmin(__cUserID)
			MsgStop("Usuário "+Alltrim(UsrRetName(__cUserID))+", não pertence ao grupo de administradores."+CRLF+"Processamento cancelado.","ZCFGA001")
			RestArea(aXArea)
			Return
		Endif

		// Ajusta parâmetros
		aAdd(aPar,{3,"Tipo de Processamento" ,"1",{"1-Usuário Recentes","2-Todos Usuários"},80,".T." ,.T.		})

		// Cria tela para confirmar processamento
		aAdd(aSays,OemToAnsi( "Essa rotina irá atualizar a tabela "+RetSqlName("ZZZ")+"." 						))
		aAdd(aSays,OemToAnsi( " " 																				))
		aAdd(aSays,OemToAnsi( "Esta tabela replica as informações dos usuários."  								))
		aAdd(aSays,OemToAnsi( "As informações são utilizadas posteriormente pela FIEG em suas rotinas "			))
		aAdd(aSays,OemToAnsi( "e procedimentos customizados." 													))
		aAdd(aSays,OemToAnsi( " " 																				))
		aAdd(aSays,OemToAnsi( "Deseja continuar?" 																))
		aAdd(aButtons, {05, .T.,{|| paramBox(aPar,cXRotina,@aRet,,,.T.,,,,,.F.,.F.)}							})
		aAdd(aButtons, {01, .T.,{|o| lXContinua := .T., o:oWnd:End()} 											})
		aAdd(aButtons, {02, .T.,{|o| o:oWnd:End()}																})

		// Mostrar uma mensagem na tela e as opções disponíveis para o usuário.
		FormBatch(cXRotina, aSays, aButtons)

		If lXContinua

			// Configura tipo de processamento
			If !Empty(MV_PAR01) .AND. MV_PAR01=2
				lProcTot := .T.
			EndIf

			// Carrega todos os registros do cadastro de usuário no arquivo de senhas (SUPERFILE)
			FWMsgRun(, {|| aXUsers := FWSFALLUSERS() }, "Usuários Protheus", "Buscando registros dos usuários...")

			// Realiza o processamento do array
			Processa( {|| Iif(!Empty(aXUsers),fXProc(aXUsers,@cXMsg),NIL) }, "Aguarde...", "Atualizando informações...",.F.)

			// Exibe mensagem
			MsgInfo("Processamento finalizado com sucesso."+CRLF+CRLF+cXMsg,"ZCFGA001")

		EndIf

	Else

		// Configura tipo de processamento
		lProcTot := .T.

		ConOut("["+FunName()+"] - Iniciada")
		ConOut("["+FunName()+"] - Buscando registros dos usuarios...")
		aXUsers := FWSFALLUSERS()
		ConOut("["+FunName()+"] - Atualizando informacoes. Aguarde finalizacao")

		If !Empty(aXUsers)
			fXProc(aXUsers)
		EndIf

		ConOut("["+FunName()+"] - Finalizada")

	EndIf

	RestArea(aXArea)
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fXProc
Função auxiliar para processamento de informações.

@type function
@author Daniel Flávio
@since 31/01/2019
@version P12.1.23

@param aXUsers, Array, Dados dos usuários
@param cXMsg, Caracteres, Variável recebida por referência a ser populada com a Mensagem.

@obs Desenvolvimento FIEG

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fXProc(aXUsers,cXMsg)
	Local nTotReg	:= Len(aXUsers)
	Local nA		:= 0
	Local nUsrBlq	:= 0
	Local nUsrDes	:= 0
	Local nUsrAlt	:= 0
	Local nUsrAdd	:= 0
	Local nUsrExc	:= 0
	Local aXInfoUsr	:= {}
	Default cXMsg	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	// Valor máximo da régua de progressão
	If !lJob

		If lProcTot
			ProcRegua(nTotReg)
		Else
			ProcRegua(nQtdUsr)
		EndIf

	EndIf

	// Define a área de trabalho especificada como ativa.
	dbSelectArea("ZZZ")

	// Percorre array com as informações de usuários
	// De: SuperFile Para: ZZZ010
	For nA := Iif(lProcTot,1,nTotReg-nQtdUsr) to nTotReg

		// Valores na régua de progressão
		If !lJob
			IncProc("Conferindo tabela ZZZ. Registro "+StrZero(nA,6)+" de "+StrZero(nTotReg,6))
		EndIf

		// Ajusta variáveis
		aXInfoUsr := {}

		// Pesquisa o arquivo de senhas - Usuário
		PswSeek(aXUsers[nA,USR_ID],.T.)

		// Informações do último usuário
		aXInfoUsr := PswRet(1,.F.)

		If !Empty(aXInfoUsr) .AND. aXInfoUsr[1,USR_PSWID]==aXUsers[nA,USR_ID]

			If ZZZ->(dbSeek(xFilial("ZZZ")+aXUsers[nA,USR_ID]))

				// Verifica se existe alguma informação de usuário que está divergente
				// do cadastro na tabela ZZZ
				// Verifica 1-Nome, 2-E-mail, 3-Bloqueado
				If (	!((Alltrim(ZZZ->ZZZ_NOME) == Alltrim(aXUsers[nA,USR_NAME]))) .OR.;
				!((Alltrim(ZZZ->ZZZ_EMAIL) == Alltrim(aXUsers[nA,USR_MAIL]))) .OR.;
				!(Iif(Alltrim(ZZZ->ZZZ_MSBLQL)=="1",.T.,.F.) == aXInfoUsr[1,USR_BLOQ]) )

					// Alimenta estatísticas
					If !(Iif(Alltrim(ZZZ->ZZZ_MSBLQL)=="1",.T.,.F.) == aXInfoUsr[1,USR_BLOQ])
						If aXInfoUsr[1,USR_BLOQ]
							nUsrBlq++
						Else
							nUsrDes++
						EndIf
					Else
						nUsrAlt++
					EndIf

					RecLock("ZZZ",.F.)
					ZZZ->ZZZ_NOME 	:= Alltrim(aXUsers[nA,USR_NAME])
					ZZZ->ZZZ_EMAIL 	:= Alltrim(aXUsers[nA,USR_MAIL])
					ZZZ->ZZZ_MSBLQL	:= Iif(aXInfoUsr[1,USR_BLOQ],"1","")
					ZZZ->(msUnlock())

				EndIf

			Else

				// Alimenta estatísticas
				nUsrAdd++

				RecLock("ZZZ",.T.)
				ZZZ->ZZZ_FILIAL	:= xFilial("ZZZ")
				ZZZ->ZZZ_CODIGO	:= aXUsers[nA,USR_ID]
				ZZZ->ZZZ_LOGIN	:= aXUsers[nA,USR_LOGIN]
				ZZZ->ZZZ_NOME 	:= Alltrim(aXUsers[nA,USR_NAME])
				ZZZ->ZZZ_EMAIL 	:= Alltrim(aXUsers[nA,USR_MAIL])
				ZZZ->ZZZ_MSBLQL	:= Iif(aXInfoUsr[1,USR_BLOQ],"1","")
				ZZZ->(msUnlock())

			EndIf

		EndIf

	Next

	// Percorre Tabela ZZZ com as informações de usuários
	// Verifica se algum usuário foi excluído e ainda está na tabela ZZZ
	// De: ZZZ010 Para: SuperFile
	If lProcTot
		FWMsgRun(, {|| fProcExZZZ(aXUsers,@nUsrExc) }, "Usuários Protheus", "Consistindo Tabela "+RetSqlName("ZZZ")+"...")
	EndIf

	// Preenche mensagem
	If !lJob

		cXMsg += "Quantidade Usuários : "+StrZero(Iif(lProcTot,nTotReg,nQtdUsr),6)+CRLF+CRLF
		cXMsg += "Usuários Adicionados: "+StrZero(nUsrAdd,6)+CRLF
		cXMsg += "Usuários Alterados: "+StrZero(nUsrAlt,6)+CRLF
		cXMsg += "Usuários Bloqueados: "+StrZero(nUsrBlq,6)+CRLF
		cXMsg += "Usuários Desbloqueados: "+StrZero(nUsrDes,6)+CRLF

		If nUsrExc > 0
			cXMsg += "Registros Excluídos ZZZ: "+StrZero(nUsrExc,6)+CRLF
		EndIf

	EndIf

	// Fecha tabela
	If Select("ZZZ") > 0
		ZZZ->(dbCloseArea())
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fProcExZZZ
Varre a tabela ZZZ em busca de registros que não existem no cadastro de usuários.

@type function
@author Daniel Flávio
@since 01/02/2019
@version P12.1.23

@param aXUsers, Array, Registros a serem verificados.
@param nUsrExc, Numérico, Variável recebida por referência a ser populada com o número de usuários excluídos.

@obs Desenvolvimento FIEG

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fProcExZZZ(aXUsers,nUsrExc)
	Default nUsrExc	:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	ZZZ->(dbGoTop())

	While ZZZ->(!Eof())

		If aScan(aXUsers,{|X| X[USR_ID]==ZZZ->ZZZ_CODIGO}) = 0

			// Alimenta estatísticas
			nUsrExc++

			RecLock("ZZZ",.F.)
			ZZZ->(dbDelete())
			ZZZ->(msUnlock())

		EndIf

		ZZZ->(dbSkip())
	EndDo

Return