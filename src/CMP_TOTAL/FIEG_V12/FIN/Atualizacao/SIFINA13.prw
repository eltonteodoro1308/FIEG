#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFINA13  บAutor  ณThiago L. Dyonisio  บ Data ณ  18/09/12   บฑฑ
ฑฑบAtualiza็ใo: 30/03/2016 - Thiago Rasmussen                             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Transferencia bancแria entre Empresas e Filiais            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - Sistema Ind๚stria                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SIFINA13(nSit)  
/* Variแvel para Montagem da tela */
Local oDlg
Local aButtons := {}
local nRecAtu	:= 0  
Private _cBkpFil := cFilAnt
Private _cNumtrf := ALLTRIM(GETMV("SI_NUMTRF"))
Private _MV_XNATORI := ALLTRIM(GETMV("MV_XNATORI"))
Private _MV_XNATDES := ALLTRIM(GETMV("MV_XNATDES"))
Private bDados:= {|| SetKey( VK_F7, NIL ) , _FIN13Get() }

/* Variแveis para Dados de Origem */
Private _cFilialOr := CFilAnt //CFilAnt: Traz na variแvel a filial corrente
Private _cBancoOr  := Space(3)
Private _cAgenciOr := Space(5)
Private _cContaOr  := Space(10)
Private _cNatureOr := IIF(EMPTY(_MV_XNATORI),SPACE(TamSX3("ED_CODIGO")[1]),_MV_XNATORI)
Private _cCtaOr    := Space(TamSX3("E5_CREDITO")[1])
Private _cUoOr     := Space(TamSX3("E5_CCD")[1])
Private _cCrOr     := Space(TamSX3("E5_ITEMD")[1])

/* Variแveis para Dados de Destino */
Private _cFilDe    := Space(8)   // Variแvel de Filial Destino na segunda tela. Vai atualizar a variแvel _cFilialDe na primeira tela
Private _cFilialDe := Space(8)
Private _cBancoDe  := Space(3)
Private _cAgenciDe := Space(5)
Private _cContaDe  := Space(10)
Private _cNatureDe := Space(TamSX3("ED_CODIGO")[1])
Private _cCtaDe    := Space(TamSX3("E5_DEBITO")[1])
Private _cUoDe     := Space(TamSX3("E5_CCD")[1])
Private _cCrDe     := Space(TamSX3("E5_ITEMD")[1])

/* Variแveis para Dados de Identifica็ใo */

Private _cNumerDoc := PADR("TRF"+_cNumtrf,TamSX3("E5_DOCUMEN")[1]) 
Private _nValor    := 0
Private dDataPag   := DDATABASE
Private dDataRec   := DDATABASE
Private _cHist     := space(60)
Private _cBenefici := Space(60)          
Private nValExc    := 6 // CANCELAR
PRIVATE nPagOPc	   := IIF(nSit==1,3,nValExc)	
PRIVATE nRecOPc	   := IIF(nSit==1,4,nValExc)
PRIVATE nRecPag	   := 0
PRIVATE nRecRec	   := 0
PRIVATE lOk 	   := .F.

