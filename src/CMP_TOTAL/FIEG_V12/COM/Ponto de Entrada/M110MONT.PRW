#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} M110MONT
Evento disparado no ato de Copiar uma SC1.

@type function
@author Oswaldo Leite - TOTVS
@since 15/01/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/
                           
User Function M110MONT()

Local lCopia := PARAMIXB[3]
Local nCont  := 1

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If lCopia
	for nCont := 1 to Len(aCols)

		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_MODAL'})]	:= "" 
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_TPMOD'})]	:= "" 
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_CODED'})]	:= "" 
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_NUMPR'})] 	:= "" 
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XCONTPR'})]	:= "               " 
				
		//--< Caio.Santos - FSW - Ajuste para atribuir valor padrao aos campos relacionados a contrato na copia da SC >--
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XCTADT'})]	:= ""
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XSTGCT'})]	:= "2"		
		
		//--< Tratamento GAP087 >---------------------------
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XCDCNTG'})]	:= ""
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XMOTIVO'})]	:= "" 
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_DATPRF'})]	:= DATE()  
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_COTACAO'})]	:= "" 
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_FORNECE'})]	:= ""  
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_LOJA'})] 	:= ""  
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XDTINI'})] 	:= "  /  /    "    
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XHRINI'})] 	:= ""    		
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XDTFIM'})] 	:= "  /  /    "    
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XHRFIM'})] 	:= ""
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XPZCONT'})] 	:= "  /  /    " 
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XRESDTA'})] 	:= "  /  /    " 
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XSTAPRO'})] 	:= "" 
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XDTAPRO'})] 	:= "  /  /    " 
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_XOBAPRO'})] 	:= "" 
		aCols[nCont][aScan(aHeader,{|x| AllTrim(x[2])=='C1_WFE'})] 		:= .F. 
	Next
EndIf

Return()