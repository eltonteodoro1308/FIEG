#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SICOMR04  ºAutor  ³Alexandre Felicio   º Data ³  12/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Viagens		                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 11.5 - CNI - FIRJAN-RJ	                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SICOMR04()   
Local aPergs	:= {}   
Local _aTP	:= {{"1-Fundo Fixo","2-Diária","3-Ajuda de Custo","4-Todas"}}  
local lRet	  := .T.  
Private aRet    := {} 
Private cAlias1 	:= GetNextAlias()  


aadd(aPergs,{1,"Período de...........:",Ctod(Space(8)),"","","","",50,.F.})
aadd(aPergs,{1,"Período até..........:",Ctod(Space(8)),"","","","",50,.F.})
aAdd(aPergs,{2,"Tp. de Solicitação:"   ,Nil,{"1-Fundo Fixo","2-Diária","3-Ajuda de Custo","4-Todas"},65,"",.F.})   

Do while lRet    
  
	If ParamBox(aPergs,'Parametros - Relatório de Viagens',@aRet,,,,,,,,.T.,.T.)     
     	if mv_par01 > mv_par02
			Alert("Período de não pode ser maior que Período de")
		else			
			Processa( {|| RunProc() }, ,OemToAnsi('Gerando Relatório......'),.F.)    
			oReport := ReportDef(cAlias1)
			oReport:PrintDialog()	   
			lRet := .F.		    
		Endif
	Else
		lRet := .F.
	Endif 
End  	
	
Return
    
  

                                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RunProc  ºAutor  ³Alexandre Felicio   º Data ³  12/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecao de Dados a partir do Parambox                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 11.5 - CNI - FIRJAN-RJ	                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunProc()
Local cWhere := ''

cWhere := "     ZA6.ZA6_DTINI >= '"+DTOS(MV_PAR01)+"' "
cWhere += " AND ZA6.ZA6_DTINI <= '"+DTOS(MV_PAR02)+"' "   
If !(AllTrim(Substr(MV_PAR03,1,1)) = '4')
  cWhere += " AND ZA6.ZA6_TPSOL = '" + AllTrim(Substr(MV_PAR03,1,1)) + "' "
Endif 
cWhere := "%"+cWhere+"%"      

   
	IF SELECT(cAlias1)>0
	   (cAlias1)->(DbCloseArea())
	ENDIF                      
	
	BeginSQL alias cAlias1 
	        SELECT ZA6.ZA6_NUM,  ZA6.ZA6_TPSOL, ZA6.ZA6_CAPROB, ZA6.ZA6_CC	, ZA6.ZA6_ITEM	, ZA6.ZA6_FORNEC,SA2.A2_NOME, SA2.A2_LOJA,
	               ZA6.ZA6_DTINI , ZA6.ZA6_DTFIM,ZA7.ZA7_ITEM,ZA7.ZA7_ORIGEM, ZA7.ZA7_DESTIN, ZAD.ZAD_HRSAI, 
	               ZAD.ZAD_HRCHE,  ZA6.ZA6_ADIANT, ZA6.ZA6_OBJETI	,ZA7.ZA7_ETICKE
	        FROM 	%Table:ZA6% ZA6, %Table:ZA7% ZA7, %Table:ZAD% ZAD, %Table:SA2% SA2
			WHERE %Exp:cWhere% AND
			         ZA6.ZA6_FILIAL = ZA7.ZA7_FILIAL                        AND
	                 ZA6.ZA6_NUM    = ZA7.ZA7_NUM  	                        AND
	                 ZAD.ZAD_FILIAL = ZA7.ZA7_FILIAL                        AND 
	                 ZAD.ZAD_NUM    = ZA7.ZA7_NUM                           AND
	                 ZAD.ZAD_ITEM   = ZA7.ZA7_ITEM                          AND
	                 ZA6.ZA6_FORNEC = SA2.A2_COD                            AND
					 ZA6.ZA6_LOJA   = SA2.A2_LOJA							AND 
					 ZAD.ZAD_STATUS = '1'									AND
	                 ZA6.D_E_L_E_T_ = ' ' 									AND
	                 ZA7.D_E_L_E_T_ = ' ' 									AND
	                 ZAD.D_E_L_E_T_ = ' '  									AND
	                 SA2.D_E_L_E_T_ = ' ' 
			Order by ZAD_ITEMC ,ZA7.ZA7_ITEM,ZAD_HRSAI      
	EndSQL   	