IF nSit==1                            
	
	IF MV_PAR04 == 2
		MSGINFO("Para realizar a transfer๊ncia entre filiais, mude o parโmetro para contabiliza on-line igual a SIM (F12).") 
		RETURN
	ENDIF	
	
	SetKey( VK_F7, bDados)
	aadd(aButtons,{'NOTE',{ || _FIN13Get(), cFilAnt := _cBkpFil},'Dados de Destino'}) //Adiciona op็ใo ao A็๕es Relacionadas
	
	DEFINE MSDIALOG oDlg TITLE "Transfer๊ncia Bancแria Entre Empresas e Filiais " FROM 000,000 TO 330,670 PIXEL
	/* Montagem da tela: Dados de Origem */
	@002,003 TO 045,335 LABEL "Dados de Origem" OF oDlg PIXEL
	
	@12,10 Say "Fil. Origem" Pixel Of oDlg
	@22,10 MSGet _cFilialOr Size 40,8 Pixel Of oDlg When .F.
	
	@12,55 Say "Banco" Pixel Of oDlg
	@22,55 MSGet _cBancoOr F3 "SA6" Valid FVerBco("O") Size 20,8 Pixel Of oDlg
	
	@12,88 Say "Agencia" Pixel Of oDlg
	@22,88 MSGet _cAgenciOr Size 20,8 Pixel Of oDlg When .F.
	
	@12,121 Say "CC" Pixel Of oDlg
	@22,121 MSGet _cContaOr Size 40,8 Pixel Of oDlg When .F.
	
	@12,164 Say "Natureza" Pixel Of oDlg
	@22,164 MSGet _cNatureOr F3 "SED" Valid ExistCpo("SED",_cNatureOr) Size 40,8 Pixel Of oDlg
	
	@08,212 Say "Conta.Crd." Pixel Of oDlg  
	@20,212 Say "C.Custo Crd." Pixel Of oDlg	
	@32,212 Say "It.Cont.Crd." Pixel Of oDlg
	                                                                                                                  	
	@08,250 MSGet _cCtaOr Valid ExistCpo("CT1",_cCtaOr) Size 80,8 Pixel Of oDlg When .F. 		
	@20,250 MSGet _cUoOr Valid ExistCpo("CTT",_cUoOr).AND.ctb105cc(_cUoOr) Size 80,8 Pixel Of oDlg When .F. 		
	@32,250 MSGet _cCrOr Valid ExistCpo("CTD",_cCrOr).AND.ctb105item(_cCrOr) Size 80,8 Pixel Of oDlg When .F. 
	
	/* Montagem da tela: Dados de Destino */
	@047,003 TO 090, 335 LABEL "Dados de Destino" OF oDlg PIXEL
	
	@57,11 Say "Fil. Destino" Pixel Of oDlg
	@67,11 MSGet _cFilialDe Valid ExistCpo("SM0",cEmpAnt+ _cFilialDe) Size 40,8 Pixel Of oDlg When .F.
	
	@57,55 Say "Banco" Pixel Of oDlg
	@67,55 MSGet _cBancoDe Valid FVerBco("D") Size 30,8 Pixel Of oDlg When .f.
	
	@57,88 Say "Agencia" Pixel Of oDlg
	@67,88 MSGet _cAgenciDe Size 20,8 Pixel Of oDlg When .f.
	
	@57,121 Say "CC" Pixel Of oDlg
	@67,121 MSGet _cContaDe Size 40,8 Pixel Of oDlg When .f.
	
	@57,164 Say "Natureza" Pixel Of oDlg
	@67,164 MSGet _cNatureDe Valid ExistCpo("SED",_cNatureDe) Size 40,8 Pixel Of oDlg When .F.

	@53,212 Say "Conta.Deb." Pixel Of oDlg  
	@65,212 Say "C.Custo Deb." Pixel Of oDlg	
	@77,212 Say "It.Cont.Deb." Pixel Of oDlg
	                                                                                                                  	
	@53,250 MSGet _cCtaDe Valid ExistCpo("CT1",_cCtaDe) Size 80,8 Pixel Of oDlg When .F. 		
	@65,250 MSGet _cUoDe Valid ExistCpo("CTT",_cUoDe).AND.ctb105cc(_cUoDe) Size 80,8 Pixel Of oDlg When .F. 		
	@77,250 MSGet _cCrDe Valid ExistCpo("CTD",_cCrDe).AND.ctb105item(_cCrDe) Size 80,8 Pixel Of oDlg When .F.	
		
	/* Montagem da tela: Dados de Identifica็ใo */
	@092,003 TO 150, 335 LABEL "Dados de Identifica็ใo" OF oDlg PIXEL
	
	@102,10 Say "Numero Doc" Pixel Of oDlg
	@112,10 MSGet _cNumerDoc Size 60,8 Pixel Of oDlg
	
	@102,73 Say "Valor" Pixel Of oDlg                                                                           
	@112,73 MSGet _nValor Valid(positivo().and.naovazio()) Size 60,8 Picture PesqPict("SE5","E5_VALOR")Pixel Of oDlg
	
	@102,137 Say "Beneficiแrio" Pixel Of oDlg
	@112,137 MSGet _cBenefici Size 193,8 Pixel Of oDlg
	
	@127,10 Say "Hist๓rico" Pixel Of oDlg
	@137,10 MSGet _cHist Size 320,8 Pixel Of oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| IIF(_FIN13Vld1(1),Eval({|| lOk := .T.,oDlg:End()}),lOk := .F.) },{|| oDlg:End()},,aButtons)
	
	IF lOk // Confirmou
		MsgRun("Transferindo...",,{|| _FIN13Proc() })
	ENDIF
	
	SetKey(VK_F7, {|| NIL })
