#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA12
Validar se usuário podera acessar o modo de Alteração.

@type function
@author Claudinei Ferreira
@since 26/02/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso se usuário podera acessar o modo de Alteração.

/*/
/*/================================================================================================================================/*/

User Function SIPCOA12

	//Local lAcessOk		:= .F.
	//Local lVisualiza	:= .T.
	Local lRet			:= .T.
	Local _aArea		:= GetArea()
	Local _aAreaAK2		:= AK2->(GetArea())
	Local lUoF			:=.F.
	Local lUoA			:=.F.
	//Local cUser	 		:=__cUserID
	Local _cQuery 		:=""
	Local cAliasTMP1 	:= GetNextAlias()

	If FunName() != "PCOA200"
		IF AK1->AK1_XAPROV == '1' // finalizado
			lRet:= .F.
			MsgAlert("Não é possível efetuar alterações.", "Orcamento Finalizado")
		ELSEIF AK1->AK1_XAPROV == '2' // aprovado
			lRet:= .F.
			MsgAlert("Não é possível efetuar alterações.", "Orcamento Aprovado")
		ELSE

			dbSelectArea('AK2')
			AK2->(dbSetOrder(1))
			AK2->(dbSeek(xFilial('AK2')+AK1->(AK1_CODIGO+AK1_VERSAO)))
			//Data Alteracao: 29-11-2016
			//Projeto PCO
			//Demanda: 2016GGF1603
			//Autor: Jalles Ara+jo
			//Descrição: Limitar a verificação das permissões na planilha apenas no range de centros de custo cada usuario que edita, de acordo com o perfil.

			//+----------------------------------------------------------------+
			//|Verifica se usuario possui acesso ao C.Custo e finaliza item    |
			//+----------------------------------------------------------------+
			_cQuery :=  "SELECT AK2_FILIAL,AK2_ID,AK2_ORCAME,AK2_VERSAO,AK2_CO,AK2_PERIOD,AK2_CC,AK2_ITCTB,AK2_CLVLR,AK2_VALOR,AK2_CLASSE,AK2_DESCRI,AK2_OPER,AK2_CHAVE,AK2_MOEDA,AK2_DATAF,AK2_DATAI,  "
			_cQuery +=  "AK2_UNIORC,AK2_ENT05,AK2_MSBLQL,AK2_ENT06,AK2_ENT07,AK2_ENT08,AK2_ENT09,AK2_XSTS,AK2_XFILE,AK2_XDTIMP,AK2_XUSER,AK2_XDUM,AK2_XORCTO,AK2_FORMUL,AK2_FORM "
			_cQuery +=  "FROM "+RetSqlName("AK2")+" AK2, "+RetSqlName("AKX")+ " AKX "
			_cQuery +=  "WHERE AK2_ORCAME = '"+Alltrim(AK2->AK2_ORCAME)+"' AND "
			_cQuery +=  "AK2_VERSAO = '"+Alltrim(AK2->AK2_VERSAO)+"' AND "
			_cQuery +=  "AK2_FILIAL = '"+xFilial("AK2")+"' AND "
			_cQuery +=  "AKX_FILIAL = AK2_FILIAL AND "
			_cQuery +=  "AKX_USER = '"+__cUserID+"' AND "
			_cQuery +=  "AK2_CC >= AKX_CC_INI AND "
			_cQuery +=  "AK2_CC <= AKX_CC_FIN  AND "
			_cQuery +=  "AK2.D_E_L_E_T_!='*' AND "
			_cQuery +=  "AK2.D_E_L_E_T_!='*' "
			_cQuery := ChangeQuery(_cQuery)
			//_cQuery +=  " WHERE ZC_FILIAL = '"+xFilial("SZC")+"' AND "

			If Select(cAliasTMP1) > 0
				dbSelectArea(cAliasTMP1)
				(cAliasTMP1)->(dbCloseArea())
			Endif

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP1,.T.,.F.)

			DbSelectArea(cAliasTMP1)
			(cAliasTMP1)->(dbGotop())

			//If !Eof(cAliasTMP1)


			//	dbSelectArea(cAliasTMP1)
			//	cAliasTMP1->(dbSetOrder(1))
			//	cAliasTMP1->(dbSeek(xFilial('AK2')+AK1->(AK1_CODIGO+AK1_VERSAO)))

			While (cAliasTMP1)->(!Eof()) .and. lRet// = AK1->(AK1_FILIAL+AK1_CODIGO+AK1_VERSAO) .AND. lRet

				//	lAcessOk:=U_SIVldAK2_CC_CV_IC(lVisualiza)

				//	If lAcessOk

				If (cAliasTMP1)->AK2_XSTS	== '1'
					lUoF:= .T.
				Elseif (cAliasTMP1)->AK2_XSTS	== '0'
					lUoA:= .T.
				Endif

				//Endif
				(cAliasTMP1)->(dbSkip())
			Enddo

			If lUoF .and. !lUoA
				lRet:= .F.
				MsgAlert("Não é possível efetuar alterações.", "UO Finalizada")
			Endif

		Endif
	EndIf

	RestArea(_aAreaAK2)
	RestArea(_aArea)

Return(lRet)

