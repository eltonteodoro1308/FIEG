#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SF1100I
Ponto de entrada para gravacao dos campos contabeis da nota fiscal para os titulos do contas a pagar. 

@type function
@author Adriano Luis Brandao
@since 19/08/2011
@version P12.1.23

@obs Projeto ELO

@history 28/03/2012, Alcinei, inclusão tratamento ESB.
@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SF1100I()

Local _aArea	:= GetArea()                         
Local _aAreaD1  := SD1->(GetArea())
Local _cAreaSF1 := SF1->(GetArea())
Local _aAreaE2	:= SE2->(GetArea())
Local _aAreaSED := SED->(GetArea())

Local lRat		:=.F.
Local cCusto

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
SD1->(DbSetOrder(1))   //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
SE2->(DbSetOrder(6))

//--< Inicio Referente ao Projeto FS007530 - Req. customização NFERIO.INI - 04/05/2016 - Totvs BH - Euler >--
//--< alterar o campo D1_CFPS, com o conteudo do campo ED_XCFPS da SED >--

SED->(DbSetOrder(1))
If Upper(AllTrim(FunName())) $ "MATA103" .Or. l103Auto
   If SE2->(DbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC))	// busca cod natureza
	  If SED->(DbSeek(xFilial("SED")+SE2->E2_NATUREZ))  									// busca natureza
         If !Empty(SED->ED_XCFPS)
		   	IF SD1->(DbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))	// percorre itens da nota
		       While !SD1->(Eof()) .And. SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == ;
		                                 SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA 
		          RecLock("SD1",.F.)
					  Replace SD1->D1_CFPS With SED->ED_XCFPS
		          SD1->(MsUnLock())
			      SD1->(DbSkip())
		       Enddo
		    EndIf
		 EndIf   
      EndIf      
   EndIf
EndIf
//--< Fim referente ao Projeto FS007530 - Req. customização NFERIO.INI - 04/05/2016 - Totvs BH - Euler >--

If SF1->F1_TIPO == "N"
	IF SD1->(DbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
		cCusto:=SD1->D1_CC  
		Do While !SD1->(Eof()) .And. SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA 
		     If cCusto <> SD1->D1_CC
		          lRat:=.T. 
		          EXIT
		     Endif  
		SD1->(DbSkip())
		Enddo  
     Endif
	
	If SD1->(DbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
		SE2->(DbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC))
		Do While ! SE2->(Eof()). And. SE2->E2_FILIAL == xFilial("SE2") .And. ;
			SE2->E2_FORNECE == SF1->F1_FORNECE .And. SE2->E2_LOJA == SF1->F1_LOJA .And. SE2->E2_PREFIXO == SF1->F1_SERIE .And.;
			SE2->E2_NUM = SF1->F1_DOC
	
			RecLock("SE2",.f.)
				If SE2->(FieldPos("E2_CONTAD")) > 0 .And. SD1->(FieldPos("D1_CONTA")) > 0
					SE2->E2_CONTAD	:= SD1->D1_CONTA
				EndIf
				If SE2->(FieldPos("E2_CCD")) > 0 .And. SD1->(FieldPos("D1_CC")) > 0
					SE2->E2_CCD		:= SD1->D1_CC
				EndIf                    
				If SE2->(FieldPos("E2_ITEMD")) > 0 .And. SD1->(FieldPos("D1_ITEMCTA")) > 0
					SE2->E2_ITEMD	:= SD1->D1_ITEMCTA
				EndIf
				If SE2->(FieldPos("E2_CLVLDB")) > 0 .And. SD1->(FieldPos("D1_CLVL")) > 0
					SE2->E2_CLVLDB	:= SD1->D1_CLVL
				EndIf  
				
				If lRat			
					SE2->E2_RATEIO :="S"
				Endif

				/*
				If SE2->(FieldPos("E2_EC05DB")) > 0 .And. SD1->(FieldPos("D1_EC05DB")) > 0
					SE2->E2_EC05DB	:= SD1->D1_EC05DB
				EndIf
				If SE2->(FieldPos("E2_EC06DB")) > 0 .And. SD1->(FieldPos("D1_EC06DB")) > 0
					SE2->E2_EC06DB	:= SD1->D1_EC06DB
				EndIf
				If SE2->(FieldPos("E2_EC07DB")) > 0 .And. SD1->(FieldPos("D1_EC07DB")) > 0
					SE2->E2_EC07DB	:= SD1->D1_EC07DB
				EndIf                     
				If SE2->(FieldPos("E2_EC08DB")) > 0 .And. SD1->(FieldPos("D1_EC08DB")) > 0
					SE2->E2_EC08DB	:= SD1->D1_EC08DB
				EndIf                     
				If SE2->(FieldPos("E2_EC09DB")) > 0 .And. SD1->(FieldPos("D1_EC09DB")) > 0
					SE2->E2_EC09DB	:= SD1->D1_EC09DB
				EndIf 
				*/
			SE2->(MsUnLock())
			SE2->(DbSkip())

		EndDo
	EndIf
EndIf                               

IF !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/  
	SZZ->(dbSetOrder(1))
	IF SZZ->(dbSeek(XFilial("SZZ")+"MATA103"))
		MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA24(3) } )
	EndIf
EndIf

RestArea(_aAreaSED)
RestArea(_cAreaSF1)
RestArea(_aAreaE2)
RestArea(_aAreaD1)
RestArea(_aArea)

Return