ELSE         
	
	IF MV_PAR04 == 2
		MSGINFO("Para exclui a transfer๊ncia entre filiais, mude o parโmetro para contabiliza on-line igual a SIM (F12).") 
		RETURN
	ENDIF

	IF !"SIFINA13"$SE5->E5_ORIGEM
		MSGINFO("Este movimento nใo pertence a rotina de trafer๊ncia de filiais!!")
	ELSE                        
		                
		lOk := .T.
		nRecAtu:= _FIN13DAD(SE5->E5_RECPAG)
		SE5->(DBGOTO(nRecAtu))
		nRecAtu:= _FIN13DAD(SE5->E5_RECPAG)
		SE5->(DBGOTO(nRecAtu))
		
		IF lOk 
			lOk := .F.
			// Dados de Identifica็ใo 
			_cNumerDoc	:= SE5->E5_DOCUMEN
			_nValor		:= SE5->E5_VALOR
			_cBenefici	:= SE5->E5_BENEF 
			_cHist		:= SE5->E5_HISTOR		
	
			DEFINE MSDIALOG oDlg TITLE "Transfer๊ncia Bancแria Entre Empresas e Filiais " FROM 000,000 TO 330,670 PIXEL
			/* Montagem da tela: Dados de Origem */
			@002,003 TO 045,335 LABEL "Dados de Origem" OF oDlg PIXEL
			
			@12,10 Say "Fil. Origem" Pixel Of oDlg
			@22,10 MSGet _cFilialOr F3 "SM0" Size 40,8 Pixel Of oDlg When .F.
			
			@12,55 Say "Banco" Pixel Of oDlg
			@22,55 MSGet _cBancoOr F3 "SA6" Valid FVerBco("O") Size 20,8 Pixel Of oDlg When .F.
			
			@12,88 Say "Agencia" Pixel Of oDlg
			@22,88 MSGet _cAgenciOr Size 20,8 Pixel Of oDlg When .F.
			
			@12,121 Say "CC" Pixel Of oDlg
			@22,121 MSGet _cContaOr Size 40,8 Pixel Of oDlg When .F.
			
			@12,164 Say "Natureza" Pixel Of oDlg
			@22,164 MSGet _cNatureOr Valid ExistCpo("SED",_cNatureOr) Size 40,8 Pixel Of oDlg When .F.
			
			@08,212 Say "Conta.Deb." Pixel Of oDlg  
			@20,212 Say "C.Custo Deb." Pixel Of oDlg	
			@32,212 Say "It.Cont.Deb." Pixel Of oDlg
			                                                                                                                  	
			@08,250 MSGet _cCtaOr Valid ExistCpo("CT1",_cCtaOr) Size 80,8 Pixel Of oDlg When .F. 		
			@20,250 MSGet _cUoOr Valid ExistCpo("CTT",_cUoOr).AND.ctb105cc(_cUoOr) Size 80,8 Pixel Of oDlg When .F. 		
			@32,250 MSGet _cCrOr Valid ExistCpo("CTD",_cCrOr).AND.ctb105item(_cCrOr) Size 80,8 Pixel Of oDlg When .F. 
			
			/* Montagem da tela: Dados de Destino */
			@047,003 TO 090, 335 LABEL "Dados de Destino" OF oDlg PIXEL
			
			@57,11 Say "Fil. Destino" Pixel Of oDlg
			@67,11 MSGet _cFilialDe F3 "SM0EMP" Valid ExistCpo("SM0",cEmpAnt+ _cFilialDe) Size 40,8 Pixel Of oDlg When .F.
			
			@57,55 Say "Banco" Pixel Of oDlg
			@67,55 MSGet _cBancoDe Valid FVerBco("D") Size 30,8 Pixel Of oDlg When .f.
			
			@57,88 Say "Agencia" Pixel Of oDlg
			@67,88 MSGet _cAgenciDe Size 20,8 Pixel Of oDlg When .f.
			
			@57,121 Say "CC" Pixel Of oDlg
			@67,121 MSGet _cContaDe Size 40,8 Pixel Of oDlg When .f.
			
			@57,164 Say "Natureza" Pixel Of oDlg
			@67,164 MSGet _cNatureDe Valid ExistCpo("SED",_cNatureDe) Size 40,8 Pixel Of oDlg When .F.        
		
			@53,212 Say "Conta.Crd." Pixel Of oDlg  
			@65,212 Say "C.Custo Crd." Pixel Of oDlg	
			@77,212 Say "It.Cont.Crd." Pixel Of oDlg
			                                                                                                                  	
			@53,250 MSGet _cCtaDe Valid ExistCpo("CT1",_cCtaDe) Size 80,8 Pixel Of oDlg When .F. 		
			@65,250 MSGet _cUoDe Valid ExistCpo("CTT",_cUoDe).AND.ctb105cc(_cUoDe) Size 80,8 Pixel Of oDlg When .F. 		
			@77,250 MSGet _cCrDe Valid ExistCpo("CTD",_cCrDe).AND.ctb105item(_cCrDe) Size 80,8 Pixel Of oDlg When .F.	
				
			/* Montagem da tela: Dados de Identifica็ใo */
			@092,003 TO 150, 335 LABEL "Dados de Identifica็ใo" OF oDlg PIXEL
			
			@102,10 Say "Numero Doc" Pixel Of oDlg
			@112,10 MSGet _cNumerDoc Size 60,8 Pixel Of oDlg When .F.
			
			@102,73 Say "Valor" Pixel Of oDlg                                                                           
			@112,73 MSGet _nValor Valid(positivo().and.naovazio()) Size 60,8 Picture PesqPict("SE5","E5_VALOR")Pixel Of oDlg When .F.
			
			@102,137 Say "Beneficiแrio" Pixel Of oDlg
			@112,137 MSGet _cBenefici Size 193,8 Pixel Of oDlg When .F.
			
			@127,10 Say "Hist๓rico" Pixel Of oDlg
			@137,10 MSGet _cHist Size 320,8 Pixel Of oDlg When .F.
			
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| IIF(_FIN13Vld1(2),Eval({|| lOk := .T.,oDlg:End()}),lOk := .F.) },{|| oDlg:End()},,aButtons)
			
			IF lOk // Confirmou
				MsgRun("Excluindo transfer๊ncia...",,{|| _FIN13Proc() })
			ENDIF	
		ENDIF
	ENDIF
