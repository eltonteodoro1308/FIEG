#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120FIM
Descrição detalhada da função.

@type function
@author TOTVS
@since 10/13/2011
@version P12.1.23

@obs Projeto ELO Alteraro pela FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT120FIM()

Local aArea 	:= GetArea()
Local aAreaSC1 	:= SC1->(GetArea())
Local cCot      := ""
Local lPrjCni  	:= FindFunction("PRJCNI") .Or. GetRpoRelease("R6") 
local cNumPed	:= PARAMIXB[2]
Local lLib 		:= IsInCallStack("U_SICOMA04")

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF lLib  
	IF Type("aPeds") == "A"
 		AADD(aPeds,cNumPed) 
 	ENDIF	
ENDIF

IF PARAMIXB[3] > 0
	If lPrjCni
		cCot := GetMv("MV_PCEXCOT",,"0")
		BeginSQL Alias "SC7TMP"
			SELECT C7_NUM, C7_NUMSC, C7_ITEMSC
			FROM %Table:SC7% SC7
			WHERE C7_FILIAL = %xFilial:SC7% AND C7_NUM = %Exp:PARAMIXB[2]% AND SC7.D_E_L_E_T_ = '*'
		EndSQL
		
		SC7TMP->(dbGoTop())
		SC1->(dbSetOrder(1))
		
		While !SC7TMP->(EOF())
			If SC1->(dbSeek(xFilial("SC1")+SC7TMP->C7_NUMSC+SC7TMP->C7_ITEMSC))
				If COI->(dbSeek(xFilial("COI")+SC1->C1_NUM+SC1->C1_ITEM))
					If (!Empty(COI->COI_DOCEDT)) //Se o PC veio de edital
						RecLock("SC1",.F.)
							SC1->C1_QUJE := SC1->C1_QUANT //Nao reabre SC
						SC1->(MsUnlock())
					EndIf
				EndIf							
			EndIf
			SC7TMP->(dbSkip())
		EndDo
		
		SC7TMP->(dbCloseArea())
		SC1->(dbSetOrder(aAreaSC1[2]))
	EndIf
	
	//--< Lançamento dos movimentos orçamentarios - GAP091 >--
	IF (ParamIXB[1] == 3 .or. ParamIXB[1] == 4) .and. ParamIXB[3] == 1
		MsgRun("Atualizando Movimentos do PC "+PARAMIXB[2],"",{|| U_SICOMA11(ParamIXB) })
	EndIf
	
	//--< Tratamento Compras Compartilhadas >--
	IF ParamIXB[1] == 3 .and. !IsInCallStack("A120Copia") .and. SC7->(FieldPos("C7_XMODOC")) <> 0 .and. SC1->(FieldPos("C1_XMODOC")) <> 0 .and. SC7->C7_TIPO == 1
		_cAreaSC7 := SC7->(GetArea())
		
		SC7->(dbSetOrder(1))
		SC7->(dbSeek(XFilial("SC7")+PARAMIXB[2]))
		
		While SC7->(!Eof()) .and. SC7->(C7_FILIAL+C7_NUM) == XFilial("SC7")+PARAMIXB[2]
			
			SC1->(dbSetOrder(1))
			IF SC1->(dbSeek(XFilial("SC1")+SC7->(C7_NUMSC+C7_ITEMSC)))
				RecLock("SC7",.F.)
				
				IF SC1->C1_XMODOC == "2"
					SC7->C7_XMODOC := "1" // 0=Nao Utiliza;1=A Distribuir;2=Distribuido
				ENDIF
				
				SC7->C7_CONTA := SC1->C1_CONTA
				SC7->C7_CC := SC1->C1_CC
				SC7->C7_ITEMCTA := SC1->C1_ITEMCTA
				SC7->C7_CLVL := SC1->C1_CLVL
				SC7->(MsUnlock())				
			ENDIF
			
			SC7->(dbSkip())
		Enddo
		
		RestArea(_cAreaSC7)
		
	ENDIF
	
	IF ISINCALLSTACK("U_CNI109AL") // PC gerado via medição de contratos RP após aprovação alçada
		MsgRun('Enviando pedido para fornecedor...',, {|| U_CWKFA005(PARAMIXB[2],.t.) } )
	ENDIF
ENDIF

RestArea(aArea)

Return
