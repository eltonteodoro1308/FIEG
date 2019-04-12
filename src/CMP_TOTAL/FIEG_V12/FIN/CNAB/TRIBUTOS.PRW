#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} TRIBUTOS
Programa para criar uma string com dados para pagamento de tributos sem código de barras.

@type function
@author TOTVS
@since 06/04/2011
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function TRIBUTOS()

Local cString1	:=""
Local cString2	:=""
Local cString3	:=""
Local cTributo1 := AllTrim( SE2->E2_XGPS02	)
Local cTributo2 := AllTrim( SE2->E2_XDARF02	)
Local cTributo3 := Alltrim( SE2->E2_XFGTS01	)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If !Empty(cTributo1) 
	
		cString1 :=  U_DADOSGPS()
		return(cString1)
	
ElseIf !Empty(cTributo2)
	
		cString2 := U_DADOSDARF()
		return(cString2)	

ElseIf !Empty(cTributo3)
	
		cString3 := U_DADOSFGTS()
		return(cString3)	
EndIf

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} DADOSGPS
Rotina para criar a string com dados para pagamento de GPS sem código de barras .

@type function
@author TOTVS
@since 06/04/2011
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

USER FUNCTION DADOSGPS()

Local 	cRetGPS  := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cRetGPS := "01" //SUBSTR(Alltrim(SE2->E2_XTRIBUT),1,2 )		// IDENTIFICACAO DO TRIBUTO (2)
cRetGPS += SUBSTR(Alltrim(SE2->E2_XGPS02),1,4 )				// CODIGO DE PAGTO (4)
cRetGPS += SUBSTR(Alltrim(SE2->E2_XGPS03),1,6 )				// COMPETENCIA (6)
//cRetGPS += SUBSTR(Alltrim(SE2->E2_XGPS04),1,14)	
cRetGPS += PADL(Alltrim(SE2->E2_XGPS04),14,'0')				//INSCRICAO NUMERO - CNPJ OU CPF (14)
cRetGPS += STRZERO((SE2->E2_VALOR)*100,14)					//VALOR PRINCIPAL (14)
cRetGPS += STRZERO((SE2->E2_SDACRES)*100,14)				//VALOR ENTIDADES (14)
cRetGPS += STRZERO((SE2->E2_MULTA + SE2->E2_JUROS )*100,14)		//VALOR DA MULTA + JUROS + ATM(14)
cRetGPS += STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)  //VALOR TOTAL (14)
cRetGPS += GRAVADATA(SE2->E2_VENCREA,.F.,5)					//DATA PAGAMENTO (8)
cRetGPS += SPACE(58)										//BRANCOS (50)
cRetGPS += SUBSTR(SM0->M0_NOME,1,30)						//NOME DO CONTRIBUINTE (30)

Return(cRetGPS )


/*/================================================================================================================================/*/
/*/{Protheus.doc} DADOSDARF
Rotina para criar a string com dados para pagamento de DARF sem código de barras.

@type function
@author TOTVS
@since 06/04/2011
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, String com dados da DARF.
/*/
/*/================================================================================================================================/*/

User Function DADOSDARF()

Local cRetDARF  := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cRetDARF := "02" //SUBSTR(Alltrim(SE2->E2_XTRIBUT),1,2)		// IDENTIFICACAO DO TRIBUTO (02)
cRetDARF += SUBSTR(Alltrim(SE2->E2_XDARF02),1,4)			// CODIGO DA RECEITA (04)
cRetDARF += "2"												//TIPO DE INSCRICAO DO CONTRIBUINTE 1=CPF, 2=CNPJ  (1)
cRetDARF += SUBSTR(SM0->M0_CGC,1,14)						//INSCRICAO NUMERO - CNPJ OU CPF (14)
cRetDARF += GRAVADATA(SE2->E2_XDARF03,.F.,5)				//PERIODO DE APURACAO (8)       
//cRetDARF += IIF(Empty(SE2->E2_XDARF04),SPACE(17),(SUBST(Alltrim(SE2->E2_XDARF04),1,17)))//NUMERO DE REFERENCIA (17)
cRetDARF += SUBST(Alltrim(SE2->E2_XDARF04),1,6)  			//NUMERO DE REFERENCIA (17)
cRetDARF += STRZERO(0,11)									//NUMERO DE REFERENCIA (17)
cRetDARF += STRZERO((SE2->E2_VALOR)*100,14)					//VALOR PRINCIPAL (14)
cRetDARF += STRZERO((SE2->E2_MULTA)*100,14)					//VALOR DA MULTA (14)
cRetDARF += STRZERO((SE2->E2_JUROS + SE2->E2_SDACRES)*100,14)//VALOR DOS JUROS/ENCARGOS (14)
cRetDARF += STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)//VALOR TOTAL (14)
cRetDARF += GRAVADATA(SE2->E2_VENCTO,.F.,5)					//DATA VENCIMENTO (8)
cRetDARF += GRAVADATA(SE2->E2_VENCREA,.F.,5)		    	//DATA PAGAMENTO (8)
cRetDARF += SPACE(30)										//BRANCOS (30)
cRetDARF += SUBSTR(SM0->M0_NOME,1,30)						//NOME DO CONTRIBUINTE (30)