ENDIF	

Return()            

STATIC FUNCTION _FIN13DAD(cTipRP)
LOCAL nRetRec	:= 0        

IF SE5->E5_SITUACA $ "C/E/X" .AND. lOk
	Help(" ",1,"JA-CANCEL")
	lOk:= .F.
Endif

If !Empty(SE5->E5_RECONC) .AND. lOk 
	Help(" ",1,"MOVRECONC")
	lOk:= .F.
Endif
	
IF cTipRP == "P"            
	// Dados de Origem 	
	dDataPag	:= SE5->E5_DATA
	_cFilialOr 	:= SE5->E5_FILIAL
	_cBancoOr	:= SE5->E5_BANCO
	_cAgenciOr	:= SE5->E5_AGENCIA
	_cContaOr	:= SE5->E5_CONTA
	_cNatureOr	:= SE5->E5_NATUREZ	
	// Tratamento para as primeiras movimenta็๕es gerada pela rotina
	_cCtaOr 	:= IIF(EMPTY(SE5->E5_CREDITO),SE5->E5_DEBITO,SE5->E5_CREDITO)
	_cUoOr  	:= IIF(EMPTY(SE5->E5_CCC),SE5->E5_CCD,SE5->E5_CCC)
	_cCrOr    	:= IIF(EMPTY(SE5->E5_ITEMC),SE5->E5_ITEMD,SE5->E5_ITEMC)	
	//_cCtaOr 	:= SE5->E5_CREDITO
	//_cUoOr  	:= SE5->E5_CCC
	//_cCrOr    	:= SE5->E5_ITEMC
	nRetRec 	:= SE5->E5_XTRAREC
	nRecRec	    := nRetRec
ELSE    
	// Dados de Destino	
	dDataRec	:= SE5->E5_DATA
	_cFilialDe	:= SE5->E5_FILIAL
	_cBancoDe	:= SE5->E5_BANCO
	_cAgenciDe	:= SE5->E5_AGENCIA
	_cContaDe	:= SE5->E5_CONTA
	_cNatureDe	:= SE5->E5_NATUREZ
	// Tratamento para as primeiras movimenta็๕es gerada pela rotina
	_cCtaDe 	:= IIF(EMPTY(SE5->E5_DEBITO),SE5->E5_CREDITO,SE5->E5_DEBITO)
	_cUoDe  	:= IIF(EMPTY(SE5->E5_CCD),SE5->E5_CCC,SE5->E5_CCD)
	_cCrDe    	:= IIF(EMPTY(SE5->E5_ITEMD),SE5->E5_ITEMC,SE5->E5_ITEMD)	
	//_cCtaDe		:= SE5->E5_DEBITO
	//_cUoDe		:= SE5->E5_CCD
	//_cCrDe		:= SE5->E5_ITEMD
	nRetRec		:= SE5->E5_XTRAREC 
	nRecPag	    := nRetRec	
ENDIF                          