Return
                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef  ºAutor  ³Alexandre Felicio   º Data ³  12/02/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o Relatorio em TReport                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 11.5 - CNI - FIRJAN-RJ	                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef(cAlias1)
Local oReportW
Local oSection1  := Nil
Local SIT 		:= ''
Local lPageBreak := .F.    
Local cRpFont := 'Courier New'
Local nRpFont := 7


oReportw := TReport():New("SICOMR04","Relatório de Viagens","", {|oReportw| ReportPrint(oReportw,cAlias1)},"Rotina responsável pela geração do Relatório de Viagens.")

oReportw:SetLandscape()			// Escolhe o padrao de Impressao como Paisagem
oReportw:cFontBody 	:= cRpFont
oReportw:nFontBody 	:= nRpFont
////oReportw:nLineHeight := (nRpFont*5) //Define o Tamanho da linha em função da fonte, multiplica por 5 para manter a porporção em pixel.


//New(oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)
oSecVI := TRSection():New(oReportw,"Viagens",{cAlias1})

//TRCell():New( oSection, Campo	, cAliasTrb, /*X3Titulo*/  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecVI,"ZA6_NUM"	  ,cAlias1 ,'Num.Solicitação' 	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZA6_TPSOL"	  ,cAlias1 ,'Tp.Solicitação'   	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZA6_CAPROB"  ,cAlias1 ,'Aprovador'		   	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZA6_CC"      ,cAlias1 ,'Centro de Custo' 	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZA6_FORNEC"  ,cAlias1 ,'Cod.Fornec.'     	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))  
TRCell():New(oSecVI,"A2_NOME"  ,cAlias1 ,'Nome Fornec.'     	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))  
TRCell():New(oSecVI,"A2_LOJA"  ,cAlias1 ,'Loja'			     	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))  
TRCell():New(oSecVI,"ZA6_DTINI"   ,cAlias1 ,'Dt.Inicial'     	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZA6_DTFIM"   ,cAlias1 ,'Dt.Final'       	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZA7_ORIGEM"  ,cAlias1 ,'Origem'         	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZA7_DESTIN"  ,cAlias1 ,'Destino'         	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZAD_HRSAI"   ,cAlias1 ,'Hr.Saida'        	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZAD_HRCHE"   ,cAlias1 ,'Hr.Chegada'      	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZA6_ADIANT"  ,cAlias1 ,'Adiant.R$'      	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZA7_ETICKE"  ,cAlias1 ,'Eticket'        	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
TRCell():New(oSecVI,"ZA6_OBJETI"  ,cAlias1 ,'objetivo'        	)//,,oReportW:Char2Pix(TamSx3("ZA6_NUM")[1],cRpFont,nRpFont))
              
    
                
Return oReportw
                   



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintºAutor  ³Alexandre Felicio   º Data ³  12/02/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz somatória da Coluna ZA6_ADIANT	                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 11.5 - CNI - FIRJAN-RJ	                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport,cAlias1)
Local oSecVI	:= oReport:Section(1)            
Local oBreak1
Local lFooter  	:= .T.
Local cOrder 	:= ""   
Local cZA6NUM   := ''
Local cQuebraPrd := ""
Local cQuebraPvP := ""
Private nRow   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Totalizadores                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oFunction1 := TRFunction():New(oSection2:Cell("VALORPAGAR"),,"SUM", oBreak1,,,,.F.,.F.)	

oBreak1 := TRBreak():New(oSecVI,oSecVI:Cell("ZA6_ADIANT"),"Valor Total do Período :",.F.)
TRFunction():New(oSecVI:Cell("ZA6_ADIANT"	),NIL,"SUM",oBreak1,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
  
oSecVI:SetTotalInLine(.F.)  // Imprime os Totais das Colunas em linha

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a Impressao                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(cAlias1)->(DbGotop())
oReport:SetMeter((cAlias1)->(RecCount()))
  
oSecVI:Print()
   
Return( .T. )






