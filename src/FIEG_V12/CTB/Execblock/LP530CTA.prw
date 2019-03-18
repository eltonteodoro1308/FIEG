#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} function_method_class_name
Retorna conta contabil na baixa do contas a pagar - LP 530.

@type function
@author Thiago Rasmussen
@since 10/13/11
@version P12.1.23

@obs Desenvolvimento FIEG

@history 28/11/2013, thiagorasmussen@sistemafieg.org.br,If SE2->E2_CODRET == "0561"
@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Conta Contábil na baixa do Contas a Pagar.

/*/
/*/================================================================================================================================/*/

User Function LP530CTA()
	Local lXRPCont	:= SuperGetMv("SI_XRPCONT",.F.,.T.)
	Local cConta := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Alltrim(SE2->E2_NATUREZ) == "IRF"					// IRF
		If SE2->E2_CODRET == "0561"
			cConta := "21010301001"
		Elseif SE2->E2_CODRET == "0588"
			cConta := "21010301002"
		Elseif SE2->E2_CODRET == "1708"
			cConta := "21010301003"
		Elseif SE2->E2_CODRET == "3280"
			cConta := "21010301004"
		Endif
	Elseif Alltrim(SE2->E2_TIPO) == "INS" 				//INSS
		If !Empty(SE2->E2_TITPAI)
			cTipo := Posicione("SA2",1,xFilial("SA2")+Subs(SE2->E2_TITPAI,19,12),"A2_TIPO")
			If cTipo == "F"
				cConta := "21010402002"
			Else
				cConta := "21010402003"
			Endif
		ElseIf Alltrim(SE2->E2_PREFIXO) == "DD"
			cConta := "21010402001"
		Else
			cConta := "21010402003"
		Endif
		/**********************************************************************************************/
		//		27/02/2013 - Thiago Rasmussen - Comentado temporariamente até que os registros de origem de
		//		uma transferência passem a gravar a informação E2_TITPAI, erro detectado.
		//	Elseif Alltrim(SE2->E2_TIPO) == "INS" 				//INSS
		//		If !Empty(SE2->E2_TITPAI)
		//			cTipo := Posicione("SA2",1,xFilial("SA2")+Subs(SE2->E2_TITPAI,19,12),"A2_TIPO")
		//			If cTipo == "F"
		//				cConta := "21010402002"
		//			Else
		//				cConta := "21010402003"
		//			Endif
		//		Else
		//			cConta := "21010402001"
		//		Endif
		/**********************************************************************************************/
	Elseif Alltrim(SE2->E2_NATUREZ) $ "PIS,COFINS,CSLL"		// PCC
		cConta := "21010308"
	Elseif Alltrim(SE2->E2_TIPO) == "ISS"					//ISS
		cConta := "21010303"
	Else

		// 14/12/2018 | Daniel Flávio
		//			  | Conforme orientação do colaborador Deuzimar, na quitação,
		// 			  | não será necessário controlar se o valor é proveniente
		// 			  | de Restos a Pagar
		If lXRPCont

			If Alltrim(SE2->E2_PREFIXO) == "DD"
				cConta := SE2->E2_CONTAD
			Elseif Alltrim(SE2->E2_PREFIXO) == "RP"
				cConta := "21011301"
			Elseif !Empty(SA2->A2_CONTA)
				cConta := SA2->A2_CONTA
			Else
				cConta := "21010201"
			Endif

		Else

			If Alltrim(SE2->E2_PREFIXO) == "DD"
				cConta := SE2->E2_CONTAD
			Elseif Alltrim(SE2->E2_PREFIXO) == "RP"
				cConta := "21011301"
			Elseif !Empty(SA2->A2_CONTA) .And. SE2->E2_XRESTPG <> "3"
				cConta := SA2->A2_CONTA
			Elseif SE2->E2_XRESTPG == "3"
				cConta := "21011301"		// Restos a Pagar
			Else
				cConta := "21010201"
			Endif

		EndIf

	Endif

Return(cConta)