RETURN nRetRec
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_FIN13Proc  บThiago L. Dyonisio  บ Data ณ  22/09/2012       บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento: Gera tํtulo a pagar na Empresa origem e     บฑฑ
ฑฑบ          ณ tํtulo a receber na Empresa destino                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI - SISTEMA INDฺSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _FIN13Proc()
Local _aMovPag 		:= {}
Local _aMovRec 		:= {}
Local nErro			:= 0
local aSE5			:= {}
local nCnt			:= 0
LOCAL cCamp			:= "" 
Local lContExc		:= .T.
Private lMsErroAuto	:=.F.                               

Begin Transaction             
	
	cFilAnt 	:= _cFilialOr
	
	// Array com dados da baixa a pagar        
	IF nPagOPc == nValExc
	
		SE5->(DBGOTO(nRecPag))
		
        _aMovPag	:= {{"E5_FILIAL"	, SE5->E5_FILIAL 	,Nil},;
        				{"E5_DATA"		, SE5->E5_DATA 		,Nil},;
        				{"E5_MOEDA" 	, SE5->E5_MOEDA		,Nil},;
            			{"E5_VALOR"   	, SE5->E5_VALOR    	,Nil},;
            			{"E5_NATUREZ"  	, SE5->E5_NATUREZ 	,Nil},;
               			{"E5_BANCO"   	, SE5->E5_BANCO   	,Nil},;
                  		{"E5_AGENCIA" 	, SE5->E5_AGENCIA  	,Nil},;
                    	{"E5_CONTA"  	, SE5->E5_CONTA    	,Nil},;
                     	{"E5_HISTOR"  	, SE5->E5_HISTOR 	,Nil},;
						{"E5_DOCUMEN"	, SE5->E5_DOCUMEN	,Nil},; 
						{"E5_ORIGEM"	, SE5->E5_ORIGEM	,Nil},;                    	
                      	{"E5_TIPOLAN" 	, SE5->E5_TIPOLAN 	,Nil} }	

		// 14/11/2018 - Daniel Flแvio - Faz a valida็ใo das datas "Data de Baixa x DDatabase"
		IF ExistBlock("FA100VET")
			IF !ExecBlock("FA100VET", .F., .F., { nRecPag , nRecRec } )
				_aMovPag := {}
				lContExc := .F.
			ENDIF
		ENDIF	

	ELSE
        _aMovPag	:= {{"E5_FILORIG"	, _cFilialDe	,Nil},;
						{"E5_DATA"		, dDataPag		,Nil},;
						{"E5_MOEDA"		, "M1"			,Nil},;		
						{"E5_VALOR"		, _nValor		,Nil},;
						{"E5_NATUREZ"	, _cNatureOr	,Nil},;
						{"E5_BANCO"		, _cBancoOr		,Nil},;
						{"E5_AGENCIA"	, _cAgenciOr	,Nil},;
						{"E5_CONTA"		, _cContaOr		,Nil},;
						{"E5_CREDITO"	, _cCtaOr		,Nil},;
						{"E5_CCC"		, _cUoOr		,Nil},;
						{"E5_ITEMC"		, _cCrOr		,Nil},;		
						{"E5_BENEF"		, _cBenefici	,Nil},;
						{"E5_HISTOR"	, _cHist		,Nil},;
						{"E5_DOCUMEN"	, _cNumerDoc	,Nil},;
						{"E5_ORIGEM"	, "SIFINA13"	,Nil},;							       
						{"E5_LA"		, "S"			,Nil} } 						                      	                      		
	ENDIF
	
	If !Empty(_aMovPag)
	
		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,_aMovPag,nPagOPc)	
		
		If lMsErroAuto  
			nErro++
			If __lSX8
				RollBackSX8()
			Endif
			
			MostraErro()
			
			DisarmTransaction()
			Break
		ELSE
			If __lSX8
				ConfirmSX8()
			Endif      
			
			IF nPagOPc != nValExc
				nRecPag	:= SE5->(RECNO())				
			ENDIF
				
		EndIf
	
	EndIf

	cFilAnt 	:= _cFilialDe
	lMsErroAuto	:= .F.

	// Array com dados da baixa a receber
	IF nPagOPc == nValExc
		SE5->(DBGOTO(nRecRec))
		
		If lContExc 
		    
	        _aMovRec	:= {{"E5_FILIAL"	, SE5->E5_FILIAL 	,Nil},;
	        				{"E5_DATA"		, SE5->E5_DATA 		,Nil},;
	        				{"E5_MOEDA" 	, SE5->E5_MOEDA		,Nil},;
	            			{"E5_VALOR"   	, SE5->E5_VALOR    	,Nil},;
	            			{"E5_NATUREZ"  	, SE5->E5_NATUREZ 	,Nil},;
	               			{"E5_BANCO"   	, SE5->E5_BANCO   	,Nil},;
	                  		{"E5_AGENCIA" 	, SE5->E5_AGENCIA  	,Nil},;
	                    	{"E5_CONTA"  	, SE5->E5_CONTA    	,Nil},;
	                     	{"E5_HISTOR"  	, SE5->E5_HISTOR 	,Nil},;
	                     	{"E5_DOCUMEN"	, SE5->E5_DOCUMEN	,Nil},;
	                     	{"E5_ORIGEM"	, SE5->E5_ORIGEM	,Nil},;
	                      	{"E5_TIPOLAN" 	, SE5->E5_TIPOLAN 	,Nil} }	
	    Else
	    
	    	_aMovRec := {}
	    
	    EndIf
	    
	ELSE
        _aMovRec	:= {{"E5_FILORIG"	, _cFilialOr		,Nil},;                                     	
						{"E5_DATA"		, dDataRec			,Nil},;		
						{"E5_MOEDA"		, "M1"				,Nil},;		
						{"E5_VALOR"		, _nValor			,Nil},;
						{"E5_NATUREZ"	, _cNatureDe		,Nil},;		
						{"E5_BANCO"		, _cBancoDe			,Nil},;		
						{"E5_AGENCIA"	, _cAgenciDe		,Nil},;				
						{"E5_CONTA"		, _cContaDe			,Nil},;	
						{"E5_DEBITO"	, _cCtaDe			,Nil},;			        
						{"E5_CCD"		, _cUoDe			,Nil},;		
						{"E5_ITEMD"		, _cCrDe			,Nil},;
						{"E5_BENEF"		, _cBenefici		,Nil},;		
						{"E5_HISTOR"	, _cHist			,Nil},;					        
						{"E5_DOCUMEN"	, _cNumerDoc		,Nil},;								
						{"E5_ORIGEM"	, "SIFINA13"		,Nil} }		
	ENDIF
  	
  	If !Empty(_aMovRec)
  		    
		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,_aMovRec,nRecOPc)					
		
		If lMsErroAuto
			nErro++
			If __lSX8
				RollBackSX8()
			Endif
			
			MostraErro()
			
			DisarmTransaction()
			Break
		Else
			If __lSX8
				ConfirmSX8()
			Endif       
			
			IF nPagOPc != nValExc
				nRecRec	:= SE5->(RECNO())
				
				RECLOCK("SE5",.F.)
				REPLACE E5_XTRAREC WITH nRecPag
				MSUNLOCK()		
				
				SE5->(DBGOTO(nRecPag))
				RECLOCK("SE5",.F.)
				REPLACE E5_XTRAREC WITH nRecRec
				MSUNLOCK()     
			ENDIF
					
		ENDIF     
	
	EndIf
	                        		
