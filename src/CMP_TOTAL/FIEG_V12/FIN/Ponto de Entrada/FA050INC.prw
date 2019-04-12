#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} FA050INC
P.E. executado pela validação do contas a pagar, para validações específicas de usuários.

@type function
@author TOTVS
@since 10/08/2011
@version P12.1.23

@obs Projeto ELO ALterado pela FIEG

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se todas as validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User function FA050INC()

Local lRet		  := .T.
Local _MV_XFILRPA := SuperGetMV("MV_XFILRPA", .F., "", SUBSTR(cFilAnt,1,4))

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF !lF050Auto 
	IF M->E2_MULTNAT == "2" .and. M->E2_RATEIO == "N"
		IF Empty(CT1->CT1_CONTA) 
			Posicione("CT1",1,XFilial("CT1")+M->E2_CONTAD,"CT1_CONTA")
		EndIf	
	
		IF CT1->CT1_ITOBRG == "1" .And. Empty(M->E2_ITEMD)
			MsgStop("Item Contábil obrigatório para esta Conta Contábil.","FA050INC")
			lRet := .F.
		ElseIF CTT->CTT_ITOBRG == "1" .And. Empty(M->E2_ITEMD)
			MsgStop("Item Contábil obrigatório para este Centro de Custo.","FA050INC")
			lRet := .F.
		ElseIF CT1->CT1_ACITEM == "2" .And. !Empty(M->E2_ITEMD)
			MsgStop("Conta Contábil não aceita Item Contábil.","FA050INC")
			lRet := .F.
		ElseIF CTT->CTT_ACITEM == "2" .And. !Empty(M->E2_ITEMD)
			MsgStop("Centro de Custo não aceita Item Contábil.","FA050INC")
			lRet := .F.
		EndIf

	// 03/12/2018 - Thiago Rasmussen - Validar inclusão do prefixo
	ElseIf Empty(M->E2_PREFIXO) 
		MsgStop("Prefixo obrigatório, consulte os prefixos válidos através da opção F3!","FA050INC")
		lRet := .F.

	// 09/12/2013 - Thiago Rasmussen - Validar inclusão de títulos do tipo "AB-"            
	ElseIf !Empty(M->E2_PREFIXO) 
		IF M->E2_TIPO!="AB-" 
			IF Empty(Posicione("SX5",1,xFilial("SX5")+"Z1"+M->E2_PREFIXO,"X5_DESCRI"))
				MsgStop("Prefixo inválido, consulte os prefixos válidos através da opção F3!","FA050INC")
				lRet := .F.
			EndIf	
		EndIf			

	// 28/10/2015 - Thiago Rasmussen - Não permitir inclusão de registros com prefixo ou tipo RPA, para algumas filiais.            
	ElseIf cFilAnt $(_MV_XFILRPA)
		IF M->E2_PREFIXO=="RPA" .OR. M->E2_TIPO=="RPA" 
			MsgStop("Não é permitido a inclusão de títulos com prefixo ou tipo RPA pela filial " + cFilAnt + "." + CRLF + CRLF + ;
					"Pagamento de autônomo deve ser realizado pela folha de pagamento, qualquer dúvida procure a GERHC.","FA050INC")
			lRet := .F.
		EndIf
		    
    // 04/04/2014 - Thiago Rasmussen - Comentado                           
	// 02/12/2013 - Thiago Rasmussen - Caso informe algum desses impostos abaixo, passe-se a ser obrigatorio, informar o código de retenção
	//IF ";"+ALLTRIM(M->E2_TIPO)+";"$GETMV("MV_XCODRET") .AND. Empty(M->E2_CODRET)
	//	MsgStop("Para este tipo de título deve ser informado o Código de Retenção","FA050INC")
	//	Return(.F.)	
	//EndIf

	// 04/04/2014 - Thiago Rasmussen - Caso o valor de IRRF do título seja maior que zero, obrigar a informar "Gerar DIRF" igual a "Sim"            
	ElseIf !Empty(M->E2_IRRF) .AND. M->E2_DIRF!="1" 
		MsgStop("Para os títulos com IRRF a opção Gerar DIRF deve ser igual a Sim!","FA050INC")
		lRet := .F.
	
	// 04/04/2014 - Thiago Rasmussen - Caso opção "Gerar DIRF" seja igual a "Sim", obrigar a informar "Código de Retenção"             
	ElseIf M->E2_DIRF=="1" .AND. Empty(M->E2_CODRET)
		MsgStop("Código de Retenção obrigatótio para os títulos que Geram DIRF!","FA050INC")
		lRet := .F.
	
	// 06/06/2014 - Thiago Rasmussen - Caso o prefixo seja igual a "DD", obrigar a informar "Rateio" igual a "Não"              
	ElseIf ALLTRIM(M->E2_PREFIXO)=="DD" .AND. M->E2_RATEIO=="S"
		MsgStop("Para os títulos com prefixo igual a DD, a opção rateio deve ser igual a Não!","FA050INC")
		lRet := .F.
	EndIf		
EndIf

Return lRet