Return(cRetDARF)


/*/================================================================================================================================/*/
/*/{Protheus.doc} DADOSFGTS
Rotina para criar a string com dados para pagamento de FGTS sem código de barras.

@type function
@author TOTVS
@since 22/08/2011
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, String com dados da FGTS.
/*/
/*/================================================================================================================================/*/

USER FUNCTION DADOSFGTS()
             
Local  cRetFGTS :=""                 	

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
			    				 							// ===> FGTS - GFIP
	cRetFGTS := SUBSTR(Alltrim(SE2->E2_XFGTS01),1,2)		// IDENTIFICACAO DO TRIBUTO (02)"11"            	                            
	cRetFGTS += "0000" //SubStr(SE2->E2_XFGTS02,1,4)		// Código da Receita
	cRetFGTS += "2"											// TIPO DE INSCRIÇÃO DO CONTRIBUINTE (1-CPF / 2-CNPJ) 
	cRetFGTS += StrZero(Val(SM0->M0_CGC),14)            	// CPF OU CNPJ DO CONTRIBUINTE 
	cRetFGTS += AllTrim(SE2->E2_XFGTS03)  					// CODIGO DE BARRAS (LINHA DIGITAVEL)	(*criar campo*) 
	cRetFGTS += REPLICATE("0",16)  					     	//StrZero(Val(SE2->E2_XFGTS04),16) 			// Identificador FGTS 
	cRetFGTS += REPLICATE("0",9) 						 	//StrZero(Val(SE2->E2_XFGTS05),9)  // Lacre de Conectividade Social 
	cRetFGTS += "00"//StrZero(Val(SE2->E2_XFGTS06),2)  		// Digito do Lacre  
	cRetFGTS += SubStr(SM0->M0_NOMECOM,1,30)                // NOME DO CONTRIBUINTE
	cRetFGTS += GravaData(SE2->E2_VENCREA,.F.,5)           	// DATA DO PAGAMENTO 
	cRetFGTS += STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)	//StrZero(SE2->E2_SALDO*100,14)	// VALOR DO PAGAMENTO 
	cRetFGTS += Space(30)                                  	// COMPLEMENTO DE REGISTRO 

Return(cRetFGTS)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SOMATOTAL
Rotina para criar a string com dados de valor total.

@type function
@author TOTVS
@since 22/08/2011
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, String com a Soma do Valor Total.
/*/
/*/================================================================================================================================/*/

USER FUNCTION SOMATOTAL()

Local cReturn1  := "" 
Local nVlTotal 	:= nSomaValor  	// variavel vindas do FINA420 GERADOR DO ARQUIVO CNAB
Local _nAcresc	:= nSomaAcres 	// variavel vindas do FINA420 GERADOR DO ARQUIVO CNAB
Local _nSomaDec	:= nSomaDecre 	// variavel vindas do FINA420 GERADOR DO ARQUIVO CNAB

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cReturn1 := STRZERO(((nVlTotal)-(_nAcresc + _nSomaDec ))*100,14) 
//cReturn1 := STRZERO(((nVlPrinc + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)  
 
Return(cReturn1)  	


/*/================================================================================================================================/*/
/*/{Protheus.doc} SOMAJM
Rotina para cRotina para criar a string com dados de juros e multa.

@type function
@author TOTVS
@since 22/08/2011
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, String com a Soma do Valor Total.
/*/
/*/================================================================================================================================/*/

USER FUNCTION SOMAJM()

Local cReturn2  := "" 
Local nValcamp  := 0
Local _nAcresc	:= nSomaAcres 								// variavel vindas do FINA420 GERADOR DO ARQUIVO CNAB

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
nValcamp := (SE2->E2_MULTA + SE2->E2_JUROS + _nAcresc) 

cReturn2 += STRZERO(nValCamp*100,14) 

Return(cReturn2)