End Transaction

IF nErro > 0                         
	Aviso("Aten็ใo",IIF(nPagOPc!=nValExc,"Transfer๊ncia nใo realizada!","Transfer๊ncia nใo excluida!"),{"Ok"})
ELSE                        
	IF nPagOPc!=nValExc               
		PutMV("SI_NUMTRF",SOMA1(_cNumtrf))
		Aviso("Aten็ใo","Transfer๊ncia realizada com sucesso!",{"Ok"})
	ELSEIF lContExc
		Aviso("Aten็ใo","Transfer๊ncia excluida com sucesso!",{"Ok"})	                                                                        	
	ENDIF	
ENDIF                                

// Restaura filial
cFilAnt := _cBkpFil			 

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_FIN13Vld1  บAutor  ณThiago L. Dyonisio  บ Data ณ 22/09/2012บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ao de Valida็ใo dos campos da primeira tela            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI - SISTEMA INDฺSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//Validacao dos campos obrigat๓rios tela Dados de Origem

Static Function _FIN13Vld1(nSit)
Private _lVldRet1 := .t.

IF Empty(_cBancoOr) 
	Aviso("Aten็ใo","Informe o Banco de Origem.",{"Ok"})
	_lVldRet1 := .f.
EndIf	          

IF Empty(_cNatureOr) .AND. _lVldRet1
	Alert("Informe a Natureza de Origem.")
	_lVldRet1 := .f.
EndIf          

IF Empty(_cUoOr) .AND. _lVldRet1                
	Aviso("Aten็ใo","Informe a UO de Origem.",{"Ok"})
	_lVldRet1 := .f.
EndIf

//IF Empty(_cCrOr) .AND. _lVldRet1
//	Aviso("Aten็ใo","Informe a CR de Origem.",{"Ok"})
//	_lVldRet1 := .f.
//EndIf 

