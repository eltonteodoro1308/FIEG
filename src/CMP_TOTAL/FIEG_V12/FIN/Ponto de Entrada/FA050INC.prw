#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} FA050INC
P.E. executado pela valida��o do contas a pagar, para valida��es espec�ficas de usu�rios.

@type function
@author TOTVS
@since 10/08/2011
@version P12.1.23

@obs Projeto ELO ALterado pela FIEG

@history 13/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna verdadeiro se todas as valida��es estiverem OK.
/*/
/*/================================================================================================================================/*/

User function FA050INC()

Local lRet		  := .T.
Local _MV_XFILRPA := SuperGetMV("MV_XFILRPA", .F., "", SUBSTR(cFilAnt,1,4))

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF !lF050Auto 
	IF M->E2_MULTNAT == "2" .and. M->E2_RATEIO == "N"
		IF Empty(CT1->CT1_CONTA) 
			Posicione("CT1",1,XFilial("CT1")+M->E2_CONTAD,"CT1_CONTA")
		EndIf	
	
		IF CT1->CT1_ITOBRG == "1" .And. Empty(M->E2_ITEMD)
			MsgStop("Item Cont�bil obrigat�rio para esta Conta Cont�bil.","FA050INC")
			lRet := .F.
		ElseIF CTT->CTT_ITOBRG == "1" .And. Empty(M->E2_ITEMD)
			MsgStop("Item Cont�bil obrigat�rio para este Centro de Custo.","FA050INC")
			lRet := .F.
		ElseIF CT1->CT1_ACITEM == "2" .And. !Empty(M->E2_ITEMD)
			MsgStop("Conta Cont�bil n�o aceita Item Cont�bil.","FA050INC")
			lRet := .F.
		ElseIF CTT->CTT_ACITEM == "2" .And. !Empty(M->E2_ITEMD)
			MsgStop("Centro de Custo n�o aceita Item Cont�bil.","FA050INC")
			lRet := .F.
		EndIf

	// 03/12/2018 - Thiago Rasmussen - Validar inclus�o do prefixo
	ElseIf Empty(M->E2_PREFIXO) 
		MsgStop("Prefixo obrigat�rio, consulte os prefixos v�lidos atrav�s da op��o F3!","FA050INC")
		lRet := .F.

	// 09/12/2013 - Thiago Rasmussen - Validar inclus�o de t�tulos do tipo "AB-"            
	ElseIf !Empty(M->E2_PREFIXO) 
		IF M->E2_TIPO!="AB-" 
			IF Empty(Posicione("SX5",1,xFilial("SX5")+"Z1"+M->E2_PREFIXO,"X5_DESCRI"))
				MsgStop("Prefixo inv�lido, consulte os prefixos v�lidos atrav�s da op��o F3!","FA050INC")
				lRet := .F.
			EndIf	
		EndIf			

	// 28/10/2015 - Thiago Rasmussen - N�o permitir inclus�o de registros com prefixo ou tipo RPA, para algumas filiais.            
	ElseIf cFilAnt $(_MV_XFILRPA)
		IF M->E2_PREFIXO=="RPA" .OR. M->E2_TIPO=="RPA" 
			MsgStop("N�o � permitido a inclus�o de t�tulos com prefixo ou tipo RPA pela filial " + cFilAnt + "." + CRLF + CRLF + ;
					"Pagamento de aut�nomo deve ser realizado pela folha de pagamento, qualquer d�vida procure a GERHC.","FA050INC")
			lRet := .F.
		EndIf
		    
    // 04/04/2014 - Thiago Rasmussen - Comentado                           
	// 02/12/2013 - Thiago Rasmussen - Caso informe algum desses impostos abaixo, passe-se a ser obrigatorio, informar o c�digo de reten��o
	//IF ";"+ALLTRIM(M->E2_TIPO)+";"$GETMV("MV_XCODRET") .AND. Empty(M->E2_CODRET)
	//	MsgStop("Para este tipo de t�tulo deve ser informado o C�digo de Reten��o","FA050INC")
	//	Return(.F.)	
	//EndIf

	// 04/04/2014 - Thiago Rasmussen - Caso o valor de IRRF do t�tulo seja maior que zero, obrigar a informar "Gerar DIRF" igual a "Sim"            
	ElseIf !Empty(M->E2_IRRF) .AND. M->E2_DIRF!="1" 
		MsgStop("Para os t�tulos com IRRF a op��o Gerar DIRF deve ser igual a Sim!","FA050INC")
		lRet := .F.
	
	// 04/04/2014 - Thiago Rasmussen - Caso op��o "Gerar DIRF" seja igual a "Sim", obrigar a informar "C�digo de Reten��o"             
	ElseIf M->E2_DIRF=="1" .AND. Empty(M->E2_CODRET)
		MsgStop("C�digo de Reten��o obrigat�tio para os t�tulos que Geram DIRF!","FA050INC")
		lRet := .F.
	
	// 06/06/2014 - Thiago Rasmussen - Caso o prefixo seja igual a "DD", obrigar a informar "Rateio" igual a "N�o"              
	ElseIf ALLTRIM(M->E2_PREFIXO)=="DD" .AND. M->E2_RATEIO=="S"
		MsgStop("Para os t�tulos com prefixo igual a DD, a op��o rateio deve ser igual a N�o!","FA050INC")
		lRet := .F.
	EndIf		
EndIf

Return lRet