//Valida dados de Destino na primeira tela
IF Empty(_cFilialDe) .AND. _lVldRet1
	Aviso("Aten็ใo","Informe a Filial de Destino.",{"Ok"})
	_lVldRet1 := .f.
EndIf

IF Empty(_cBancoDe) .AND. _lVldRet1
	Aviso("Aten็ใo","Informe o Banco de Destino.",{"Ok"})
	_lVldRet1 := .f.
EndIf               

IF Empty(_cNatureDe) .AND. _lVldRet1
	Aviso("Aten็ใo","Informe a Natureza de Destino.",{"Ok"})
	_lVldRet1 := .f.
EndIf

IF Empty(_cUoDe) .AND. _lVldRet1
	Aviso("Aten็ใo","Informe a UO de Destino.",{"Ok"})
	_lVldRet1 := .f.
EndIf

//IF Empty(_cCrDe) .AND. _lVldRet1
//	Aviso("Aten็ใo","Informe a CR de Destino.",{"Ok"})
//	_lVldRet1 := .f.
//EndIf   

// fim valida็ใo de dados destino na primeira tela
IF Empty(_nValor) .AND. _lVldRet1
	Aviso("Aten็ใo","Informe o valor da transferencia!",{"Ok"})
	_lVldRet1 := .f.
EndIf              

// fim valida็ใo de dados destino na primeira tela
IF Empty(_cHist) .AND. _lVldRet1
	Aviso("Aten็ใo","Informe o hist๓rico da transferencia!",{"Ok"})
	_lVldRet1 := .f.
EndIf

// fim valida็ใo de dados destino na primeira tela
IF Empty(_cNumerDoc) .AND. _lVldRet1
	Aviso("Aten็ใo","Informe o documento da transferencia!",{"Ok"})
	_lVldRet1 := .f.
EndIf
            
IF _lVldRet1                       
	IF nSit == 1
		IF Aviso("Aten็ใo","Confirma a Transfer๊ncia?",{"Sim","Nใo"})<>1
			_lVldRet1 := .f.
		EndIf
	ELSE 
		IF Aviso("Aten็ใo","Confirma a Exclusใo da Transfer๊ncia?",{"Sim","Nใo"})<>1
			_lVldRet1 := .f.
		EndIf
	ENDIF
ENDIF    

Return(_lVldRet1) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_FIN13Vld2  บAutor  ณThiago L. Dyonisioบ Data ณ  24/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo dos campos da segunda tela com dados de destino  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI - SISTEMA INDฺSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//Validacao dos campos obrigat๓rios tela Dados de Destino

Static Function _FIN13Vld2()
Private _lVldRet2 := .t.

IF Empty(_cFilDe)
	Aviso("Aten็ใo","Informe a Filial de Destino.",{"Ok"})
	_lVldRet2 := .f.
EndIf

IF Empty(_cBancoDe) .AND. _lVldRet2
	Aviso("Aten็ใo","Informe o Banco de Destino.",{"Ok"})
	_lVldRet2 := .f.
EndIf               

IF Empty(_cNatureDe).AND. _lVldRet2
	Aviso("Aten็ใo","Informe a Natureza de Destino.",{"Ok"})
	_lVldRet2 := .f.
EndIf

IF Empty(_cUoDe).AND. _lVldRet2
	Aviso("Aten็ใo","Informe a UO de Destino.",{"Ok"})
	_lVldRet2 := .f.
EndIf

//IF Empty(_cCrDe) .AND. _lVldRet2
//	Aviso("Aten็ใo","Informe a CR de Destino.",{"Ok"})
//	_lVldRet2 := .f.
//EndIf      

Return(_lVldRet2) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_FIN13Get บAutor  ณThiago L. Dyonisio  บ Data ณ  24/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com dados de Destino                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI - SISTEMA INDฺSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _FIN13Get()               
Local oDlgGet
Local lOk
                       
_cFilDe    := Space(8)   // Variแvel de Filial Destino na segunda tela. Vai atualizar a variแvel _cFilialDe na primeira tela
_cFilialDe := Space(8)
_cBancoDe  := Space(3)
_cAgenciDe := Space(5)
_cContaDe  := Space(10)
_cNatureDe := IIF(EMPTY(_MV_XNATDES),SPACE(TamSX3("ED_CODIGO")[1]),_MV_XNATDES)
_cCtaDe    := Space(TamSX3("E5_DEBITO")[1])
_cUoDe     := Space(TamSX3("E5_CCD")[1])
_cCrDe     := Space(TamSX3("E5_ITEMD")[1])

DEFINE MSDIALOG oDlgGet TITLE "Transfer๊ncia - Dados de Destino" FROM 000,000 TO 115,670 PIXEL
oDlgGet:lEscClose := .F.

/* Montagem da tela: Dados de Destino */                                      	
@002,003 TO 045,335 LABEL "Dados de Destino" OF oDlgGet PIXEL   

@012,010 Say "Fil. Destino" Pixel Of oDlgGet
@022,010 MSGet _cFilDe F3 "SM0EMP" Valid ExistCpo("SM0",cEmpAnt+ _cFilDe).AND._FIN13Fil() Size 40,8 Pixel Of oDlgGet  

@012,055 Say "Banco" Pixel Of oDlgGet
@022,055 MSGet _cBancoDe F3 "SA6" Valid FVerBco("D") Size 20,8 Pixel Of oDlgGet  

@012,088 Say "Agencia" Pixel Of oDlgGet
@022,088 MSGet _cAgenciDe Size 20,8 Pixel Of oDlgGet When .F.

@012,121 Say "CC" Pixel Of oDlgGet
@022,121 MSGet _cContaDe Size 40,8 Pixel Of oDlgGet When .F. 

@012,164 Say "Natureza" Pixel Of oDlgGet
@022,164 MSGet _cNatureDe F3 "SED" Valid ExistCpo("SED",_cNatureDe) Size 40,8 Pixel Of oDlgGet

@08,212 Say "Conta.Deb." Pixel Of oDlgGet  
@20,212 Say "C.Custo Deb." Pixel Of oDlgGet	
@32,212 Say "It.Cont.Deb." Pixel Of oDlgGet
                                                                                                                  	
@08,250 MSGet _cCtaDe Valid ExistCpo("CT1",_cCtaDe) Size 80,8 Pixel Of oDlgGet When .F. 		
@20,250 MSGet _cUoDe Valid ExistCpo("CTT",_cUoDe).AND.ctb105cc(_cUoDe) Size 80,8 Pixel Of oDlgGet When .F. 		
@32,250 MSGet _cCrDe Valid ExistCpo("CTD",_cCrDe).AND.ctb105item(_cCrDe) Size 80,8 Pixel Of oDlgGet When .F.

ACTIVATE MSDIALOG oDlgGet CENTERED ON INIT EnchoiceBar(oDlgGet,{|| lOk :=.T., IIF(_FIN13Vld2(),oDlgGet:End(),NIL)   },{|| lOk := .F. ,oDlgGet:End()},,aButtons)

_cFilialDe := _cFilDe
cFilAnt    := _cBkpFil 
                                                                                                                                     
IF !lOk 
	_cFilDe    := Space(8)   // Variแvel de Filial Destino na segunda tela. Vai atualizar a variแvel _cFilialDe na primeira tela
	_cFilialDe := Space(8)
	_cBancoDe  := Space(3)
	_cAgenciDe := Space(5)
	_cContaDe  := Space(10)
	_cNatureDe := Space(6)
	_cCtaDe    := Space(TamSX3("E5_DEBITO")[1])
	_cUoDe     := Space(TamSX3("E5_CCD")[1])
	_cCrDe     := Space(TamSX3("E5_ITEMD")[1])
	_cHist	   := space(60)
	_cBenefici := Space(60)
ELSE
	_cHist	   := "TRF.MOV.DE "+cFilAnt+" P/ "+_cFilialDe	
	_cBenefici := POSICIONE("SM0",1,cEmpAnt+_cFilialDe,"M0_NOME")
ENDIF
 
SetKey( VK_F7, bDados)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_FIN13Fil  บAutor  ณThiago L. Dyonisio บ Data ณ  24/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTroca a Filial Corrente na tela de dados de destino         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI - SISTEMA INDฺSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function _FIN13Fil()

	cFilAnt := _cFilDe	

Return(.T.)      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FVerBco   บAutor  ณJoao Carlos A. Neto  Data ณ  14/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Dados dos bancos de origem e destino                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI - SISTEMA INDฺSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FVerBco(_xFlag)
lRet := .F.
If _xFlag == "O" // Origem
	lRet := (ExistCpo("SA6",_cBancoOr,).AND.!CCBlocked(_cBancoOr,_cAgenciOr,_cContaOr))
	_cCtaOr := SA6->A6_CONTA
	_cUoOr  := SA6->A6_XUO
ElseIf _xFlag == "D"	// Destino
	lRet := (ExistCpo("SA6",_cBancoDe).AND.!CCBlocked(_cBancoDe,_cAgenciDe,_cContaDe))
	_cCtaDe := SA6->A6_CONTA
	_cUoDe  := SA6->A6_XUO
Endif
Return(lRet)	